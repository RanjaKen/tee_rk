import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/cart_provider.dart';
import '../../providers/navigation_provider.dart';
import '../../widgets/common/rk_bottom_nav.dart';
import '../cart/cart_screen.dart';
import '../favorites/favorites_screen.dart';
import '../home/home_screen.dart';
import '../profile/profile_screen.dart';
import '../search/search_screen.dart';

/// Root scaffold: keeps the five destinations alive in an [IndexedStack]
/// so scroll position and local state survive tab switches.
class MainShell extends ConsumerWidget {
  const MainShell({super.key});

  static const List<Widget> _screens = [
    HomeScreen(),
    SearchScreen(),
    FavoritesScreen(),
    CartScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tab = ref.watch(navigationProvider);
    final cartCount = ref.watch(cartCountProvider);

    return Scaffold(
      body: IndexedStack(index: tab.index, children: _screens),
      bottomNavigationBar: RkBottomNav(
        current: tab,
        cartCount: cartCount,
        onSelect: (next) => ref.read(navigationProvider.notifier).select(next),
      ),
    );
  }
}
