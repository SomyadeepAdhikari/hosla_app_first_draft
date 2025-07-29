const twilio = require('twilio');
const Notification = require('../models/Notification');
const logger = require('../utils/logger');

class NotificationService {
  constructor() {
    this.twilioClient = twilio(
      process.env.TWILIO_ACCOUNT_SID,
      process.env.TWILIO_AUTH_TOKEN
    );
  }

  // Create notification in database
  async createNotification(notificationData) {
    try {
      const notification = new Notification(notificationData);
      await notification.save();
      return notification;
    } catch (error) {
      logger.error('Create notification error:', error);
      throw error;
    }
  }

  // Send push notification (placeholder for actual push service)
  async sendPushNotification(userId, title, body, data = {}) {
    try {
      // In real implementation, integrate with FCM/APNS
      logger.info(`Push notification sent to user ${userId}: ${title}`);
      
      // Create notification record
      await this.createNotification({
        userId,
        title,
        message: body,
        type: data.type || 'general',
        data,
        deliveryMethod: 'push'
      });

      return { success: true };
    } catch (error) {
      logger.error('Send push notification error:', error);
      return { success: false, error: error.message };
    }
  }

  // Send SMS notification
  async sendSMS(phoneNumber, message, userId) {
    try {
      if (!process.env.TWILIO_ACCOUNT_SID || !process.env.TWILIO_AUTH_TOKEN) {
        logger.warn('Twilio credentials not configured');
        return { success: false, error: 'SMS service not configured' };
      }

      const result = await this.twilioClient.messages.create({
        body: message,
        from: process.env.TWILIO_PHONE_NUMBER,
        to: phoneNumber
      });

      // Create notification record
      if (userId) {
        await this.createNotification({
          userId,
          title: 'SMS Notification',
          message,
          type: 'sms',
          deliveryMethod: 'sms',
          data: { messageSid: result.sid }
        });
      }

      logger.info(`SMS sent to ${phoneNumber}: ${result.sid}`);
      return { success: true, messageSid: result.sid };

    } catch (error) {
      logger.error('Send SMS error:', error);
      return { success: false, error: error.message };
    }
  }

  // Send emergency alert to multiple contacts
  async sendEmergencyAlert(emergencyData, contacts) {
    try {
      const { userName, location, message, severity } = emergencyData;
      const alertMessage = `🚨 आपातकाल: ${userName} को सहायता की आवश्यकता है। स्थान: ${location}। संदेश: ${message}`;

      const results = [];

      for (const contact of contacts) {
        try {
          // Send push notification
          if (contact.userId) {
            const pushResult = await this.sendPushNotification(
              contact.userId,
              '🚨 आपातकालीन अलर्ट',
              alertMessage,
              {
                type: 'emergency',
                severity,
                location,
                emergencyId: emergencyData.emergencyId
              }
            );
            results.push({ contact: contact.name, method: 'push', ...pushResult });
          }

          // Send SMS if phone number available
          if (contact.phoneNumber) {
            const smsResult = await this.sendSMS(
              contact.phoneNumber,
              alertMessage,
              contact.userId
            );
            results.push({ contact: contact.name, method: 'sms', ...smsResult });
          }

        } catch (error) {
          logger.error(`Failed to notify contact ${contact.name}:`, error);
          results.push({ 
            contact: contact.name, 
            success: false, 
            error: error.message 
          });
        }
      }

      return results;

    } catch (error) {
      logger.error('Send emergency alert error:', error);
      throw error;
    }
  }

  // Send bulk notifications
  async sendBulkNotifications(notifications) {
    try {
      const results = [];

      for (const notification of notifications) {
        try {
          const result = await this.sendPushNotification(
            notification.userId,
            notification.title,
            notification.message,
            notification.data
          );
          results.push({ userId: notification.userId, ...result });
        } catch (error) {
          results.push({ 
            userId: notification.userId, 
            success: false, 
            error: error.message 
          });
        }
      }

      return results;

    } catch (error) {
      logger.error('Send bulk notifications error:', error);
      throw error;
    }
  }

  // Send follow notification
  async sendFollowNotification(followerId, followedUserId, followerName) {
    try {
      return await this.sendPushNotification(
        followedUserId,
        'नया फॉलोअर',
        `${followerName} ने आपको फॉलो किया है`,
        {
          type: 'follow',
          followerId,
          followerName
        }
      );
    } catch (error) {
      logger.error('Send follow notification error:', error);
      throw error;
    }
  }

  // Send like notification
  async sendLikeNotification(likerId, postOwnerId, likerName, postId) {
    try {
      return await this.sendPushNotification(
        postOwnerId,
        'नई लाइक',
        `${likerName} ने आपकी पोस्ट को पसंद किया`,
        {
          type: 'like',
          likerId,
          likerName,
          postId
        }
      );
    } catch (error) {
      logger.error('Send like notification error:', error);
      throw error;
    }
  }

  // Send comment notification
  async sendCommentNotification(commenterId, postOwnerId, commenterName, postId, comment) {
    try {
      return await this.sendPushNotification(
        postOwnerId,
        'नई कमेंट',
        `${commenterName} ने आपकी पोस्ट पर कमेंट किया: ${comment.substring(0, 50)}...`,
        {
          type: 'comment',
          commenterId,
          commenterName,
          postId,
          comment
        }
      );
    } catch (error) {
      logger.error('Send comment notification error:', error);
      throw error;
    }
  }

  // Send event reminder
  async sendEventReminder(userId, eventTitle, eventDate) {
    try {
      return await this.sendPushNotification(
        userId,
        'इवेंट रिमाइंडर',
        `आपका इवेंट "${eventTitle}" ${eventDate} को है`,
        {
          type: 'event_reminder',
          eventTitle,
          eventDate
        }
      );
    } catch (error) {
      logger.error('Send event reminder error:', error);
      throw error;
    }
  }
}

module.exports = new NotificationService();
