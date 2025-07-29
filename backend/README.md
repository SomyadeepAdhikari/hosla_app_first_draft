# Hosla Varta Backend API

A comprehensive Node.js/Express.js backend API for the Hosla Varta senior citizens social platform.

## 🚀 Quick Start

1. **Install Dependencies**
   ```bash
   npm install
   ```

2. **Setup Configuration**
   ```bash
   npm run setup
   ```

3. **Start Development Server**
   ```bash
   npm run dev
   ```

## 📋 Prerequisites

- **Node.js** (v16.0.0 or higher)
- **MongoDB** (v4.4 or higher)
- **npm** or **yarn**

## 🔧 Configuration

### Environment Variables

Copy `.env` and configure the following:

```env
# Database
MONGODB_URI=mongodb://localhost:27017/hoslavarta

# JWT Authentication
JWT_SECRET=your_secure_jwt_secret

# Cloudinary (File Upload)
CLOUDINARY_CLOUD_NAME=your_cloudinary_cloud_name
CLOUDINARY_API_KEY=your_cloudinary_api_key
CLOUDINARY_API_SECRET=your_cloudinary_api_secret

# Twilio (SMS/OTP)
TWILIO_ACCOUNT_SID=your_twilio_account_sid
TWILIO_AUTH_TOKEN=your_twilio_auth_token
TWILIO_PHONE_NUMBER=your_twilio_phone_number
```

### Required External Services

1. **MongoDB**: Database storage
2. **Cloudinary**: Image/video upload service
3. **Twilio**: SMS/OTP service
4. **Firebase** (optional): Push notifications

## 📁 Project Structure

```
backend/
├── config/           # Configuration files
├── middleware/       # Express middleware
├── models/          # MongoDB/Mongoose models
├── routes/          # API routes
├── services/        # Business logic services
├── utils/           # Utility functions
├── logs/            # Application logs
├── .env             # Environment variables
├── server.js        # Main application entry
└── package.json     # Dependencies and scripts
```

## 🛠️ Available Scripts

- `npm start` - Start production server
- `npm run dev` - Start development server with auto-reload
- `npm run setup` - Check configuration and setup
- `npm test` - Run tests
- `npm run lint` - Run ESLint
- `npm run format` - Format code with Prettier

## 📚 API Endpoints

### Authentication
- `POST /api/auth/send-otp` - Send OTP for login/registration
- `POST /api/auth/verify-otp` - Verify OTP and authenticate

### User Management
- `GET /api/users/profile` - Get user profile
- `PUT /api/users/profile` - Update profile
- `POST /api/users/follow/:userId` - Follow/unfollow user

### Social Features
- `GET /api/posts` - Get posts feed
- `POST /api/posts` - Create new post
- `POST /api/posts/:id/like` - Like/unlike post
- `POST /api/posts/:id/comment` - Add comment

### Emergency System
- `POST /api/emergency/alert` - Create emergency alert
- `GET /api/emergency/alerts` - Get emergency alerts

### Events
- `GET /api/events` - Get community events
- `POST /api/events` - Create new event

### Chat System
- `GET /api/chats` - Get user's chats
- `POST /api/chats/:id/messages` - Send message

### File Upload
- `POST /api/upload/profile-picture` - Upload profile picture
- `POST /api/upload/post-media` - Upload post media

## 🔐 Authentication

The API uses JWT tokens with OTP-based phone number authentication:

1. Send OTP to phone number
2. Verify OTP to receive JWT token
3. Include token in Authorization header: `Bearer <token>`

## 🛡️ Security Features

- JWT token authentication
- Input validation and sanitization
- Rate limiting
- CORS protection
- Helmet security headers
- Content moderation

## 🌐 Senior Citizen Features

- Hindi language support
- Age validation (50+)
- Emergency alert system
- Trust circles for family safety
- Simple API design
- Large font preferences support

## 📊 Monitoring

- Health check: `GET /health`
- Structured logging with Winston
- Error tracking and reporting

## 🧪 Testing

Run tests with:
```bash
npm test
```

## 🚀 Deployment

### Development
```bash
npm run dev
```

### Production
```bash
NODE_ENV=production npm start
```

## � Support

For support, please check:
1. Run `npm run setup` for configuration issues
2. Check logs in `/logs` directory
3. Verify environment variables in `.env`

---

**होसला वार्ता** - Empowering senior citizens through technology and community connection.
