#!/usr/bin/env node

const fs = require('fs');
const path = require('path');
const readline = require('readline');

const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout
});

console.log('🍃 MongoDB Atlas Quick Setup for Hosla Varta\n');

console.log('This script will help you configure MongoDB Atlas (cloud database)');
console.log('Follow these steps first:\n');

console.log('1. Go to https://cloud.mongodb.com and create a free account');
console.log('2. Create a new cluster (free tier)');
console.log('3. Create a database user with read/write access');
console.log('4. Add your IP to network access (0.0.0.0/0 for development)');
console.log('5. Get your connection string from "Connect" → "Connect your application"');
console.log('\nExample connection string:');
console.log('mongodb+srv://username:password@cluster0.xxxxx.mongodb.net/hoslavarta\n');

rl.question('Enter your MongoDB Atlas connection string: ', (connectionString) => {
  if (!connectionString.trim()) {
    console.log('❌ No connection string provided. Exiting...');
    rl.close();
    return;
  }

  // Validate basic format
  if (!connectionString.startsWith('mongodb+srv://') && !connectionString.startsWith('mongodb://')) {
    console.log('❌ Invalid connection string format. Please check and try again.');
    rl.close();
    return;
  }

  // Read current .env file
  const envPath = path.join(__dirname, '.env');
  let envContent = fs.readFileSync(envPath, 'utf8');

  // Replace the MONGODB_URI line
  const updatedContent = envContent.replace(
    /^MONGODB_URI=.*$/m,
    `MONGODB_URI=${connectionString}`
  );

  // Write back to .env file
  fs.writeFileSync(envPath, updatedContent);

  console.log('\n✅ MongoDB connection string updated in .env file!');
  console.log('\n🧪 Testing connection...');

  // Test the connection
  require('dotenv').config();
  const mongoose = require('mongoose');

  mongoose.connect(connectionString, {
    useNewUrlParser: true,
    useUnifiedTopology: true,
    serverSelectionTimeoutMS: 5000,
  })
  .then(() => {
    console.log('✅ MongoDB Atlas connection successful!');
    console.log('\n🚀 You can now start your backend:');
    console.log('npm run dev');
    mongoose.connection.close();
    rl.close();
  })
  .catch((error) => {
    console.log('❌ Connection failed:', error.message);
    console.log('\n💡 Please check:');
    console.log('- Username and password are correct');
    console.log('- Network access is configured (add 0.0.0.0/0)');
    console.log('- Database user has read/write permissions');
    rl.close();
  });
});
