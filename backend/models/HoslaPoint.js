const mongoose = require('mongoose');

const hoslaPointSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  points: {
    type: Number,
    required: true,
    min: 0
  },
  type: {
    type: String,
    enum: [
      'post_created',
      'post_liked',
      'comment_added',
      'event_created',
      'event_attended',
      'emergency_helped',
      'trust_circle_joined',
      'daily_login',
      'weekly_bonus',
      'profile_completed',
      'friend_referred',
      'milestone_reached',
      'community_service',
      'other'
    ],
    required: true
  },
  description: {
    type: String,
    trim: true,
    maxlength: 200
  },
  relatedId: {
    type: mongoose.Schema.Types.ObjectId,
    required: false // Can reference post, event, user, etc.
  },
  relatedModel: {
    type: String,
    enum: ['Post', 'Event', 'User', 'EmergencyAlert'],
    required: false
  },
  multiplier: {
    type: Number,
    default: 1,
    min: 0.1,
    max: 10
  },
  validUntil: {
    type: Date,
    default: null // null means permanent
  },
  isActive: {
    type: Boolean,
    default: true
  },
  metadata: {
    type: mongoose.Schema.Types.Mixed,
    default: {}
  }
}, {
  timestamps: true,
  toJSON: { virtuals: true },
  toObject: { virtuals: true }
});

// Virtual for final points (considering multiplier)
hoslaPointSchema.virtual('finalPoints').get(function() {
  return Math.floor(this.points * this.multiplier);
});

// Virtual for is expired
hoslaPointSchema.virtual('isExpired').get(function() {
  return this.validUntil && this.validUntil < new Date();
});

// Method to activate points
hoslaPointSchema.methods.activate = function() {
  this.isActive = true;
  return this.save();
};

// Method to deactivate points
hoslaPointSchema.methods.deactivate = function() {
  this.isActive = false;
  return this.save();
};

// Static method to get total points for user
hoslaPointSchema.statics.getTotalPointsForUser = function(userId) {
  return this.aggregate([
    {
      $match: {
        userId: mongoose.Types.ObjectId(userId),
        isActive: true,
        $or: [
          { validUntil: null },
          { validUntil: { $gt: new Date() } }
        ]
      }
    },
    {
      $group: {
        _id: null,
        totalPoints: {
          $sum: {
            $multiply: ['$points', '$multiplier']
          }
        }
      }
    }
  ]);
};

// Static method to get points breakdown for user
hoslaPointSchema.statics.getPointsBreakdownForUser = function(userId) {
  return this.aggregate([
    {
      $match: {
        userId: mongoose.Types.ObjectId(userId),
        isActive: true,
        $or: [
          { validUntil: null },
          { validUntil: { $gt: new Date() } }
        ]
      }
    },
    {
      $group: {
        _id: '$type',
        totalPoints: {
          $sum: {
            $multiply: ['$points', '$multiplier']
          }
        },
        count: { $sum: 1 }
      }
    },
    {
      $sort: { totalPoints: -1 }
    }
  ]);
};

// Static method to award points
hoslaPointSchema.statics.awardPoints = function(userId, type, points, description, relatedId = null, relatedModel = null, multiplier = 1) {
  const pointEntry = new this({
    userId,
    type,
    points,
    description,
    relatedId,
    relatedModel,
    multiplier
  });
  
  return pointEntry.save();
};

// Static method to get leaderboard
hoslaPointSchema.statics.getLeaderboard = function(limit = 10, timeframe = null) {
  const matchQuery = {
    isActive: true,
    $or: [
      { validUntil: null },
      { validUntil: { $gt: new Date() } }
    ]
  };
  
  // Add timeframe filter if specified
  if (timeframe) {
    let startDate;
    const now = new Date();
    
    switch (timeframe) {
      case 'daily':
        startDate = new Date(now.getFullYear(), now.getMonth(), now.getDate());
        break;
      case 'weekly':
        startDate = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);
        break;
      case 'monthly':
        startDate = new Date(now.getFullYear(), now.getMonth(), 1);
        break;
      default:
        startDate = null;
    }
    
    if (startDate) {
      matchQuery.createdAt = { $gte: startDate };
    }
  }
  
  return this.aggregate([
    { $match: matchQuery },
    {
      $group: {
        _id: '$userId',
        totalPoints: {
          $sum: {
            $multiply: ['$points', '$multiplier']
          }
        },
        lastActivity: { $max: '$createdAt' }
      }
    },
    {
      $lookup: {
        from: 'users',
        localField: '_id',
        foreignField: '_id',
        as: 'user'
      }
    },
    { $unwind: '$user' },
    {
      $project: {
        userId: '$_id',
        totalPoints: 1,
        lastActivity: 1,
        name: '$user.name',
        profilePicture: '$user.profilePicture',
        city: '$user.location.city'
      }
    },
    { $sort: { totalPoints: -1 } },
    { $limit: limit }
  ]);
};

// Static method to award daily login points
hoslaPointSchema.statics.awardDailyLoginPoints = function(userId) {
  // Check if user already got daily login points today
  const today = new Date();
  today.setHours(0, 0, 0, 0);
  
  return this.findOne({
    userId,
    type: 'daily_login',
    createdAt: { $gte: today }
  }).then(existing => {
    if (!existing) {
      return this.awardPoints(userId, 'daily_login', 10, 'Daily login bonus');
    }
    return null;
  });
};

// Static method to check and award milestones
hoslaPointSchema.statics.checkAndAwardMilestones = function(userId) {
  return this.getTotalPointsForUser(userId).then(result => {
    const totalPoints = result[0]?.totalPoints || 0;
    const milestones = [100, 500, 1000, 2500, 5000, 10000];
    
    const promises = milestones.map(milestone => {
      if (totalPoints >= milestone) {
        // Check if milestone already awarded
        return this.findOne({
          userId,
          type: 'milestone_reached',
          'metadata.milestone': milestone
        }).then(existing => {
          if (!existing) {
            return this.awardPoints(
              userId,
              'milestone_reached',
              milestone * 0.1, // 10% bonus
              `Milestone reached: ${milestone} points`,
              null,
              null,
              1,
              { milestone }
            );
          }
          return null;
        });
      }
      return null;
    });
    
    return Promise.all(promises);
  });
};

// Static method to cleanup expired points
hoslaPointSchema.statics.cleanupExpiredPoints = function() {
  return this.updateMany(
    { 
      validUntil: { $lt: new Date() },
      isActive: true
    },
    { 
      $set: { isActive: false } 
    }
  );
};

// Indexes
hoslaPointSchema.index({ userId: 1, type: 1, createdAt: -1 });
hoslaPointSchema.index({ userId: 1, isActive: 1, validUntil: 1 });
hoslaPointSchema.index({ type: 1, createdAt: -1 });
hoslaPointSchema.index({ relatedId: 1, relatedModel: 1 });

module.exports = mongoose.model('HoslaPoint', hoslaPointSchema);
