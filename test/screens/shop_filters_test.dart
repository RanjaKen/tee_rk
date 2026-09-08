import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tee_rk/providers/catalog_filter_providers.dart';
import 'package:tee_rk/providers/favorites_provider.dart';
import 'package:tee_rk/providers/product_providers.dart';
import 'package:tee_rk/repositories/favorites_repository.dart';
import 'package:tee_rk/repositories/product_repository.dart';
import 'package:tee_rk/screens/search/search_screen.dart';
import 'package:tee_rk/widgets/common/empty_state.dart';
import 'package:tee_rk/widgets/common/search_field.dart';
import 'package:tee_rk/widgets/product/category_chip.dart';
import 'package:tee_rk/widgets/product/product_card.dart';

late FakeProductRepository repository;

Future<ProviderContainer> _pumpShop(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1200, 2600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.runAsync(repository.fetchProducts);

  final container = ProviderContainer(
    overrides: [
      productRepositoryProvider.overrideWithValue(repository),
      favoritesRepositoryProvider.overrideWithValue(
        InMemoryFavoritesRepository(),
      ),
    ],
  );
  addTearDown(container.dispose);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: SearchScreen()),
    ),
  );
  await tester.pump();
  await tester.pump();

  return container;
}

void main() {
  setUp(() => repository = FakeProductRepository(latency: Duration.zero));

  testWidgets('shows the full catalog with search and chips', (tester) async {
    await _pumpShop(tester);

    expect(find.byType(SearchField), findsOneWidget);
    expect(find.byType(CategoryChip), findsNWidgets(5)); // ALL + 4 categories
    expect(find.text('16 PRODUCTS'), findsOneWidget);
    expect(find.byType(ProductCard), findsWidgets);
  });

  testWidgets('typing filters the grid', (tester) async {
    final container = await _pumpShop(tester);

    await tester.enterText(find.byType(TextField), 'duffle');
    await tester.pump();

    expect(container.read(searchQueryProvider), 'duffle');
    expect(find.text('1 PRODUCT'), findsOneWidget);
  });

  testWidgets('a category chip narrows the results', (tester) async {
    final container = await _pumpShop(tester);

    await tester.tap(find.widgetWithText(CategoryChip, 'SNEAKERS'));
    await tester.pump();

    expect(container.read(filteredProductsProvider).requireValue, hasLength(4));
    expect(find.text('4 PRODUCTS'), findsOneWidget);
  });

  testWidgets('no match shows the empty state and clearing restores it', (
    tester,
  ) async {
    final container = await _pumpShop(tester);

    await tester.enterText(find.byType(TextField), 'zzzzz');
    await tester.pump();

    expect(find.byType(EmptyState), findsOneWidget);
    expect(find.text('NO PRODUCTS FOUND'), findsOneWidget);
    expect(find.text('0 PRODUCTS'), findsOneWidget);

    await tester.tap(find.text('CLEAR FILTERS'));
    await tester.pump();

    expect(container.read(searchQueryProvider), isEmpty);
    expect(find.text('16 PRODUCTS'), findsOneWidget);
  });
}
