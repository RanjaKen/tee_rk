import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/product.dart';
import '../repositories/favorites_repository.dart';
import 'product_providers.dart';

/// Injection point for the favorites storage.
final favoritesRepositoryProvider = Provider<FavoritesRepository>(
  (ref) => const LocalFavoritesRepository(),
);

/// Favorite product ids, loaded from and written back to the device.
///
/// Toggling updates the state first so the heart reacts immediately, then
/// persists; if the write fails the change is rolled back.
class FavoritesNotifier extends AsyncNotifier<Set<String>> {
  @override
  Future<Set<String>> build() {
    return ref.watch(favoritesRepositoryProvider).load();
  }

  /// Adds or removes [productId]. Returns false when persistence failed
  /// and the change was rolled back.
  Future<bool> toggle(String productId) async {
    final previous = state.value ?? const <String>{};
    final next = {...previous};
    if (!next.remove(productId)) next.add(productId);

    state = AsyncData(next);

    try {
      await ref.read(favoritesRepositoryProvider).save(next);
      return true;
    } catch (_) {
      state = AsyncData(previous);
      return false;
    }
  }

  Future<bool> clear() async {
    final previous = state.value ?? const <String>{};
    state = const AsyncData({});

    try {
      await ref.read(favoritesRepositoryProvider).save(const {});
      return true;
    } catch (_) {
      state = AsyncData(previous);
      return false;
    }
  }

  bool contains(String productId) => state.value?.contains(productId) ?? false;
}

final favoritesProvider =
    AsyncNotifierProvider<FavoritesNotifier, Set<String>>(
      FavoritesNotifier.new,
      retry: _noRetry,
    );

Duration? _noRetry(int retryCount, Object error) => null;

/// Whether one product is saved. Cheap to watch from a card.
final isFavoriteProvider = Provider.family<bool, String>((ref, productId) {
  return ref.watch(favoritesProvider).value?.contains(productId) ?? false;
});

final favoritesCountProvider = Provider<int>((ref) {
  return ref.watch(favoritesProvider).value?.length ?? 0;
});

/// Saved products, resolved against the catalog and kept in catalog order.
///
/// Stays in loading/error while either source is, so the screen can show
/// a single coherent state.
final favoriteProductsProvider = Provider<AsyncValue<List<Product>>>((ref) {
  final catalog = ref.watch(productsProvider);
  final favorites = ref.watch(favoritesProvider);

  if (catalog.isLoading || favorites.isLoading) {
    return const AsyncValue<List<Product>>.loading();
  }
  if (catalog.hasError) {
    return AsyncValue<List<Product>>.error(
      catalog.error!,
      catalog.stackTrace ?? StackTrace.empty,
    );
  }
  if (favorites.hasError) {
    return AsyncValue<List<Product>>.error(
      favorites.error!,
      favorites.stackTrace ?? StackTrace.empty,
    );
  }

  final ids = favorites.value ?? const <String>{};
  final products = (catalog.value ?? const <Product>[])
      .where((product) => ids.contains(product.id))
      .toList(growable: false);

  return AsyncValue<List<Product>>.data(products);
});
