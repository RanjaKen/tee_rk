import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/price_formatter.dart';
import '../../models/price_range.dart';
import '../../models/sort_option.dart';
import '../../providers/catalog_filter_providers.dart';

/// Bottom sheet holding the price window and the sort order.
///
/// Changes apply immediately to [filteredProductsProvider]; the sheet only
/// reads and writes the providers.
class FilterSortSheet extends ConsumerWidget {
  const FilterSortSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusLg),
        ),
      ),
      builder: (_) => const FilterSortSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bounds = ref.watch(priceBoundsProvider);
    final range = ref.watch(effectivePriceRangeProvider);
    final sort = ref.watch(sortOptionProvider);
    final canSlide = bounds.max > bounds.min;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.page),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text('FILTER & SORT', style: AppTypography.headline),
                ),
                TextButton(
                  onPressed: () {
                    ref.read(priceRangeProvider.notifier).clear();
                    ref.read(categoryFilterProvider.notifier).clear();
                    ref.read(sortOptionProvider.notifier).reset();
                  },
                  child: Text(
                    'RESET',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.accent,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            Text('PRICE', style: AppTypography.label),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '${PriceFormatter.format(range.min)} — '
              '${PriceFormatter.format(range.max)}',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            RangeSlider(
              min: bounds.min.toDouble(),
              max: canSlide ? bounds.max.toDouble() : bounds.min + 1,
              divisions: canSlide ? 20 : null,
              activeColor: AppColors.accent,
              inactiveColor: AppColors.surfaceAlt,
              values: RangeValues(
                range.min.toDouble().clamp(
                  bounds.min.toDouble(),
                  bounds.max.toDouble(),
                ),
                range.max.toDouble().clamp(
                  bounds.min.toDouble(),
                  bounds.max.toDouble(),
                ),
              ),
              labels: RangeLabels(
                PriceFormatter.grouped(range.min),
                PriceFormatter.grouped(range.max),
              ),
              onChanged: canSlide
                  ? (values) => ref
                        .read(priceRangeProvider.notifier)
                        .update(
                          PriceRange(
                            min: values.start.round(),
                            max: values.end.round(),
                          ),
                        )
                  : null,
            ),
            const SizedBox(height: AppSpacing.lg),
            const Divider(),
            const SizedBox(height: AppSpacing.lg),
            Text('SORT BY', style: AppTypography.label),
            const SizedBox(height: AppSpacing.sm),
            for (final option in SortOption.values)
              _SortRow(
                option: option,
                selected: option == sort,
                onTap: () =>
                    ref.read(sortOptionProvider.notifier).select(option),
              ),
            const SizedBox(height: AppSpacing.xl),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('SHOW RESULTS'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SortRow extends StatelessWidget {
  const _SortRow({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final SortOption option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              size: 17,
              color: selected ? AppColors.accent : AppColors.textMuted,
            ),
            const SizedBox(width: AppSpacing.md),
            Text(
              option.label,
              style: AppTypography.labelSmall.copyWith(
                color: selected ? AppColors.textPrimary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
