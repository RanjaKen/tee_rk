import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tee_rk/providers/product_providers.dart';
import 'package:tee_rk/providers/selected_size_provider.dart';
import 'package:tee_rk/repositories/product_repository.dart';
import 'package:tee_rk/screens/product/product_detail_screen.dart';
import 'package:tee_rk/widgets/common/cart_button.dart';
import 'package:tee_rk/widgets/common/error_view.dart';

late FakeProductRepository repository;

Widget _app(String id) {
  return ProviderScope(
    overrides: [productRepositoryProvider.overrideWithValue(repository)],
    child: MaterialApp(home: ProductDetailScreen(productId: id)),
  );
}

/// Boots the screen deterministically:
/// - a phone sized surface, because the default 800x600 test window leaves
///   the lower slivers and the bottom bar unbuilt;
/// - the catalog is read through [WidgetTester.runAsync] first, so the real
///   asset IO completes before the widget pumps under fake time;
/// - plain pumps rather than `pumpAndSettle`, which would never settle while
///   a skeleton is pulsing.
Future<void> _boot(WidgetTester tester, String id) async {
  tester.view.physicalSize = const Size(1200, 2600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.runAsync(repository.fetchProducts);
  await tester.pumpWidget(_app(id));
  await tester.pump();
  await tester.pump();
}

void main() {
  setUp(() => repository = FakeProductRepository(latency: Duration.zero));

  testWidgets('renders the product and gates add to bag on size', (
    tester,
  ) async {
    await _boot(tester, 'tee-001');

    expect(find.text('RKN-ATHL. URBAN CANVAS TEE'), findsOneWidget);
    expect(find.text('129 000 Ar'), findsWidgets);
    // Header eyebrow plus the details table row.
    expect(find.text('T-SHIRTS'), findsNWidgets(2));
    expect(find.text('IN STOCK'), findsOneWidget);
    expect(find.text('SELECT A SIZE'), findsOneWidget);

    // Multi size product: the CTA stays disabled until a size is picked.
    expect(tester.widget<CartButton>(find.byType(CartButton)).onPressed, isNull);
    expect(find.text('NO SIZE'), findsOneWidget);

    await tester.tap(find.text('L'));
    await tester.pump();

    expect(find.text('SIZE L'), findsOneWidget);
    expect(find.text('SELECT A SIZE'), findsNothing);
    expect(
      tester.widget<CartButton>(find.byType(CartButton)).onPressed,
      isNotNull,
    );
  });

  testWidgets('single size products are preselected', (tester) async {
    await _boot(tester, 'acc-004');

    expect(find.text('SIZE ONE SIZE'), findsOneWidget);
    expect(
      tester.widget<CartButton>(find.byType(CartButton)).onPressed,
      isNotNull,
    );
  });

  testWidgets('sold out products cannot be added', (tester) async {
    await _boot(tester, 'tee-004');

    // Once on the stock line, once as the disabled button label.
    expect(find.text('SOLD OUT'), findsNWidgets(2));
    expect(tester.widget<CartButton>(find.byType(CartButton)).onPressed, isNull);
  });

  testWidgets('unknown id shows the error state', (tester) async {
    await _boot(tester, 'does-not-exist');

    expect(find.byType(ErrorView), findsOneWidget);
    expect(find.textContaining('No product matches'), findsOneWidget);
  });

  test('selecting a size stores it per product', () {
    final container = ProviderContainer(
      overrides: [
        productRepositoryProvider.overrideWithValue(
          FakeProductRepository(latency: Duration.zero),
        ),
      ],
    );
    addTearDown(container.dispose);

    container.read(selectedSizesProvider.notifier).select('tee-001', 'M');
    container.read(selectedSizesProvider.notifier).select('snk-001', '43');

    expect(container.read(selectedSizesProvider), {
      'tee-001': 'M',
      'snk-001': '43',
    });

    container.read(selectedSizesProvider.notifier).clear('tee-001');
    expect(container.read(selectedSizesProvider), {'snk-001': '43'});
  });
}
