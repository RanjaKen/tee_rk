import 'package:flutter/material.dart';

/// TEE_RK palette : dark / neutral premium streetwear.
///
/// Single source of truth for every color used in the app.
/// Widgets must never declare raw [Color] values.
class AppColors {
  const AppColors._();

  // Backgrounds
  static const Color background = Color(0xFF0B0B0C);
  static const Color surface = Color(0xFF131315);
  static const Color surfaceAlt = Color(0xFF1C1C1F);
  static const Color overlay = Color(0xCC0B0B0C);

  // Lines
  static const Color border = Color(0xFF2A2A2E);
  static const Color borderSoft = Color(0xFF1F1F23);

  // Text
  static const Color textPrimary = Color(0xFFF5F5F3);
  static const Color textSecondary = Color(0xFF9A9AA1);
  static const Color textMuted = Color(0xFF6B6B72);
  static const Color onAccent = Color(0xFFFFFFFF);

  // Brand
  static const Color accent = Color(0xFFE8452C);
  static const Color accentDark = Color(0xFFC0361F);

  // Feedback
  static const Color success = Color(0xFF3FA66A);
  static const Color danger = Color(0xFFE5484D);
  static const Color warning = Color(0xFFE9A23B);

  // Product imagery placeholder background
  static const Color imageBackdrop = Color(0xFF1A1A1D);
}
