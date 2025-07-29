const express = require('express');
const router = express.Router();
const EmergencyAlert = require('../models/EmergencyAlert');
const User = require('../models/User');
const TrustCircle = require('../models/TrustCircle');
const Notification = require('../models/Notification');
const HoslaPoint = require('../models/HoslaPoint');
const { authenticateToken } = require('../middleware/auth');
const { validateEmergencyAlert, validatePagination, validateObjectId } = require('../middleware/validation');
const { emergencyLimiter } = require('../middleware/rateLimiting');
const responseHelper = require('../utils/responseHelper');
const logger = require('../utils/logger');

// Send emergency alert
router.post('/alert', authenticateToken, emergencyLimiter, validateEmergencyAlert, async (req, res) => {
  try {
    const { type, message, location } = req.body;

    // Get user's trust circle
    const trustCircle = await TrustCircle.getTrustCircleForUser(req.userId);
    
    if (!trustCircle || trustCircle.members.length === 0) {
      return responseHelper.error(res, 'No trust circle members found. Please add emergency contacts first.', 400);
    }

    // Create emergency alert
    const alert = new EmergencyAlert({
      userId: req.userId,
      type,
      message: message?.trim(),
      location,
      priority: type === 'not_feeling_well' ? 'high' : type === 'need_help' ? 'medium' : 'low'
    });

    await alert.save();
    await alert.populate('userId', 'name phoneNumber profilePicture');

    // Get emergency contacts from trust circle
    const emergencyContacts = trustCircle.members
      .filter(member => member.isEmergencyContact)
      .map(member => member.memberId._id);

    // Send notifications to emergency contacts
    if (emergencyContacts.length > 0) {
      await Notification.createEmergencyNotification(
        emergencyContacts,
        req.userId,
        alert._id,
        type
      );

      // Mark contacts as notified
      for (const contactId of emergencyContacts) {
        await alert.addNotifiedContact(contactId, 'push');
      }
    }

    // Log emergency alert for monitoring
    logger.logBusinessEvent('EMERGENCY_ALERT_SENT', req.userId, {
      alertId: alert._id,
      type,
      location: location?.city,
      contactsNotified: emergencyContacts.length
    });

    return responseHelper.emergencyAlertSent(res, alert._id, emergencyContacts.length, 'Emergency alert sent successfully');

  } catch (error) {
    logger.error('Send emergency alert error:', error);
    return responseHelper.serverError(res, 'Failed to send emergency alert');
  }
});

// Get emergency alerts for user's trust circle
router.get('/alerts', authenticateToken, validatePagination, async (req, res) => {
  try {
    const { status = 'active' } = req.query;
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 20;
    const skip = (page - 1) * limit;

    // Get user's trust circle
    const trustCircle = await TrustCircle.getTrustCircleForUser(req.userId);
    
    if (!trustCircle) {
      return responseHelper.emptyResult(res, 'No trust circle found');
    }

    // Get user IDs from trust circle
    const trustCircleUserIds = trustCircle.members.map(member => member.memberId._id);
    trustCircleUserIds.push(req.userId); // Include user's own alerts

    let query = {
      userId: { $in: trustCircleUserIds },
      isTestAlert: false
    };

    if (status !== 'all') {
      query.status = status;
    }

    const alerts = await EmergencyAlert.find(query)
      .populate('userId', 'name profilePicture phoneNumber')
      .populate('respondedBy.userId', 'name profilePicture')
      .sort({ priority: -1, createdAt: -1 })
      .skip(skip)
      .limit(limit);

    const total = await EmergencyAlert.countDocuments(query);

    // Add additional info for each alert
    const alertsWithInfo = alerts.map(alert => {
      const alertObj = alert.toObject();
      alertObj.canRespond = !alert.userId._id.equals(req.userId);
      alertObj.hasResponded = alert.respondedBy.some(response => response.userId._id.equals(req.userId));
      return alertObj;
    });

    return responseHelper.paginated(res, alertsWithInfo, { page, limit, total });

  } catch (error) {
    logger.error('Get emergency alerts error:', error);
    return responseHelper.serverError(res, 'Failed to get emergency alerts');
  }
});

// Get specific emergency alert
router.get('/alerts/:alertId', authenticateToken, validateObjectId('alertId'), async (req, res) => {
  try {
    const { alertId } = req.params;

    const alert = await EmergencyAlert.findById(alertId)
      .populate('userId', 'name profilePicture phoneNumber location')
      .populate('respondedBy.userId', 'name profilePicture phoneNumber')
      .populate('resolvedBy', 'name profilePicture');

    if (!alert) {
      return responseHelper.notFound(res, 'Emergency alert not found');
    }

    // Check if user has access to this alert
    const trustCircle = await TrustCircle.getTrustCircleForUser(alert.userId);
    const hasAccess = alert.userId._id.equals(req.userId) || 
                     (trustCircle && trustCircle.members.some(member => member.memberId._id.equals(req.userId)));

    if (!hasAccess) {
      return responseHelper.forbidden(res, 'Access denied to this emergency alert');
    }

    const alertObj = alert.toObject();
    alertObj.canRespond = !alert.userId._id.equals(req.userId) && alert.status === 'active';
    alertObj.hasResponded = alert.respondedBy.some(response => response.userId._id.equals(req.userId));

    return responseHelper.success(res, 'Emergency alert retrieved successfully', alertObj);

  } catch (error) {
    logger.error('Get emergency alert error:', error);
    return responseHelper.serverError(res, 'Failed to get emergency alert');
  }
});

// Respond to emergency alert
router.post('/alerts/:alertId/respond', authenticateToken, validateObjectId('alertId'), async (req, res) => {
  try {
    const { alertId } = req.params;
    const { response, responseType = 'text', estimatedArrival } = req.body;

    if (!response || response.trim().length === 0) {
      return responseHelper.error(res, 'Response message is required', 400);
    }

    const alert = await EmergencyAlert.findById(alertId)
      .populate('userId', 'name');

    if (!alert) {
      return responseHelper.notFound(res, 'Emergency alert not found');
    }

    if (alert.status !== 'active') {
      return responseHelper.error(res, 'Cannot respond to inactive alert', 400);
    }

    // Don't allow self-response
    if (alert.userId._id.equals(req.userId)) {
      return responseHelper.error(res, 'Cannot respond to your own alert', 400);
    }

    // Check if user is in the trust circle
    const trustCircle = await TrustCircle.getTrustCircleForUser(alert.userId);
    const isTrustCircleMember = trustCircle && 
      trustCircle.members.some(member => member.memberId._id.equals(req.userId));

    if (!isTrustCircleMember) {
      return responseHelper.forbidden(res, 'Only trust circle members can respond');
    }

    // Add response
    await alert.addResponse(
      req.userId, 
      response.trim(), 
      responseType, 
      estimatedArrival ? new Date(estimatedArrival) : null
    );

    // Award points to responder
    await HoslaPoint.awardPoints(
      req.userId,
      'emergency_helped',
      20,
      'Responded to emergency alert',
      alert._id,
      'EmergencyAlert'
    );

    // Create notification for alert creator
    await Notification.createNotification({
      recipientId: alert.userId._id,
      senderId: req.userId,
      type: 'emergency_response',
      title: 'Emergency Response',
      message: `Someone responded to your emergency alert: "${response.substring(0, 50)}${response.length > 50 ? '...' : ''}"`,
      data: { alertId: alert._id, response },
      category: 'emergency',
      priority: 'high'
    });

    logger.logBusinessEvent('EMERGENCY_RESPONSE_ADDED', req.userId, {
      alertId: alert._id,
      alertUserId: alert.userId._id,
      responseType
    });

    return responseHelper.success(res, 'Response added successfully', {
      responseCount: alert.responseCount
    });

  } catch (error) {
    logger.error('Respond to emergency alert error:', error);
    return responseHelper.serverError(res, 'Failed to respond to emergency alert');
  }
});

// Resolve emergency alert
router.post('/alerts/:alertId/resolve', authenticateToken, validateObjectId('alertId'), async (req, res) => {
  try {
    const { alertId } = req.params;
    const { resolutionNote } = req.body;

    const alert = await EmergencyAlert.findById(alertId);

    if (!alert) {
      return responseHelper.notFound(res, 'Emergency alert not found');
    }

    // Only the alert creator can resolve their alert
    if (!alert.userId.equals(req.userId)) {
      return responseHelper.forbidden(res, 'Only the alert creator can resolve this alert');
    }

    if (alert.status !== 'active') {
      return responseHelper.error(res, 'Alert is already resolved or cancelled', 400);
    }

    await alert.resolve(req.userId, resolutionNote?.trim());

    logger.logBusinessEvent('EMERGENCY_ALERT_RESOLVED', req.userId, {
      alertId: alert._id,
      responseCount: alert.responseCount
    });

    return responseHelper.success(res, 'Emergency alert resolved successfully');

  } catch (error) {
    logger.error('Resolve emergency alert error:', error);
    return responseHelper.serverError(res, 'Failed to resolve emergency alert');
  }
});

// Cancel emergency alert
router.post('/alerts/:alertId/cancel', authenticateToken, validateObjectId('alertId'), async (req, res) => {
  try {
    const { alertId } = req.params;

    const alert = await EmergencyAlert.findById(alertId);

    if (!alert) {
      return responseHelper.notFound(res, 'Emergency alert not found');
    }

    // Only the alert creator can cancel their alert
    if (!alert.userId.equals(req.userId)) {
      return responseHelper.forbidden(res, 'Only the alert creator can cancel this alert');
    }

    if (alert.status !== 'active') {
      return responseHelper.error(res, 'Alert is already resolved or cancelled', 400);
    }

    await alert.cancel();

    logger.logBusinessEvent('EMERGENCY_ALERT_CANCELLED', req.userId, {
      alertId: alert._id
    });

    return responseHelper.success(res, 'Emergency alert cancelled successfully');

  } catch (error) {
    logger.error('Cancel emergency alert error:', error);
    return responseHelper.serverError(res, 'Failed to cancel emergency alert');
  }
});

// Get user's own emergency alerts
router.get('/my-alerts', authenticateToken, validatePagination, async (req, res) => {
  try {
    const { status } = req.query;
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 20;
    const skip = (page - 1) * limit;

    let query = {
      userId: req.userId,
      isTestAlert: false
    };

    if (status) {
      query.status = status;
    }

    const alerts = await EmergencyAlert.find(query)
      .populate('respondedBy.userId', 'name profilePicture phoneNumber')
      .populate('resolvedBy', 'name profilePicture')
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(limit);

    const total = await EmergencyAlert.countDocuments(query);

    return responseHelper.paginated(res, alerts, { page, limit, total });

  } catch (error) {
    logger.error('Get my emergency alerts error:', error);
    return responseHelper.serverError(res, 'Failed to get your emergency alerts');
  }
});

// Test emergency alert (for testing the system)
router.post('/test-alert', authenticateToken, async (req, res) => {
  try {
    const alert = new EmergencyAlert({
      userId: req.userId,
      type: 'want_to_talk',
      message: 'This is a test alert to check the emergency system',
      priority: 'low',
      isTestAlert: true
    });

    await alert.save();

    logger.logBusinessEvent('TEST_EMERGENCY_ALERT', req.userId, {
      alertId: alert._id
    });

    return responseHelper.success(res, 'Test emergency alert created successfully', {
      alertId: alert._id,
      message: 'Test alert created. This will not notify your emergency contacts.'
    });

  } catch (error) {
    logger.error('Test emergency alert error:', error);
    return responseHelper.serverError(res, 'Failed to create test alert');
  }
});

// Get emergency statistics
router.get('/stats', authenticateToken, async (req, res) => {
  try {
    const { period = '30' } = req.query; // days
    const startDate = new Date(Date.now() - parseInt(period) * 24 * 60 * 60 * 1000);

    const stats = await EmergencyAlert.aggregate([
      {
        $match: {
          userId: req.userId,
          createdAt: { $gte: startDate },
          isTestAlert: false
        }
      },
      {
        $group: {
          _id: {
            type: '$type',
            status: '$status'
          },
          count: { $sum: 1 },
          avgResponseTime: {
            $avg: {
              $cond: [
                { $eq: ['$status', 'resolved'] },
                { $subtract: ['$resolvedAt', '$createdAt'] },
                null
              ]
            }
          }
        }
      }
    ]);

    const summary = {
      totalAlerts: 0,
      activeAlerts: 0,
      resolvedAlerts: 0,
      responseRate: 0,
      avgResponseTime: 0
    };

    stats.forEach(stat => {
      summary.totalAlerts += stat.count;
      if (stat._id.status === 'active') {
        summary.activeAlerts += stat.count;
      } else if (stat._id.status === 'resolved') {
        summary.resolvedAlerts += stat.count;
        if (stat.avgResponseTime) {
          summary.avgResponseTime = Math.round(stat.avgResponseTime / (1000 * 60)); // minutes
        }
      }
    });

    if (summary.totalAlerts > 0) {
      summary.responseRate = Math.round((summary.resolvedAlerts / summary.totalAlerts) * 100);
    }

    return responseHelper.analytics(res, {
      summary,
      breakdown: stats
    }, `${period} days`, 'Emergency alert statistics retrieved');

  } catch (error) {
    logger.error('Get emergency stats error:', error);
    return responseHelper.serverError(res, 'Failed to get emergency statistics');
  }
});

module.exports = router;
