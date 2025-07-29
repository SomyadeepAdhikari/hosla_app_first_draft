const mongoose = require('mongoose');
const APP_CONSTANTS = require('../config/constants');

const emergencyAlertSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  type: {
    type: String,
    enum: APP_CONSTANTS.EMERGENCY.TYPES,
    required: true
  },
  message: {
    type: String,
    maxlength: APP_CONSTANTS.EMERGENCY.MAX_MESSAGE_LENGTH,
    trim: true
  },
  location: {
    latitude: {
      type: Number,
      required: false,
      min: -90,
      max: 90
    },
    longitude: {
      type: Number,
      required: false,
      min: -180,
      max: 180
    },
    address: {
      type: String,
      trim: true
    },
    city: String,
    state: String,
    country: { type: String, default: 'India' }
  },
  status: {
    type: String,
    enum: APP_CONSTANTS.EMERGENCY.STATUSES,
    default: 'active'
  },
  priority: {
    type: String,
    enum: APP_CONSTANTS.EMERGENCY.PRIORITIES,
    default: 'medium'
  },
  respondedBy: [{
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User'
    },
    respondedAt: {
      type: Date,
      default: Date.now
    },
    response: {
      type: String,
      maxlength: 300,
      trim: true
    },
    responseType: {
      type: String,
      enum: ['text', 'call', 'visit'],
      default: 'text'
    },
    estimatedArrival: {
      type: Date
    }
  }],
  resolvedAt: {
    type: Date,
    default: null
  },
  resolvedBy: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    default: null
  },
  resolutionNote: {
    type: String,
    trim: true
  },
  notifiedContacts: [{
    contactId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User'
    },
    notifiedAt: {
      type: Date,
      default: Date.now
    },
    notificationMethod: {
      type: String,
      enum: ['push', 'sms', 'call'],
      default: 'push'
    }
  }],
  escalationLevel: {
    type: Number,
    default: 0,
    min: 0,
    max: 3
  },
  lastEscalatedAt: {
    type: Date
  },
  isTestAlert: {
    type: Boolean,
    default: false
  }
}, {
  timestamps: true,
  toJSON: { virtuals: true },
  toObject: { virtuals: true }
});

// Virtual for response count
emergencyAlertSchema.virtual('responseCount').get(function() {
  return this.respondedBy.length;
});

// Virtual for time elapsed since creation
emergencyAlertSchema.virtual('timeElapsed').get(function() {
  return Date.now() - this.createdAt;
});

// Virtual for is overdue (more than 30 minutes without response)
emergencyAlertSchema.virtual('isOverdue').get(function() {
  const thirtyMinutes = 30 * 60 * 1000;
  return this.status === 'active' && 
         this.timeElapsed > thirtyMinutes && 
         this.responseCount === 0;
});

// Virtual for priority color
emergencyAlertSchema.virtual('priorityColor').get(function() {
  const colors = {
    low: '#28a745',
    medium: '#ffc107',
    high: '#fd7e14',
    critical: '#dc3545'
  };
  return colors[this.priority] || colors.medium;
});

// Method to add response
emergencyAlertSchema.methods.addResponse = function(userId, response, responseType = 'text', estimatedArrival = null) {
  this.respondedBy.push({
    userId,
    response,
    responseType,
    estimatedArrival
  });
  return this.save();
};

// Method to resolve alert
emergencyAlertSchema.methods.resolve = function(resolvedBy, resolutionNote = '') {
  this.status = 'resolved';
  this.resolvedAt = new Date();
  this.resolvedBy = resolvedBy;
  this.resolutionNote = resolutionNote;
  return this.save();
};

// Method to cancel alert
emergencyAlertSchema.methods.cancel = function() {
  this.status = 'cancelled';
  return this.save();
};

// Method to escalate alert
emergencyAlertSchema.methods.escalate = function() {
  if (this.escalationLevel < 3) {
    this.escalationLevel += 1;
    this.lastEscalatedAt = new Date();
    
    // Increase priority based on escalation
    if (this.escalationLevel === 1 && this.priority === 'low') {
      this.priority = 'medium';
    } else if (this.escalationLevel === 2 && this.priority === 'medium') {
      this.priority = 'high';
    } else if (this.escalationLevel === 3 && this.priority === 'high') {
      this.priority = 'critical';
    }
    
    return this.save();
  }
  return Promise.resolve(this);
};

// Method to add notified contact
emergencyAlertSchema.methods.addNotifiedContact = function(contactId, notificationMethod = 'push') {
  this.notifiedContacts.push({
    contactId,
    notificationMethod
  });
  return this.save();
};

// Auto-resolve alerts after specified hours
emergencyAlertSchema.methods.autoResolve = function() {
  const autoResolveTime = APP_CONSTANTS.EMERGENCY.AUTO_RESOLVE_HOURS * 60 * 60 * 1000;
  if (Date.now() - this.createdAt > autoResolveTime && this.status === 'active') {
    this.status = 'resolved';
    this.resolvedAt = new Date();
    this.resolutionNote = 'Auto-resolved after 24 hours';
    return this.save();
  }
  return Promise.resolve(this);
};

// Static method to get active alerts for user's trust circle
emergencyAlertSchema.statics.getActiveAlertsForTrustCircle = function(userIds) {
  return this.find({
    userId: { $in: userIds },
    status: 'active',
    isTestAlert: false
  })
  .populate('userId', 'name profilePicture phoneNumber')
  .sort({ priority: -1, createdAt: -1 });
};

// Static method to get overdue alerts
emergencyAlertSchema.statics.getOverdueAlerts = function() {
  const thirtyMinutesAgo = new Date(Date.now() - 30 * 60 * 1000);
  return this.find({
    status: 'active',
    createdAt: { $lt: thirtyMinutesAgo },
    respondedBy: { $size: 0 },
    isTestAlert: false
  });
};

// Pre-save middleware to set priority based on type and escalation
emergencyAlertSchema.pre('save', function(next) {
  if (this.isNew) {
    // Set initial priority based on type
    if (this.type === 'not_feeling_well') {
      this.priority = this.priority || 'high';
    } else if (this.type === 'need_help') {
      this.priority = this.priority || 'medium';
    } else if (this.type === 'want_to_talk') {
      this.priority = this.priority || 'low';
    }
  }
  next();
});

// Indexes for better performance
emergencyAlertSchema.index({ userId: 1, status: 1, createdAt: -1 });
emergencyAlertSchema.index({ status: 1, priority: -1, createdAt: -1 });
emergencyAlertSchema.index({ 'location.city': 1, 'location.state': 1 });
emergencyAlertSchema.index({ type: 1, status: 1 });
emergencyAlertSchema.index({ escalationLevel: 1, lastEscalatedAt: -1 });
emergencyAlertSchema.index({ isTestAlert: 1 });

module.exports = mongoose.model('EmergencyAlert', emergencyAlertSchema);
