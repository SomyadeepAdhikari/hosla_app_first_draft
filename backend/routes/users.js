const express = require('express');
const router = express.Router();
const User = require('../models/User');
const Post = require('../models/Post');
const HoslaPoint = require('../models/HoslaPoint');
const { authenticateToken } = require('../middleware/auth');
const { validateProfileUpdate, validatePagination, validateObjectId } = require('../middleware/validation');
const { uploadProfilePicture } = require('../config/cloudinary');
const responseHelper = require('../utils/responseHelper');
const logger = require('../utils/logger');

// Get user profile
router.get('/profile', authenticateToken, async (req, res) => {
  try {
    const user = await User.findById(req.userId)
      .populate('trustCircle', 'name profilePicture phoneNumber isActive')
      .select('-password');

    if (!user) {
      return responseHelper.notFound(res, 'User not found');
    }

    // Get total reward points
    const pointsResult = await HoslaPoint.getTotalPointsForUser(req.userId);
    const totalPoints = pointsResult[0]?.totalPoints || 0;

    const userProfile = {
      id: user._id,
      name: user.name,
      phoneNumber: user.phoneNumber,
      email: user.email,
      dateOfBirth: user.dateOfBirth,
      age: user.age,
      gender: user.gender,
      bio: user.bio,
      profilePicture: user.profilePicture,
      rewardPoints: totalPoints,
      preferences: user.preferences,
      trustCircle: user.trustCircle,
      trustCircleCount: user.trustCircleCount,
      followerCount: user.followerCount,
      followingCount: user.followingCount,
      location: user.location,
      emergencyContacts: user.emergencyContacts,
      isVerified: user.isVerified,
      lastActive: user.lastActive,
      joinedAt: user.createdAt
    };

    return responseHelper.success(res, 'Profile retrieved successfully', userProfile);

  } catch (error) {
    logger.error('Get profile error:', error);
    return responseHelper.serverError(res, 'Failed to get profile');
  }
});

// Update user profile
router.put('/profile', authenticateToken, validateProfileUpdate, async (req, res) => {
  try {
    const updates = req.body;
    const user = await User.findById(req.userId);

    if (!user) {
      return responseHelper.notFound(res, 'User not found');
    }

    // Update allowed fields
    const allowedUpdates = ['name', 'email', 'dateOfBirth', 'gender', 'bio', 'preferences', 'location'];
    Object.keys(updates).forEach(key => {
      if (allowedUpdates.includes(key)) {
        if (key === 'preferences' || key === 'location') {
          user[key] = { ...user[key].toObject(), ...updates[key] };
        } else {
          user[key] = updates[key];
        }
      }
    });

    await user.save();

    // Award points for profile completion
    if (user.bio && user.dateOfBirth && user.gender && !user.profileCompletionPointsAwarded) {
      await HoslaPoint.awardPoints(
        user._id,
        'profile_completed',
        25,
        'Profile completion bonus'
      );
      user.profileCompletionPointsAwarded = true;
      await user.save();
    }

    logger.logBusinessEvent('PROFILE_UPDATED', user._id, updates);

    return responseHelper.success(res, 'Profile updated successfully', {
      id: user._id,
      name: user.name,
      email: user.email,
      bio: user.bio,
      preferences: user.preferences,
      location: user.location
    });

  } catch (error) {
    logger.error('Update profile error:', error);
    return responseHelper.serverError(res, 'Failed to update profile');
  }
});

// Upload profile picture
router.post('/profile/picture', authenticateToken, uploadProfilePicture.single('picture'), async (req, res) => {
  try {
    if (!req.file) {
      return responseHelper.error(res, 'No image file provided', 400);
    }

    const user = await User.findById(req.userId);
    if (!user) {
      return responseHelper.notFound(res, 'User not found');
    }

    // Update profile picture URL
    user.profilePicture = req.file.path;
    await user.save();

    logger.logBusinessEvent('PROFILE_PICTURE_UPDATED', user._id, { imageUrl: req.file.path });

    return responseHelper.success(res, 'Profile picture updated successfully', {
      profilePicture: user.profilePicture
    });

  } catch (error) {
    logger.error('Upload profile picture error:', error);
    return responseHelper.serverError(res, 'Failed to upload profile picture');
  }
});

// Get user by ID
router.get('/:userId', authenticateToken, validateObjectId('userId'), async (req, res) => {
  try {
    const { userId } = req.params;
    
    const user = await User.findById(userId)
      .select('name profilePicture bio location isActive lastActive createdAt')
      .populate('followers', 'name profilePicture')
      .populate('following', 'name profilePicture');

    if (!user) {
      return responseHelper.notFound(res, 'User not found');
    }

    // Check if current user can view this profile
    const isOwnProfile = req.userId.equals(userId);
    const isTrustCircleMember = user.trustCircle.includes(req.userId);

    const userProfile = {
      id: user._id,
      name: user.name,
      profilePicture: user.profilePicture,
      bio: user.bio,
      isActive: user.isActive,
      lastActive: user.lastActive,
      joinedAt: user.createdAt,
      followerCount: user.followerCount,
      followingCount: user.followingCount,
      isFollowedByCurrentUser: user.followers.some(f => f._id.equals(req.userId))
    };

    // Show additional info if own profile or trust circle member
    if (isOwnProfile || isTrustCircleMember) {
      userProfile.location = user.location;
      userProfile.age = user.age;
    }

    return responseHelper.success(res, 'User profile retrieved', userProfile);

  } catch (error) {
    logger.error('Get user by ID error:', error);
    return responseHelper.serverError(res, 'Failed to get user profile');
  }
});

// Follow user
router.post('/:userId/follow', authenticateToken, validateObjectId('userId'), async (req, res) => {
  try {
    const { userId } = req.params;
    
    if (req.userId.equals(userId)) {
      return responseHelper.error(res, 'Cannot follow yourself', 400);
    }

    const userToFollow = await User.findById(userId);
    const currentUser = await User.findById(req.userId);

    if (!userToFollow || !currentUser) {
      return responseHelper.notFound(res, 'User not found');
    }

    // Check if already following
    if (currentUser.following.includes(userId)) {
      return responseHelper.error(res, 'Already following this user', 400);
    }

    // Add to following and followers
    await currentUser.followUser(userId);
    await userToFollow.addFollower(req.userId);

    // Award points for social interaction
    await HoslaPoint.awardPoints(
      req.userId,
      'friend_referred',
      5,
      'Following a new user'
    );

    logger.logBusinessEvent('USER_FOLLOWED', req.userId, { followedUserId: userId });

    return responseHelper.success(res, 'User followed successfully');

  } catch (error) {
    logger.error('Follow user error:', error);
    return responseHelper.serverError(res, 'Failed to follow user');
  }
});

// Unfollow user
router.delete('/:userId/follow', authenticateToken, validateObjectId('userId'), async (req, res) => {
  try {
    const { userId } = req.params;
    
    const userToUnfollow = await User.findById(userId);
    const currentUser = await User.findById(req.userId);

    if (!userToUnfollow || !currentUser) {
      return responseHelper.notFound(res, 'User not found');
    }

    // Remove from following and followers
    await currentUser.unfollowUser(userId);
    await userToUnfollow.removeFollower(req.userId);

    logger.logBusinessEvent('USER_UNFOLLOWED', req.userId, { unfollowedUserId: userId });

    return responseHelper.success(res, 'User unfollowed successfully');

  } catch (error) {
    logger.error('Unfollow user error:', error);
    return responseHelper.serverError(res, 'Failed to unfollow user');
  }
});

// Get user's followers
router.get('/:userId/followers', authenticateToken, validateObjectId('userId'), validatePagination, async (req, res) => {
  try {
    const { userId } = req.params;
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 20;
    const skip = (page - 1) * limit;

    const user = await User.findById(userId)
      .populate({
        path: 'followers',
        select: 'name profilePicture bio isActive lastActive',
        options: { skip, limit }
      });

    if (!user) {
      return responseHelper.notFound(res, 'User not found');
    }

    const total = user.followers.length;

    return responseHelper.paginated(res, user.followers, { page, limit, total });

  } catch (error) {
    logger.error('Get followers error:', error);
    return responseHelper.serverError(res, 'Failed to get followers');
  }
});

// Get user's following
router.get('/:userId/following', authenticateToken, validateObjectId('userId'), validatePagination, async (req, res) => {
  try {
    const { userId } = req.params;
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 20;
    const skip = (page - 1) * limit;

    const user = await User.findById(userId)
      .populate({
        path: 'following',
        select: 'name profilePicture bio isActive lastActive',
        options: { skip, limit }
      });

    if (!user) {
      return responseHelper.notFound(res, 'User not found');
    }

    const total = user.following.length;

    return responseHelper.paginated(res, user.following, { page, limit, total });

  } catch (error) {
    logger.error('Get following error:', error);
    return responseHelper.serverError(res, 'Failed to get following');
  }
});

// Search users
router.get('/search', authenticateToken, validatePagination, async (req, res) => {
  try {
    const { q, city, state } = req.query;
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 20;
    const skip = (page - 1) * limit;

    if (!q || q.trim().length < 2) {
      return responseHelper.error(res, 'Search query must be at least 2 characters', 400);
    }

    const searchQuery = {
      $and: [
        { isActive: true },
        { _id: { $ne: req.userId } }, // Exclude current user
        {
          $or: [
            { name: { $regex: q.trim(), $options: 'i' } },
            { bio: { $regex: q.trim(), $options: 'i' } }
          ]
        }
      ]
    };

    // Add location filters if provided
    if (city) {
      searchQuery.$and.push({ 'location.city': { $regex: city, $options: 'i' } });
    }
    if (state) {
      searchQuery.$and.push({ 'location.state': { $regex: state, $options: 'i' } });
    }

    const users = await User.find(searchQuery)
      .select('name profilePicture bio location isActive lastActive')
      .skip(skip)
      .limit(limit)
      .sort({ lastActive: -1 });

    const total = await User.countDocuments(searchQuery);

    return responseHelper.paginated(res, users, { page, limit, total });

  } catch (error) {
    logger.error('Search users error:', error);
    return responseHelper.serverError(res, 'Failed to search users');
  }
});

// Get user's reward points
router.get('/profile/points', authenticateToken, async (req, res) => {
  try {
    const [totalResult, breakdown] = await Promise.all([
      HoslaPoint.getTotalPointsForUser(req.userId),
      HoslaPoint.getPointsBreakdownForUser(req.userId)
    ]);

    const totalPoints = totalResult[0]?.totalPoints || 0;

    return responseHelper.success(res, 'Points retrieved successfully', {
      totalPoints,
      breakdown
    });

  } catch (error) {
    logger.error('Get points error:', error);
    return responseHelper.serverError(res, 'Failed to get points');
  }
});

// Update emergency contacts
router.put('/emergency-contacts', authenticateToken, async (req, res) => {
  try {
    const { emergencyContacts } = req.body;

    if (!Array.isArray(emergencyContacts)) {
      return responseHelper.error(res, 'Emergency contacts must be an array', 400);
    }

    const user = await User.findById(req.userId);
    if (!user) {
      return responseHelper.notFound(res, 'User not found');
    }

    user.emergencyContacts = emergencyContacts;
    await user.save();

    logger.logBusinessEvent('EMERGENCY_CONTACTS_UPDATED', user._id, { contactCount: emergencyContacts.length });

    return responseHelper.success(res, 'Emergency contacts updated successfully', {
      emergencyContacts: user.emergencyContacts
    });

  } catch (error) {
    logger.error('Update emergency contacts error:', error);
    return responseHelper.serverError(res, 'Failed to update emergency contacts');
  }
});

// Block user
router.post('/:userId/block', authenticateToken, validateObjectId('userId'), async (req, res) => {
  try {
    const { userId } = req.params;
    
    if (req.userId.equals(userId)) {
      return responseHelper.error(res, 'Cannot block yourself', 400);
    }

    const user = await User.findById(req.userId);
    if (!user) {
      return responseHelper.notFound(res, 'User not found');
    }

    await user.blockUser(userId);

    logger.logBusinessEvent('USER_BLOCKED', req.userId, { blockedUserId: userId });

    return responseHelper.success(res, 'User blocked successfully');

  } catch (error) {
    logger.error('Block user error:', error);
    return responseHelper.serverError(res, 'Failed to block user');
  }
});

// Unblock user
router.delete('/:userId/block', authenticateToken, validateObjectId('userId'), async (req, res) => {
  try {
    const { userId } = req.params;
    
    const user = await User.findById(req.userId);
    if (!user) {
      return responseHelper.notFound(res, 'User not found');
    }

    await user.unblockUser(userId);

    logger.logBusinessEvent('USER_UNBLOCKED', req.userId, { unblockedUserId: userId });

    return responseHelper.success(res, 'User unblocked successfully');

  } catch (error) {
    logger.error('Unblock user error:', error);
    return responseHelper.serverError(res, 'Failed to unblock user');
  }
});

module.exports = router;
