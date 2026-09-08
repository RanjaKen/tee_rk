import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../models/cart_item.dart';
import '../common/quantity_stepper.dart';
import '../product/price_text.dart';
import '../product/product_image.dart';

/// One row of the bag: thumbnail, name, size, stepper and line total.
class CartLineTile extends StatelessWidget {
  const CartLineTile({
    super.key,
    required this.item,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
    this.onTap,
  });

  final CartItem item;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onRemove;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final atStockCeiling = item.quantity >= item.product.stock;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 110,
              width: 84,
              child: ProductImage(path: item.product.image),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          item.product.name.toUpperCase(),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.title.copyWith(fontSize: 13),
                        ),
                      ),
                      InkWell(
                        onTap: onRemove,
                        child: const Padding(
                          padding: EdgeInsets.only(left: AppSpacing.sm),
                          child: Icon(
                            Icons.close,
                            size: 16,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'SIZE ${item.size}  ·  ${item.product.brand.toUpperCase()}',
                    style: AppTypography.labelSmall,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      QuantityStepper(
                        quantity: item.quantity,
                        canIncrement: !atStockCeiling,
                        onIncrement: onIncrement,
                        onDecrement: onDecrement,
                      ),
                      const Spacer(),
                      PriceText(item.lineTotal),
                    ],
                  ),
                  if (atStockCeiling) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'MAX STOCK REACHED',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.warning,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
