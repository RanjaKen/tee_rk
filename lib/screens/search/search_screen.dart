import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_strings.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../providers/product_providers.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/error_view.dart';
import '../../widgets/common/rk_app_bar.dart';
import '../../widgets/common/skeleton.dart';
import '../../widgets/product/product_grid.dart';

/// Full catalog grid. Search, category filters and sorting are added
/// on top of this screen in Step 7.
class SearchScreen extends ConsumerWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(productsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const RkAppBar(title: AppStrings.searchTitle),
      body: RefreshIndicator(
        color: AppColors.accent,
        backgroundColor: AppColors.surfaceAlt,
        onRefresh: () => ref.read(productsProvider.notifier).refresh(),
        child: catalog.when(
          loading: () => const CustomScrollView(
            slivers: [SliverProductGridSkeleton(itemCount: 8)],
          ),
          error: (error, _) => CustomScrollView(
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: ErrorView(
                  error: error,
                  onRetry: () => ref.read(productsProvider.notifier).refresh(),
                ),
              ),
            ],
          ),
          data: (products) {
            if (products.isEmpty) {
              return const CustomScrollView(
                slivers: [
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: EmptyState(
                      icon: Icons.inventory_2_outlined,
                      title: 'Catalog empty',
                      message: 'No products are available right now.',
                    ),
                  ),
                ],
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
                      '${products.length} PRODUCTS',
                      style: AppTypography.labelSmall,
                    ),
                  ),
                ),
                SliverProductGrid(
                  products: products,
                  onTapProduct: (product) =>
                      AppRouter.openProduct(context, product.id),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: AppSpacing.xxl),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
