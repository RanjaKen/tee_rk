import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../models/product.dart';
import 'product_card.dart';

/// Two column catalog grid as a sliver, so screens can compose it with
/// banners and headers inside a single [CustomScrollView].
class SliverProductGrid extends StatelessWidget {
  const SliverProductGrid({
    super.key,
    required this.products,
    this.onTapProduct,
    this.isFavorite,
    this.onToggleFavorite,
    this.useHero = true,
  });

  final List<Product> products;
  final void Function(Product product)? onTapProduct;
  final bool Function(Product product)? isFavorite;
  final void Function(Product product)? onToggleFavorite;
  final bool useHero;

  static const SliverGridDelegateWithFixedCrossAxisCount delegate =
      SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.xl,
        childAspectRatio: 0.62,
      );

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
      sliver: SliverGrid.builder(
        gridDelegate: delegate,
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return ProductCard(
            product: product,
            useHero: useHero,
            onTap: onTapProduct == null ? null : () => onTapProduct!(product),
            isFavorite: isFavorite?.call(product) ?? false,
            onToggleFavorite: onToggleFavorite == null
                ? null
                : () => onToggleFavorite!(product),
          );
        },
      ),
    );
  }
}
