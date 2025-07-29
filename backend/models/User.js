const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
const APP_CONSTANTS = require('../config/constants');

const userSchema = new mongoose.Schema({
  phoneNumber: {
    type: String,
    required: true,
    unique: true,
    trim: true,
    validate: {
      validator: function(v) {
        return /^\+91[6-9]\d{9}$/.test(v);
      },
      message: 'Please provide a valid Indian phone number'
    }
  },
  name: {
    type: String,
    required: true,
    trim: true,
    maxlength: APP_CONSTANTS.USER.MAX_NAME_LENGTH
  },
  email: {
    type: String,
    trim: true,
    lowercase: true,
    validate: {
      validator: function(v) {
        return !v || /^\w+([.-]?\w+)*@\w+([.-]?\w+)*(\.\w{2,3})+$/.test(v);
      },
      message: 'Please provide a valid email address'
    }
  },
  dateOfBirth: {
    type: Date,
    required: false,
    validate: {
      validator: function(v) {
        if (!v) return true;
        const age = Math.floor((Date.now() - v) / (365.25 * 24 * 60 * 60 * 1000));
        return age >= APP_CONSTANTS.USER.MIN_AGE;
      },
      message: 'User must be at least 50 years old'
    }
  },
  gender: {
    type: String,
    enum: ['male', 'female', 'other'],
    required: false
  },
  bio: {
    type: String,
    maxlength: APP_CONSTANTS.USER.MAX_BIO_LENGTH,
    trim: true
  },
  profilePicture: {
    type: String,
    default: null
  },
  rewardPoints: {
    type: Number,
    default: APP_CONSTANTS.USER.DEFAULT_REWARD_POINTS,
    min: 0
  },
  preferences: {
    language: {
      type: String,
      enum: APP_CONSTANTS.LANGUAGES,
      default: 'en'
    },
    theme: {
      type: String,
      enum: APP_CONSTANTS.THEMES,
      default: 'light'
    },
    notifications: {
      push: { type: Boolean, default: true },
      sms: { type: Boolean, default: true },
      email: { type: Boolean, default: false }
    },
    fontSize: {
      type: String,
      enum: ['small', 'medium', 'large', 'extra-large'],
      default: 'large'
    }
  },
  trustCircle: [{
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User'
  }],
  followers: [{
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User'
  }],
  following: [{
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User'
  }],
  isVerified: {
    type: Boolean,
    default: false
  },
  isActive: {
    type: Boolean,
    default: true
  },
  lastActive: {
    type: Date,
    default: Date.now
  },
  fcmToken: {
    type: String,
    default: null
  },
  location: {
    city: { type: String, trim: true },
    state: { type: String, trim: true },
    country: { type: String, default: 'India' },
    coordinates: {
      latitude: Number,
      longitude: Number
    }
  },
  emergencyContacts: [{
    name: { type: String, required: true },
    phoneNumber: { type: String, required: true },
    relationship: { type: String, required: true }
  }],
  blockedUsers: [{
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User'
  }]
}, {
  timestamps: true,
  toJSON: { virtuals: true },
  toObject: { virtuals: true }
});

// Virtual for age calculation
userSchema.virtual('age').get(function() {
  if (!this.dateOfBirth) return null;
  return Math.floor((Date.now() - this.dateOfBirth) / (365.25 * 24 * 60 * 60 * 1000));
});

// Virtual for follower count
userSchema.virtual('followerCount').get(function() {
  return this.followers.length;
});

// Virtual for following count
userSchema.virtual('followingCount').get(function() {
  return this.following.length;
});

// Virtual for trust circle count
userSchema.virtual('trustCircleCount').get(function() {
  return this.trustCircle.length;
});

// Pre-save middleware to update lastActive
userSchema.pre('save', function(next) {
  if (this.isModified() && !this.isModified('lastActive')) {
    this.lastActive = new Date();
  }
  next();
});

// Method to check if user can add to trust circle
userSchema.methods.canAddToTrustCircle = function() {
  return this.trustCircle.length < APP_CONSTANTS.TRUST_CIRCLE.MAX_MEMBERS;
};

// Method to add user to trust circle
userSchema.methods.addToTrustCircle = function(userId) {
  if (this.canAddToTrustCircle() && !this.trustCircle.includes(userId)) {
    this.trustCircle.push(userId);
    return this.save();
  }
  throw new Error('Cannot add to trust circle');
};

// Method to remove from trust circle
userSchema.methods.removeFromTrustCircle = function(userId) {
  this.trustCircle = this.trustCircle.filter(id => !id.equals(userId));
  return this.save();
};

// Method to follow user
userSchema.methods.followUser = function(userId) {
  if (!this.following.includes(userId)) {
    this.following.push(userId);
    return this.save();
  }
};

// Method to unfollow user
userSchema.methods.unfollowUser = function(userId) {
  this.following = this.following.filter(id => !id.equals(userId));
  return this.save();
};

// Method to add follower
userSchema.methods.addFollower = function(userId) {
  if (!this.followers.includes(userId)) {
    this.followers.push(userId);
    return this.save();
  }
};

// Method to remove follower
userSchema.methods.removeFollower = function(userId) {
  this.followers = this.followers.filter(id => !id.equals(userId));
  return this.save();
};

// Method to block user
userSchema.methods.blockUser = function(userId) {
  if (!this.blockedUsers.includes(userId)) {
    this.blockedUsers.push(userId);
    return this.save();
  }
};

// Method to unblock user
userSchema.methods.unblockUser = function(userId) {
  this.blockedUsers = this.blockedUsers.filter(id => !id.equals(userId));
  return this.save();
};

// Method to check if user is blocked
userSchema.methods.isBlocked = function(userId) {
  return this.blockedUsers.includes(userId);
};

// Indexes for better performance
userSchema.index({ phoneNumber: 1 });
userSchema.index({ isActive: 1, lastActive: -1 });
userSchema.index({ 'location.city': 1, 'location.state': 1 });
userSchema.index({ name: 'text', bio: 'text' });

module.exports = mongoose.model('User', userSchema);
