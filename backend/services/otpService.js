const twilio = require('twilio');
const logger = require('../utils/logger');

class OTPService {
  constructor() {
    this.twilioClient = twilio(
      process.env.TWILIO_ACCOUNT_SID,
      process.env.TWILIO_AUTH_TOKEN
    );
    
    // In-memory storage for OTPs (in production, use Redis)
    this.otpStore = new Map();
    this.otpExpiry = 5 * 60 * 1000; // 5 minutes
    this.maxAttempts = 3;
  }

  // Generate 6-digit OTP
  generateOTP() {
    return Math.floor(100000 + Math.random() * 900000).toString();
  }

  // Send OTP via SMS
  async sendOTP(phoneNumber, purpose = 'verification') {
    try {
      const otp = this.generateOTP();
      const expiresAt = Date.now() + this.otpExpiry;

      // Store OTP with metadata
      const otpData = {
        otp,
        phoneNumber,
        purpose,
        expiresAt,
        attempts: 0,
        createdAt: Date.now()
      };

      this.otpStore.set(phoneNumber, otpData);

      // Prepare message based on purpose
      let message;
      switch (purpose) {
        case 'login':
          message = `आपका होसला वार्ता लॉगिन OTP: ${otp}। यह 5 मिनट में समाप्त हो जाएगा। किसी के साथ साझा न करें।`;
          break;
        case 'registration':
          message = `आपका होसला वार्ता पंजीकरण OTP: ${otp}। यह 5 मिनट में समाप्त हो जाएगा।`;
          break;
        case 'password_reset':
          message = `आपका होसला वार्ता पासवर्ड रीसेट OTP: ${otp}। यह 5 मिनट में समाप्त हो जाएगा।`;
          break;
        case 'emergency_verification':
          message = `आपातकालीन सत्यापन OTP: ${otp}। यह 5 मिनट में समाप्त हो जाएगा।`;
          break;
        default:
          message = `आपका होसला वार्ता OTP: ${otp}। यह 5 मिनट में समाप्त हो जाएगा।`;
      }

      // Send SMS using Twilio
      if (process.env.TWILIO_ACCOUNT_SID && process.env.TWILIO_AUTH_TOKEN) {
        const result = await this.twilioClient.messages.create({
          body: message,
          from: process.env.TWILIO_PHONE_NUMBER,
          to: phoneNumber
        });

        logger.info(`OTP sent to ${phoneNumber} for ${purpose}: ${result.sid}`);
        
        return {
          success: true,
          message: 'OTP sent successfully',
          expiresIn: this.otpExpiry / 1000 // in seconds
        };
      } else {
        // For development/testing
        logger.info(`OTP for ${phoneNumber} (${purpose}): ${otp}`);
        
        return {
          success: true,
          message: 'OTP sent successfully (development mode)',
          expiresIn: this.otpExpiry / 1000,
          otp: process.env.NODE_ENV === 'development' ? otp : undefined
        };
      }

    } catch (error) {
      logger.error('Send OTP error:', error);
      return {
        success: false,
        message: 'Failed to send OTP',
        error: error.message
      };
    }
  }

  // Verify OTP
  async verifyOTP(phoneNumber, otp, purpose = 'verification') {
    try {
      const otpData = this.otpStore.get(phoneNumber);

      if (!otpData) {
        return {
          success: false,
          message: 'OTP not found or expired',
          code: 'OTP_NOT_FOUND'
        };
      }

      // Check if OTP has expired
      if (Date.now() > otpData.expiresAt) {
        this.otpStore.delete(phoneNumber);
        return {
          success: false,
          message: 'OTP has expired',
          code: 'OTP_EXPIRED'
        };
      }

      // Check purpose match
      if (otpData.purpose !== purpose) {
        return {
          success: false,
          message: 'Invalid OTP purpose',
          code: 'INVALID_PURPOSE'
        };
      }

      // Check attempts
      if (otpData.attempts >= this.maxAttempts) {
        this.otpStore.delete(phoneNumber);
        return {
          success: false,
          message: 'Too many attempts. Please request a new OTP.',
          code: 'MAX_ATTEMPTS_EXCEEDED'
        };
      }

      // Verify OTP
      if (otpData.otp !== otp) {
        otpData.attempts++;
        this.otpStore.set(phoneNumber, otpData);
        
        return {
          success: false,
          message: 'Invalid OTP',
          code: 'INVALID_OTP',
          attemptsLeft: this.maxAttempts - otpData.attempts
        };
      }

      // OTP is valid, remove from store
      this.otpStore.delete(phoneNumber);
      
      logger.info(`OTP verified successfully for ${phoneNumber} (${purpose})`);
      
      return {
        success: true,
        message: 'OTP verified successfully'
      };

    } catch (error) {
      logger.error('Verify OTP error:', error);
      return {
        success: false,
        message: 'Failed to verify OTP',
        error: error.message
      };
    }
  }

  // Resend OTP
  async resendOTP(phoneNumber, purpose = 'verification') {
    try {
      // Remove existing OTP
      this.otpStore.delete(phoneNumber);
      
      // Send new OTP
      return await this.sendOTP(phoneNumber, purpose);
      
    } catch (error) {
      logger.error('Resend OTP error:', error);
      return {
        success: false,
        message: 'Failed to resend OTP',
        error: error.message
      };
    }
  }

  // Check if OTP exists for phone number
  hasValidOTP(phoneNumber) {
    const otpData = this.otpStore.get(phoneNumber);
    return otpData && Date.now() <= otpData.expiresAt;
  }

  // Clean expired OTPs (should be called periodically)
  cleanExpiredOTPs() {
    const now = Date.now();
    for (const [phoneNumber, otpData] of this.otpStore.entries()) {
      if (now > otpData.expiresAt) {
        this.otpStore.delete(phoneNumber);
      }
    }
  }

  // Get OTP statistics (for monitoring)
  getStats() {
    const now = Date.now();
    let active = 0;
    let expired = 0;
    
    for (const otpData of this.otpStore.values()) {
      if (now <= otpData.expiresAt) {
        active++;
      } else {
        expired++;
      }
    }
    
    return { active, expired, total: this.otpStore.size };
  }
}

module.exports = new OTPService();
