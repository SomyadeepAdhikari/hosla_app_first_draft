import 'package:flutter/material.dart';

class AppConfig {
  static const String appName = 'Hosla Varta';
  static const String appVersion = '1.0.0';

  // API Configuration
  static const String baseUrl = 'https://api.hoslavarta.com';
  static const String apiVersion = 'v1';
  static const String apiUrl = '$baseUrl/api/$apiVersion';

  // Supported Languages
  static const List<Locale> supportedLocales = [
    Locale('en', 'US'), // English
    Locale('hi', 'IN'), // Hindi
    Locale('bn', 'IN'), // Bengali
    Locale('ta', 'IN'), // Tamil
    Locale('te', 'IN'), // Telugu
  ];

  // App Theme Colors (Senior-friendly)
  static const Color primaryTeal = Color(0xFF26A69A);
  static const Color lightCream = Color(0xFFFFF8E1);
  static const Color softLavender = Color(0xFFE1BEE7);
  static const Color warmGray = Color(0xFF757575);
  static const Color successGreen = Color(0xFF4CAF50);
  static const Color warningOrange = Color(0xFFFF9800);
  static const Color errorRed = Color(0xFFF44336);

  // Emergency Alert Colors
  static const Color sosRed = Color(0xFFD32F2F);
  static const Color helpOrange = Color(0xFFFF6F00);
  static const Color talkBlue = Color(0xFF1976D2);

  // Font Sizes (Accessible)
  static const double smallFontSize = 16.0;
  static const double mediumFontSize = 18.0;
  static const double largeFontSize = 22.0;
  static const double extraLargeFontSize = 28.0;

  // Spacing
  static const double smallSpacing = 8.0;
  static const double mediumSpacing = 16.0;
  static const double largeSpacing = 24.0;
  static const double extraLargeSpacing = 32.0;

  // Button Heights (Touch-friendly)
  static const double buttonHeight = 56.0;
  static const double smallButtonHeight = 48.0;

  // Border Radius
  static const double borderRadius = 12.0;
  static const double cardBorderRadius = 16.0;

  // App Features
  static const int maxTrustCircleMembers = 50;
  static const int maxPostLength = 500;
  static const int maxVoiceNoteDuration = 300; // 5 minutes
  static const int sosAlertDuration = 24; // 24 hours

  // File Upload Limits
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  static const int maxVideoSize = 50 * 1024 * 1024; // 50MB
  static const int maxAudioSize = 10 * 1024 * 1024; // 10MB
}
