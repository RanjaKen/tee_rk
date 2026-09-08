import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tee_rk/models/product.dart';
import 'package:tee_rk/providers/favorites_provider.dart';
import 'package:tee_rk/providers/product_providers.dart';
import 'package:tee_rk/repositories/favorites_repository.dart';
import 'package:tee_rk/repositories/product_repository.dart';
import 'package:tee_rk/screens/favorites/favorites_screen.dart';
import 'package:tee_rk/screens/home/home_screen.dart';
import 'package:tee_rk/widgets/common/empty_state.dart';
import 'package:tee_rk/widgets/common/error_view.dart';

/// Repository with a catalog we control, including an empty one.
class _StubProductRepository implements ProductRepository {
  _StubProductRepository(this.products);

  final List<Product> products;

  @override
  Future<List<Product>> fetchProducts() async => products;

  @override
  Future<Product> fetchProductById(String id) async =>
      products.firstWhere((product) => product.id == id);
}

Future<void> _pump(WidgetTester tester, Widget screen, ProviderContainer c) async {
  tester.view.physicalSize = const Size(1200, 2600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: c,
      child: MaterialApp(home: screen),
    ),
  );
  await tester.pump();
  await tester.pump();
}

ProviderContainer _container(ProductRepository products) {
  final container = ProviderContainer(
    overrides: [
      productRepositoryProvider.overrideWithValue(products),
      favoritesRepositoryProvider.overrideWithValue(
        InMemoryFavoritesRepository(),
      ),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  testWidgets('home shows an empty state when the catalog is empty', (
    tester,
  ) async {
    // Regression: the feed used to read products.first and would throw.
    final container = _container(_StubProductRepository(const []));
    await _pump(tester, const HomeScreen(), container);

    expect(tester.takeException(), isNull);
    expect(find.byType(EmptyState), findsOneWidget);
    expect(find.text('NOTHING IN STORE YET'), findsOneWidget);
  });

  testWidgets('favorites shows an empty state with a shop shortcut', (
    tester,
  ) async {
    final repository = FakeProductRepository(latency: Duration.zero);
    await tester.runAsync(repository.fetchProducts);
    final container = _container(repository);

    await _pump(tester, const FavoritesScreen(), container);

    expect(find.byType(EmptyState), findsOneWidget);
    expect(find.text('NO FAVORITES YET'), findsOneWidget);
    expect(find.text('BROWSE THE SHOP'), findsOneWidget);
  });

  testWidgets('the simulate failure switch drives the error state', (
    tester,
  ) async {
    final container = ProviderContainer(
      overrides: [
        favoritesRepositoryProvider.overrideWithValue(
          InMemoryFavoritesRepository(),
        ),
      ],
    );
    addTearDown(container.dispose);

    // The default repository honours the switch, so flipping it must put
    // the catalog into its error state.
    container.read(simulateNetworkErrorProvider.notifier).set(true);

    await _pump(tester, const HomeScreen(), container);
    await tester.pump(const Duration(seconds: 1));

    expect(container.read(productsProvider).hasError, isTrue);
    expect(find.byType(ErrorView), findsOneWidget);
    expect(find.text('RETRY'), findsOneWidget);
  });
}
