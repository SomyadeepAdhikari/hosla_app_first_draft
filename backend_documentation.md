# Hosla Varta Backend Documentation

## Backend Architecture Overview

The Hosla Varta backend is built using Node.js with Express.js framework, MongoDB database, and follows RESTful API principles with JWT authentication.

## 📁 Directory Structure

```
hosla_varta_backend/
├── server.js                      # Entry point
├── package.json                   # Dependencies
├── .env                          # Environment variables
├── .gitignore                    # Git ignore rules
├── README.md                     # Backend documentation
├── config/
│   ├── database.js              # MongoDB connection
│   ├── auth.js                  # Authentication config
│   ├── cloudinary.js           # File upload config
│   └── constants.js             # Application constants
├── models/                      # Database schemas
│   ├── User.js                  # User model
│   ├── Post.js                  # Post model
│   ├── Chat.js                  # Chat model
│   ├── Message.js               # Message model
│   ├── Event.js                 # Event model
│   ├── TrustCircle.js          # Trust circle model
│   ├── EmergencyAlert.js       # Emergency alert model
│   ├── Notification.js         # Notification model
│   └── HoslaPoint.js           # Volunteer points model
├── routes/                     # API endpoints
│   ├── auth.js                 # Authentication routes
│   ├── users.js                # User management
│   ├── posts.js                # Post CRUD
│   ├── chats.js                # Chat functionality
│   ├── events.js               # Event management
│   ├── trustCircle.js         # Trust circle management
│   ├── emergency.js           # Emergency alerts
│   ├── notifications.js       # Push notifications
│   └── upload.js              # File upload handling
├── middleware/
│   ├── auth.js                 # JWT verification
│   ├── validation.js          # Input validation
│   ├── rateLimiting.js        # Rate limiting
│   ├── fileUpload.js          # File handling
│   └── errorHandler.js        # Global error handling
├── services/
│   ├── otpService.js          # OTP generation/verification
│   ├── notificationService.js # Push notifications
│   ├── moderationService.js   # Content moderation
│   ├── emailService.js        # Email notifications
│   └── smsService.js          # SMS notifications
├── utils/
│   ├── responseHelper.js      # Standard API responses
│   ├── logger.js              # Logging utility
│   ├── validation.js          # Validation helpers
│   └── dateHelper.js          # Date utility functions
├── scripts/
│   ├── seedDatabase.js        # Database seeding
│   └── cleanup.js             # Database cleanup
└── tests/                     # Test files
    ├── auth.test.js
    ├── posts.test.js
    └── emergency.test.js
```

## 🔧 Setup Instructions

### 1. Prerequisites
```bash
# Install Node.js (16+ required)
node --version

# Install MongoDB (local or use MongoDB Atlas)
# Install Redis (for caching and sessions)
# Install Postman (for API testing)
```

### 2. Installation
```bash
# Create project directory
mkdir hosla_varta_backend
cd hosla_varta_backend

# Initialize project
npm init -y

# Install dependencies
npm install express mongoose jsonwebtoken bcryptjs cors helmet morgan dotenv
npm install multer cloudinary socket.io nodemailer twilio
npm install express-rate-limit express-validator compression
npm install --save-dev nodemon jest supertest
```

### 3. Environment Configuration
Create `.env` file:
```env
# Server Configuration
PORT=3000
NODE_ENV=development

# Database
MONGODB_URI=mongodb://localhost:27017/hoslavarta
REDIS_URI=redis://localhost:6379

# Authentication
JWT_SECRET=your_super_secret_jwt_key_here
JWT_EXPIRES_IN=7d
OTP_EXPIRES_IN=300

# File Upload (Cloudinary)
CLOUDINARY_CLOUD_NAME=your_cloud_name
CLOUDINARY_API_KEY=your_api_key
CLOUDINARY_API_SECRET=your_api_secret

# SMS Service (Twilio)
TWILIO_ACCOUNT_SID=your_twilio_sid
TWILIO_AUTH_TOKEN=your_twilio_token
TWILIO_PHONE_NUMBER=+1234567890

# Email Service
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=your_email@gmail.com
SMTP_PASS=your_app_password

# Push Notifications (Firebase)
FIREBASE_SERVER_KEY=your_firebase_server_key

# Security
BCRYPT_ROUNDS=12
MAX_FILE_SIZE=10485760
```

### 4. Package.json Scripts
```json
{
  "scripts": {
    "start": "node server.js",
    "dev": "nodemon server.js",
    "test": "jest",
    "test:watch": "jest --watch",
    "seed": "node scripts/seedDatabase.js",
    "lint": "eslint .",
    "format": "prettier --write ."
  }
}
```

## 📊 Database Models

### User Model (`models/User.js`)
```javascript
const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

const userSchema = new mongoose.Schema({
  phoneNumber: {
    type: String,
    required: true,
    unique: true,
    trim: true
  },
  name: {
    type: String,
    required: true,
    trim: true,
    maxlength: 100
  },
  dateOfBirth: {
    type: Date,
    required: false
  },
  gender: {
    type: String,
    enum: ['male', 'female', 'other'],
    required: false
  },
  bio: {
    type: String,
    maxlength: 500,
    trim: true
  },
  profilePicture: {
    type: String,
    default: null
  },
  rewardPoints: {
    type: Number,
    default: 0,
    min: 0
  },
  preferences: {
    language: {
      type: String,
      enum: ['en', 'hi', 'bn', 'ta', 'te'],
      default: 'en'
    },
    theme: {
      type: String,
      enum: ['light', 'dark'],
      default: 'light'
    },
    notifications: {
      push: { type: Boolean, default: true },
      sms: { type: Boolean, default: true },
      email: { type: Boolean, default: false }
    }
  },
  isVerified: {
    type: Boolean,
    default: false
  },
  isActive: {
    type: Boolean,
    default: true
  },
  lastActive: {
    type: Date,
    default: Date.now
  },
  fcmToken: {
    type: String,
    default: null
  }
}, {
  timestamps: true,
  toJSON: { virtuals: true },
  toObject: { virtuals: true }
});

// Virtual for age calculation
userSchema.virtual('age').get(function() {
  if (!this.dateOfBirth) return null;
  return Math.floor((Date.now() - this.dateOfBirth) / (365.25 * 24 * 60 * 60 * 1000));
});

// Index for better performance
userSchema.index({ phoneNumber: 1 });
userSchema.index({ isActive: 1, lastActive: -1 });

module.exports = mongoose.model('User', userSchema);
```

### Post Model (`models/Post.js`)
```javascript
const mongoose = require('mongoose');

const postSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  content: {
    type: String,
    maxlength: 500,
    trim: true
  },
  mediaType: {
    type: String,
    enum: ['text', 'image', 'video', 'audio'],
    default: 'text'
  },
  mediaUrl: {
    type: String,
    default: null
  },
  mediaDuration: {
    type: Number, // For audio/video duration in seconds
    default: null
  },
  likes: [{
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User'
    },
    likedAt: {
      type: Date,
      default: Date.now
    }
  }],
  comments: [{
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true
    },
    content: {
      type: String,
      required: true,
      maxlength: 300
    },
    createdAt: {
      type: Date,
      default: Date.now
    }
  }],
  views: [{
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User'
    },
    viewedAt: {
      type: Date,
      default: Date.now
    }
  }],
  isVisible: {
    type: Boolean,
    default: true
  },
  isModerated: {
    type: Boolean,
    default: false
  },
  moderationStatus: {
    type: String,
    enum: ['pending', 'approved', 'rejected'],
    default: 'approved'
  }
}, {
  timestamps: true
});

// Virtual for like count
postSchema.virtual('likeCount').get(function() {
  return this.likes.length;
});

// Virtual for comment count
postSchema.virtual('commentCount').get(function() {
  return this.comments.length;
});

// Virtual for view count
postSchema.virtual('viewCount').get(function() {
  return this.views.length;
});

// Indexes
postSchema.index({ userId: 1, createdAt: -1 });
postSchema.index({ isVisible: 1, moderationStatus: 1, createdAt: -1 });

module.exports = mongoose.model('Post', postSchema);
```

### Emergency Alert Model (`models/EmergencyAlert.js`)
```javascript
const mongoose = require('mongoose');

const emergencyAlertSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  type: {
    type: String,
    enum: ['not_feeling_well', 'need_help', 'want_to_talk'],
    required: true
  },
  message: {
    type: String,
    maxlength: 500,
    trim: true
  },
  location: {
    latitude: {
      type: Number,
      required: false
    },
    longitude: {
      type: Number,
      required: false
    },
    address: {
      type: String,
      trim: true
    }
  },
  status: {
    type: String,
    enum: ['active', 'resolved', 'cancelled'],
    default: 'active'
  },
  priority: {
    type: String,
    enum: ['low', 'medium', 'high', 'critical'],
    default: 'medium'
  },
  respondedBy: [{
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User'
    },
    respondedAt: {
      type: Date,
      default: Date.now
    },
    response: {
      type: String,
      maxlength: 300
    }
  }],
  resolvedAt: {
    type: Date,
    default: null
  },
  resolvedBy: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    default: null
  }
}, {
  timestamps: true
});

// Auto-resolve alerts after 24 hours
emergencyAlertSchema.methods.autoResolve = function() {
  const twentyFourHours = 24 * 60 * 60 * 1000;
  if (Date.now() - this.createdAt > twentyFourHours && this.status === 'active') {
    this.status = 'resolved';
    this.resolvedAt = new Date();
    return this.save();
  }
};

// Indexes
emergencyAlertSchema.index({ userId: 1, status: 1, createdAt: -1 });
emergencyAlertSchema.index({ status: 1, priority: -1, createdAt: -1 });

module.exports = mongoose.model('EmergencyAlert', emergencyAlertSchema);
```

## 🔐 API Endpoints

### Authentication Routes (`routes/auth.js`)

#### POST /api/auth/send-otp
Send OTP to phone number
```javascript
// Request Body
{
  "phoneNumber": "+919876543210"
}

// Response
{
  "success": true,
  "message": "OTP sent successfully",
  "expiresIn": 300
}
```

#### POST /api/auth/verify-otp
Verify OTP and authenticate user
```javascript
// Request Body
{
  "phoneNumber": "+919876543210",
  "otp": "123456",
  "name": "User Name" // Required for new users
}

// Response
{
  "success": true,
  "token": "jwt_token_here",
  "user": {
    "id": "user_id",
    "name": "User Name",
    "phoneNumber": "+919876543210",
    "isNewUser": false
  }
}
```

#### POST /api/auth/refresh-token
Refresh JWT token
```javascript
// Request Body
{
  "refreshToken": "refresh_token_here"
}

// Response
{
  "success": true,
  "token": "new_jwt_token",
  "refreshToken": "new_refresh_token"
}
```

### Post Routes (`routes/posts.js`)

#### GET /api/posts
Get posts for feed
```javascript
// Query Parameters: page, limit, userId
// Headers: Authorization: Bearer <token>

// Response
{
  "success": true,
  "posts": [
    {
      "id": "post_id",
      "user": {
        "id": "user_id",
        "name": "User Name",
        "profilePicture": "image_url"
      },
      "content": "Post content",
      "mediaType": "text",
      "mediaUrl": null,
      "likeCount": 5,
      "commentCount": 2,
      "viewCount": 10,
      "isLiked": false,
      "createdAt": "2024-01-01T00:00:00.000Z"
    }
  ],
  "pagination": {
    "currentPage": 1,
    "totalPages": 5,
    "totalPosts": 50,
    "hasNextPage": true
  }
}
```

#### POST /api/posts
Create new post
```javascript
// Request (multipart/form-data)
// Headers: Authorization: Bearer <token>
{
  "content": "Post content",
  "mediaType": "text|image|video|audio"
  // file: media file (if applicable)
}

// Response
{
  "success": true,
  "post": {
    "id": "post_id",
    "content": "Post content",
    "mediaType": "text",
    "createdAt": "2024-01-01T00:00:00.000Z"
  }
}
```

#### POST /api/posts/:postId/like
Like/unlike a post
```javascript
// Headers: Authorization: Bearer <token>

// Response
{
  "success": true,
  "isLiked": true,
  "likeCount": 6
}
```

#### POST /api/posts/:postId/view
Record post view
```javascript
// Headers: Authorization: Bearer <token>

// Response
{
  "success": true,
  "viewCount": 11
}
```

### Emergency Routes (`routes/emergency.js`)

#### POST /api/emergency/alert
Send emergency alert
```javascript
// Request Body
// Headers: Authorization: Bearer <token>
{
  "type": "not_feeling_well|need_help|want_to_talk",
  "message": "Optional message",
  "location": {
    "latitude": 28.6139,
    "longitude": 77.2090,
    "address": "New Delhi, India"
  }
}

// Response
{
  "success": true,
  "alert": {
    "id": "alert_id",
    "type": "need_help",
    "status": "active",
    "createdAt": "2024-01-01T00:00:00.000Z"
  }
}
```

#### GET /api/emergency/alerts
Get emergency alerts (for trust circle members)
```javascript
// Headers: Authorization: Bearer <token>
// Query: status=active|resolved|all

// Response
{
  "success": true,
  "alerts": [
    {
      "id": "alert_id",
      "user": {
        "id": "user_id",
        "name": "User Name"
      },
      "type": "need_help",
      "message": "Need help with groceries",
      "status": "active",
      "location": {
        "address": "New Delhi, India"
      },
      "createdAt": "2024-01-01T00:00:00.000Z"
    }
  ]
}
```

#### POST /api/emergency/alerts/:alertId/respond
Respond to emergency alert
```javascript
// Request Body
// Headers: Authorization: Bearer <token>
{
  "response": "I'm coming to help"
}

// Response
{
  "success": true,
  "message": "Response recorded successfully"
}
```

## 🔧 Middleware

### Authentication Middleware (`middleware/auth.js`)
```javascript
const jwt = require('jsonwebtoken');
const User = require('../models/User');

const authenticateToken = async (req, res, next) => {
  try {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1];

    if (!token) {
      return res.status(401).json({
        success: false,
        message: 'Access token required'
      });
    }

    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    const user = await User.findById(decoded.userId).select('-password');

    if (!user || !user.isActive) {
      return res.status(401).json({
        success: false,
        message: 'Invalid or expired token'
      });
    }

    req.user = user;
    next();
  } catch (error) {
    return res.status(403).json({
      success: false,
      message: 'Invalid token'
    });
  }
};

module.exports = { authenticateToken };
```

### Validation Middleware (`middleware/validation.js`)
```javascript
const { body, validationResult } = require('express-validator');

const validatePhoneNumber = [
  body('phoneNumber')
    .isMobilePhone('en-IN')
    .withMessage('Please provide a valid Indian phone number'),
  
  (req, res, next) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        message: 'Validation failed',
        errors: errors.array()
      });
    }
    next();
  }
];

const validatePostCreation = [
  body('content')
    .optional()
    .isLength({ max: 500 })
    .withMessage('Content cannot exceed 500 characters'),
  
  body('mediaType')
    .optional()
    .isIn(['text', 'image', 'video', 'audio'])
    .withMessage('Invalid media type'),
  
  (req, res, next) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        success: false,
        message: 'Validation failed',
        errors: errors.array()
      });
    }
    next();
  }
];

module.exports = {
  validatePhoneNumber,
  validatePostCreation
};
```

## 📱 Push Notification Service

### Notification Service (`services/notificationService.js`)
```javascript
const admin = require('firebase-admin');
const User = require('../models/User');

// Initialize Firebase Admin
const serviceAccount = require('../config/firebase-service-account.json');
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

class NotificationService {
  static async sendToUser(userId, notification) {
    try {
      const user = await User.findById(userId);
      if (!user || !user.fcmToken) {
        throw new Error('User not found or FCM token not available');
      }

      const message = {
        token: user.fcmToken,
        notification: {
          title: notification.title,
          body: notification.body
        },
        data: notification.data || {}
      };

      const response = await admin.messaging().send(message);
      console.log('Notification sent successfully:', response);
      return response;
    } catch (error) {
      console.error('Error sending notification:', error);
      throw error;
    }
  }

  static async sendToTrustCircle(userId, notification) {
    try {
      const user = await User.findById(userId).populate('trustCircle');
      const tokens = user.trustCircle
        .filter(member => member.fcmToken)
        .map(member => member.fcmToken);

      if (tokens.length === 0) {
        throw new Error('No FCM tokens found for trust circle');
      }

      const message = {
        tokens: tokens,
        notification: {
          title: notification.title,
          body: notification.body
        },
        data: notification.data || {}
      };

      const response = await admin.messaging().sendMulticast(message);
      console.log('Notifications sent to trust circle:', response);
      return response;
    } catch (error) {
      console.error('Error sending notifications to trust circle:', error);
      throw error;
    }
  }

  static async sendEmergencyAlert(alert) {
    const notification = {
      title: 'Emergency Alert',
      body: `${alert.user.name} needs help: ${alert.type.replace('_', ' ')}`,
      data: {
        type: 'emergency',
        alertId: alert._id.toString(),
        alertType: alert.type
      }
    };

    return this.sendToTrustCircle(alert.userId, notification);
  }
}

module.exports = NotificationService;
```

## 🚀 Deployment

### Production Setup

1. **Environment Variables for Production**
```env
NODE_ENV=production
PORT=3000
MONGODB_URI=mongodb+srv://username:password@cluster.mongodb.net/hoslavarta
JWT_SECRET=super_secure_production_secret
# ... other production configs
```

2. **Docker Deployment**
```dockerfile
FROM node:16-alpine

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci --only=production

# Copy source code
COPY . .

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:3000/health || exit 1

# Start the application
CMD ["npm", "start"]
```

3. **docker-compose.yml**
```yaml
version: '3.8'

services:
  app:
    build: .
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
      - MONGODB_URI=mongodb://mongo:27017/hoslavarta
    depends_on:
      - mongo
      - redis

  mongo:
    image: mongo:5.0
    volumes:
      - mongo_data:/data/db
    ports:
      - "27017:27017"

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"

volumes:
  mongo_data:
```

## 🧪 Testing

### Unit Tests Example (`tests/auth.test.js`)
```javascript
const request = require('supertest');
const app = require('../server');
const User = require('../models/User');

describe('Authentication Endpoints', () => {
  beforeEach(async () => {
    await User.deleteMany({});
  });

  describe('POST /api/auth/send-otp', () => {
    it('should send OTP for valid phone number', async () => {
      const response = await request(app)
        .post('/api/auth/send-otp')
        .send({ phoneNumber: '+919876543210' });

      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);
      expect(response.body.message).toBe('OTP sent successfully');
    });

    it('should return error for invalid phone number', async () => {
      const response = await request(app)
        .post('/api/auth/send-otp')
        .send({ phoneNumber: 'invalid' });

      expect(response.status).toBe(400);
      expect(response.body.success).toBe(false);
    });
  });
});
```

## 📊 Monitoring and Logging

### Logging Setup (`utils/logger.js`)
```javascript
const winston = require('winston');

const logger = winston.createLogger({
  level: process.env.NODE_ENV === 'production' ? 'info' : 'debug',
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.errors({ stack: true }),
    winston.format.json()
  ),
  defaultMeta: { service: 'hosla-varta-api' },
  transports: [
    new winston.transports.File({ filename: 'logs/error.log', level: 'error' }),
    new winston.transports.File({ filename: 'logs/combined.log' })
  ]
});

if (process.env.NODE_ENV !== 'production') {
  logger.add(new winston.transports.Console({
    format: winston.format.simple()
  }));
}

module.exports = logger;
```

---

This backend documentation provides a comprehensive foundation for the Hosla Varta API. The structure is designed to be scalable, maintainable, and secure, with proper error handling, validation, and monitoring capabilities.
