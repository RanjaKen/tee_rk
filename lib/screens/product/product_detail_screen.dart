import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_config.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/price_formatter.dart';
import '../../models/product.dart';
import '../../providers/cart_provider.dart';
import '../../providers/favorites_provider.dart';
import '../../providers/navigation_provider.dart';
import '../../providers/product_providers.dart';
import '../../providers/selected_size_provider.dart';
import '../../widgets/common/cart_button.dart';
import '../../widgets/common/error_view.dart';
import '../../widgets/common/skeleton.dart';
import '../../widgets/product/price_text.dart';
import '../../widgets/product/product_image.dart';
import '../../widgets/product/size_selector.dart';

/// Full product page. Reads a single product through
/// [productDetailProvider] so it owns its own loading and error states.
class ProductDetailScreen extends ConsumerWidget {
  const ProductDetailScreen({super.key, required this.productId});

  final String productId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final product = ref.watch(productDetailProvider(productId));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: product.when(
        loading: () => const _DetailSkeleton(),
        error: (error, _) => SafeArea(
          child: Column(
            children: [
              const _BackBar(),
              Expanded(
                child: ErrorView(
                  error: error,
                  onRetry: () =>
                      ref.invalidate(productDetailProvider(productId)),
                ),
              ),
            ],
          ),
        ),
        data: (value) => _DetailBody(product: value),
      ),
      bottomNavigationBar: product.maybeWhen(
        data: (value) => _AddToBagBar(product: value),
        orElse: () => null,
      ),
    );
  }
}

class _DetailBody extends ConsumerWidget {
  const _DetailBody({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedSize = ref.watch(selectedSizeProvider(product.id));

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          expandedHeight: 420,
          backgroundColor: AppColors.background,
          leading: const _BackButton(),
          actions: [_FavoriteButton(productId: product.id)],
          flexibleSpace: FlexibleSpaceBar(
            background: ProductImage(
              path: product.image,
              heroTag: 'product-${product.id}',
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.page,
            AppSpacing.xl,
            AppSpacing.page,
            AppSpacing.xxl,
          ),
          sliver: SliverList.list(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      product.brand.toUpperCase(),
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.accent,
                      ),
                    ),
                  ),
                  Text(product.category.label, style: AppTypography.labelSmall),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                product.name.toUpperCase(),
                style: AppTypography.display.copyWith(fontSize: 24),
              ),
              const SizedBox(height: AppSpacing.md),
              _RatingRow(product: product),
              const SizedBox(height: AppSpacing.lg),
              PriceText(product.price, size: PriceSize.large),
              const SizedBox(height: AppSpacing.sm),
              _StockLine(product: product),
              const SizedBox(height: AppSpacing.xl),
              const Divider(),
              const SizedBox(height: AppSpacing.xl),
              Row(
                children: [
                  Expanded(child: Text('SIZE', style: AppTypography.label)),
                  if (selectedSize == null && product.inStock)
                    Text(
                      'SELECT A SIZE',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.accent,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              SizeSelector(
                sizes: product.sizes,
                selected: selectedSize,
                enabled: product.inStock,
                onSelect: (size) => ref
                    .read(selectedSizesProvider.notifier)
                    .select(product.id, size),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text('COLOURWAY', style: AppTypography.label),
              const SizedBox(height: AppSpacing.sm),
              Text(product.colors.join('  ·  '), style: AppTypography.body),
              const SizedBox(height: AppSpacing.xl),
              const Divider(),
              const SizedBox(height: AppSpacing.xl),
              Text('DESCRIPTION', style: AppTypography.label),
              const SizedBox(height: AppSpacing.sm),
              Text(product.description, style: AppTypography.body),
              const SizedBox(height: AppSpacing.xl),
              const Divider(),
              const SizedBox(height: AppSpacing.lg),
              _DetailRow(label: 'REFERENCE', value: product.id.toUpperCase()),
              _DetailRow(label: 'BRAND', value: product.brand),
              _DetailRow(label: 'CATEGORY', value: product.category.label),
              _DetailRow(label: 'RELEASED', value: _formatDate(product.releasedAt)),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Free shipping worldwide on orders over '
                '${PriceFormatter.format(AppConfig.freeShippingThreshold)}. '
                'Returns accepted within 14 days.',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day.$month.${date.year}';
  }
}

/// Heart toggle backed by [favoritesProvider].
class _FavoriteButton extends ConsumerWidget {
  const _FavoriteButton({required this.productId});

  final String productId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFavorite = ref.watch(isFavoriteProvider(productId));

    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.sm),
      child: IconButton(
        onPressed: () async {
          final messenger = ScaffoldMessenger.of(context);
          final saved = !isFavorite;
          final ok = await ref
              .read(favoritesProvider.notifier)
              .toggle(productId);

          messenger
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(
                  ok
                      ? (saved ? 'Saved to favorites' : 'Removed from favorites')
                      : 'Favorites could not be saved on this device.',
                ),
              ),
            );
        },
        tooltip: isFavorite ? 'Remove from favorites' : 'Save to favorites',
        icon: Icon(
          isFavorite ? Icons.favorite : Icons.favorite_border,
          color: isFavorite ? AppColors.accent : AppColors.textPrimary,
        ),
        style: IconButton.styleFrom(
          backgroundColor: AppColors.overlay,
          shape: const CircleBorder(),
        ),
      ),
    );
  }
}

class _RatingRow extends StatelessWidget {
  const _RatingRow({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 1; i <= 5; i++)
          Icon(
            i <= product.rating.round() ? Icons.star : Icons.star_border,
            size: 14,
            color: AppColors.textPrimary,
          ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          '${product.rating}  (${product.reviewCount})',
          style: AppTypography.bodySmall,
        ),
      ],
    );
  }
}

class _StockLine extends StatelessWidget {
  const _StockLine({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (product.stock) {
      0 => ('SOLD OUT', AppColors.danger),
      < 10 => ('ONLY ${product.stock} LEFT', AppColors.warning),
      _ => ('IN STOCK', AppColors.success),
    };

    return Text(label, style: AppTypography.labelSmall.copyWith(color: color));
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label, style: AppTypography.labelSmall),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Sticky bottom bar: price plus the add to bag call to action.
class _AddToBagBar extends ConsumerWidget {
  const _AddToBagBar({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = ref.watch(selectedSizeProvider(product.id));
    final canAdd = product.inStock && size != null;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.page),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    size == null ? 'NO SIZE' : 'SIZE $size',
                    style: AppTypography.labelSmall,
                  ),
                  const SizedBox(height: 2),
                  PriceText(product.price),
                ],
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: CartButton(
                  label: product.inStock ? 'Add to bag' : 'Sold out',
                  onPressed: canAdd
                      ? () => _addToBag(context, ref, size)
                      : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addToBag(BuildContext context, WidgetRef ref, String size) {
    ref.read(cartProvider.notifier).add(product, size);

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('Added to bag · SIZE $size'),
          action: SnackBarAction(
            label: 'VIEW BAG',
            textColor: AppColors.accent,
            onPressed: () {
              ref.read(navigationProvider.notifier).select(AppTab.cart);
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          ),
        ),
      );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton();

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => Navigator.of(context).maybePop(),
      icon: const Icon(Icons.arrow_back),
      style: IconButton.styleFrom(
        backgroundColor: AppColors.overlay,
        shape: const CircleBorder(),
      ),
    );
  }
}

class _BackBar extends StatelessWidget {
  const _BackBar();

  @override
  Widget build(BuildContext context) {
    return const Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.sm),
        child: _BackButton(),
      ),
    );
  }
}

class _DetailSkeleton extends StatelessWidget {
  const _DetailSkeleton();

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: SkeletonPulse(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SkeletonBox(height: 380, radius: 0),
            Padding(
              padding: EdgeInsets.all(AppSpacing.page),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonBox(height: 10, width: 90),
                  SizedBox(height: AppSpacing.md),
                  SkeletonBox(height: 22),
                  SizedBox(height: AppSpacing.sm),
                  SkeletonBox(height: 22, width: 180),
                  SizedBox(height: AppSpacing.xl),
                  SkeletonBox(height: 18, width: 130),
                  SizedBox(height: AppSpacing.xl),
                  Row(
                    children: [
                      SkeletonBox(height: 44, width: 56),
                      SizedBox(width: AppSpacing.sm),
                      SkeletonBox(height: 44, width: 56),
                      SizedBox(width: AppSpacing.sm),
                      SkeletonBox(height: 44, width: 56),
                      SizedBox(width: AppSpacing.sm),
                      SkeletonBox(height: 44, width: 56),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
