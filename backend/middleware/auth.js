const jwt = require('jsonwebtoken');
const User = require('../models/User');
const logger = require('../utils/logger');
const responseHelper = require('../utils/responseHelper');

// Authenticate JWT token
const authenticateToken = async (req, res, next) => {
  try {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1]; // Bearer TOKEN

    if (!token) {
      return responseHelper.error(res, 'Access token required', 401);
    }

    // Verify token
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    
    // Get user from database
    const user = await User.findById(decoded.userId).select('-password');

    if (!user || !user.isActive) {
      return responseHelper.error(res, 'Invalid or expired token', 401);
    }

    // Update last active time
    user.lastActive = new Date();
    await user.save();

    // Attach user to request
    req.user = user;
    req.userId = user._id;

    next();
  } catch (error) {
    logger.error('Authentication error:', error);
    
    if (error.name === 'JsonWebTokenError') {
      return responseHelper.error(res, 'Invalid token', 403);
    } else if (error.name === 'TokenExpiredError') {
      return responseHelper.error(res, 'Token expired', 403);
    }
    
    return responseHelper.error(res, 'Authentication failed', 403);
  }
};

// Optional authentication - doesn't fail if no token
const optionalAuth = async (req, res, next) => {
  try {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1];

    if (token) {
      const decoded = jwt.verify(token, process.env.JWT_SECRET);
      const user = await User.findById(decoded.userId).select('-password');

      if (user && user.isActive) {
        req.user = user;
        req.userId = user._id;
        
        // Update last active time
        user.lastActive = new Date();
        await user.save();
      }
    }

    next();
  } catch (error) {
    // Continue without authentication
    logger.warn('Optional auth failed:', error.message);
    next();
  }
};

// Check if user is verified
const requireVerified = (req, res, next) => {
  if (!req.user.isVerified) {
    return responseHelper.error(res, 'Account verification required', 403);
  }
  next();
};

// Check if user is admin (for future admin features)
const requireAdmin = (req, res, next) => {
  if (!req.user.isAdmin) {
    return responseHelper.error(res, 'Admin access required', 403);
  }
  next();
};

// Check resource ownership
const checkOwnership = (resourceType) => {
  return async (req, res, next) => {
    try {
      const resourceId = req.params.id || req.params.postId || req.params.eventId;
      const Model = require(`../models/${resourceType}`);
      
      const resource = await Model.findById(resourceId);
      
      if (!resource) {
        return responseHelper.error(res, `${resourceType} not found`, 404);
      }

      // Check if user owns the resource
      if (!resource.userId.equals(req.userId) && !resource.organizer?.equals(req.userId)) {
        return responseHelper.error(res, 'Access denied', 403);
      }

      req.resource = resource;
      next();
    } catch (error) {
      logger.error(`Ownership check error for ${resourceType}:`, error);
      return responseHelper.error(res, 'Access validation failed', 500);
    }
  };
};

// Check trust circle membership
const checkTrustCircleMember = async (req, res, next) => {
  try {
    const targetUserId = req.params.userId || req.body.userId;
    
    if (!targetUserId) {
      return responseHelper.error(res, 'Target user ID required', 400);
    }

    // User can always access their own data
    if (req.userId.equals(targetUserId)) {
      return next();
    }

    const targetUser = await User.findById(targetUserId);
    if (!targetUser) {
      return responseHelper.error(res, 'User not found', 404);
    }

    // Check if current user is in target user's trust circle
    if (!targetUser.trustCircle.includes(req.userId)) {
      return responseHelper.error(res, 'Trust circle membership required', 403);
    }

    next();
  } catch (error) {
    logger.error('Trust circle check error:', error);
    return responseHelper.error(res, 'Access validation failed', 500);
  }
};

// Rate limiting for sensitive operations
const sensitiveOperationLimit = (maxAttempts = 5, windowMs = 15 * 60 * 1000) => {
  const attempts = new Map();

  return (req, res, next) => {
    const key = `${req.ip}_${req.userId}`;
    const now = Date.now();
    
    if (!attempts.has(key)) {
      attempts.set(key, { count: 1, firstAttempt: now });
      return next();
    }

    const userAttempts = attempts.get(key);
    
    // Reset if window has passed
    if (now - userAttempts.firstAttempt > windowMs) {
      attempts.set(key, { count: 1, firstAttempt: now });
      return next();
    }

    // Check if limit exceeded
    if (userAttempts.count >= maxAttempts) {
      return responseHelper.error(res, 'Too many attempts. Please try again later.', 429);
    }

    // Increment attempt count
    userAttempts.count++;
    next();
  };
};

// Validate user age for senior citizen app
const validateAge = async (req, res, next) => {
  try {
    if (req.user.dateOfBirth) {
      const age = Math.floor((Date.now() - req.user.dateOfBirth) / (365.25 * 24 * 60 * 60 * 1000));
      
      if (age < 50) {
        return responseHelper.error(res, 'This app is designed for users aged 50 and above', 403);
      }
    }
    
    next();
  } catch (error) {
    logger.error('Age validation error:', error);
    next(); // Continue without age validation if there's an error
  }
};

module.exports = {
  authenticateToken,
  optionalAuth,
  requireVerified,
  requireAdmin,
  checkOwnership,
  checkTrustCircleMember,
  sensitiveOperationLimit,
  validateAge
};
