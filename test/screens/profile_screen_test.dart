import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tee_rk/providers/favorites_provider.dart';
import 'package:tee_rk/providers/product_providers.dart';
import 'package:tee_rk/providers/profile_providers.dart';
import 'package:tee_rk/repositories/favorites_repository.dart';
import 'package:tee_rk/repositories/product_repository.dart';
import 'package:tee_rk/repositories/profile_repository.dart';
import 'package:tee_rk/screens/profile/profile_screen.dart';
import 'package:tee_rk/widgets/profile/order_tile.dart';

Future<ProviderContainer> _pumpProfile(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1200, 3200);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final container = ProviderContainer(
    overrides: [
      productRepositoryProvider.overrideWithValue(
        FakeProductRepository(latency: Duration.zero),
      ),
      profileRepositoryProvider.overrideWithValue(
        MockProfileRepository(latency: Duration.zero),
      ),
      favoritesRepositoryProvider.overrideWithValue(
        InMemoryFavoritesRepository(initial: {'tee-001'}),
      ),
    ],
  );
  addTearDown(container.dispose);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: ProfileScreen()),
    ),
  );
  for (var i = 0; i < 4; i++) {
    await tester.pump(const Duration(milliseconds: 20));
  }

  return container;
}

void main() {
  testWidgets('renders the account header and stats', (tester) async {
    await _pumpProfile(tester);

    expect(find.text('RANJA ANDRIAMALALA'), findsOneWidget);
    expect(find.text('ranja@tee-rk.mg'), findsOneWidget);
    expect(find.text('RA'), findsOneWidget); // avatar initials
    expect(find.textContaining('COURTSIDE MEMBER'), findsOneWidget);
    expect(find.text('MEMBER SINCE 2024'), findsOneWidget);

    expect(find.text('ORDERS'), findsWidgets);
    expect(find.text('SAVED'), findsOneWidget);
    expect(find.text('IN BAG'), findsOneWidget);
  });

  testWidgets('shows the recent orders', (tester) async {
    await _pumpProfile(tester);

    expect(find.byType(OrderTile), findsNWidgets(2));
    expect(find.text('RK-2608-0142'), findsOneWidget);
    expect(find.text('DELIVERED'), findsOneWidget);
    expect(find.text('434 000 Ar'), findsOneWidget);
  });

  testWidgets('settings switches update the provider', (tester) async {
    final container = await _pumpProfile(tester);

    expect(container.read(settingsProvider).newsletter, isFalse);

    await tester.tap(find.byType(Switch).at(1)); // newsletter
    await tester.pump();

    expect(container.read(settingsProvider).newsletter, isTrue);
  });

  testWidgets('favorites count comes from the favorites provider', (
    tester,
  ) async {
    final container = await _pumpProfile(tester);

    expect(container.read(favoritesCountProvider), 1);
    expect(find.text('FAVORITES'), findsOneWidget);
  });
}
