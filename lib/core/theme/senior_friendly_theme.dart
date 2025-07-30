import 'package:flutter/material.dart';

/// Senior-friendly color themes optimized for older adults
/// Features: High contrast, warm colors, easy on the eyes
class SeniorFriendlyTheme {
  // Primary warm theme - better visibility and comfort for seniors
  static const Color warmBlue = Color(0xFF2196F3);  // Softer than teal, high contrast
  static const Color warmCream = Color(0xFFFFFBF0);  // Warmer, less stark than white
  static const Color softLavender = Color(0xFFE8E4F3);  // Gentle accent color
  static const Color darkNavy = Color(0xFF1A237E);  // Strong contrast for text
  static const Color warmGray = Color(0xFF424242);  // Readable gray
  
  // Emergency and action colors (high visibility)
  static const Color emergencyRed = Color(0xFFE53935);  // Clear warning color
  static const Color successGreen = Color(0xFF43A047);  // Positive feedback
  static const Color warningAmber = Color(0xFFFF8F00);  // Attention color
  static const Color infoBlue = Color(0xFF1E88E5);  // Information color
  
  // Text colors (high contrast)
  static const Color primaryText = Color(0xFF212121);
  static const Color secondaryText = Color(0xFF757575);
  static const Color disabledText = Color(0xFFBDBDBD);
  
  // Background variations
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color surfaceBackground = Color(0xFFFAFAFA);
  static const Color dividerColor = Color(0xFFE0E0E0);

  static ThemeData get warmTheme => _buildWarmTheme();
  
  // Alternative high contrast theme for users with vision difficulties
  static ThemeData get highContrastTheme => _buildHighContrastTheme();

  static ThemeData _buildWarmTheme() {
    const ColorScheme colorScheme = ColorScheme.light(
      primary: warmBlue,
      secondary: softLavender,
      surface: cardBackground,
      background: warmCream,
      error: emergencyRed,
      onPrimary: Colors.white,
      onSecondary: primaryText,
      onSurface: primaryText,
      onBackground: primaryText,
      onError: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      fontFamily: 'Roboto', // Good readability for seniors
      
      // Scaffold background
      scaffoldBackgroundColor: warmCream,

      // App Bar Theme - warm blue with good contrast
      appBarTheme: const AppBarTheme(
        backgroundColor: warmBlue,
        foregroundColor: Colors.white,
        elevation: 4, // Slight shadow for depth perception
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),

      // Text Theme - larger, more readable fonts
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 32, // Larger for better visibility
          fontWeight: FontWeight.bold,
          color: primaryText,
        ),
        headlineMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: primaryText,
        ),
        bodyLarge: TextStyle(
          fontSize: 20, // Increased from 18
          color: primaryText,
          fontWeight: FontWeight.w400,
        ),
        bodyMedium: TextStyle(
          fontSize: 18, // Increased from 16
          color: primaryText,
          fontWeight: FontWeight.w400,
        ),
        bodySmall: TextStyle(
          fontSize: 16, // Minimum readable size
          color: secondaryText,
        ),
      ),

      // Button Themes - larger touch targets
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: warmBlue,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 60), // Larger buttons
          textStyle: const TextStyle(
            fontSize: 20, // Larger button text
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
        ),
      ),

      // Card Theme - soft shadows, rounded corners
      cardTheme: CardThemeData(
        color: cardBackground,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),

      // Bottom Navigation - high contrast
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: cardBackground,
        elevation: 8,
        selectedItemColor: warmBlue,
        unselectedItemColor: warmGray,
        selectedLabelStyle: TextStyle(
          fontSize: 16, // Larger labels
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 14,
        ),
        type: BottomNavigationBarType.fixed,
      ),

      // Floating Action Button
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: warmBlue,
        foregroundColor: Colors.white,
        elevation: 6,
      ),

      // Input fields - clear borders and backgrounds
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: dividerColor, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: dividerColor, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: warmBlue, width: 3),
        ),
        labelStyle: const TextStyle(
          fontSize: 18,
          color: secondaryText,
        ),
        hintStyle: const TextStyle(
          fontSize: 18,
          color: secondaryText,
        ),
      ),
    );
  }

  static ThemeData _buildHighContrastTheme() {
    // High contrast theme for users with visual impairments
    const ColorScheme colorScheme = ColorScheme.light(
      primary: Color(0xFF000000), // Pure black
      secondary: Color(0xFF757575),
      surface: Color(0xFFFFFFFF), // Pure white
      background: Color(0xFFFFFFFF),
      error: Color(0xFFD32F2F),
      onPrimary: Color(0xFFFFFFFF),
      onSecondary: Color(0xFF000000),
      onSurface: Color(0xFF000000),
      onBackground: Color(0xFF000000),
      onError: Color(0xFFFFFFFF),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      fontFamily: 'Roboto',
      
      scaffoldBackgroundColor: Colors.white,

      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF000000),
        foregroundColor: Color(0xFFFFFFFF),
        elevation: 4,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Color(0xFFFFFFFF),
        ),
      ),

      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 34,
          fontWeight: FontWeight.bold,
          color: Color(0xFF000000),
        ),
        headlineMedium: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.bold,
          color: Color(0xFF000000),
        ),
        bodyLarge: TextStyle(
          fontSize: 22,
          color: Color(0xFF000000),
          fontWeight: FontWeight.w500,
        ),
        bodyMedium: TextStyle(
          fontSize: 20,
          color: Color(0xFF000000),
          fontWeight: FontWeight.w500,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF000000),
          foregroundColor: const Color(0xFFFFFFFF),
          minimumSize: const Size(double.infinity, 64),
          textStyle: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: Color(0xFF000000), width: 3),
          ),
          elevation: 6,
        ),
      ),

      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFF000000), width: 2),
        ),
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFFFFFFFF),
        elevation: 8,
        selectedItemColor: Color(0xFF000000),
        unselectedItemColor: Color(0xFF757575),
        selectedLabelStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
