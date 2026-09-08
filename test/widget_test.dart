import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tee_rk/main.dart';
import 'package:tee_rk/providers/product_providers.dart';
import 'package:tee_rk/providers/profile_providers.dart';
import 'package:tee_rk/providers/favorites_provider.dart';
import 'package:tee_rk/repositories/favorites_repository.dart';
import 'package:tee_rk/repositories/product_repository.dart';
import 'package:tee_rk/repositories/profile_repository.dart';
import 'package:tee_rk/screens/shell/main_shell.dart';
import 'package:tee_rk/widgets/product/product_card.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('app boots into the main shell and renders the feed', (
    tester,
  ) async {
    // The editorial feed opens with a 380px banner, so the first product
    // cards only exist on a phone sized surface.
    tester.view.physicalSize = const Size(1200, 2600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final repository = FakeProductRepository(latency: Duration.zero);
    // Warm the catalog so the asset IO is done before pumping under fake time.
    await tester.runAsync(repository.fetchProducts);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          productRepositoryProvider.overrideWithValue(repository),
          favoritesRepositoryProvider.overrideWithValue(
            InMemoryFavoritesRepository(),
          ),
          // The shell builds every tab, including the profile.
          profileRepositoryProvider.overrideWithValue(
            MockProfileRepository(latency: Duration.zero),
          ),
        ],
        child: const TeeRkApp(),
      ),
    );

    // Bounded pumps rather than pumpAndSettle: the loading skeleton pulses
    // forever, so a settle would never complete.
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 20));
    }

    expect(find.byType(MainShell), findsOneWidget);
    expect(find.text('HOME'), findsOneWidget);
    expect(find.text('BAG'), findsOneWidget);
    expect(find.text('SAVED'), findsOneWidget);
    expect(find.byType(ProductCard), findsWidgets);
  });
}
