import 'package:flutter/material.dart';
import '../config/app_config.dart';

class AppTheme {
  static ThemeData get lightTheme => _buildLightTheme();
  static ThemeData get darkTheme => _buildDarkTheme();

  static ThemeData _buildLightTheme() {
    const ColorScheme colorScheme = ColorScheme.light(
      primary: AppConfig.primaryTeal,
      secondary: AppConfig.softLavender,
      surface: Colors.white,
      background: AppConfig.lightCream,
      error: AppConfig.errorRed,
      onPrimary: Colors.white,
      onSecondary: Colors.black87,
      onSurface: Colors.black87,
      onBackground: Colors.black87,
      onError: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      fontFamily: 'Noto',

      // App Bar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: AppConfig.primaryTeal,
        foregroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: AppConfig.largeFontSize,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),

      // Text Theme (Large, accessible fonts)
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: AppConfig.extraLargeFontSize,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
        displayMedium: TextStyle(
          fontSize: 26.0,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
        displaySmall: TextStyle(
          fontSize: AppConfig.largeFontSize,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
        headlineLarge: TextStyle(
          fontSize: AppConfig.largeFontSize,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
        headlineMedium: TextStyle(
          fontSize: 20.0,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
        headlineSmall: TextStyle(
          fontSize: AppConfig.mediumFontSize,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
        bodyLarge: TextStyle(
          fontSize: AppConfig.mediumFontSize,
          fontWeight: FontWeight.normal,
          color: Colors.black87,
        ),
        bodyMedium: TextStyle(
          fontSize: AppConfig.smallFontSize,
          fontWeight: FontWeight.normal,
          color: Colors.black87,
        ),
        bodySmall: TextStyle(
          fontSize: 14.0,
          fontWeight: FontWeight.normal,
          color: Colors.black54,
        ),
      ),

      // Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConfig.primaryTeal,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, AppConfig.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConfig.borderRadius),
          ),
          textStyle: const TextStyle(
            fontSize: AppConfig.mediumFontSize,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppConfig.primaryTeal,
          minimumSize: const Size(double.infinity, AppConfig.buttonHeight),
          side: const BorderSide(color: AppConfig.primaryTeal, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConfig.borderRadius),
          ),
          textStyle: const TextStyle(
            fontSize: AppConfig.mediumFontSize,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConfig.cardBorderRadius),
        ),
        margin: const EdgeInsets.symmetric(
          horizontal: AppConfig.mediumSpacing,
          vertical: AppConfig.smallSpacing,
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConfig.borderRadius),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConfig.borderRadius),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConfig.borderRadius),
          borderSide: const BorderSide(color: AppConfig.primaryTeal, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConfig.borderRadius),
          borderSide: const BorderSide(color: AppConfig.errorRed, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppConfig.mediumSpacing,
          vertical: AppConfig.mediumSpacing,
        ),
        labelStyle: const TextStyle(fontSize: AppConfig.mediumFontSize),
        hintStyle: TextStyle(
          fontSize: AppConfig.mediumFontSize,
          color: Colors.grey[600],
        ),
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: AppConfig.primaryTeal,
        unselectedItemColor: AppConfig.warmGray,
        selectedLabelStyle: TextStyle(
          fontSize: AppConfig.smallFontSize,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: AppConfig.smallFontSize,
          fontWeight: FontWeight.normal,
        ),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // Floating Action Button Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppConfig.primaryTeal,
        foregroundColor: Colors.white,
        elevation: 6,
        extendedSizeConstraints: BoxConstraints(
          minHeight: AppConfig.buttonHeight,
        ),
      ),
    );
  }

  static ThemeData _buildDarkTheme() {
    const ColorScheme colorScheme = ColorScheme.dark(
      primary: AppConfig.primaryTeal,
      secondary: AppConfig.softLavender,
      surface: Color(0xFF1E1E1E),
      background: Color(0xFF121212),
      error: AppConfig.errorRed,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.white,
      onBackground: Colors.white,
      onError: Colors.white,
    );

    return _buildLightTheme().copyWith(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(0xFF121212),

      // Dark theme specific overrides
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1E1E1E),
        foregroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: AppConfig.largeFontSize,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),

      cardTheme: CardThemeData(
        color: const Color(0xFF1E1E1E),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConfig.cardBorderRadius),
        ),
        margin: const EdgeInsets.symmetric(
          horizontal: AppConfig.mediumSpacing,
          vertical: AppConfig.smallSpacing,
        ),
      ),

      textTheme: _buildLightTheme().textTheme.apply(
            bodyColor: Colors.white,
            displayColor: Colors.white,
          ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF1E1E1E),
        selectedItemColor: AppConfig.primaryTeal,
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: TextStyle(
          fontSize: AppConfig.smallFontSize,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: AppConfig.smallFontSize,
          fontWeight: FontWeight.normal,
        ),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }
}
