import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tee_rk/data/favorites_local_data_source.dart';
import 'package:tee_rk/providers/favorites_provider.dart';
import 'package:tee_rk/providers/product_providers.dart';
import 'package:tee_rk/repositories/favorites_repository.dart';
import 'package:tee_rk/repositories/product_repository.dart';

ProviderContainer _container(FavoritesRepository favorites) {
  final container = ProviderContainer(
    overrides: [
      productRepositoryProvider.overrideWithValue(
        FakeProductRepository(latency: Duration.zero),
      ),
      favoritesRepositoryProvider.overrideWithValue(favorites),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('notifier', () {
    test('loads the stored ids', () async {
      final container = _container(
        InMemoryFavoritesRepository(initial: {'tee-001', 'snk-001'}),
      );

      final ids = await container.read(favoritesProvider.future);
      expect(ids, {'tee-001', 'snk-001'});
      expect(container.read(favoritesCountProvider), 2);
      expect(container.read(isFavoriteProvider('tee-001')), isTrue);
      expect(container.read(isFavoriteProvider('acc-001')), isFalse);
    });

    test('toggle adds then removes', () async {
      final repository = InMemoryFavoritesRepository();
      final container = _container(repository);
      await container.read(favoritesProvider.future);

      expect(await container.read(favoritesProvider.notifier).toggle('tee-001'),
          isTrue);
      expect(container.read(favoritesProvider).requireValue, {'tee-001'});
      expect(await repository.load(), {'tee-001'});

      await container.read(favoritesProvider.notifier).toggle('tee-001');
      expect(container.read(favoritesProvider).requireValue, isEmpty);
      expect(await repository.load(), isEmpty);
    });

    test('clear empties the list and the storage', () async {
      final repository = InMemoryFavoritesRepository(
        initial: {'tee-001', 'jrs-001'},
      );
      final container = _container(repository);
      await container.read(favoritesProvider.future);

      await container.read(favoritesProvider.notifier).clear();

      expect(container.read(favoritesProvider).requireValue, isEmpty);
      expect(await repository.load(), isEmpty);
    });

    test('a failed write is rolled back', () async {
      final container = _container(
        InMemoryFavoritesRepository(initial: {'tee-001'}, failOnSave: true),
      );
      await container.read(favoritesProvider.future);

      final ok = await container
          .read(favoritesProvider.notifier)
          .toggle('snk-001');

      expect(ok, isFalse);
      expect(container.read(favoritesProvider).requireValue, {'tee-001'});
    });
  });

  group('favoriteProductsProvider', () {
    test('resolves ids against the catalog, in catalog order', () async {
      final container = _container(
        InMemoryFavoritesRepository(initial: {'acc-001', 'tee-001'}),
      );
      await container.read(productsProvider.future);
      await container.read(favoritesProvider.future);

      final products = container.read(favoriteProductsProvider).requireValue;
      expect(products.map((p) => p.id).toList(), ['tee-001', 'acc-001']);
    });

    test('ignores ids that are no longer in the catalog', () async {
      final container = _container(
        InMemoryFavoritesRepository(initial: {'tee-001', 'ghost-999'}),
      );
      await container.read(productsProvider.future);
      await container.read(favoritesProvider.future);

      final products = container.read(favoriteProductsProvider).requireValue;
      expect(products.map((p) => p.id).toList(), ['tee-001']);
    });

    test('surfaces a catalog failure', () async {
      final container = ProviderContainer(
        overrides: [
          productRepositoryProvider.overrideWithValue(
            FakeProductRepository(latency: Duration.zero, shouldFail: true),
          ),
          favoritesRepositoryProvider.overrideWithValue(
            InMemoryFavoritesRepository(),
          ),
        ],
      );
      addTearDown(container.dispose);

      await expectLater(
        container.read(productsProvider.future),
        throwsA(anything),
      );
      await container.read(favoritesProvider.future);

      expect(container.read(favoriteProductsProvider).hasError, isTrue);
    });
  });

  group('device persistence', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('survives a fresh provider container', () async {
      const repository = LocalFavoritesRepository();

      final first = _container(repository);
      await first.read(favoritesProvider.future);
      await first.read(favoritesProvider.notifier).toggle('snk-002');

      // A new container is the equivalent of relaunching the app.
      final second = _container(repository);
      expect(await second.read(favoritesProvider.future), {'snk-002'});
    });

    test('writes through the documented storage key', () async {
      SharedPreferences.setMockInitialValues({
        FavoritesLocalDataSource.storageKey: <String>['jrs-001'],
      });

      const dataSource = FavoritesLocalDataSource();
      expect(await dataSource.read(), {'jrs-001'});

      await dataSource.write({'jrs-001', 'acc-002'});
      expect(await dataSource.read(), {'jrs-001', 'acc-002'});
    });
  });
}
