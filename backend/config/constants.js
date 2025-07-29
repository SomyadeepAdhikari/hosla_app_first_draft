// Application constants
const APP_CONSTANTS = {
  // User related
  USER: {
    MIN_AGE: 50,
    MAX_NAME_LENGTH: 100,
    MAX_BIO_LENGTH: 500,
    DEFAULT_REWARD_POINTS: 0
  },

  // Post related
  POST: {
    MAX_CONTENT_LENGTH: 500,
    MAX_COMMENT_LENGTH: 300,
    MEDIA_TYPES: ['text', 'image', 'video', 'audio']
  },

  // Emergency related
  EMERGENCY: {
    TYPES: ['not_feeling_well', 'need_help', 'want_to_talk'],
    STATUSES: ['active', 'resolved', 'cancelled'],
    PRIORITIES: ['low', 'medium', 'high', 'critical'],
    AUTO_RESOLVE_HOURS: 24,
    MAX_MESSAGE_LENGTH: 500
  },

  // Event related
  EVENT: {
    MAX_TITLE_LENGTH: 200,
    MAX_DESCRIPTION_LENGTH: 1000,
    TYPES: ['social', 'health', 'entertainment', 'education', 'other']
  },

  // Chat related
  CHAT: {
    MAX_MESSAGE_LENGTH: 1000,
    MESSAGE_TYPES: ['text', 'image', 'audio', 'location']
  },

  // Trust Circle
  TRUST_CIRCLE: {
    MAX_MEMBERS: 10,
    MIN_MEMBERS: 1
  },

  // Notification types
  NOTIFICATION_TYPES: {
    POST_LIKE: 'post_like',
    POST_COMMENT: 'post_comment',
    NEW_FOLLOWER: 'new_follower',
    EMERGENCY_ALERT: 'emergency_alert',
    EVENT_REMINDER: 'event_reminder',
    CHAT_MESSAGE: 'chat_message',
    TRUST_CIRCLE_INVITE: 'trust_circle_invite'
  },

  // Languages supported
  LANGUAGES: ['en', 'hi', 'bn', 'ta', 'te'],

  // Themes
  THEMES: ['light', 'dark'],

  // File upload limits
  FILE_LIMITS: {
    IMAGE_MAX_SIZE: 5 * 1024 * 1024, // 5MB
    VIDEO_MAX_SIZE: 50 * 1024 * 1024, // 50MB
    AUDIO_MAX_SIZE: 10 * 1024 * 1024, // 10MB
    PROFILE_IMAGE_SIZE: 2 * 1024 * 1024 // 2MB
  },

  // Pagination
  PAGINATION: {
    DEFAULT_PAGE: 1,
    DEFAULT_LIMIT: 20,
    MAX_LIMIT: 100
  },

  // Language options
  LANGUAGES: ['en', 'hi', 'ta', 'te', 'mr', 'bn', 'gu'],

  // Theme options
  THEMES: ['light', 'dark', 'auto'],

  // Response messages
  MESSAGES: {
    SUCCESS: {
      OTP_SENT: 'OTP sent successfully',
      LOGIN_SUCCESS: 'Login successful',
      PROFILE_UPDATED: 'Profile updated successfully',
      POST_CREATED: 'Post created successfully',
      POST_DELETED: 'Post deleted successfully',
      EMERGENCY_ALERT_SENT: 'Emergency alert sent successfully',
      EVENT_CREATED: 'Event created successfully'
    },
    ERROR: {
      INVALID_CREDENTIALS: 'Invalid credentials',
      USER_NOT_FOUND: 'User not found',
      INVALID_OTP: 'Invalid or expired OTP',
      UNAUTHORIZED: 'Unauthorized access',
      FORBIDDEN: 'Access forbidden',
      VALIDATION_FAILED: 'Validation failed',
      SERVER_ERROR: 'Internal server error',
      FILE_TOO_LARGE: 'File size too large',
      INVALID_FILE_TYPE: 'Invalid file type'
    }
  }
};

module.exports = APP_CONSTANTS;
