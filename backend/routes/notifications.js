const express = require('express');
const router = express.Router();
const Notification = require('../models/Notification');
const { authenticateToken } = require('../middleware/auth');
const { validatePagination } = require('../middleware/validation');
const responseHelper = require('../utils/responseHelper');
const logger = require('../utils/logger');

// Get user's notifications
router.get('/', authenticateToken, validatePagination, async (req, res) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 20;
    const skip = (page - 1) * limit;
    const unreadOnly = req.query.unread === 'true';

    const filter = { userId: req.userId };
    if (unreadOnly) {
      filter.read = false;
    }

    const notifications = await Notification.find(filter)
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(limit);

    const total = await Notification.countDocuments(filter);
    const unreadCount = await Notification.countDocuments({
      userId: req.userId,
      read: false
    });

    const response = {
      notifications,
      unreadCount,
      pagination: {
        page,
        limit,
        total,
        totalPages: Math.ceil(total / limit)
      }
    };

    return responseHelper.success(res, response);

  } catch (error) {
    logger.error('Get notifications error:', error);
    return responseHelper.serverError(res, 'Failed to get notifications');
  }
});

// Mark notification as read
router.patch('/:notificationId/read', authenticateToken, async (req, res) => {
  try {
    const notification = await Notification.findOneAndUpdate(
      { _id: req.params.notificationId, userId: req.userId },
      { read: true, readAt: new Date() },
      { new: true }
    );

    if (!notification) {
      return responseHelper.error(res, 'Notification not found', 404);
    }

    return responseHelper.success(res, notification, 'Notification marked as read');

  } catch (error) {
    logger.error('Mark notification read error:', error);
    return responseHelper.serverError(res, 'Failed to mark notification as read');
  }
});

// Mark all notifications as read
router.patch('/read-all', authenticateToken, async (req, res) => {
  try {
    const result = await Notification.updateMany(
      { userId: req.userId, read: false },
      { read: true, readAt: new Date() }
    );

    return responseHelper.success(res, { 
      modifiedCount: result.modifiedCount 
    }, 'All notifications marked as read');

  } catch (error) {
    logger.error('Mark all notifications read error:', error);
    return responseHelper.serverError(res, 'Failed to mark all notifications as read');
  }
});

// Delete notification
router.delete('/:notificationId', authenticateToken, async (req, res) => {
  try {
    const notification = await Notification.findOneAndDelete({
      _id: req.params.notificationId,
      userId: req.userId
    });

    if (!notification) {
      return responseHelper.error(res, 'Notification not found', 404);
    }

    return responseHelper.success(res, null, 'Notification deleted successfully');

  } catch (error) {
    logger.error('Delete notification error:', error);
    return responseHelper.serverError(res, 'Failed to delete notification');
  }
});

// Delete all notifications
router.delete('/', authenticateToken, async (req, res) => {
  try {
    const result = await Notification.deleteMany({ userId: req.userId });

    return responseHelper.success(res, {
      deletedCount: result.deletedCount
    }, 'All notifications deleted successfully');

  } catch (error) {
    logger.error('Delete all notifications error:', error);
    return responseHelper.serverError(res, 'Failed to delete all notifications');
  }
});

// Get notification statistics
router.get('/stats', authenticateToken, async (req, res) => {
  try {
    const stats = await Notification.aggregate([
      {
        $match: { userId: req.userId }
      },
      {
        $group: {
          _id: null,
          total: { $sum: 1 },
          unread: {
            $sum: {
              $cond: [{ $eq: ['$read', false] }, 1, 0]
            }
          },
          byType: {
            $push: {
              type: '$type',
              read: '$read'
            }
          }
        }
      },
      {
        $project: {
          _id: 0,
          total: 1,
          unread: 1,
          read: { $subtract: ['$total', '$unread'] },
          typeBreakdown: {
            $reduce: {
              input: '$byType',
              initialValue: {},
              in: {
                $mergeObjects: [
                  '$$value',
                  {
                    $switch: {
                      branches: [
                        {
                          case: { $eq: ['$$this.type', 'like'] },
                          then: { 
                            likes: { 
                              $add: [
                                { $ifNull: ['$$value.likes', 0] }, 
                                1
                              ] 
                            } 
                          }
                        },
                        {
                          case: { $eq: ['$$this.type', 'comment'] },
                          then: { 
                            comments: { 
                              $add: [
                                { $ifNull: ['$$value.comments', 0] }, 
                                1
                              ] 
                            } 
                          }
                        },
                        {
                          case: { $eq: ['$$this.type', 'follow'] },
                          then: { 
                            follows: { 
                              $add: [
                                { $ifNull: ['$$value.follows', 0] }, 
                                1
                              ] 
                            } 
                          }
                        },
                        {
                          case: { $eq: ['$$this.type', 'emergency'] },
                          then: { 
                            emergency: { 
                              $add: [
                                { $ifNull: ['$$value.emergency', 0] }, 
                                1
                              ] 
                            } 
                          }
                        }
                      ],
                      default: {
                        other: {
                          $add: [
                            { $ifNull: ['$$value.other', 0] },
                            1
                          ]
                        }
                      }
                    }
                  }
                ]
              }
            }
          }
        }
      }
    ]);

    const result = stats[0] || {
      total: 0,
      unread: 0,
      read: 0,
      typeBreakdown: {}
    };

    return responseHelper.success(res, result);

  } catch (error) {
    logger.error('Get notification stats error:', error);
    return responseHelper.serverError(res, 'Failed to get notification statistics');
  }
});

module.exports = router;
