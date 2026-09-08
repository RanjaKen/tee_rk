import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tee_rk/models/product.dart';
import 'package:tee_rk/providers/cart_provider.dart';
import 'package:tee_rk/providers/product_providers.dart';
import 'package:tee_rk/repositories/product_repository.dart';
import 'package:tee_rk/screens/cart/cart_screen.dart';
import 'package:tee_rk/widgets/cart/cart_line_tile.dart';
import 'package:tee_rk/widgets/common/empty_state.dart';

late FakeProductRepository repository;

/// Pumps the bag with a phone sized surface so the summary and the
/// checkout bar are actually laid out.
Future<ProviderContainer> _pumpCart(
  WidgetTester tester,
  void Function(CartNotifier cart, Map<String, Product> catalog) seed,
) async {
  tester.view.physicalSize = const Size(1200, 2600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final products = await tester.runAsync(repository.fetchProducts) ?? const [];
  final catalog = {for (final product in products) product.id: product};

  final container = ProviderContainer(
    overrides: [productRepositoryProvider.overrideWithValue(repository)],
  );
  addTearDown(container.dispose);
  seed(container.read(cartProvider.notifier), catalog);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: CartScreen()),
    ),
  );
  await tester.pump();

  return container;
}

void main() {
  setUp(() => repository = FakeProductRepository(latency: Duration.zero));

  testWidgets('empty bag shows the empty state and no checkout bar', (
    tester,
  ) async {
    await _pumpCart(tester, (_, _) {});

    expect(find.byType(EmptyState), findsOneWidget);
    expect(find.text('YOUR BAG IS EMPTY'), findsOneWidget);
    expect(find.text('CHECKOUT'), findsNothing);
  });

  testWidgets('lines, totals and the checkout bar render', (tester) async {
    await _pumpCart(tester, (cart, catalog) {
      cart.add(catalog['tee-001']!, 'M', quantity: 2); // 258 000 Ar
      cart.add(catalog['acc-003']!, 'L'); //  45 000 Ar
    });

    expect(find.byType(CartLineTile), findsNWidgets(2));
    expect(find.text('3 ITEMS'), findsOneWidget);
    expect(find.text('258 000 Ar'), findsOneWidget); // line total
    expect(find.text('303 000 Ar'), findsOneWidget); // subtotal
    expect(find.text('20 000 Ar'), findsOneWidget); // shipping
    expect(find.text('323 000 Ar'), findsWidgets); // total + checkout button
    expect(find.text('CHECKOUT'), findsOneWidget);
  });

  testWidgets('the stepper updates quantity and totals', (tester) async {
    final container = await _pumpCart(tester, (cart, catalog) {
      cart.add(catalog['tee-001']!, 'M');
    });

    expect(container.read(cartCountProvider), 1);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();
    expect(container.read(cartCountProvider), 2);
    expect(find.text('258 000 Ar'), findsWidgets);

    await tester.tap(find.byIcon(Icons.remove));
    await tester.pump();
    expect(container.read(cartCountProvider), 1);
  });

  testWidgets('removing the last line falls back to the empty state', (
    tester,
  ) async {
    final container = await _pumpCart(tester, (cart, catalog) {
      cart.add(catalog['tee-001']!, 'M');
    });

    await tester.tap(find.byIcon(Icons.close));
    await tester.pump();

    expect(container.read(cartProvider), isEmpty);
    expect(find.byType(EmptyState), findsOneWidget);
  });

  testWidgets('free shipping above the threshold', (tester) async {
    await _pumpCart(tester, (cart, catalog) {
      cart.add(catalog['jrs-001']!, 'L', quantity: 2); // 570 000 Ar
    });

    expect(find.text('FREE'), findsOneWidget);
    expect(find.text('570 000 Ar'), findsWidgets);
  });
}
