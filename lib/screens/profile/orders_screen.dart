import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../providers/profile_providers.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/error_view.dart';
import '../../widgets/common/rk_app_bar.dart';
import '../../widgets/common/skeleton.dart';
import '../../widgets/profile/order_tile.dart';

/// Full order history.
class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(ordersProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: RkAppBar(
        title: 'ORDERS',
        showLogo: false,
        showAnnouncement: false,
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: orders.when(
        loading: () => const SkeletonPulse(
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.page),
            child: Column(
              children: [
                SkeletonBox(height: 170),
                SizedBox(height: AppSpacing.md),
                SkeletonBox(height: 170),
              ],
            ),
          ),
        ),
        error: (error, _) => ErrorView(
          error: error,
          onRetry: () => ref.invalidate(ordersProvider),
        ),
        data: (list) {
          if (list.isEmpty) {
            return const EmptyState(
              icon: Icons.receipt_long_outlined,
              title: 'No orders yet',
              message: 'Your placed orders will appear here.',
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.page),
            itemCount: list.length,
            itemBuilder: (context, index) => OrderTile(
              order: list[index],
              onTapLine: (line) =>
                  AppRouter.openProduct(context, line.productId),
            ),
          );
        },
      ),
    );
  }
}
