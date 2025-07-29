const express = require('express');
const router = express.Router();
const TrustCircle = require('../models/TrustCircle');
const User = require('../models/User');
const { authenticateToken } = require('../middleware/auth');
const { validateTrustCircle, validateObjectId } = require('../middleware/validation');
const responseHelper = require('../utils/responseHelper');
const logger = require('../utils/logger');

// Get user's trust circles
router.get('/', authenticateToken, async (req, res) => {
  try {
    const trustCircles = await TrustCircle.find({
      $or: [
        { creator: req.userId },
        { members: req.userId }
      ]
    })
    .populate('creator', 'name profilePicture')
    .populate('members', 'name profilePicture relationship')
    .sort({ createdAt: -1 });

    return responseHelper.success(res, trustCircles);

  } catch (error) {
    logger.error('Get trust circles error:', error);
    return responseHelper.serverError(res, 'Failed to get trust circles');
  }
});

// Create trust circle
router.post('/', authenticateToken, validateTrustCircle, async (req, res) => {
  try {
    const { name, description, memberIds, emergencyPermissions } = req.body;

    const trustCircleData = {
      name: name?.trim(),
      description: description?.trim(),
      creator: req.userId,
      members: memberIds || [],
      emergencyPermissions: emergencyPermissions || {
        canReceiveAlerts: true,
        canViewLocation: false,
        canContactEmergencyServices: false
      }
    };

    const trustCircle = new TrustCircle(trustCircleData);
    await trustCircle.save();

    await trustCircle.populate('creator', 'name profilePicture');
    await trustCircle.populate('members', 'name profilePicture');

    return responseHelper.created(res, 'Trust circle created successfully', trustCircle);

  } catch (error) {
    logger.error('Create trust circle error:', error);
    return responseHelper.serverError(res, 'Failed to create trust circle');
  }
});

// Get specific trust circle
router.get('/:circleId', authenticateToken, validateObjectId('circleId'), async (req, res) => {
  try {
    const trustCircle = await TrustCircle.findById(req.params.circleId)
      .populate('creator', 'name profilePicture')
      .populate('members', 'name profilePicture relationship');

    if (!trustCircle) {
      return responseHelper.error(res, 'Trust circle not found', 404);
    }

    // Check if user has access
    const hasAccess = trustCircle.creator.equals(req.userId) || 
                     trustCircle.members.some(member => member._id.equals(req.userId));

    if (!hasAccess) {
      return responseHelper.forbidden(res, 'Access denied to this trust circle');
    }

    return responseHelper.success(res, trustCircle);

  } catch (error) {
    logger.error('Get trust circle error:', error);
    return responseHelper.serverError(res, 'Failed to get trust circle');
  }
});

// Update trust circle
router.put('/:circleId', authenticateToken, validateObjectId('circleId'), async (req, res) => {
  try {
    const { name, description, emergencyPermissions } = req.body;

    const trustCircle = await TrustCircle.findById(req.params.circleId);

    if (!trustCircle) {
      return responseHelper.error(res, 'Trust circle not found', 404);
    }

    // Only creator can update
    if (!trustCircle.creator.equals(req.userId)) {
      return responseHelper.forbidden(res, 'Only creator can update trust circle');
    }

    const updateData = {};
    if (name !== undefined) updateData.name = name.trim();
    if (description !== undefined) updateData.description = description.trim();
    if (emergencyPermissions !== undefined) updateData.emergencyPermissions = emergencyPermissions;

    const updatedTrustCircle = await TrustCircle.findByIdAndUpdate(
      req.params.circleId,
      updateData,
      { new: true }
    )
    .populate('creator', 'name profilePicture')
    .populate('members', 'name profilePicture');

    return responseHelper.success(res, updatedTrustCircle, 'Trust circle updated successfully');

  } catch (error) {
    logger.error('Update trust circle error:', error);
    return responseHelper.serverError(res, 'Failed to update trust circle');
  }
});

// Add member to trust circle
router.post('/:circleId/members', authenticateToken, validateObjectId('circleId'), async (req, res) => {
  try {
    const { userId } = req.body;

    if (!userId) {
      return responseHelper.error(res, 'User ID is required', 400);
    }

    const trustCircle = await TrustCircle.findById(req.params.circleId);

    if (!trustCircle) {
      return responseHelper.error(res, 'Trust circle not found', 404);
    }

    // Only creator can add members
    if (!trustCircle.creator.equals(req.userId)) {
      return responseHelper.forbidden(res, 'Only creator can add members');
    }

    // Check if user exists
    const userToAdd = await User.findById(userId);
    if (!userToAdd) {
      return responseHelper.error(res, 'User not found', 404);
    }

    // Check if already a member
    if (trustCircle.members.includes(userId)) {
      return responseHelper.error(res, 'User is already a member', 400);
    }

    trustCircle.members.push(userId);
    await trustCircle.save();

    await trustCircle.populate('members', 'name profilePicture');

    return responseHelper.success(res, trustCircle, 'Member added successfully');

  } catch (error) {
    logger.error('Add member error:', error);
    return responseHelper.serverError(res, 'Failed to add member');
  }
});

// Remove member from trust circle
router.delete('/:circleId/members/:userId', authenticateToken, validateObjectId('circleId'), validateObjectId('userId'), async (req, res) => {
  try {
    const { circleId, userId } = req.params;

    const trustCircle = await TrustCircle.findById(circleId);

    if (!trustCircle) {
      return responseHelper.error(res, 'Trust circle not found', 404);
    }

    // Only creator can remove members, or member can remove themselves
    const isCreator = trustCircle.creator.equals(req.userId);
    const isSelfRemoval = userId === req.userId;

    if (!isCreator && !isSelfRemoval) {
      return responseHelper.forbidden(res, 'Access denied');
    }

    // Remove member
    trustCircle.members = trustCircle.members.filter(member => !member.equals(userId));
    await trustCircle.save();

    return responseHelper.success(res, null, 'Member removed successfully');

  } catch (error) {
    logger.error('Remove member error:', error);
    return responseHelper.serverError(res, 'Failed to remove member');
  }
});

// Delete trust circle
router.delete('/:circleId', authenticateToken, validateObjectId('circleId'), async (req, res) => {
  try {
    const trustCircle = await TrustCircle.findById(req.params.circleId);

    if (!trustCircle) {
      return responseHelper.error(res, 'Trust circle not found', 404);
    }

    // Only creator can delete
    if (!trustCircle.creator.equals(req.userId)) {
      return responseHelper.forbidden(res, 'Only creator can delete trust circle');
    }

    await TrustCircle.findByIdAndDelete(req.params.circleId);

    return responseHelper.success(res, null, 'Trust circle deleted successfully');

  } catch (error) {
    logger.error('Delete trust circle error:', error);
    return responseHelper.serverError(res, 'Failed to delete trust circle');
  }
});

module.exports = router;
