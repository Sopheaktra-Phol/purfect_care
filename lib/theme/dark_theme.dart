import 'package:flutter/material.dart';

class DarkTheme {
  // Dark theme colors - Improved for better contrast and visual appeal
  static const Color darkPrimary = Color(0xFF4CAF8F); // Lighter green for better visibility
  static const Color darkBackground = Color(0xFF0D1117); // Slightly warmer dark background
  static const Color darkSurface = Color(0xFF161B22); // Card/surface color with better contrast
  static const Color darkSurfaceVariant = Color(0xFF21262D); // Elevated surfaces
  static const Color darkOnPrimary = Color(0xFFFFFFFF); // White text on primary (better contrast)
  static const Color darkOnSurface = Color(0xFFE6EDF3); // Softer white for text (easier on eyes)
  static const Color darkTextSecondary = Color(0xFF8B949E); // Better secondary text color
  static const Color darkAccentOrange = Color(0xFFFFA726); // Lighter orange for dark mode
  static const Color darkBorder = Color(0xFF30363D); // Subtle borders

  static ThemeData getTheme() {
    return ThemeData(
      useMaterial3: false,
      primaryColor: darkPrimary,
      scaffoldBackgroundColor: darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: darkPrimary,
        secondary: Color(0xFF9AA5C7), // Slate blue for secondary
        surface: darkSurface,
        background: darkBackground,
        tertiary: darkAccentOrange, // Lighter orange for accents
        error: Color(0xFFF85149), // Softer red for errors
        onPrimary: darkOnPrimary,
        onSecondary: Color(0xFF0D1117), // Dark text on secondary
        onSurface: darkOnSurface,
        onBackground: darkOnSurface,
        surfaceVariant: darkSurfaceVariant,
        onSurfaceVariant: darkTextSecondary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkSurfaceVariant, // Slightly elevated for better distinction
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: darkOnSurface, size: 24),
        titleTextStyle: TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w700,
          fontSize: 20,
          color: darkOnSurface,
          letterSpacing: 0.5,
        ),
      ),
      cardTheme: CardThemeData(
        color: darkSurfaceVariant, // Better contrast for cards
        elevation: 2,
        shadowColor: const Color(0x50000000),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: darkBorder, width: 0.5), // Subtle border
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: darkPrimary,
          foregroundColor: darkOnPrimary, // White text on primary
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 16,
            letterSpacing: 0.5,
          ),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: darkSurface,
        selectedItemColor: darkPrimary,
        unselectedItemColor: darkTextSecondary,
        selectedLabelStyle: TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w600,
          fontSize: 10,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w500,
          fontSize: 10,
        ),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurface, // Softer input background
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: darkBorder,
            width: 1.5,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: darkBorder,
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: darkPrimary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFFF85149),
            width: 1.5,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFFF85149),
            width: 2,
          ),
        ),
        labelStyle: const TextStyle(
          fontFamily: 'Poppins',
          color: darkTextSecondary,
          fontSize: 14,
        ),
        hintStyle: TextStyle(
          fontFamily: 'Poppins',
          color: darkTextSecondary.withOpacity(0.7),
          fontSize: 14,
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.bold,
          fontSize: 32,
          color: darkOnSurface,
          letterSpacing: -0.5,
        ),
        displayMedium: TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.bold,
          fontSize: 28,
          color: darkOnSurface,
          letterSpacing: -0.5,
        ),
        displaySmall: TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.bold,
          fontSize: 24,
          color: darkOnSurface,
          letterSpacing: 0,
        ),
        headlineLarge: TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.bold,
          fontSize: 24,
          color: darkOnSurface,
          letterSpacing: 0,
        ),
        headlineMedium: TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w600,
          fontSize: 20,
          color: darkOnSurface,
          letterSpacing: 0,
        ),
        headlineSmall: TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w600,
          fontSize: 18,
          color: darkOnSurface,
          letterSpacing: 0,
        ),
        titleLarge: TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.bold,
          fontSize: 20,
          color: darkOnSurface,
          letterSpacing: 0.15,
        ),
        titleMedium: TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w600,
          fontSize: 18,
          color: darkOnSurface,
          letterSpacing: 0.15,
        ),
        titleSmall: TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w600,
          fontSize: 16,
          color: darkOnSurface,
          letterSpacing: 0.1,
        ),
        bodyLarge: TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.normal,
          fontSize: 18,
          color: darkOnSurface,
          letterSpacing: 0.15,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.normal,
          fontSize: 16,
          color: darkOnSurface,
          letterSpacing: 0.25,
        ),
        bodySmall: TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.normal,
          fontSize: 14,
          color: darkTextSecondary,
          letterSpacing: 0.4,
        ),
        labelLarge: TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w600,
          fontSize: 16,
          color: darkOnSurface,
          letterSpacing: 0.5,
        ),
        labelMedium: TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w500,
          fontSize: 14,
          color: darkOnSurface,
          letterSpacing: 0.5,
        ),
        labelSmall: TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w500,
          fontSize: 12,
          color: darkTextSecondary,
          letterSpacing: 0.5,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: darkBorder,
        thickness: 1,
        space: 1,
      ),
      iconTheme: const IconThemeData(
        color: darkOnSurface,
        size: 24,
      ),
    );
  }
}

