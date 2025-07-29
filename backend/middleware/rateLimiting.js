const rateLimit = require('express-rate-limit');
const responseHelper = require('../utils/responseHelper');

// General API rate limiting
const generalLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 1000, // limit each IP to 1000 requests per windowMs
  message: {
    success: false,
    message: 'Too many requests from this IP, please try again later.'
  },
  standardHeaders: true,
  legacyHeaders: false,
  handler: (req, res) => {
    responseHelper.error(res, 'Too many requests, please try again later.', 429);
  }
});

// Strict rate limiting for authentication endpoints
const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 10, // limit each IP to 10 auth requests per windowMs
  message: {
    success: false,
    message: 'Too many authentication attempts, please try again later.'
  },
  skipSuccessfulRequests: true,
  handler: (req, res) => {
    responseHelper.error(res, 'Too many authentication attempts, please try again later.', 429);
  }
});

// Very strict rate limiting for OTP requests
const otpLimiter = rateLimit({
  windowMs: 60 * 1000, // 1 minute
  max: 2, // limit each IP to 2 OTP requests per minute
  message: {
    success: false,
    message: 'Too many OTP requests, please wait before requesting again.'
  },
  skipSuccessfulRequests: false,
  handler: (req, res) => {
    responseHelper.error(res, 'Too many OTP requests, please wait before requesting again.', 429);
  }
});

// Rate limiting for emergency alerts
const emergencyLimiter = rateLimit({
  windowMs: 5 * 60 * 1000, // 5 minutes
  max: 3, // limit each IP to 3 emergency alerts per 5 minutes
  message: {
    success: false,
    message: 'Too many emergency alerts, please wait before sending another.'
  },
  keyGenerator: (req) => {
    // Use user ID if authenticated, otherwise fall back to IP
    return req.user ? req.user._id.toString() : req.ip;
  },
  handler: (req, res) => {
    responseHelper.error(res, 'Too many emergency alerts, please wait before sending another.', 429);
  }
});

// Rate limiting for post creation
const postCreationLimiter = rateLimit({
  windowMs: 60 * 1000, // 1 minute
  max: 5, // limit each user to 5 posts per minute
  message: {
    success: false,
    message: 'Too many posts created, please wait before creating another.'
  },
  keyGenerator: (req) => {
    return req.user ? req.user._id.toString() : req.ip;
  },
  handler: (req, res) => {
    responseHelper.error(res, 'Too many posts created, please wait before creating another.', 429);
  }
});

// Rate limiting for chat messages
const chatMessageLimiter = rateLimit({
  windowMs: 60 * 1000, // 1 minute
  max: 30, // limit each user to 30 messages per minute
  message: {
    success: false,
    message: 'Too many messages sent, please slow down.'
  },
  keyGenerator: (req) => {
    return req.user ? req.user._id.toString() : req.ip;
  },
  handler: (req, res) => {
    responseHelper.error(res, 'Too many messages sent, please slow down.', 429);
  }
});

// Rate limiting for file uploads
const uploadLimiter = rateLimit({
  windowMs: 60 * 1000, // 1 minute
  max: 10, // limit each user to 10 uploads per minute
  message: {
    success: false,
    message: 'Too many file uploads, please wait before uploading again.'
  },
  keyGenerator: (req) => {
    return req.user ? req.user._id.toString() : req.ip;
  },
  handler: (req, res) => {
    responseHelper.error(res, 'Too many file uploads, please wait before uploading again.', 429);
  }
});

// Rate limiting for search operations
const searchLimiter = rateLimit({
  windowMs: 60 * 1000, // 1 minute
  max: 60, // limit each user to 60 searches per minute
  message: {
    success: false,
    message: 'Too many search requests, please slow down.'
  },
  keyGenerator: (req) => {
    return req.user ? req.user._id.toString() : req.ip;
  },
  handler: (req, res) => {
    responseHelper.error(res, 'Too many search requests, please slow down.', 429);
  }
});

// Rate limiting for password reset (if implemented)
const passwordResetLimiter = rateLimit({
  windowMs: 60 * 60 * 1000, // 1 hour
  max: 3, // limit each IP to 3 password reset requests per hour
  message: {
    success: false,
    message: 'Too many password reset attempts, please try again later.'
  },
  handler: (req, res) => {
    responseHelper.error(res, 'Too many password reset attempts, please try again later.', 429);
  }
});

// Rate limiting for trust circle operations
const trustCircleLimiter = rateLimit({
  windowMs: 60 * 1000, // 1 minute
  max: 10, // limit each user to 10 trust circle operations per minute
  message: {
    success: false,
    message: 'Too many trust circle operations, please slow down.'
  },
  keyGenerator: (req) => {
    return req.user ? req.user._id.toString() : req.ip;
  },
  handler: (req, res) => {
    responseHelper.error(res, 'Too many trust circle operations, please slow down.', 429);
  }
});

// Create a dynamic rate limiter
const createDynamicLimiter = (windowMs, max, message, keyType = 'ip') => {
  return rateLimit({
    windowMs,
    max,
    message: {
      success: false,
      message
    },
    keyGenerator: (req) => {
      switch (keyType) {
        case 'user':
          return req.user ? req.user._id.toString() : req.ip;
        case 'ip':
        default:
          return req.ip;
      }
    },
    handler: (req, res) => {
      responseHelper.error(res, message, 429);
    }
  });
};

module.exports = {
  generalLimiter,
  authLimiter,
  otpLimiter,
  emergencyLimiter,
  postCreationLimiter,
  chatMessageLimiter,
  uploadLimiter,
  searchLimiter,
  passwordResetLimiter,
  trustCircleLimiter,
  createDynamicLimiter
};
