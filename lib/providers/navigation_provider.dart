import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The five root destinations of the app shell.
enum AppTab { home, shop, favorites, cart, profile }

/// Holds the selected root tab.
///
/// Navigation state lives in Riverpod so any screen can jump to another
/// tab (e.g. "continue shopping" from the empty bag) without callbacks.
class NavigationNotifier extends Notifier<AppTab> {
  @override
  AppTab build() => AppTab.home;

  void select(AppTab tab) => state = tab;
}

final navigationProvider = NotifierProvider<NavigationNotifier, AppTab>(
  NavigationNotifier.new,
);
