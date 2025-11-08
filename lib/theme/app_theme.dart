import 'package:flutter/material.dart';

class AppTheme {
  static const Color mint = Color(0xFFA8E6CF);
  static const Color lightBeige = Color(0xFFFFF3E0);
  static const Color lightPink = Color(0xFFFFD1DC);

  static ThemeData lightTheme() {
    return ThemeData(
      primaryColor: mint,
      scaffoldBackgroundColor: lightBeige,
      colorScheme: const ColorScheme.light(
        primary: mint,
        secondary: lightPink,
        surface: Colors.white,
        background: lightBeige,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: mint,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black87),
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: mint,
          foregroundColor: Colors.black87,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.bold,
          fontSize: 24,
          color: Colors.black87,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 16,
          color: Colors.black87,
        ),
      ),
    );
  }
}
