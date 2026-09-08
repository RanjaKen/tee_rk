import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tee_rk/providers/product_providers.dart';
import 'package:tee_rk/repositories/product_repository.dart';
import 'package:tee_rk/screens/search/search_screen.dart';
import 'package:tee_rk/widgets/common/error_view.dart';
import 'package:tee_rk/widgets/common/skeleton.dart';
import 'package:tee_rk/widgets/product/product_card.dart';

Widget _app(FakeProductRepository repository) {
  return ProviderScope(
    overrides: [productRepositoryProvider.overrideWithValue(repository)],
    child: const MaterialApp(home: SearchScreen()),
  );
}

/// Warms the catalog through [WidgetTester.runAsync] so the asset IO is
/// finished before the widget pumps under fake time.
Future<void> _warm(WidgetTester tester, FakeProductRepository repository) async {
  await tester.runAsync(() async {
    try {
      await repository.fetchProducts();
    } on Object {
      // The failing repository is expected to throw here.
    }
  });
}

void main() {
  testWidgets('shop grid shows the skeleton then the products', (tester) async {
    final repository = FakeProductRepository(latency: Duration.zero);
    await _warm(tester, repository);
    await tester.pumpWidget(_app(repository));

    expect(find.byType(SliverProductGridSkeleton), findsOneWidget);
    expect(find.byType(ProductCard), findsNothing);

    await tester.pump();
    await tester.pump();

    expect(find.byType(SliverProductGridSkeleton), findsNothing);
    expect(find.byType(ProductCard), findsWidgets);
    expect(find.text('16 PRODUCTS'), findsOneWidget);
    expect(find.textContaining('129 000 Ar'), findsWidgets);
  });

  testWidgets('shop grid shows the error state with a retry', (tester) async {
    final repository = FakeProductRepository(
      latency: Duration.zero,
      shouldFail: true,
    );
    await _warm(tester, repository);
    await tester.pumpWidget(_app(repository));
    await tester.pump();
    await tester.pump();

    expect(find.byType(ErrorView), findsOneWidget);
    expect(find.text('RETRY'), findsOneWidget);
    expect(find.textContaining('Connection lost'), findsOneWidget);
  });
}
