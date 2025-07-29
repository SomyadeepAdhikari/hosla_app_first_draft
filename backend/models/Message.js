const mongoose = require('mongoose');
const APP_CONSTANTS = require('../config/constants');

const messageSchema = new mongoose.Schema({
  chatId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Chat',
    required: true
  },
  senderId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  messageType: {
    type: String,
    enum: APP_CONSTANTS.CHAT.MESSAGE_TYPES,
    default: 'text'
  },
  content: {
    type: String,
    maxlength: APP_CONSTANTS.CHAT.MAX_MESSAGE_LENGTH,
    trim: true
  },
  mediaUrl: {
    type: String,
    default: null
  },
  mediaDuration: {
    type: Number, // For audio messages in seconds
    default: null
  },
  location: {
    latitude: Number,
    longitude: Number,
    address: String
  },
  replyTo: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Message',
    default: null
  },
  readBy: [{
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User'
    },
    readAt: {
      type: Date,
      default: Date.now
    }
  }],
  deliveredTo: [{
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User'
    },
    deliveredAt: {
      type: Date,
      default: Date.now
    }
  }],
  isEdited: {
    type: Boolean,
    default: false
  },
  editedAt: {
    type: Date
  },
  isDeleted: {
    type: Boolean,
    default: false
  },
  deletedAt: {
    type: Date
  },
  deletedFor: [{
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User'
  }]
}, {
  timestamps: true,
  toJSON: { virtuals: true },
  toObject: { virtuals: true }
});

// Virtual for read count
messageSchema.virtual('readCount').get(function() {
  return this.readBy.length;
});

// Virtual for delivery count
messageSchema.virtual('deliveryCount').get(function() {
  return this.deliveredTo.length;
});

// Method to mark as read by user
messageSchema.methods.markAsRead = function(userId) {
  if (!this.readBy.some(read => read.userId.equals(userId))) {
    this.readBy.push({ userId });
    return this.save();
  }
  return Promise.resolve(this);
};

// Method to mark as delivered to user
messageSchema.methods.markAsDelivered = function(userId) {
  if (!this.deliveredTo.some(delivery => delivery.userId.equals(userId))) {
    this.deliveredTo.push({ userId });
    return this.save();
  }
  return Promise.resolve(this);
};

// Method to edit message
messageSchema.methods.editMessage = function(newContent) {
  this.content = newContent;
  this.isEdited = true;
  this.editedAt = new Date();
  return this.save();
};

// Method to delete message for specific user
messageSchema.methods.deleteForUser = function(userId) {
  if (!this.deletedFor.includes(userId)) {
    this.deletedFor.push(userId);
    return this.save();
  }
  return Promise.resolve(this);
};

// Method to delete message completely
messageSchema.methods.deleteCompletely = function() {
  this.isDeleted = true;
  this.deletedAt = new Date();
  this.content = 'This message was deleted';
  this.mediaUrl = null;
  return this.save();
};

// Method to check if message is read by user
messageSchema.methods.isReadBy = function(userId) {
  return this.readBy.some(read => read.userId.equals(userId));
};

// Method to check if message is delivered to user
messageSchema.methods.isDeliveredTo = function(userId) {
  return this.deliveredTo.some(delivery => delivery.userId.equals(userId));
};

// Method to check if message is deleted for user
messageSchema.methods.isDeletedFor = function(userId) {
  return this.deletedFor.includes(userId);
};

// Static method to get unread count for user in chat
messageSchema.statics.getUnreadCount = function(chatId, userId) {
  return this.countDocuments({
    chatId: chatId,
    senderId: { $ne: userId },
    readBy: { $not: { $elemMatch: { userId: userId } } },
    isDeleted: false,
    deletedFor: { $ne: userId }
  });
};

// Static method to mark all messages as read in a chat
messageSchema.statics.markAllAsRead = function(chatId, userId) {
  return this.updateMany(
    {
      chatId: chatId,
      senderId: { $ne: userId },
      readBy: { $not: { $elemMatch: { userId: userId } } },
      isDeleted: false,
      deletedFor: { $ne: userId }
    },
    {
      $push: {
        readBy: {
          userId: userId,
          readAt: new Date()
        }
      }
    }
  );
};

// Indexes
messageSchema.index({ chatId: 1, createdAt: -1 });
messageSchema.index({ senderId: 1, createdAt: -1 });
messageSchema.index({ 'readBy.userId': 1 });
messageSchema.index({ isDeleted: 1, deletedFor: 1 });

module.exports = mongoose.model('Message', messageSchema);
