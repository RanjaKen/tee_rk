import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/price_formatter.dart';

/// Renders an Ariary amount with the app price typography.
class PriceText extends StatelessWidget {
  const PriceText(
    this.amount, {
    super.key,
    this.size = PriceSize.medium,
    this.color,
  });

  final int amount;
  final PriceSize size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final style = switch (size) {
      PriceSize.small => AppTypography.price.copyWith(fontSize: 11.5),
      PriceSize.medium => AppTypography.price,
      PriceSize.large => AppTypography.price.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w800,
        letterSpacing: 0,
      ),
    };

    return Text(
      PriceFormatter.format(amount),
      style: style.copyWith(color: color ?? AppColors.textPrimary),
    );
  }
}

enum PriceSize { small, medium, large }
