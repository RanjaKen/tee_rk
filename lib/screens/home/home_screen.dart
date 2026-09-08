import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../models/product.dart';
import '../../providers/navigation_provider.dart';
import '../../providers/product_providers.dart';
import '../../widgets/common/error_view.dart';
import '../../widgets/common/rk_app_bar.dart';
import '../../widgets/common/section_header.dart';
import '../../widgets/common/skeleton.dart';
import '../../widgets/home/editorial_banner.dart';
import '../../widgets/home/store_footer.dart';
import '../../widgets/product/product_card.dart';
import '../../widgets/product/product_grid.dart';

/// Editorial landing feed: lookbook banners, a featured pair and the
/// latest drops. All content comes from [productsProvider].
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const int _newArrivalsPreview = 6;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(productsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: RkAppBar(
        actions: [
          IconButton(
            onPressed: () =>
                ref.read(navigationProvider.notifier).select(AppTab.shop),
            icon: const Icon(Icons.search),
          ),
          IconButton(
            onPressed: () =>
                ref.read(navigationProvider.notifier).select(AppTab.cart),
            icon: const Icon(Icons.shopping_bag_outlined),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.accent,
        backgroundColor: AppColors.surfaceAlt,
        onRefresh: () => ref.read(productsProvider.notifier).refresh(),
        child: catalog.when(
          loading: () => const CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: SkeletonPulse(
                  child: Padding(
                    padding: EdgeInsets.all(AppSpacing.page),
                    child: SkeletonBox(height: 320),
                  ),
                ),
              ),
              SliverProductGridSkeleton(),
            ],
          ),
          error: (error, _) => _ErrorScroll(
            error: error,
            onRetry: () => ref.read(productsProvider.notifier).refresh(),
          ),
          data: (products) => _Feed(
            products: products,
            featured: ref.watch(featuredProductsProvider).value ?? const [],
            newArrivals: ref.watch(newArrivalsProvider).value ?? const [],
            onSeeAll: () =>
                ref.read(navigationProvider.notifier).select(AppTab.shop),
            onOpenProduct: (product) =>
                AppRouter.openProduct(context, product.id),
          ),
        ),
      ),
    );
  }
}

class _Feed extends StatelessWidget {
  const _Feed({
    required this.products,
    required this.featured,
    required this.newArrivals,
    required this.onSeeAll,
    required this.onOpenProduct,
  });

  final List<Product> products;
  final List<Product> featured;
  final List<Product> newArrivals;
  final VoidCallback onSeeAll;
  final void Function(Product product) onOpenProduct;

  @override
  Widget build(BuildContext context) {
    final hero = featured.isNotEmpty ? featured.first : products.first;
    final pair = featured.skip(1).take(2).toList();
    final secondBanner = featured.length > 3 ? featured[3] : products.last;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: EditorialBanner(
            image: hero.image,
            eyebrow: 'DROP 02',
            caption: hero.name,
            overlayLabel: 'NEW',
            height: 380,
            onTap: () => onOpenProduct(hero),
          ),
        ),
        if (pair.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: SectionHeader(
              title: 'TEE_RK FALL 26',
              actionLabel: 'VIEW ALL',
              onAction: onSeeAll,
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
            sliver: SliverToBoxAdapter(
              child: SizedBox(
                height: 300,
                child: Row(
                  children: [
                    for (final product in pair) ...[
                      Expanded(
                        child: ProductCard(
                          product: product,
                          useHero: false,
                          onTap: () => onOpenProduct(product),
                        ),
                      ),
                      if (product != pair.last)
                        const SizedBox(width: AppSpacing.md),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xxl),
            child: EditorialBanner(
              image: secondBanner.image,
              eyebrow: 'ON COURT',
              caption: 'RKN Jerseys & Practice Kit',
              height: 300,
              onTap: () => onOpenProduct(secondBanner),
            ),
          ),
        ),
        const SliverToBoxAdapter(
          child: SectionHeader(title: 'NEW ARRIVALS', centered: true),
        ),
        SliverProductGrid(
          products: newArrivals.take(HomeScreen._newArrivalsPreview).toList(),
          onTapProduct: onOpenProduct,
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.page,
              AppSpacing.xxl,
              AppSpacing.page,
              AppSpacing.xxl,
            ),
            child: OutlinedButton(
              onPressed: onSeeAll,
              child: const Text('VIEW ALL NEW ARRIVALS'),
            ),
          ),
        ),
        const SliverToBoxAdapter(child: StoreFooter()),
      ],
    );
  }
}

/// Error state that still scrolls, so pull to refresh keeps working.
class _ErrorScroll extends StatelessWidget {
  const _ErrorScroll({required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: ErrorView(error: error, onRetry: onRetry),
        ),
      ],
    );
  }
}
