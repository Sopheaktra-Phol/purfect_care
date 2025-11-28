import 'package:flutter/material.dart';
import 'app_theme.dart';

class LightTheme {
  static ThemeData getTheme() {
    return ThemeData(
      useMaterial3: false,
      primaryColor: AppTheme.primary,
      scaffoldBackgroundColor: AppTheme.background,
      colorScheme: const ColorScheme.light(
        primary: AppTheme.primary,
        secondary: AppTheme.secondary,
        surface: AppTheme.cardBackground,
        background: AppTheme.background,
        tertiary: AppTheme.accentOrange,
        error: AppTheme.accentRed,
        onPrimary: AppTheme.secondary,
        onSecondary: AppTheme.textPrimary,
        onSurface: AppTheme.textPrimary,
        onBackground: AppTheme.textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppTheme.primary,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: AppTheme.secondary, size: 24),
        titleTextStyle: TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w700,
          fontSize: 20,
          color: AppTheme.secondary,
          letterSpacing: 0.5,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppTheme.cardBackground,
        elevation: 4,
        shadowColor: AppTheme.shadowColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primary,
          foregroundColor: AppTheme.secondary,
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
        backgroundColor: AppTheme.primary,
        selectedItemColor: AppTheme.secondary,
        unselectedItemColor: AppTheme.secondary,
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
        fillColor: const Color(0xFFF5F5F5),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppTheme.borderColor,
            width: 1.5,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppTheme.borderColor,
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppTheme.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppTheme.accentRed,
            width: 1.5,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppTheme.accentRed,
            width: 2,
          ),
        ),
        labelStyle: const TextStyle(
          fontFamily: 'Poppins',
          color: AppTheme.textSecondary,
          fontSize: 14,
        ),
        hintStyle: TextStyle(
          fontFamily: 'Poppins',
          color: AppTheme.textSecondary.withOpacity(0.6),
          fontSize: 14,
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.bold,
          fontSize: 32,
          color: AppTheme.textPrimary,
          letterSpacing: -0.5,
        ),
        displayMedium: TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.bold,
          fontSize: 28,
          color: AppTheme.textPrimary,
          letterSpacing: -0.5,
        ),
        displaySmall: TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.bold,
          fontSize: 24,
          color: AppTheme.textPrimary,
          letterSpacing: 0,
        ),
        headlineLarge: TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.bold,
          fontSize: 24,
          color: AppTheme.textPrimary,
          letterSpacing: 0,
        ),
        headlineMedium: TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w600,
          fontSize: 20,
          color: AppTheme.textPrimary,
          letterSpacing: 0,
        ),
        headlineSmall: TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w600,
          fontSize: 18,
          color: AppTheme.textPrimary,
          letterSpacing: 0,
        ),
        titleLarge: TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.bold,
          fontSize: 20,
          color: AppTheme.textPrimary,
          letterSpacing: 0.15,
        ),
        titleMedium: TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w600,
          fontSize: 18,
          color: AppTheme.textPrimary,
          letterSpacing: 0.15,
        ),
        titleSmall: TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w600,
          fontSize: 16,
          color: AppTheme.textPrimary,
          letterSpacing: 0.1,
        ),
        bodyLarge: TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.normal,
          fontSize: 18,
          color: AppTheme.textPrimary,
          letterSpacing: 0.15,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.normal,
          fontSize: 16,
          color: AppTheme.textPrimary,
          letterSpacing: 0.25,
        ),
        bodySmall: TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.normal,
          fontSize: 14,
          color: AppTheme.textSecondary,
          letterSpacing: 0.4,
        ),
        labelLarge: TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w600,
          fontSize: 16,
          color: AppTheme.textPrimary,
          letterSpacing: 0.5,
        ),
        labelMedium: TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w500,
          fontSize: 14,
          color: AppTheme.textPrimary,
          letterSpacing: 0.5,
        ),
        labelSmall: TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w500,
          fontSize: 12,
          color: AppTheme.textSecondary,
          letterSpacing: 0.5,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppTheme.borderColor,
        thickness: 1,
        space: 1,
      ),
      iconTheme: const IconThemeData(
        color: AppTheme.textPrimary,
        size: 24,
      ),
    );
  }
}

