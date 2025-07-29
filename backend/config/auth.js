const jwt = require('jsonwebtoken');

const authConfig = {
  jwt: {
    secret: process.env.JWT_SECRET,
    expiresIn: process.env.JWT_EXPIRES_IN || '7d',
    algorithm: 'HS256'
  },
  otp: {
    expiresIn: parseInt(process.env.OTP_EXPIRES_IN) || 300, // 5 minutes
    length: 6,
    maxAttempts: 5
  },
  bcrypt: {
    rounds: parseInt(process.env.BCRYPT_ROUNDS) || 12
  }
};

// Generate JWT token
const generateToken = (payload) => {
  return jwt.sign(payload, authConfig.jwt.secret, {
    expiresIn: authConfig.jwt.expiresIn,
    algorithm: authConfig.jwt.algorithm
  });
};

// Verify JWT token
const verifyToken = (token) => {
  return jwt.verify(token, authConfig.jwt.secret);
};

// Generate OTP
const generateOTP = () => {
  return Math.floor(100000 + Math.random() * 900000).toString();
};

module.exports = {
  authConfig,
  generateToken,
  verifyToken,
  generateOTP
};
