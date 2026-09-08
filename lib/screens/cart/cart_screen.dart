import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_config.dart';
import '../../core/constants/app_strings.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/price_formatter.dart';
import '../../models/cart_item.dart';
import '../../providers/cart_provider.dart';
import '../../providers/navigation_provider.dart';
import '../../widgets/cart/cart_line_tile.dart';
import '../../widgets/common/cart_button.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/rk_app_bar.dart';

/// The bag: lines, quantity edits and the order summary.
class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(cartProvider);
    final count = ref.watch(cartCountProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: RkAppBar(
        title: AppStrings.cartTitle,
        actions: [
          if (items.isNotEmpty)
            TextButton(
              onPressed: () => _confirmClear(context, ref),
              child: const Text('CLEAR'),
            ),
        ],
      ),
      body: items.isEmpty
          ? EmptyState(
              icon: Icons.shopping_bag_outlined,
              title: 'Your bag is empty',
              message: 'Browse the drop and add something to it.',
              actionLabel: 'Start shopping',
              onAction: () =>
                  ref.read(navigationProvider.notifier).select(AppTab.shop),
            )
          : ListView(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.lg),
                  child: Text(
                    '$count ${count == 1 ? 'ITEM' : 'ITEMS'}',
                    style: AppTypography.labelSmall,
                  ),
                ),
                for (final item in items) ...[
                  CartLineTile(
                    item: item,
                    onIncrement: () =>
                        ref.read(cartProvider.notifier).increment(item.key),
                    onDecrement: () =>
                        ref.read(cartProvider.notifier).decrement(item.key),
                    onRemove: () => _removeLine(context, ref, item),
                    onTap: () =>
                        AppRouter.openProduct(context, item.product.id),
                  ),
                  const Divider(),
                ],
                const SizedBox(height: AppSpacing.lg),
                const _OrderSummary(),
                const SizedBox(height: AppSpacing.xxl),
              ],
            ),
      bottomNavigationBar: items.isEmpty ? null : const _CheckoutBar(),
    );
  }

  void _removeLine(BuildContext context, WidgetRef ref, CartItem item) {
    ref.read(cartProvider.notifier).remove(item.key);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('${item.product.name} removed'),
          action: SnackBarAction(
            label: 'UNDO',
            textColor: AppColors.accent,
            onPressed: () => ref
                .read(cartProvider.notifier)
                .add(item.product, item.size, quantity: item.quantity),
          ),
        ),
      );
  }

  Future<void> _confirmClear(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surfaceAlt,
        title: Text('EMPTY THE BAG?', style: AppTypography.label),
        content: Text(
          'This removes every item from your bag.',
          style: AppTypography.bodySmall,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              'EMPTY',
              style: AppTypography.label.copyWith(color: AppColors.accent),
            ),
          ),
        ],
      ),
    );

    if (confirmed ?? false) ref.read(cartProvider.notifier).clear();
  }
}

/// Subtotal, shipping and total.
class _OrderSummary extends ConsumerWidget {
  const _OrderSummary();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subtotal = ref.watch(cartSubtotalProvider);
    final shipping = ref.watch(cartShippingProvider);
    final total = ref.watch(cartTotalProvider);
    final missing = AppConfig.freeShippingThreshold - subtotal;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _SummaryRow(label: 'SUBTOTAL', value: PriceFormatter.format(subtotal)),
          const SizedBox(height: AppSpacing.sm),
          _SummaryRow(
            label: 'SHIPPING',
            value: shipping == 0 ? 'FREE' : PriceFormatter.format(shipping),
          ),
          if (missing > 0) ...[
            const SizedBox(height: AppSpacing.sm),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'ADD ${PriceFormatter.format(missing)} FOR FREE SHIPPING',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.accent,
                ),
              ),
            ),
          ],
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Divider(),
          ),
          _SummaryRow(
            label: 'TOTAL',
            value: PriceFormatter.format(total),
            emphasised: true,
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.emphasised = false,
  });

  final String label;
  final String value;
  final bool emphasised;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: emphasised
              ? AppTypography.label
              : AppTypography.labelSmall.copyWith(
                  color: AppColors.textSecondary,
                ),
        ),
        Text(
          value,
          style: emphasised
              ? AppTypography.price.copyWith(fontSize: 16)
              : AppTypography.price.copyWith(fontSize: 12),
        ),
      ],
    );
  }
}

/// Sticky checkout bar.
class _CheckoutBar extends ConsumerWidget {
  const _CheckoutBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final total = ref.watch(cartTotalProvider);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.page),
          child: CartButton(
            label: 'Checkout',
            price: total,
            icon: Icons.lock_outline,
            onPressed: () => _checkout(context, ref),
          ),
        ),
      ),
    );
  }

  void _checkout(BuildContext context, WidgetRef ref) {
    final total = ref.read(cartTotalProvider);
    ref.read(cartProvider.notifier).clear();

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            'Order placed · ${PriceFormatter.format(total)}. '
            'Payment is mocked in this build.',
          ),
        ),
      );
  }
}
