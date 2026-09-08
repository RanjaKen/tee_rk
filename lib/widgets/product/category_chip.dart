import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';

/// Selectable category pill used in the shop filter row.
class CategoryChip extends StatelessWidget {
  const CategoryChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.count,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  /// Optional number of matching products.
  final int? count;

  @override
  Widget build(BuildContext context) {
    final foreground = selected ? AppColors.background : AppColors.textPrimary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm + 2,
        ),
        decoration: BoxDecoration(
          color: selected ? AppColors.textPrimary : Colors.transparent,
          border: Border.all(
            color: selected ? AppColors.textPrimary : AppColors.border,
          ),
          borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label.toUpperCase(),
              style: AppTypography.labelSmall.copyWith(color: foreground),
            ),
            if (count != null) ...[
              const SizedBox(width: AppSpacing.xs),
              Text(
                '$count',
                style: AppTypography.labelSmall.copyWith(
                  color: selected ? AppColors.background : AppColors.textMuted,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
