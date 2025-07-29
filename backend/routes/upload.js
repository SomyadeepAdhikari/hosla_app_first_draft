const express = require('express');
const router = express.Router();
const { authenticateToken } = require('../middleware/auth');
const { uploadPostMedia, uploadProfilePicture, uploadEventImage } = require('../config/cloudinary');
const { uploadLimiter } = require('../middleware/rateLimiting');
const responseHelper = require('../utils/responseHelper');
const logger = require('../utils/logger');

// Upload profile picture
router.post('/profile-picture', authenticateToken, uploadLimiter, uploadProfilePicture.single('image'), async (req, res) => {
  try {
    if (!req.file) {
      return responseHelper.error(res, 'No image file provided', 400);
    }

    logger.logBusinessEvent('PROFILE_PICTURE_UPLOADED', req.userId, {
      filename: req.file.filename,
      size: req.file.size
    });

    return responseHelper.uploadSuccess(res, req.file.path, 'Profile picture uploaded successfully');

  } catch (error) {
    logger.error('Upload profile picture error:', error);
    return responseHelper.serverError(res, 'Failed to upload profile picture');
  }
});

// Upload post media
router.post('/post-media', authenticateToken, uploadLimiter, uploadPostMedia.single('media'), async (req, res) => {
  try {
    if (!req.file) {
      return responseHelper.error(res, 'No media file provided', 400);
    }

    let mediaType = 'file';
    if (req.file.mimetype.startsWith('image/')) {
      mediaType = 'image';
    } else if (req.file.mimetype.startsWith('video/')) {
      mediaType = 'video';
    } else if (req.file.mimetype.startsWith('audio/')) {
      mediaType = 'audio';
    }

    logger.logBusinessEvent('POST_MEDIA_UPLOADED', req.userId, {
      filename: req.file.filename,
      size: req.file.size,
      mediaType
    });

    return responseHelper.uploadSuccess(res, req.file.path, 'Media uploaded successfully');

  } catch (error) {
    logger.error('Upload post media error:', error);
    return responseHelper.serverError(res, 'Failed to upload media');
  }
});

// Upload event image
router.post('/event-image', authenticateToken, uploadLimiter, uploadEventImage.single('image'), async (req, res) => {
  try {
    if (!req.file) {
      return responseHelper.error(res, 'No image file provided', 400);
    }

    logger.logBusinessEvent('EVENT_IMAGE_UPLOADED', req.userId, {
      filename: req.file.filename,
      size: req.file.size
    });

    return responseHelper.uploadSuccess(res, req.file.path, 'Event image uploaded successfully');

  } catch (error) {
    logger.error('Upload event image error:', error);
    return responseHelper.serverError(res, 'Failed to upload event image');
  }
});

module.exports = router;
