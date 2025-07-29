const mongoose = require('mongoose');
const APP_CONSTANTS = require('../config/constants');

const chatSchema = new mongoose.Schema({
  participants: [{
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  }],
  isGroup: {
    type: Boolean,
    default: false
  },
  groupName: {
    type: String,
    trim: true,
    maxlength: 100
  },
  groupDescription: {
    type: String,
    trim: true,
    maxlength: 500
  },
  groupIcon: {
    type: String,
    default: null
  },
  admins: [{
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User'
  }],
  lastMessage: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Message'
  },
  lastMessageAt: {
    type: Date,
    default: Date.now
  },
  isActive: {
    type: Boolean,
    default: true
  },
  createdBy: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  }
}, {
  timestamps: true,
  toJSON: { virtuals: true },
  toObject: { virtuals: true }
});

// Virtual for participant count
chatSchema.virtual('participantCount').get(function() {
  return this.participants.length;
});

// Method to add participant
chatSchema.methods.addParticipant = function(userId) {
  if (!this.participants.includes(userId)) {
    this.participants.push(userId);
    return this.save();
  }
  return Promise.resolve(this);
};

// Method to remove participant
chatSchema.methods.removeParticipant = function(userId) {
  this.participants = this.participants.filter(id => !id.equals(userId));
  return this.save();
};

// Method to add admin
chatSchema.methods.addAdmin = function(userId) {
  if (this.participants.includes(userId) && !this.admins.includes(userId)) {
    this.admins.push(userId);
    return this.save();
  }
  throw new Error('User must be a participant to become admin');
};

// Method to remove admin
chatSchema.methods.removeAdmin = function(userId) {
  this.admins = this.admins.filter(id => !id.equals(userId));
  return this.save();
};

// Method to check if user is admin
chatSchema.methods.isAdmin = function(userId) {
  return this.admins.some(id => id.equals(userId));
};

// Method to check if user is participant
chatSchema.methods.isParticipant = function(userId) {
  return this.participants.some(id => id.equals(userId));
};

// Indexes
chatSchema.index({ participants: 1, lastMessageAt: -1 });
chatSchema.index({ isGroup: 1, isActive: 1 });
chatSchema.index({ createdBy: 1 });

module.exports = mongoose.model('Chat', chatSchema);
