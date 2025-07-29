const { body, param, query, validationResult } = require('express-validator');
const responseHelper = require('../utils/responseHelper');
const APP_CONSTANTS = require('../config/constants');

// Handle validation errors
const handleValidationErrors = (req, res, next) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return responseHelper.error(res, 'Validation failed', 400, errors.array());
  }
  next();
};

// Phone number validation for Indian numbers
const validatePhoneNumber = [
  body('phoneNumber')
    .matches(/^\+91[6-9]\d{9}$/)
    .withMessage('Please provide a valid Indian phone number (e.g., +919876543210)'),
  handleValidationErrors
];

// OTP validation
const validateOTP = [
  body('otp')
    .isLength({ min: 6, max: 6 })
    .isNumeric()
    .withMessage('OTP must be 6 digits'),
  handleValidationErrors
];

// User registration validation
const validateUserRegistration = [
  body('name')
    .trim()
    .isLength({ min: 2, max: APP_CONSTANTS.USER.MAX_NAME_LENGTH })
    .withMessage(`Name must be between 2 and ${APP_CONSTANTS.USER.MAX_NAME_LENGTH} characters`),
  
  body('email')
    .optional()
    .isEmail()
    .normalizeEmail()
    .withMessage('Please provide a valid email address'),
  
  body('dateOfBirth')
    .optional()
    .isISO8601()
    .custom((value) => {
      if (value) {
        const age = Math.floor((Date.now() - new Date(value)) / (365.25 * 24 * 60 * 60 * 1000));
        if (age < APP_CONSTANTS.USER.MIN_AGE) {
          throw new Error('User must be at least 50 years old');
        }
      }
      return true;
    }),
  
  body('gender')
    .optional()
    .isIn(['male', 'female', 'other'])
    .withMessage('Gender must be male, female, or other'),
  
  handleValidationErrors
];

// Profile update validation
const validateProfileUpdate = [
  body('name')
    .optional()
    .trim()
    .isLength({ min: 2, max: APP_CONSTANTS.USER.MAX_NAME_LENGTH })
    .withMessage(`Name must be between 2 and ${APP_CONSTANTS.USER.MAX_NAME_LENGTH} characters`),
  
  body('bio')
    .optional()
    .trim()
    .isLength({ max: APP_CONSTANTS.USER.MAX_BIO_LENGTH })
    .withMessage(`Bio cannot exceed ${APP_CONSTANTS.USER.MAX_BIO_LENGTH} characters`),
  
  body('email')
    .optional()
    .isEmail()
    .normalizeEmail()
    .withMessage('Please provide a valid email address'),
  
  body('preferences.language')
    .optional()
    .isIn(APP_CONSTANTS.LANGUAGES)
    .withMessage('Invalid language selection'),
  
  body('preferences.theme')
    .optional()
    .isIn(APP_CONSTANTS.THEMES)
    .withMessage('Invalid theme selection'),
  
  handleValidationErrors
];

// Post creation validation
const validatePostCreation = [
  body('content')
    .optional()
    .trim()
    .isLength({ min: 1, max: APP_CONSTANTS.POST.MAX_CONTENT_LENGTH })
    .withMessage(`Content cannot exceed ${APP_CONSTANTS.POST.MAX_CONTENT_LENGTH} characters`),
  
  body('mediaType')
    .optional()
    .isIn(APP_CONSTANTS.POST.MEDIA_TYPES)
    .withMessage('Invalid media type'),
  
  body('tags')
    .optional()
    .isArray()
    .withMessage('Tags must be an array'),
  
  body('tags.*')
    .optional()
    .trim()
    .isLength({ min: 1, max: 50 })
    .withMessage('Each tag must be between 1 and 50 characters'),
  
  // Ensure either content or media is provided
  body()
    .custom((value, { req }) => {
      if (!req.body.content && !req.file) {
        throw new Error('Either content or media file is required');
      }
      return true;
    }),
  
  handleValidationErrors
];

// Comment validation
const validateComment = [
  body('content')
    .trim()
    .isLength({ min: 1, max: APP_CONSTANTS.POST.MAX_COMMENT_LENGTH })
    .withMessage(`Comment must be between 1 and ${APP_CONSTANTS.POST.MAX_COMMENT_LENGTH} characters`),
  
  handleValidationErrors
];

// Emergency alert validation
const validateEmergencyAlert = [
  body('type')
    .isIn(APP_CONSTANTS.EMERGENCY.TYPES)
    .withMessage('Invalid emergency type'),
  
  body('message')
    .optional()
    .trim()
    .isLength({ max: APP_CONSTANTS.EMERGENCY.MAX_MESSAGE_LENGTH })
    .withMessage(`Message cannot exceed ${APP_CONSTANTS.EMERGENCY.MAX_MESSAGE_LENGTH} characters`),
  
  body('location.latitude')
    .optional()
    .isFloat({ min: -90, max: 90 })
    .withMessage('Invalid latitude'),
  
  body('location.longitude')
    .optional()
    .isFloat({ min: -180, max: 180 })
    .withMessage('Invalid longitude'),
  
  handleValidationErrors
];

// Event creation validation
const validateEventCreation = [
  body('title')
    .trim()
    .isLength({ min: 5, max: APP_CONSTANTS.EVENT.MAX_TITLE_LENGTH })
    .withMessage(`Title must be between 5 and ${APP_CONSTANTS.EVENT.MAX_TITLE_LENGTH} characters`),
  
  body('description')
    .trim()
    .isLength({ min: 10, max: APP_CONSTANTS.EVENT.MAX_DESCRIPTION_LENGTH })
    .withMessage(`Description must be between 10 and ${APP_CONSTANTS.EVENT.MAX_DESCRIPTION_LENGTH} characters`),
  
  body('type')
    .isIn(APP_CONSTANTS.EVENT.TYPES)
    .withMessage('Invalid event type'),
  
  body('startDate')
    .isISO8601()
    .custom((value) => {
      if (new Date(value) <= new Date()) {
        throw new Error('Start date must be in the future');
      }
      return true;
    }),
  
  body('endDate')
    .isISO8601()
    .custom((value, { req }) => {
      if (new Date(value) <= new Date(req.body.startDate)) {
        throw new Error('End date must be after start date');
      }
      return true;
    }),
  
  body('location.address')
    .trim()
    .isLength({ min: 5, max: 200 })
    .withMessage('Address must be between 5 and 200 characters'),
  
  body('location.city')
    .trim()
    .isLength({ min: 2, max: 50 })
    .withMessage('City must be between 2 and 50 characters'),
  
  body('location.state')
    .trim()
    .isLength({ min: 2, max: 50 })
    .withMessage('State must be between 2 and 50 characters'),
  
  body('maxParticipants')
    .optional()
    .isInt({ min: 1, max: 1000 })
    .withMessage('Max participants must be between 1 and 1000'),
  
  body('cost.amount')
    .optional()
    .isFloat({ min: 0 })
    .withMessage('Cost must be a positive number'),
  
  handleValidationErrors
];

// Chat message validation
const validateChatMessage = [
  body('content')
    .optional()
    .trim()
    .isLength({ min: 1, max: APP_CONSTANTS.CHAT.MAX_MESSAGE_LENGTH })
    .withMessage(`Message cannot exceed ${APP_CONSTANTS.CHAT.MAX_MESSAGE_LENGTH} characters`),
  
  body('messageType')
    .optional()
    .isIn(APP_CONSTANTS.CHAT.MESSAGE_TYPES)
    .withMessage('Invalid message type'),
  
  // Ensure either content or media is provided
  body()
    .custom((value, { req }) => {
      if (!req.body.content && !req.file && req.body.messageType !== 'location') {
        throw new Error('Message content, media, or location is required');
      }
      return true;
    }),
  
  handleValidationErrors
];

// Pagination validation
const validatePagination = [
  query('page')
    .optional()
    .isInt({ min: 1 })
    .withMessage('Page must be a positive integer'),
  
  query('limit')
    .optional()
    .isInt({ min: 1, max: APP_CONSTANTS.PAGINATION.MAX_LIMIT })
    .withMessage(`Limit must be between 1 and ${APP_CONSTANTS.PAGINATION.MAX_LIMIT}`),
  
  handleValidationErrors
];

// MongoDB ObjectId validation
const validateObjectId = (paramName) => [
  param(paramName)
    .isMongoId()
    .withMessage(`Invalid ${paramName}`),
  
  handleValidationErrors
];

// File upload validation
const validateFileUpload = (allowedTypes, maxSize) => {
  return (req, res, next) => {
    if (!req.file) {
      return next();
    }

    // Check file type
    if (allowedTypes && !allowedTypes.includes(req.file.mimetype)) {
      return responseHelper.error(res, `File type not allowed. Allowed types: ${allowedTypes.join(', ')}`, 400);
    }

    // Check file size
    if (maxSize && req.file.size > maxSize) {
      return responseHelper.error(res, `File size too large. Maximum size: ${maxSize / (1024 * 1024)}MB`, 400);
    }

    next();
  };
};

// Trust circle creation validation
const validateTrustCircle = [
  body('name')
    .trim()
    .isLength({ min: 2, max: 100 })
    .withMessage('Trust circle name must be between 2 and 100 characters'),
  
  body('description')
    .optional()
    .trim()
    .isLength({ max: 300 })
    .withMessage('Description cannot exceed 300 characters'),
  
  body('memberIds')
    .optional()
    .isArray()
    .withMessage('Member IDs must be an array'),
  
  body('memberIds.*')
    .optional()
    .isMongoId()
    .withMessage('Invalid member ID format'),
  
  body('emergencyPermissions.canReceiveAlerts')
    .optional()
    .isBoolean()
    .withMessage('canReceiveAlerts must be a boolean'),
  
  body('emergencyPermissions.canViewLocation')
    .optional()
    .isBoolean()
    .withMessage('canViewLocation must be a boolean'),
  
  body('emergencyPermissions.canContactEmergencyServices')
    .optional()
    .isBoolean()
    .withMessage('canContactEmergencyServices must be a boolean'),
  
  handleValidationErrors
];

// Trust circle invitation validation
const validateTrustCircleInvite = [
  body('invitedUserId')
    .isMongoId()
    .withMessage('Invalid user ID'),
  
  body('invitationMessage')
    .optional()
    .trim()
    .isLength({ max: 300 })
    .withMessage('Invitation message cannot exceed 300 characters'),
  
  handleValidationErrors
];

// Emergency contact validation
const validateEmergencyContact = [
  body('name')
    .trim()
    .isLength({ min: 2, max: 100 })
    .withMessage('Name must be between 2 and 100 characters'),
  
  body('phoneNumber')
    .matches(/^\+91[6-9]\d{9}$/)
    .withMessage('Please provide a valid Indian phone number'),
  
  body('relationship')
    .trim()
    .isLength({ min: 2, max: 50 })
    .withMessage('Relationship must be between 2 and 50 characters'),
  
  handleValidationErrors
];

module.exports = {
  handleValidationErrors,
  validatePhoneNumber,
  validateOTP,
  validateUserRegistration,
  validateProfileUpdate,
  validatePostCreation,
  validateComment,
  validateEmergencyAlert,
  validateEventCreation,
  validateChatMessage,
  validatePagination,
  validateObjectId,
  validateFileUpload,
  validateTrustCircle,
  validateTrustCircleInvite,
  validateEmergencyContact
};
