const express = require('express');
const router = express.Router();
const HoslaPoint = require('../models/HoslaPoint');
const { authenticateToken } = require('../middleware/auth');
const { validatePagination } = require('../middleware/validation');
const responseHelper = require('../utils/responseHelper');
const logger = require('../utils/logger');

// Get user's points history
router.get('/', authenticateToken, validatePagination, async (req, res) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 20;
    const skip = (page - 1) * limit;

    const points = await HoslaPoint.find({ userId: req.userId })
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(limit);

    const total = await HoslaPoint.countDocuments({ userId: req.userId });

    // Calculate total points
    const totalPoints = await HoslaPoint.aggregate([
      { $match: { userId: req.userId } },
      { $group: { _id: null, total: { $sum: '$points' } } }
    ]);

    const userTotalPoints = totalPoints[0]?.total || 0;

    const response = {
      points,
      totalPoints: userTotalPoints,
      pagination: {
        page,
        limit,
        total,
        totalPages: Math.ceil(total / limit)
      }
    };

    return responseHelper.success(res, response);

  } catch (error) {
    logger.error('Get points error:', error);
    return responseHelper.serverError(res, 'Failed to get points');
  }
});

// Get leaderboard
router.get('/leaderboard', authenticateToken, async (req, res) => {
  try {
    const period = req.query.period || 'all'; // all, weekly, monthly
    const limit = parseInt(req.query.limit) || 10;

    let matchStage = {};
    
    if (period === 'weekly') {
      const weekAgo = new Date();
      weekAgo.setDate(weekAgo.getDate() - 7);
      matchStage.createdAt = { $gte: weekAgo };
    } else if (period === 'monthly') {
      const monthAgo = new Date();
      monthAgo.setMonth(monthAgo.getMonth() - 1);
      matchStage.createdAt = { $gte: monthAgo };
    }

    const leaderboard = await HoslaPoint.aggregate([
      { $match: matchStage },
      {
        $group: {
          _id: '$userId',
          totalPoints: { $sum: '$points' },
          lastActivity: { $max: '$createdAt' }
        }
      },
      {
        $lookup: {
          from: 'users',
          localField: '_id',
          foreignField: '_id',
          as: 'user'
        }
      },
      {
        $unwind: '$user'
      },
      {
        $project: {
          _id: 1,
          totalPoints: 1,
          lastActivity: 1,
          user: {
            name: 1,
            profilePicture: 1
          }
        }
      },
      { $sort: { totalPoints: -1 } },
      { $limit: limit }
    ]);

    // Find current user's rank
    const userRank = await HoslaPoint.aggregate([
      { $match: matchStage },
      {
        $group: {
          _id: '$userId',
          totalPoints: { $sum: '$points' }
        }
      },
      { $sort: { totalPoints: -1 } },
      {
        $group: {
          _id: null,
          users: { $push: { userId: '$_id', totalPoints: '$totalPoints' } }
        }
      },
      {
        $project: {
          userRank: {
            $add: [
              {
                $indexOfArray: [
                  '$users.userId',
                  req.userId
                ]
              },
              1
            ]
          }
        }
      }
    ]);

    const currentUserRank = userRank[0]?.userRank || null;

    return responseHelper.success(res, {
      leaderboard,
      currentUserRank,
      period
    });

  } catch (error) {
    logger.error('Get leaderboard error:', error);
    return responseHelper.serverError(res, 'Failed to get leaderboard');
  }
});

// Get points summary
router.get('/summary', authenticateToken, async (req, res) => {
  try {
    const summary = await HoslaPoint.aggregate([
      { $match: { userId: req.userId } },
      {
        $group: {
          _id: '$type',
          totalPoints: { $sum: '$points' },
          count: { $sum: 1 },
          lastEarned: { $max: '$createdAt' }
        }
      },
      {
        $group: {
          _id: null,
          totalPoints: { $sum: '$totalPoints' },
          breakdown: {
            $push: {
              type: '$_id',
              points: '$totalPoints',
              count: '$count',
              lastEarned: '$lastEarned'
            }
          }
        }
      }
    ]);

    const result = summary[0] || {
      totalPoints: 0,
      breakdown: []
    };

    // Get recent achievements (last 7 days)
    const weekAgo = new Date();
    weekAgo.setDate(weekAgo.getDate() - 7);

    const recentPoints = await HoslaPoint.find({
      userId: req.userId,
      createdAt: { $gte: weekAgo }
    }).sort({ createdAt: -1 });

    const weeklyTotal = recentPoints.reduce((sum, point) => sum + point.points, 0);

    return responseHelper.success(res, {
      ...result,
      weeklyPoints: weeklyTotal,
      recentActivities: recentPoints.slice(0, 5)
    });

  } catch (error) {
    logger.error('Get points summary error:', error);
    return responseHelper.serverError(res, 'Failed to get points summary');
  }
});

// Get available rewards/milestones
router.get('/milestones', authenticateToken, async (req, res) => {
  try {
    // Get user's total points
    const totalPoints = await HoslaPoint.aggregate([
      { $match: { userId: req.userId } },
      { $group: { _id: null, total: { $sum: '$points' } } }
    ]);

    const userPoints = totalPoints[0]?.total || 0;

    // Define milestones
    const milestones = [
      { points: 100, title: 'होसला शुरुआत', description: 'पहले 100 अंक पूरे करें', badge: 'starter' },
      { points: 500, title: 'होसला मित्र', description: '500 अंक पूरे करें', badge: 'friend' },
      { points: 1000, title: 'होसला गुरु', description: '1000 अंक पूरे करें', badge: 'guru' },
      { points: 2500, title: 'होसला चैंपियन', description: '2500 अंक पूरे करें', badge: 'champion' },
      { points: 5000, title: 'होसला मास्टर', description: '5000 अंक पूरे करें', badge: 'master' },
      { points: 10000, title: 'होसला लीजेंड', description: '10000 अंक पूरे करें', badge: 'legend' }
    ];

    const milestonesWithStatus = milestones.map(milestone => ({
      ...milestone,
      achieved: userPoints >= milestone.points,
      progress: Math.min((userPoints / milestone.points) * 100, 100)
    }));

    return responseHelper.success(res, {
      userPoints,
      milestones: milestonesWithStatus,
      nextMilestone: milestonesWithStatus.find(m => !m.achieved) || null
    });

  } catch (error) {
    logger.error('Get milestones error:', error);
    return responseHelper.serverError(res, 'Failed to get milestones');
  }
});

module.exports = router;
