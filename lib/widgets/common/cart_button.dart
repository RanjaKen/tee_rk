import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/price_formatter.dart';

/// Primary call to action used for anything that puts items in the bag.
///
/// Disabled automatically when [onPressed] is null, so callers express
/// "sold out" or "pick a size" simply by passing null.
class CartButton extends StatelessWidget {
  const CartButton({
    super.key,
    required this.label,
    this.onPressed,
    this.price,
    this.icon = Icons.shopping_bag_outlined,
  });

  final String label;
  final VoidCallback? onPressed;

  /// Optional trailing amount in Ariary.
  final int? price;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 17),
            const SizedBox(width: AppSpacing.sm),
          ],
          Flexible(
            child: Text(
              label.toUpperCase(),
              overflow: TextOverflow.ellipsis,
              style: AppTypography.button,
            ),
          ),
          if (price != null) ...[
            const SizedBox(width: AppSpacing.sm),
            Text('·', style: AppTypography.button),
            const SizedBox(width: AppSpacing.sm),
            Text(PriceFormatter.format(price!), style: AppTypography.button),
          ],
        ],
      ),
    );
  }
}
