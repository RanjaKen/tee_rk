import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tee_rk/models/price_range.dart';
import 'package:tee_rk/models/product.dart';
import 'package:tee_rk/models/product_category.dart';
import 'package:tee_rk/models/sort_option.dart';
import 'package:tee_rk/providers/catalog_filter_providers.dart';
import 'package:tee_rk/providers/product_providers.dart';
import 'package:tee_rk/repositories/product_repository.dart';

late ProviderContainer container;

List<Product> get results =>
    container.read(filteredProductsProvider).requireValue;

List<String> get ids => results.map((p) => p.id).toList();

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    container = ProviderContainer(
      overrides: [
        productRepositoryProvider.overrideWithValue(
          FakeProductRepository(latency: Duration.zero),
        ),
      ],
    );
    addTearDown(container.dispose);
    await container.read(productsProvider.future);
  });

  test('no filters returns the whole catalog, newest first', () {
    expect(results, hasLength(16));
    expect(ids.first, 'snk-001'); // released 2026-09-01
    expect(container.read(activeFilterCountProvider), 0);
  });

  test('price bounds come from the catalog', () {
    expect(
      container.read(priceBoundsProvider),
      const PriceRange(min: 45000, max: 845000),
    );
  });

  group('search', () {
    test('matches the product name, case insensitively', () {
      container.read(searchQueryProvider.notifier).update('jersey');
      expect(ids, contains('jrs-001'));
      expect(results.every((p) => p.name.toLowerCase().contains('jersey') ||
          p.description.toLowerCase().contains('jersey')), isTrue);
    });

    test('matches the brand', () {
      container.read(searchQueryProvider.notifier).update('ranjaken');
      expect(results, isNotEmpty);
      expect(results.every((p) => p.brand == 'RANJAKEN'), isTrue);
    });

    test('surrounding whitespace is ignored', () {
      container.read(searchQueryProvider.notifier).update('  duffle  ');
      expect(ids, ['acc-004']);
    });

    test('no match yields an empty list, not an error', () {
      container.read(searchQueryProvider.notifier).update('zzzzz');
      expect(results, isEmpty);
      expect(container.read(filteredProductsProvider).hasError, isFalse);
    });

    test('clearing restores the catalog', () {
      container.read(searchQueryProvider.notifier).update('zzzzz');
      container.read(searchQueryProvider.notifier).clear();
      expect(results, hasLength(16));
    });
  });

  group('category', () {
    test('narrows to one category', () {
      container
          .read(categoryFilterProvider.notifier)
          .select(ProductCategory.sneakers);

      expect(results, hasLength(4));
      expect(
        results.every((p) => p.category == ProductCategory.sneakers),
        isTrue,
      );
      expect(container.read(activeFilterCountProvider), 1);
    });

    test('selecting the active category toggles it off', () {
      final notifier = container.read(categoryFilterProvider.notifier);
      notifier.select(ProductCategory.jerseys);
      notifier.select(ProductCategory.jerseys);

      expect(container.read(categoryFilterProvider), isNull);
      expect(results, hasLength(16));
    });
  });

  group('price filter', () {
    test('keeps only products inside the window', () {
      container
          .read(priceRangeProvider.notifier)
          .update(const PriceRange(min: 0, max: 100000));

      expect(results.every((p) => p.price <= 100000), isTrue);
      expect(ids, contains('acc-003')); // 45 000 Ar
      expect(ids, isNot(contains('snk-002'))); // 845 000 Ar
      expect(container.read(activeFilterCountProvider), 1);
    });

    test('a window covering the bounds does not count as a filter', () {
      container
          .read(priceRangeProvider.notifier)
          .update(const PriceRange(min: 45000, max: 845000));

      expect(results, hasLength(16));
      expect(container.read(activeFilterCountProvider), 0);
    });
  });

  group('sorting', () {
    test('price low to high', () {
      container
          .read(sortOptionProvider.notifier)
          .select(SortOption.priceLowHigh);

      final prices = results.map((p) => p.price).toList();
      expect(prices.first, 45000);
      expect(prices.last, 845000);
      expect(prices, orderedEquals([...prices]..sort()));
    });

    test('price high to low', () {
      container
          .read(sortOptionProvider.notifier)
          .select(SortOption.priceHighLow);

      expect(results.first.price, 845000);
      expect(results.last.price, 45000);
    });

    test('name A to Z and Z to A are mirror images', () {
      container.read(sortOptionProvider.notifier).select(SortOption.nameAZ);
      final az = ids;

      container.read(sortOptionProvider.notifier).select(SortOption.nameZA);
      expect(ids, az.reversed.toList());
    });
  });

  test('search, category, price and sort compose', () {
    container.read(searchQueryProvider.notifier).update('tee');
    container
        .read(categoryFilterProvider.notifier)
        .select(ProductCategory.tshirts);
    container
        .read(priceRangeProvider.notifier)
        .update(const PriceRange(min: 80000, max: 140000));
    container
        .read(sortOptionProvider.notifier)
        .select(SortOption.priceLowHigh);

    expect(results, isNotEmpty);
    expect(
      results.every(
        (p) =>
            p.category == ProductCategory.tshirts &&
            p.price >= 80000 &&
            p.price <= 140000,
      ),
      isTrue,
    );
    final prices = results.map((p) => p.price).toList();
    expect(prices, orderedEquals([...prices]..sort()));
    expect(container.read(activeFilterCountProvider), 3);
  });

  test('filters keep the catalog loading state', () {
    final failing = ProviderContainer(
      overrides: [
        productRepositoryProvider.overrideWithValue(
          FakeProductRepository(latency: Duration.zero),
        ),
      ],
    );
    addTearDown(failing.dispose);

    expect(failing.read(filteredProductsProvider).isLoading, isTrue);
  });
}
