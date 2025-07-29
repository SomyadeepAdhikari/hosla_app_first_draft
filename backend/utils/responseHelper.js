// Standard API response helper functions

const success = (res, message = 'Success', data = null, statusCode = 200) => {
  const response = {
    success: true,
    message,
    timestamp: new Date().toISOString()
  };

  if (data !== null) {
    response.data = data;
  }

  return res.status(statusCode).json(response);
};

const error = (res, message = 'An error occurred', statusCode = 500, errors = null) => {
  const response = {
    success: false,
    message,
    timestamp: new Date().toISOString()
  };

  if (errors) {
    response.errors = errors;
  }

  return res.status(statusCode).json(response);
};

const paginated = (res, data, pagination, message = 'Data retrieved successfully') => {
  return res.status(200).json({
    success: true,
    message,
    data,
    pagination: {
      currentPage: pagination.page,
      totalPages: Math.ceil(pagination.total / pagination.limit),
      totalItems: pagination.total,
      itemsPerPage: pagination.limit,
      hasNextPage: pagination.page < Math.ceil(pagination.total / pagination.limit),
      hasPrevPage: pagination.page > 1
    },
    timestamp: new Date().toISOString()
  });
};

const created = (res, message = 'Resource created successfully', data = null) => {
  return success(res, message, data, 201);
};

const noContent = (res, message = 'Operation completed successfully') => {
  return success(res, message, null, 204);
};

const unauthorized = (res, message = 'Unauthorized access') => {
  return error(res, message, 401);
};

const forbidden = (res, message = 'Access forbidden') => {
  return error(res, message, 403);
};

const notFound = (res, message = 'Resource not found') => {
  return error(res, message, 404);
};

const conflict = (res, message = 'Resource conflict') => {
  return error(res, message, 409);
};

const validationError = (res, message = 'Validation failed', errors = null) => {
  return error(res, message, 400, errors);
};

const serverError = (res, message = 'Internal server error') => {
  return error(res, message, 500);
};

const tooManyRequests = (res, message = 'Too many requests') => {
  return error(res, message, 429);
};

// Helper for API responses with additional metadata
const withMeta = (res, data, meta = {}, message = 'Success', statusCode = 200) => {
  return res.status(statusCode).json({
    success: true,
    message,
    data,
    meta,
    timestamp: new Date().toISOString()
  });
};

// Helper for authentication responses
const authSuccess = (res, user, token, message = 'Authentication successful') => {
  return res.status(200).json({
    success: true,
    message,
    data: {
      user: {
        id: user._id,
        name: user.name,
        phoneNumber: user.phoneNumber,
        profilePicture: user.profilePicture,
        isVerified: user.isVerified,
        preferences: user.preferences
      },
      token
    },
    timestamp: new Date().toISOString()
  });
};

// Helper for OTP responses
const otpSent = (res, message = 'OTP sent successfully', expiresIn = 300) => {
  return res.status(200).json({
    success: true,
    message,
    data: {
      expiresIn,
      nextResendAllowedAt: new Date(Date.now() + 60000).toISOString() // 1 minute
    },
    timestamp: new Date().toISOString()
  });
};

// Helper for empty results
const emptyResult = (res, message = 'No data found') => {
  return res.status(200).json({
    success: true,
    message,
    data: [],
    pagination: {
      currentPage: 1,
      totalPages: 0,
      totalItems: 0,
      itemsPerPage: 0,
      hasNextPage: false,
      hasPrevPage: false
    },
    timestamp: new Date().toISOString()
  });
};

// Helper for file upload responses
const uploadSuccess = (res, fileUrl, message = 'File uploaded successfully') => {
  return res.status(200).json({
    success: true,
    message,
    data: {
      url: fileUrl
    },
    timestamp: new Date().toISOString()
  });
};

// Helper for notification responses
const notificationSent = (res, count, message = 'Notifications sent successfully') => {
  return res.status(200).json({
    success: true,
    message,
    data: {
      notificationsSent: count
    },
    timestamp: new Date().toISOString()
  });
};

// Helper for emergency alert responses
const emergencyAlertSent = (res, alertId, contactsNotified, message = 'Emergency alert sent successfully') => {
  return res.status(200).json({
    success: true,
    message,
    data: {
      alertId,
      contactsNotified,
      priority: 'urgent'
    },
    timestamp: new Date().toISOString()
  });
};

// Helper for analytics responses
const analytics = (res, data, period, message = 'Analytics data retrieved') => {
  return res.status(200).json({
    success: true,
    message,
    data,
    meta: {
      period,
      generatedAt: new Date().toISOString()
    },
    timestamp: new Date().toISOString()
  });
};

module.exports = {
  success,
  error,
  paginated,
  created,
  noContent,
  unauthorized,
  forbidden,
  notFound,
  conflict,
  validationError,
  serverError,
  tooManyRequests,
  withMeta,
  authSuccess,
  otpSent,
  emptyResult,
  uploadSuccess,
  notificationSent,
  emergencyAlertSent,
  analytics
};
