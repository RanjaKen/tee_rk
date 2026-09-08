import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Typography scale: strong, tight, uppercase-friendly.
///
/// Uses the platform grotesque (Roboto / SF) with heavy weights and
/// negative tracking on large sizes, wide tracking on small caps labels.
class AppTypography {
  const AppTypography._();

  /// Big editorial statements ("UNDEFEATED FALL DROP" style banners).
  static const TextStyle display = TextStyle(
    fontSize: 30,
    height: 1.05,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.6,
    color: AppColors.textPrimary,
  );

  /// Screen / section titles.
  static const TextStyle headline = TextStyle(
    fontSize: 20,
    height: 1.15,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.2,
    color: AppColors.textPrimary,
  );

  /// Card titles, list rows.
  static const TextStyle title = TextStyle(
    fontSize: 15,
    height: 1.25,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.1,
    color: AppColors.textPrimary,
  );

  /// Small caps label: nav items, chips, section eyebrows.
  static const TextStyle label = TextStyle(
    fontSize: 11,
    height: 1.2,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.2,
    color: AppColors.textPrimary,
  );

  /// Even smaller caps (badges, meta).
  static const TextStyle labelSmall = TextStyle(
    fontSize: 9.5,
    height: 1.2,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.0,
    color: AppColors.textSecondary,
  );

  static const TextStyle body = TextStyle(
    fontSize: 14,
    height: 1.45,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    height: 1.4,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  /// Prices are typographically distinct from product names.
  static const TextStyle price = TextStyle(
    fontSize: 13,
    height: 1.2,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.3,
    color: AppColors.textPrimary,
  );

  /// Button text.
  static const TextStyle button = TextStyle(
    fontSize: 13,
    height: 1.1,
    fontWeight: FontWeight.w800,
    letterSpacing: 1.4,
    color: AppColors.onAccent,
  );
}
