#!/bin/bash
# Script to install the correct cloudinary storage package

echo "Installing multer-storage-cloudinary..."
npm install multer-storage-cloudinary

echo "Checking if installation was successful..."
npm list multer-storage-cloudinary

echo "Starting server..."
npm run dev
