#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

console.log('🚀 Hosla Varta Backend Setup\n');

// Check if .env file exists
const envPath = path.join(__dirname, '.env');
if (!fs.existsSync(envPath)) {
  console.log('❌ .env file not found!');
  console.log('Please copy .env.example to .env and configure your credentials.');
  process.exit(1);
}

// Read .env file and check for placeholder values
const envContent = fs.readFileSync(envPath, 'utf8');
const placeholders = [
  'your_cloud_name',
  'your_api_key', 
  'your_api_secret',
  'your_twilio_sid',
  'your_twilio_token',
  'your_email@gmail.com',
  'your_firebase_server_key'
];

const hasPlaceholders = placeholders.some(placeholder => 
  envContent.includes(placeholder)
);

if (hasPlaceholders) {
  console.log('⚠️  Warning: Some environment variables still have placeholder values.');
  console.log('Please update your .env file with actual credentials:\n');
  console.log('📋 Required Services:');
  console.log('• MongoDB: Database connection');
  console.log('• Cloudinary: File upload service');
  console.log('• Twilio: SMS/OTP service');
  console.log('• Firebase (optional): Push notifications\n');
  console.log('💡 The server will start but some features may not work properly.');
}

// Test MongoDB connection
try {
  console.log('🔄 Testing configuration...');
  
  // Load environment variables
  require('dotenv').config();
  
  // Test basic imports
  require('./config/constants');
  require('./middleware/validation');
  require('./config/cloudinary');
  
  console.log('✅ All configurations loaded successfully!');
  console.log('\n🎯 Ready to start:');
  console.log('• Development: npm run dev');
  console.log('• Production: npm start');
  console.log('• Health check: http://localhost:3000/health');
  
} catch (error) {
  console.log('❌ Configuration error:', error.message);
  process.exit(1);
}
