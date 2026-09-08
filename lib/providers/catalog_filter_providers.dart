import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/price_range.dart';
import '../models/product.dart';
import '../models/product_category.dart';
import '../models/sort_option.dart';
import 'product_providers.dart';

/// Free text query typed in the shop search field.
class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void update(String value) => state = value;

  void clear() => state = '';
}

final searchQueryProvider = NotifierProvider<SearchQueryNotifier, String>(
  SearchQueryNotifier.new,
);

/// Selected category, or null for "ALL".
class CategoryFilterNotifier extends Notifier<ProductCategory?> {
  @override
  ProductCategory? build() => null;

  /// Selecting the active category clears it, so chips toggle.
  void select(ProductCategory? category) =>
      state = state == category ? null : category;

  void clear() => state = null;
}

final categoryFilterProvider =
    NotifierProvider<CategoryFilterNotifier, ProductCategory?>(
      CategoryFilterNotifier.new,
    );

/// Cheapest and most expensive products in the catalog.
///
/// Drives the slider bounds, so the UI never hardcodes prices.
final priceBoundsProvider = Provider<PriceRange>((ref) {
  final products = ref.watch(productsProvider).value ?? const <Product>[];
  if (products.isEmpty) return const PriceRange(min: 0, max: 0);

  var min = products.first.price;
  var max = products.first.price;
  for (final product in products) {
    if (product.price < min) min = product.price;
    if (product.price > max) max = product.price;
  }
  return PriceRange(min: min, max: max);
});

/// Active price window. Null means "not narrowed yet": the effective
/// window is then [priceBoundsProvider].
class PriceRangeNotifier extends Notifier<PriceRange?> {
  @override
  PriceRange? build() => null;

  void update(PriceRange range) => state = range;

  void clear() => state = null;
}

final priceRangeProvider = NotifierProvider<PriceRangeNotifier, PriceRange?>(
  PriceRangeNotifier.new,
);

/// The window actually applied, resolved against the catalog bounds.
final effectivePriceRangeProvider = Provider<PriceRange>((ref) {
  return ref.watch(priceRangeProvider) ?? ref.watch(priceBoundsProvider);
});

class SortOptionNotifier extends Notifier<SortOption> {
  @override
  SortOption build() => SortOption.newest;

  void select(SortOption option) => state = option;

  void reset() => state = SortOption.newest;
}

final sortOptionProvider = NotifierProvider<SortOptionNotifier, SortOption>(
  SortOptionNotifier.new,
);

/// The catalog after search, category, price filtering and sorting.
///
/// This is the single source the shop grid renders; it keeps the
/// [AsyncValue] of the underlying catalog so loading and error states
/// still flow through.
final filteredProductsProvider = Provider<AsyncValue<List<Product>>>((ref) {
  final catalog = ref.watch(productsProvider);
  final query = ref.watch(searchQueryProvider).trim().toLowerCase();
  final category = ref.watch(categoryFilterProvider);
  final range = ref.watch(effectivePriceRangeProvider);
  final sort = ref.watch(sortOptionProvider);

  return catalog.whenData((products) {
    final matches = products.where((product) {
      if (category != null && product.category != category) return false;
      if (!range.contains(product.price)) return false;
      if (query.isEmpty) return true;
      return _matchesQuery(product, query);
    }).toList();

    matches.sort(_comparatorFor(sort));
    return matches;
  });
});

/// How many filters the user has actually applied (search excluded, it has
/// its own visible field). Drives the badge on the filter button.
final activeFilterCountProvider = Provider<int>((ref) {
  var count = 0;
  if (ref.watch(categoryFilterProvider) != null) count++;

  final range = ref.watch(priceRangeProvider);
  final bounds = ref.watch(priceBoundsProvider);
  if (range != null && !range.coversAll(bounds)) count++;

  if (ref.watch(sortOptionProvider) != SortOption.newest) count++;
  return count;
});

/// Clears search, category, price and sort in one call.
void resetCatalogFilters(WidgetRef ref) {
  ref.read(searchQueryProvider.notifier).clear();
  ref.read(categoryFilterProvider.notifier).clear();
  ref.read(priceRangeProvider.notifier).clear();
  ref.read(sortOptionProvider.notifier).reset();
}

bool _matchesQuery(Product product, String query) {
  return product.name.toLowerCase().contains(query) ||
      product.brand.toLowerCase().contains(query) ||
      product.category.label.toLowerCase().contains(query) ||
      product.description.toLowerCase().contains(query);
}

Comparator<Product> _comparatorFor(SortOption sort) {
  return switch (sort) {
    SortOption.newest => (a, b) => b.releasedAt.compareTo(a.releasedAt),
    SortOption.priceLowHigh => (a, b) => a.price.compareTo(b.price),
    SortOption.priceHighLow => (a, b) => b.price.compareTo(a.price),
    SortOption.nameAZ => (a, b) =>
        a.name.toLowerCase().compareTo(b.name.toLowerCase()),
    SortOption.nameZA => (a, b) =>
        b.name.toLowerCase().compareTo(a.name.toLowerCase()),
  };
}
