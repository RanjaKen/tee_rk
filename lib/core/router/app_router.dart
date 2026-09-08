import 'package:flutter/material.dart';

import '../../screens/product/product_detail_screen.dart';
import '../../screens/shell/main_shell.dart';
import '../../widgets/common/empty_state.dart';

/// Route names. Detail routes get wired as the matching step lands.
class AppRoutes {
  const AppRoutes._();

  static const String home = '/';
  static const String productDetail = '/product';
}

/// Central route table. The shell owns tab navigation; the router only
/// handles pushed full screen routes (product detail, checkout...).
class AppRouter {
  const AppRouter._();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.home:
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const MainShell(),
        );
      case AppRoutes.productDetail:
        final id = settings.arguments;
        if (id is! String) return _unknown(settings);
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => ProductDetailScreen(productId: id),
        );
      default:
        return _unknown(settings);
    }
  }

  /// Opens the detail page of [productId].
  static Future<void> openProduct(BuildContext context, String productId) {
    return Navigator.of(
      context,
    ).pushNamed(AppRoutes.productDetail, arguments: productId);
  }

  static Route<dynamic> _unknown(RouteSettings settings) {
    return MaterialPageRoute<void>(
      settings: settings,
      builder: (_) => Scaffold(
        appBar: AppBar(),
        body: EmptyState(
          icon: Icons.error_outline,
          title: 'Page not found',
          message: 'No route registered for "${settings.name}".',
        ),
      ),
    );
  }
}
