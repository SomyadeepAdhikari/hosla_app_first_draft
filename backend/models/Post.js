const mongoose = require('mongoose');
const APP_CONSTANTS = require('../config/constants');

const postSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  content: {
    type: String,
    maxlength: APP_CONSTANTS.POST.MAX_CONTENT_LENGTH,
    trim: true
  },
  mediaType: {
    type: String,
    enum: APP_CONSTANTS.POST.MEDIA_TYPES,
    default: 'text'
  },
  mediaUrl: {
    type: String,
    default: null
  },
  mediaDuration: {
    type: Number, // For audio/video duration in seconds
    default: null
  },
  mediaSize: {
    type: Number, // File size in bytes
    default: null
  },
  tags: [{
    type: String,
    trim: true
  }],
  likes: [{
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User'
    },
    likedAt: {
      type: Date,
      default: Date.now
    }
  }],
  comments: [{
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true
    },
    content: {
      type: String,
      required: true,
      maxlength: APP_CONSTANTS.POST.MAX_COMMENT_LENGTH,
      trim: true
    },
    createdAt: {
      type: Date,
      default: Date.now
    },
    likes: [{
      userId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User'
      },
      likedAt: {
        type: Date,
        default: Date.now
      }
    }]
  }],
  views: [{
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User'
    },
    viewedAt: {
      type: Date,
      default: Date.now
    }
  }],
  shares: [{
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User'
    },
    sharedAt: {
      type: Date,
      default: Date.now
    }
  }],
  isVisible: {
    type: Boolean,
    default: true
  },
  isModerated: {
    type: Boolean,
    default: false
  },
  moderationStatus: {
    type: String,
    enum: ['pending', 'approved', 'rejected'],
    default: 'approved'
  },
  moderationReason: {
    type: String,
    trim: true
  },
  isPromoted: {
    type: Boolean,
    default: false
  },
  promotedUntil: {
    type: Date,
    default: null
  },
  location: {
    city: String,
    state: String,
    country: { type: String, default: 'India' }
  }
}, {
  timestamps: true,
  toJSON: { virtuals: true },
  toObject: { virtuals: true }
});

// Virtual for like count
postSchema.virtual('likeCount').get(function() {
  return this.likes.length;
});

// Virtual for comment count
postSchema.virtual('commentCount').get(function() {
  return this.comments.length;
});

// Virtual for view count
postSchema.virtual('viewCount').get(function() {
  return this.views.length;
});

// Virtual for share count
postSchema.virtual('shareCount').get(function() {
  return this.shares.length;
});

// Virtual for engagement score
postSchema.virtual('engagementScore').get(function() {
  const weights = { like: 1, comment: 3, view: 0.1, share: 5 };
  return (this.likeCount * weights.like) + 
         (this.commentCount * weights.comment) + 
         (this.viewCount * weights.view) + 
         (this.shareCount * weights.share);
});

// Method to add like
postSchema.methods.addLike = function(userId) {
  if (!this.likes.some(like => like.userId.equals(userId))) {
    this.likes.push({ userId });
    return this.save();
  }
  return Promise.resolve(this);
};

// Method to remove like
postSchema.methods.removeLike = function(userId) {
  this.likes = this.likes.filter(like => !like.userId.equals(userId));
  return this.save();
};

// Method to add view
postSchema.methods.addView = function(userId) {
  // Only add view if user hasn't viewed in last 24 hours
  const twentyFourHoursAgo = new Date(Date.now() - 24 * 60 * 60 * 1000);
  const existingView = this.views.find(view => 
    view.userId.equals(userId) && view.viewedAt > twentyFourHoursAgo
  );
  
  if (!existingView) {
    this.views.push({ userId });
    return this.save();
  }
  return Promise.resolve(this);
};

// Method to add comment
postSchema.methods.addComment = function(userId, content) {
  this.comments.push({ userId, content });
  return this.save();
};

// Method to remove comment
postSchema.methods.removeComment = function(commentId) {
  this.comments = this.comments.filter(comment => !comment._id.equals(commentId));
  return this.save();
};

// Method to add share
postSchema.methods.addShare = function(userId) {
  this.shares.push({ userId });
  return this.save();
};

// Method to check if user liked post
postSchema.methods.isLikedBy = function(userId) {
  return this.likes.some(like => like.userId.equals(userId));
};

// Static method to get trending posts
postSchema.statics.getTrending = function(limit = 10) {
  const twentyFourHoursAgo = new Date(Date.now() - 24 * 60 * 60 * 1000);
  
  return this.aggregate([
    {
      $match: {
        isVisible: true,
        moderationStatus: 'approved',
        createdAt: { $gte: twentyFourHoursAgo }
      }
    },
    {
      $addFields: {
        engagementScore: {
          $add: [
            { $multiply: [{ $size: '$likes' }, 1] },
            { $multiply: [{ $size: '$comments' }, 3] },
            { $multiply: [{ $size: '$views' }, 0.1] },
            { $multiply: [{ $size: '$shares' }, 5] }
          ]
        }
      }
    },
    { $sort: { engagementScore: -1 } },
    { $limit: limit }
  ]);
};

// Indexes for better performance
postSchema.index({ userId: 1, createdAt: -1 });
postSchema.index({ isVisible: 1, moderationStatus: 1, createdAt: -1 });
postSchema.index({ tags: 1 });
postSchema.index({ 'location.city': 1, 'location.state': 1 });
postSchema.index({ mediaType: 1 });
postSchema.index({ isPromoted: 1, promotedUntil: 1 });

// Text index for search
postSchema.index({ content: 'text', tags: 'text' });

module.exports = mongoose.model('Post', postSchema);
