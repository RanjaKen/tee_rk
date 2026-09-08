import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_strings.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../providers/favorites_provider.dart';
import '../../providers/navigation_provider.dart';
import '../../providers/product_providers.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/error_view.dart';
import '../../widgets/common/rk_app_bar.dart';
import '../../widgets/common/skeleton.dart';
import '../../widgets/product/product_grid.dart';

/// Saved products. The list is device local and survives restarts.
class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoriteProductsProvider);
    final count = ref.watch(favoritesCountProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: RkAppBar(
        title: AppStrings.favoritesTitle,
        actions: [
          if (count > 0)
            TextButton(
              onPressed: () => ref.read(favoritesProvider.notifier).clear(),
              child: const Text('CLEAR'),
            ),
        ],
      ),
      body: favorites.when(
        loading: () => const CustomScrollView(
          slivers: [SliverProductGridSkeleton(itemCount: 4)],
        ),
        error: (error, _) => ErrorView(
          error: error,
          onRetry: () {
            ref.invalidate(favoritesProvider);
            ref.read(productsProvider.notifier).refresh();
          },
        ),
        data: (products) {
          if (products.isEmpty) {
            return EmptyState(
              icon: Icons.favorite_border,
              title: 'No favorites yet',
              message:
                  'Tap the heart on a product to keep it here. '
                  'Your list stays on this device.',
              actionLabel: 'Browse the shop',
              onAction: () =>
                  ref.read(navigationProvider.notifier).select(AppTab.shop),
            );
          }

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.page,
                    AppSpacing.lg,
                    AppSpacing.page,
                    AppSpacing.lg,
                  ),
                  child: Text(
                    '${products.length} SAVED',
                    style: AppTypography.labelSmall,
                  ),
                ),
              ),
              SliverProductGrid(
                products: products,
                onTapProduct: (product) =>
                    AppRouter.openProduct(context, product.id),
                isFavorite: (_) => true,
                onToggleFavorite: (product) =>
                    ref.read(favoritesProvider.notifier).toggle(product.id),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxl)),
            ],
          );
        },
      ),
    );
  }
}
