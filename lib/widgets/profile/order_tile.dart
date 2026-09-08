import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/price_formatter.dart';
import '../../models/order.dart';
import '../product/product_image.dart';

/// One order in the history: reference, status, thumbnails and total.
class OrderTile extends StatelessWidget {
  const OrderTile({super.key, required this.order, this.onTapLine});

  final Order order;
  final void Function(OrderLine line)? onTapLine;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(order.reference, style: AppTypography.label),
              ),
              _StatusPill(status: order.status),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '${_formatDate(order.placedAt)}  ·  ${order.itemCount} '
            '${order.itemCount == 1 ? 'item' : 'items'}',
            style: AppTypography.bodySmall,
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: 64,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: order.lines.length,
              separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
              itemBuilder: (context, index) {
                final line = order.lines[index];
                return GestureDetector(
                  onTap: onTapLine == null ? null : () => onTapLine!(line),
                  child: SizedBox(
                    height: 64,
                    width: 52,
                    child: ProductImage(path: line.image),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          const Divider(),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('TOTAL', style: AppTypography.labelSmall),
              Text(
                PriceFormatter.format(order.total),
                style: AppTypography.price,
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day.$month.${date.year}';
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});

  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      OrderStatus.processing => AppColors.warning,
      OrderStatus.shipped => AppColors.textSecondary,
      OrderStatus.delivered => AppColors.success,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 3),
      decoration: BoxDecoration(
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
      ),
      child: Text(
        status.label,
        style: AppTypography.labelSmall.copyWith(color: color, fontSize: 8.5),
      ),
    );
  }
}
