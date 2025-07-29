const express = require('express');
const router = express.Router();
const { generateOTP, generateToken, verifyToken } = require('../config/auth');
const User = require('../models/User');
const HoslaPoint = require('../models/HoslaPoint');
const responseHelper = require('../utils/responseHelper');
const logger = require('../utils/logger');
const { validatePhoneNumber, validateOTP, validateUserRegistration } = require('../middleware/validation');
const { authLimiter, otpLimiter } = require('../middleware/rateLimiting');

// Store OTPs in memory (in production, use Redis)
const otpStore = new Map();

// Generate and send OTP
router.post('/send-otp', otpLimiter, validatePhoneNumber, async (req, res) => {
  try {
    const { phoneNumber } = req.body;

    // Generate OTP
    const otp = generateOTP();
    const expiresAt = new Date(Date.now() + 5 * 60 * 1000); // 5 minutes

    // Store OTP (in production, use Redis with expiration)
    otpStore.set(phoneNumber, {
      otp,
      expiresAt,
      attempts: 0
    });

    // Log OTP generation
    logger.logBusinessEvent('OTP_GENERATED', null, { phoneNumber });

    // In production, send OTP via SMS using Twilio
    // For development, log the OTP
    if (process.env.NODE_ENV === 'development') {
      console.log(`🔐 OTP for ${phoneNumber}: ${otp}`);
      // Include OTP in response for development only
      return responseHelper.success(res, {
        message: 'OTP sent successfully',
        otp: otp, // Only for development
        expiresIn: 300
      });
    }

    // TODO: Implement actual SMS sending with Twilio
    // const twilioClient = require('twilio')(process.env.TWILIO_ACCOUNT_SID, process.env.TWILIO_AUTH_TOKEN);
    // await twilioClient.messages.create({
    //   body: `Your Hosla Varta OTP is: ${otp}. It will expire in 5 minutes.`,
    //   from: process.env.TWILIO_PHONE_NUMBER,
    //   to: phoneNumber
    // });

    return responseHelper.otpSent(res, 'OTP sent successfully', 300);

  } catch (error) {
    logger.error('OTP generation error:', error);
    return responseHelper.serverError(res, 'Failed to send OTP');
  }
});

// Verify OTP and authenticate
router.post('/verify-otp', authLimiter, validateOTP, async (req, res) => {
  try {
    const { phoneNumber, otp, name } = req.body;

    // Check if OTP exists
    const storedOTP = otpStore.get(phoneNumber);
    if (!storedOTP) {
      return responseHelper.error(res, 'OTP not found or expired', 400);
    }

    // Check if OTP is expired
    if (new Date() > storedOTP.expiresAt) {
      otpStore.delete(phoneNumber);
      return responseHelper.error(res, 'OTP expired', 400);
    }

    // Check attempts
    if (storedOTP.attempts >= 5) {
      otpStore.delete(phoneNumber);
      return responseHelper.error(res, 'Too many invalid attempts', 400);
    }

    // Verify OTP
    if (storedOTP.otp !== otp) {
      storedOTP.attempts++;
      return responseHelper.error(res, 'Invalid OTP', 400);
    }

    // OTP is valid, remove from store
    otpStore.delete(phoneNumber);

    // Check if user exists
    let user = await User.findOne({ phoneNumber });
    let isNewUser = false;

    if (!user) {
      // Create new user
      if (!name) {
        return responseHelper.error(res, 'Name is required for new users', 400);
      }

      user = new User({
        phoneNumber,
        name: name.trim(),
        isVerified: true,
        isActive: true
      });

      await user.save();
      isNewUser = true;

      // Award welcome points for new users
      await HoslaPoint.awardPoints(
        user._id,
        'profile_completed',
        50,
        'Welcome to Hosla Varta!'
      );

      logger.logBusinessEvent('USER_REGISTERED', user._id, { phoneNumber, name });
    } else {
      // Update existing user
      user.isVerified = true;
      user.isActive = true;
      user.lastActive = new Date();
      await user.save();

      // Award daily login points
      await HoslaPoint.awardDailyLoginPoints(user._id);

      logger.logBusinessEvent('USER_LOGIN', user._id, { phoneNumber });
    }

    // Generate JWT token
    const token = generateToken({ userId: user._id, phoneNumber: user.phoneNumber });

    // Prepare user data for response
    const userData = {
      id: user._id,
      name: user.name,
      phoneNumber: user.phoneNumber,
      profilePicture: user.profilePicture,
      isVerified: user.isVerified,
      preferences: user.preferences,
      rewardPoints: user.rewardPoints,
      isNewUser
    };

    return responseHelper.authSuccess(res, userData, token, 
      isNewUser ? 'Registration successful' : 'Login successful'
    );

  } catch (error) {
    logger.error('OTP verification error:', error);
    return responseHelper.serverError(res, 'Authentication failed');
  }
});

// Refresh token
router.post('/refresh-token', async (req, res) => {
  try {
    const { token } = req.body;

    if (!token) {
      return responseHelper.error(res, 'Token is required', 400);
    }

    // Verify the token
    const decoded = verifyToken(token);
    
    // Get user
    const user = await User.findById(decoded.userId);
    if (!user || !user.isActive) {
      return responseHelper.error(res, 'Invalid token', 401);
    }

    // Generate new token
    const newToken = generateToken({ 
      userId: user._id, 
      phoneNumber: user.phoneNumber 
    });

    return responseHelper.success(res, 'Token refreshed successfully', { token: newToken });

  } catch (error) {
    logger.error('Token refresh error:', error);
    return responseHelper.error(res, 'Token refresh failed', 401);
  }
});

// Logout (mainly for cleaning up client-side)
router.post('/logout', async (req, res) => {
  try {
    // In a stateless JWT system, logout is mainly handled client-side
    // But we can log the event for analytics
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1];

    if (token) {
      try {
        const decoded = verifyToken(token);
        logger.logBusinessEvent('USER_LOGOUT', decoded.userId);
      } catch (err) {
        // Token might be invalid, but that's ok for logout
      }
    }

    return responseHelper.success(res, 'Logged out successfully');

  } catch (error) {
    logger.error('Logout error:', error);
    return responseHelper.serverError(res, 'Logout failed');
  }
});

// Check authentication status
router.get('/me', async (req, res) => {
  try {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1];

    if (!token) {
      return responseHelper.error(res, 'No token provided', 401);
    }

    const decoded = verifyToken(token);
    const user = await User.findById(decoded.userId).select('-password');

    if (!user || !user.isActive) {
      return responseHelper.error(res, 'User not found', 404);
    }

    // Update last active
    user.lastActive = new Date();
    await user.save();

    const userData = {
      id: user._id,
      name: user.name,
      phoneNumber: user.phoneNumber,
      email: user.email,
      profilePicture: user.profilePicture,
      isVerified: user.isVerified,
      preferences: user.preferences,
      rewardPoints: user.rewardPoints,
      trustCircleCount: user.trustCircle.length,
      followerCount: user.followers.length,
      followingCount: user.following.length
    };

    return responseHelper.success(res, 'User data retrieved', userData);

  } catch (error) {
    logger.error('Get user error:', error);
    return responseHelper.error(res, 'Failed to get user data', 401);
  }
});

// Resend OTP
router.post('/resend-otp', otpLimiter, validatePhoneNumber, async (req, res) => {
  try {
    const { phoneNumber } = req.body;

    // Check if user can request new OTP (1 minute cooldown)
    const lastOTP = otpStore.get(phoneNumber);
    if (lastOTP && (new Date() - lastOTP.createdAt) < 60000) {
      return responseHelper.error(res, 'Please wait before requesting new OTP', 429);
    }

    // Generate new OTP
    const otp = generateOTP();
    const expiresAt = new Date(Date.now() + 5 * 60 * 1000);

    otpStore.set(phoneNumber, {
      otp,
      expiresAt,
      attempts: 0,
      createdAt: new Date()
    });

    logger.logBusinessEvent('OTP_RESENT', null, { phoneNumber });

    if (process.env.NODE_ENV === 'development') {
      console.log(`🔐 Resent OTP for ${phoneNumber}: ${otp}`);
    }

    return responseHelper.otpSent(res, 'OTP resent successfully', 300);

  } catch (error) {
    logger.error('OTP resend error:', error);
    return responseHelper.serverError(res, 'Failed to resend OTP');
  }
});

module.exports = router;
