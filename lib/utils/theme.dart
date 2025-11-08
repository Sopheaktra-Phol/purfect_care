import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData light() {
    const primary = Colors.teal;
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: primary),
      useMaterial3: true,
      appBarTheme: AppBarTheme(backgroundColor: primary),
      floatingActionButtonTheme: FloatingActionButtonThemeData(backgroundColor: primary),
    );
  }
}