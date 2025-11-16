import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors (untuk onboarding, auth screens)
  static const Color primaryPurple = Color(0xFF512DA8);
  static const Color darkPurple = Color(0xFF6A1B9A);
  static const Color lightPurple = Color(0xFF9C7FC9);
  static const Color veryLightPurple = Color(0xFFE1BEE7);

  // Text Colors
  static const Color textPrimary = Color(0xFF000000);
  static const Color textBlack = Color(0xFF0F0F0F);
  static const Color textSecondary = Color(0xFF7E7E7E);
  static const Color textDisabled = Color(0xFFBDBDBD);

  // Border & Input Colors
  static const Color borderDefault = Color(0xFFE0E0E0);
  static const Color borderFocused = primaryPurple;
  static const Color borderError = Colors.red; // Dari red.shade600

  // Background Colors
  static const Color backgroundWhite = Colors.white;
  static const Color backgroundGrey = Color(0xFFF5F5F5);

  // Status Colors
  static const Color success = Colors.green;
  static const Color error = Colors.red;

  // Gradient Colors (untuk splash & onboarding)
  static const List<Color> splashGradient = [
    Color(0xFF7E57C2),
    Color(0xFF673AB7),
    Color(0xFF512DA8),
    Color(0xFF4527A0),
  ];
}