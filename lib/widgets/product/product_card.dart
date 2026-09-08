import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../models/product.dart';
import 'price_text.dart';
import 'product_image.dart';

/// Catalog tile: large image, price, uppercase name.
///
/// Pure presentation — it receives a [Product] and callbacks, and knows
/// nothing about providers.
class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.isFavorite = false,
    this.onToggleFavorite,
    this.useHero = true,
  });

  final Product product;
  final VoidCallback? onTap;

  /// Wired to the favorites provider in Step 6.
  final bool isFavorite;
  final VoidCallback? onToggleFavorite;

  /// Hero tags must be unique per screen: disable this when the same
  /// product can appear twice in one page (home feed).
  final bool useHero;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                ProductImage(
                  path: product.image,
                  heroTag: useHero ? 'product-${product.id}' : null,
                ),
                Positioned(
                  top: AppSpacing.sm,
                  left: AppSpacing.sm,
                  child: _Badges(product: product),
                ),
                if (onToggleFavorite != null)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: IconButton(
                      onPressed: onToggleFavorite,
                      iconSize: 18,
                      visualDensity: VisualDensity.compact,
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite
                            ? AppColors.accent
                            : AppColors.textPrimary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          PriceText(product.price, size: PriceSize.small),
          const SizedBox(height: AppSpacing.xs),
          Text(
            product.name.toUpperCase(),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textSecondary,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

/// NEW / SOLD OUT flags drawn over the image.
class _Badges extends StatelessWidget {
  const _Badges({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final badges = <Widget>[
      if (!product.inStock)
        const _Badge(label: 'SOLD OUT', background: AppColors.overlay),
      if (product.isNew && product.inStock)
        const _Badge(label: 'NEW', background: AppColors.accent),
    ];

    if (badges.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final badge in badges) ...[badge, const SizedBox(height: 4)],
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.background});

  final String label;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      color: background,
      child: Text(
        label,
        style: AppTypography.labelSmall.copyWith(
          color: AppColors.textPrimary,
          fontSize: 8.5,
        ),
      ),
    );
  }
}
