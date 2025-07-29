const mongoose = require('mongoose');
const APP_CONSTANTS = require('../config/constants');

const eventSchema = new mongoose.Schema({
  title: {
    type: String,
    required: true,
    trim: true,
    maxlength: APP_CONSTANTS.EVENT.MAX_TITLE_LENGTH
  },
  description: {
    type: String,
    required: true,
    trim: true,
    maxlength: APP_CONSTANTS.EVENT.MAX_DESCRIPTION_LENGTH
  },
  type: {
    type: String,
    enum: APP_CONSTANTS.EVENT.TYPES,
    required: true
  },
  organizer: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  startDate: {
    type: Date,
    required: true
  },
  endDate: {
    type: Date,
    required: true
  },
  location: {
    address: {
      type: String,
      required: true,
      trim: true
    },
    city: {
      type: String,
      required: true,
      trim: true
    },
    state: {
      type: String,
      required: true,
      trim: true
    },
    country: {
      type: String,
      default: 'India'
    },
    coordinates: {
      latitude: Number,
      longitude: Number
    },
    venue: {
      type: String,
      trim: true
    }
  },
  isOnline: {
    type: Boolean,
    default: false
  },
  onlineLink: {
    type: String,
    trim: true
  },
  maxParticipants: {
    type: Number,
    min: 1,
    default: 50
  },
  participants: [{
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User'
    },
    joinedAt: {
      type: Date,
      default: Date.now
    },
    status: {
      type: String,
      enum: ['going', 'maybe', 'not_going'],
      default: 'going'
    }
  }],
  tags: [{
    type: String,
    trim: true
  }],
  imageUrl: {
    type: String,
    default: null
  },
  cost: {
    amount: {
      type: Number,
      min: 0,
      default: 0
    },
    currency: {
      type: String,
      default: 'INR'
    }
  },
  isRecurring: {
    type: Boolean,
    default: false
  },
  recurringPattern: {
    frequency: {
      type: String,
      enum: ['daily', 'weekly', 'monthly', 'yearly']
    },
    interval: {
      type: Number,
      min: 1
    },
    endDate: Date
  },
  requirements: [{
    type: String,
    trim: true
  }],
  benefits: [{
    type: String,
    trim: true
  }],
  status: {
    type: String,
    enum: ['draft', 'published', 'cancelled', 'completed'],
    default: 'published'
  },
  isPublic: {
    type: Boolean,
    default: true
  },
  targetAgeGroup: {
    min: {
      type: Number,
      default: 50
    },
    max: {
      type: Number,
      default: 100
    }
  },
  remindersSent: [{
    type: {
      type: String,
      enum: ['1_day', '1_hour', '30_min']
    },
    sentAt: Date
  }],
  feedback: [{
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User'
    },
    rating: {
      type: Number,
      min: 1,
      max: 5
    },
    comment: {
      type: String,
      maxlength: 500,
      trim: true
    },
    submittedAt: {
      type: Date,
      default: Date.now
    }
  }]
}, {
  timestamps: true,
  toJSON: { virtuals: true },
  toObject: { virtuals: true }
});

// Virtual for participant count
eventSchema.virtual('participantCount').get(function() {
  return this.participants.filter(p => p.status === 'going').length;
});

// Virtual for maybe count
eventSchema.virtual('maybeCount').get(function() {
  return this.participants.filter(p => p.status === 'maybe').length;
});

// Virtual for not going count
eventSchema.virtual('notGoingCount').get(function() {
  return this.participants.filter(p => p.status === 'not_going').length;
});

// Virtual for average rating
eventSchema.virtual('averageRating').get(function() {
  if (this.feedback.length === 0) return 0;
  const sum = this.feedback.reduce((acc, fb) => acc + fb.rating, 0);
  return sum / this.feedback.length;
});

// Virtual for is full
eventSchema.virtual('isFull').get(function() {
  return this.participantCount >= this.maxParticipants;
});

// Virtual for is past event
eventSchema.virtual('isPast').get(function() {
  return this.endDate < new Date();
});

// Virtual for is upcoming
eventSchema.virtual('isUpcoming').get(function() {
  return this.startDate > new Date();
});

// Virtual for is ongoing
eventSchema.virtual('isOngoing').get(function() {
  const now = new Date();
  return this.startDate <= now && this.endDate >= now;
});

// Method to join event
eventSchema.methods.joinEvent = function(userId, status = 'going') {
  const existingParticipant = this.participants.find(p => p.userId.equals(userId));
  
  if (existingParticipant) {
    existingParticipant.status = status;
  } else {
    if (this.isFull && status === 'going') {
      throw new Error('Event is full');
    }
    this.participants.push({ userId, status });
  }
  
  return this.save();
};

// Method to leave event
eventSchema.methods.leaveEvent = function(userId) {
  this.participants = this.participants.filter(p => !p.userId.equals(userId));
  return this.save();
};

// Method to add feedback
eventSchema.methods.addFeedback = function(userId, rating, comment) {
  // Check if user participated
  const participant = this.participants.find(p => p.userId.equals(userId) && p.status === 'going');
  if (!participant) {
    throw new Error('Only participants can give feedback');
  }
  
  // Check if event is completed
  if (!this.isPast) {
    throw new Error('Can only give feedback after event completion');
  }
  
  // Remove existing feedback from same user
  this.feedback = this.feedback.filter(fb => !fb.userId.equals(userId));
  
  // Add new feedback
  this.feedback.push({ userId, rating, comment });
  
  return this.save();
};

// Method to check if user is participant
eventSchema.methods.isParticipant = function(userId) {
  return this.participants.some(p => p.userId.equals(userId));
};

// Method to get participant status
eventSchema.methods.getParticipantStatus = function(userId) {
  const participant = this.participants.find(p => p.userId.equals(userId));
  return participant ? participant.status : null;
};

// Method to cancel event
eventSchema.methods.cancelEvent = function() {
  this.status = 'cancelled';
  return this.save();
};

// Method to complete event
eventSchema.methods.completeEvent = function() {
  this.status = 'completed';
  return this.save();
};

// Static method to get upcoming events
eventSchema.statics.getUpcoming = function(limit = 10, location = null) {
  const query = {
    startDate: { $gt: new Date() },
    status: 'published',
    isPublic: true
  };
  
  if (location) {
    query['location.city'] = location.city;
    query['location.state'] = location.state;
  }
  
  return this.find(query)
    .populate('organizer', 'name profilePicture')
    .sort({ startDate: 1 })
    .limit(limit);
};

// Static method to get popular events
eventSchema.statics.getPopular = function(limit = 10) {
  return this.aggregate([
    {
      $match: {
        startDate: { $gt: new Date() },
        status: 'published',
        isPublic: true
      }
    },
    {
      $addFields: {
        popularityScore: {
          $add: [
            { $size: { $filter: { input: '$participants', cond: { $eq: ['$$this.status', 'going'] } } } },
            { $multiply: [{ $size: { $filter: { input: '$participants', cond: { $eq: ['$$this.status', 'maybe'] } } } }, 0.5] }
          ]
        }
      }
    },
    { $sort: { popularityScore: -1 } },
    { $limit: limit }
  ]);
};

// Indexes
eventSchema.index({ startDate: 1, status: 1, isPublic: 1 });
eventSchema.index({ organizer: 1, createdAt: -1 });
eventSchema.index({ 'location.city': 1, 'location.state': 1 });
eventSchema.index({ type: 1, startDate: 1 });
eventSchema.index({ tags: 1 });
eventSchema.index({ isOnline: 1 });

// Text index for search
eventSchema.index({ title: 'text', description: 'text', tags: 'text' });

module.exports = mongoose.model('Event', eventSchema);
