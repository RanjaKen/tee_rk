import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/product.dart';
import '../repositories/product_repository.dart';

/// Single injection point for the catalog source.
///
/// Overriding this provider in a `ProviderScope` swaps the whole data
/// layer (tests, error demos, a future HTTP repository).
final productRepositoryProvider = Provider<ProductRepository>(
  (ref) => FakeProductRepository(),
);

/// Owns the catalog as an [AsyncValue]: loading / error / data.
class ProductsNotifier extends AsyncNotifier<List<Product>> {
  @override
  Future<List<Product>> build() {
    return ref.watch(productRepositoryProvider).fetchProducts();
  }

  /// Re-runs the fetch while keeping the previous list on screen.
  Future<void> refresh() async {
    state = await AsyncValue.guard(
      () => ref.read(productRepositoryProvider).fetchProducts(),
    );
  }
}

/// The full catalog. Every list, grid, search and filter derives from it.
///
/// `retry` is disabled: Riverpod 3 would otherwise retry a failed build with
/// exponential backoff, leaving the UI spinning. TEE_RK surfaces the failure
/// straight away and lets the user retry from the error state.
final productsProvider =
    AsyncNotifierProvider<ProductsNotifier, List<Product>>(
      ProductsNotifier.new,
      retry: _noRetry,
    );

/// A single product by id, for the detail screen.
final productDetailProvider = FutureProvider.family<Product, String>((
  ref,
  id,
) async {
  return ref.watch(productRepositoryProvider).fetchProductById(id);
}, retry: _noRetry);

/// Opt out of Riverpod's automatic retry: failures are user-retried.
Duration? _noRetry(int retryCount, Object error) => null;

/// Curated slice used by the home screen hero rail.
final featuredProductsProvider = Provider<AsyncValue<List<Product>>>((ref) {
  return ref
      .watch(productsProvider)
      .whenData((products) => products.where((p) => p.isFeatured).toList());
});

/// Latest drops, newest first: the "NEW ARRIVALS" section.
final newArrivalsProvider = Provider<AsyncValue<List<Product>>>((ref) {
  return ref.watch(productsProvider).whenData((products) {
    final sorted = [...products]
      ..sort((a, b) => b.releasedAt.compareTo(a.releasedAt));
    return sorted;
  });
});
