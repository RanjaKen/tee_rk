import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_strings.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../models/product_category.dart';
import '../../providers/catalog_filter_providers.dart';
import '../../providers/favorites_provider.dart';
import '../../providers/product_providers.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/error_view.dart';
import '../../widgets/common/rk_app_bar.dart';
import '../../widgets/common/search_field.dart';
import '../../widgets/common/skeleton.dart';
import '../../widgets/product/category_chip.dart';
import '../../widgets/product/filter_sort_sheet.dart';
import '../../widgets/product/product_grid.dart';

/// Shop tab: search, category chips, filter/sort and the result grid.
///
/// Everything it renders comes from [filteredProductsProvider]; matching
/// and ordering happen in the provider layer.
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final results = ref.watch(filteredProductsProvider);
    final activeFilters = ref.watch(activeFilterCountProvider);

    // Keep the field in sync when filters are cleared from elsewhere.
    final query = ref.watch(searchQueryProvider);
    if (_controller.text != query) {
      _controller.value = TextEditingValue(
        text: query,
        selection: TextSelection.collapsed(offset: query.length),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const RkAppBar(title: AppStrings.searchTitle),
      body: RefreshIndicator(
        color: AppColors.accent,
        backgroundColor: AppColors.surfaceAlt,
        onRefresh: () => ref.read(productsProvider.notifier).refresh(),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.page,
                  AppSpacing.lg,
                  AppSpacing.page,
                  AppSpacing.md,
                ),
                child: SearchField(
                  controller: _controller,
                  onChanged: (value) =>
                      ref.read(searchQueryProvider.notifier).update(value),
                  onClear: () =>
                      ref.read(searchQueryProvider.notifier).clear(),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: _CategoryRow()),
            SliverToBoxAdapter(
              child: _ResultsBar(
                count: results.value?.length,
                activeFilters: activeFilters,
              ),
            ),
            ...switch (results) {
              AsyncValue(isLoading: true) => const [
                SliverProductGridSkeleton(itemCount: 8),
              ],
              AsyncValue(hasError: true, :final error?) => [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: ErrorView(
                    error: error,
                    onRetry: () =>
                        ref.read(productsProvider.notifier).refresh(),
                  ),
                ),
              ],
              AsyncValue(value: final products?) => products.isEmpty
                  ? [
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: EmptyState(
                          icon: Icons.search_off,
                          title: 'No products found',
                          message:
                              'Nothing matches this search and filters. '
                              'Try widening them.',
                          actionLabel: 'Clear filters',
                          onAction: () => resetCatalogFilters(ref),
                        ),
                      ),
                    ]
                  : [
                      SliverProductGrid(
                        products: products,
                        onTapProduct: (product) =>
                            AppRouter.openProduct(context, product.id),
                        isFavorite: (product) =>
                            ref.watch(isFavoriteProvider(product.id)),
                        onToggleFavorite: (product) => ref
                            .read(favoritesProvider.notifier)
                            .toggle(product.id),
                      ),
                      const SliverToBoxAdapter(
                        child: SizedBox(height: AppSpacing.xxl),
                      ),
                    ],
              _ => const <Widget>[],
            },
          ],
        ),
      ),
    );
  }
}

/// Horizontal ALL + category chips.
class _CategoryRow extends ConsumerWidget {
  const _CategoryRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(categoryFilterProvider);
    final notifier = ref.read(categoryFilterProvider.notifier);

    return SizedBox(
      height: 46,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
        children: [
          CategoryChip(
            label: 'ALL',
            selected: selected == null,
            onTap: notifier.clear,
          ),
          for (final category in ProductCategory.values) ...[
            const SizedBox(width: AppSpacing.sm),
            CategoryChip(
              label: category.label,
              selected: selected == category,
              onTap: () => notifier.select(category),
            ),
          ],
        ],
      ),
    );
  }
}

/// Result count on the left, filter entry point on the right.
class _ResultsBar extends StatelessWidget {
  const _ResultsBar({required this.count, required this.activeFilters});

  final int? count;
  final int activeFilters;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.page,
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.md,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              count == null
                  ? 'LOADING…'
                  : '$count ${count == 1 ? 'PRODUCT' : 'PRODUCTS'}',
              style: AppTypography.labelSmall,
            ),
          ),
          TextButton.icon(
            onPressed: () => FilterSortSheet.show(context),
            icon: Badge(
              isLabelVisible: activeFilters > 0,
              label: Text('$activeFilters'),
              backgroundColor: AppColors.accent,
              textColor: AppColors.onAccent,
              child: const Icon(Icons.tune, size: 17),
            ),
            label: Text(
              'FILTER & SORT',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
