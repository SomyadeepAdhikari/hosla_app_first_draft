const mongoose = require('mongoose');
const APP_CONSTANTS = require('../config/constants');

const notificationSchema = new mongoose.Schema({
  recipientId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  senderId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: false // Can be null for system notifications
  },
  type: {
    type: String,
    enum: Object.values(APP_CONSTANTS.NOTIFICATION_TYPES),
    required: true
  },
  title: {
    type: String,
    required: true,
    trim: true,
    maxlength: 100
  },
  message: {
    type: String,
    required: true,
    trim: true,
    maxlength: 500
  },
  data: {
    type: mongoose.Schema.Types.Mixed,
    default: {}
  },
  isRead: {
    type: Boolean,
    default: false
  },
  readAt: {
    type: Date,
    default: null
  },
  deliveryStatus: {
    type: String,
    enum: ['pending', 'sent', 'delivered', 'failed'],
    default: 'pending'
  },
  deliveryMethod: [{
    type: String,
    enum: ['push', 'sms', 'email', 'in_app'],
    default: 'in_app'
  }],
  priority: {
    type: String,
    enum: ['low', 'normal', 'high', 'urgent'],
    default: 'normal'
  },
  expiresAt: {
    type: Date,
    default: function() {
      return new Date(Date.now() + 30 * 24 * 60 * 60 * 1000); // 30 days
    }
  },
  actionUrl: {
    type: String,
    trim: true
  },
  category: {
    type: String,
    enum: ['social', 'emergency', 'event', 'system', 'promotional'],
    default: 'social'
  }
}, {
  timestamps: true,
  toJSON: { virtuals: true },
  toObject: { virtuals: true }
});

// Virtual for is expired
notificationSchema.virtual('isExpired').get(function() {
  return this.expiresAt < new Date();
});

// Method to mark as read
notificationSchema.methods.markAsRead = function() {
  this.isRead = true;
  this.readAt = new Date();
  return this.save();
};

// Method to mark as delivered
notificationSchema.methods.markAsDelivered = function() {
  this.deliveryStatus = 'delivered';
  return this.save();
};

// Method to mark as failed
notificationSchema.methods.markAsFailed = function() {
  this.deliveryStatus = 'failed';
  return this.save();
};

// Static method to get unread count for user
notificationSchema.statics.getUnreadCount = function(userId) {
  return this.countDocuments({
    recipientId: userId,
    isRead: false,
    expiresAt: { $gt: new Date() }
  });
};

// Static method to mark all as read for user
notificationSchema.statics.markAllAsRead = function(userId) {
  return this.updateMany(
    { recipientId: userId, isRead: false },
    { 
      $set: { 
        isRead: true, 
        readAt: new Date() 
      } 
    }
  );
};

// Static method to cleanup expired notifications
notificationSchema.statics.cleanupExpired = function() {
  return this.deleteMany({
    expiresAt: { $lt: new Date() }
  });
};

// Static method to get notifications for user with pagination
notificationSchema.statics.getForUser = function(userId, page = 1, limit = 20, category = null) {
  const query = {
    recipientId: userId,
    expiresAt: { $gt: new Date() }
  };
  
  if (category) {
    query.category = category;
  }
  
  const skip = (page - 1) * limit;
  
  return this.find(query)
    .populate('senderId', 'name profilePicture')
    .sort({ createdAt: -1 })
    .skip(skip)
    .limit(limit);
};

// Static method to create notification
notificationSchema.statics.createNotification = function(data) {
  const notification = new this(data);
  return notification.save();
};

// Static method to create and send post like notification
notificationSchema.statics.createPostLikeNotification = function(postUserId, likerUserId, postId) {
  return this.createNotification({
    recipientId: postUserId,
    senderId: likerUserId,
    type: APP_CONSTANTS.NOTIFICATION_TYPES.POST_LIKE,
    title: 'New Like',
    message: 'Someone liked your post',
    data: { postId },
    category: 'social'
  });
};

// Static method to create and send post comment notification
notificationSchema.statics.createPostCommentNotification = function(postUserId, commenterUserId, postId, comment) {
  return this.createNotification({
    recipientId: postUserId,
    senderId: commenterUserId,
    type: APP_CONSTANTS.NOTIFICATION_TYPES.POST_COMMENT,
    title: 'New Comment',
    message: `Someone commented: "${comment.substring(0, 50)}${comment.length > 50 ? '...' : ''}"`,
    data: { postId, comment },
    category: 'social'
  });
};

// Static method to create emergency alert notification
notificationSchema.statics.createEmergencyNotification = function(recipientIds, senderId, alertId, alertType) {
  const notifications = recipientIds.map(recipientId => ({
    recipientId,
    senderId,
    type: APP_CONSTANTS.NOTIFICATION_TYPES.EMERGENCY_ALERT,
    title: 'Emergency Alert',
    message: `Someone in your trust circle needs help: ${alertType.replace('_', ' ')}`,
    data: { alertId, alertType },
    category: 'emergency',
    priority: 'urgent',
    deliveryMethod: ['push', 'sms']
  }));
  
  return this.insertMany(notifications);
};

// Static method to create event reminder notification
notificationSchema.statics.createEventReminderNotification = function(participantIds, eventId, eventTitle, reminderType) {
  const notifications = participantIds.map(participantId => ({
    recipientId: participantId,
    type: APP_CONSTANTS.NOTIFICATION_TYPES.EVENT_REMINDER,
    title: 'Event Reminder',
    message: `Reminder: "${eventTitle}" is starting ${reminderType === '1_day' ? 'tomorrow' : reminderType === '1_hour' ? 'in 1 hour' : 'in 30 minutes'}`,
    data: { eventId, reminderType },
    category: 'event',
    priority: 'normal'
  }));
  
  return this.insertMany(notifications);
};

// Static method to create trust circle invitation notification
notificationSchema.statics.createTrustCircleInviteNotification = function(recipientId, senderId, invitationMessage) {
  return this.createNotification({
    recipientId,
    senderId,
    type: APP_CONSTANTS.NOTIFICATION_TYPES.TRUST_CIRCLE_INVITE,
    title: 'Trust Circle Invitation',
    message: invitationMessage || 'You have been invited to join a trust circle',
    data: {},
    category: 'social',
    priority: 'normal'
  });
};

// Indexes
notificationSchema.index({ recipientId: 1, isRead: 1, createdAt: -1 });
notificationSchema.index({ recipientId: 1, category: 1, createdAt: -1 });
notificationSchema.index({ expiresAt: 1 });
notificationSchema.index({ deliveryStatus: 1, createdAt: 1 });

module.exports = mongoose.model('Notification', notificationSchema);
