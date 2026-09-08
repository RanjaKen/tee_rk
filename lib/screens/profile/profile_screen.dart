import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_strings.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../models/user_profile.dart';
import '../../providers/cart_provider.dart';
import '../../providers/favorites_provider.dart';
import '../../providers/navigation_provider.dart';
import '../../providers/product_providers.dart';
import '../../providers/profile_providers.dart';
import '../../widgets/common/error_view.dart';
import '../../widgets/common/rk_app_bar.dart';
import '../../widgets/common/section_header.dart';
import '../../widgets/common/skeleton.dart';
import '../../widgets/profile/order_tile.dart';

/// Account tab: identity, stats, recent orders, favorites and settings.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  static const int _recentOrders = 2;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const RkAppBar(title: AppStrings.profileTitle),
      body: profile.when(
        loading: () => const _ProfileSkeleton(),
        error: (error, _) => ErrorView(
          error: error,
          onRetry: () => ref.read(profileProvider.notifier).refresh(),
        ),
        data: (user) => ListView(
          padding: EdgeInsets.zero,
          children: [
            _AccountHeader(user: user),
            const _StatsRow(),
            const _OrdersSection(),
            const _ShortcutsSection(),
            const _SettingsSection(),
            const _DeveloperSection(),
            const _AboutSection(),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }
}

class _AccountHeader extends StatelessWidget {
  const _AccountHeader({required this.user});

  final UserProfile user;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.page),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Container(
            height: 64,
            width: 64,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.accent,
              shape: BoxShape.circle,
            ),
            child: Text(
              user.initials,
              style: AppTypography.headline.copyWith(
                color: AppColors.onAccent,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.fullName.toUpperCase(),
                  style: AppTypography.title,
                ),
                const SizedBox(height: 2),
                Text(user.email, style: AppTypography.bodySmall),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  '${user.tier}  ·  ${user.city}',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.accent,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'MEMBER SINCE ${user.memberSince.year}',
                  style: AppTypography.labelSmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Orders / saved / bag counters, each reading its own provider.
class _StatsRow extends ConsumerWidget {
  const _StatsRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = <(String, int)>[
      ('ORDERS', ref.watch(ordersCountProvider)),
      ('SAVED', ref.watch(favoritesCountProvider)),
      ('IN BAG', ref.watch(cartCountProvider)),
    ];

    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      child: Row(
        children: [
          for (final (label, value) in stats)
            Expanded(
              child: Column(
                children: [
                  Text('$value', style: AppTypography.headline),
                  const SizedBox(height: AppSpacing.xs),
                  Text(label, style: AppTypography.labelSmall),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _OrdersSection extends ConsumerWidget {
  const _OrdersSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(ordersProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'ORDERS',
          actionLabel: 'VIEW ALL',
          onAction: () => Navigator.of(context).pushNamed(AppRoutes.orders),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
          child: orders.when(
            loading: () => const SkeletonPulse(child: SkeletonBox(height: 170)),
            error: (error, _) => ErrorView(
              error: error,
              onRetry: () => ref.invalidate(ordersProvider),
            ),
            data: (list) {
              if (list.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    'No orders yet. Anything you check out shows up here.',
                    style: AppTypography.bodySmall,
                  ),
                );
              }

              return Column(
                children: [
                  for (final order in list.take(ProfileScreen._recentOrders))
                    OrderTile(
                      order: order,
                      onTapLine: (line) =>
                          AppRouter.openProduct(context, line.productId),
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ShortcutsSection extends ConsumerWidget {
  const _ShortcutsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        const SectionHeader(title: 'YOUR STORE'),
        _ProfileRow(
          icon: Icons.favorite_border,
          label: 'FAVORITES',
          trailing: '${ref.watch(favoritesCountProvider)}',
          onTap: () =>
              ref.read(navigationProvider.notifier).select(AppTab.favorites),
        ),
        _ProfileRow(
          icon: Icons.shopping_bag_outlined,
          label: 'YOUR BAG',
          trailing: '${ref.watch(cartCountProvider)}',
          onTap: () => ref.read(navigationProvider.notifier).select(AppTab.cart),
        ),
        _ProfileRow(
          icon: Icons.receipt_long_outlined,
          label: 'ORDER HISTORY',
          trailing: '${ref.watch(ordersCountProvider)}',
          onTap: () => Navigator.of(context).pushNamed(AppRoutes.orders),
        ),
      ],
    );
  }
}

class _SettingsSection extends ConsumerWidget {
  const _SettingsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return Column(
      children: [
        const SectionHeader(title: 'SETTINGS'),
        _SettingSwitch(
          label: 'DROP NOTIFICATIONS',
          description: 'Get told when a new drop lands.',
          value: settings.dropNotifications,
          onChanged: notifier.setDropNotifications,
        ),
        _SettingSwitch(
          label: 'NEWSLETTER',
          description: 'Monthly editorial from the TEE_RK team.',
          value: settings.newsletter,
          onChanged: notifier.setNewsletter,
        ),
        _SettingSwitch(
          label: 'PRICE ALERTS',
          description: 'Ping me when a saved item goes on sale.',
          value: settings.priceAlerts,
          onChanged: notifier.setPriceAlerts,
        ),
      ],
    );
  }
}

/// Switch that forces the catalog into its error state, so loading,
/// error and retry can be checked from the running app.
class _DeveloperSection extends ConsumerWidget {
  const _DeveloperSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        const SectionHeader(title: 'DEVELOPER'),
        _SettingSwitch(
          label: 'SIMULATE NETWORK ERROR',
          description:
              'Force the catalog to fail, to preview the error and retry '
              'states.',
          value: ref.watch(simulateNetworkErrorProvider),
          onChanged: (value) =>
              ref.read(simulateNetworkErrorProvider.notifier).set(value),
        ),
      ],
    );
  }
}

class _AboutSection extends StatelessWidget {
  const _AboutSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SectionHeader(title: 'ABOUT'),
        _ProfileRow(
          icon: Icons.info_outline,
          label: 'APP VERSION',
          trailing: '1.0.0',
          onTap: null,
        ),
        _ProfileRow(
          icon: Icons.logout,
          label: 'SIGN OUT',
          onTap: () => ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(
                content: Text('Accounts are mocked in this build.'),
              ),
            ),
        ),
        Padding(
          padding: const EdgeInsets.all(AppSpacing.page),
          child: Text(
            '${AppStrings.appName} — ${AppStrings.tagline}\n'
            'Favorites are stored on this device. Orders and settings last '
            'for the session.',
            style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
          ),
        ),
      ],
    );
  }
}

class _ProfileRow extends StatelessWidget {
  const _ProfileRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.trailing,
  });

  final IconData icon;
  final String label;
  final String? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.page,
          vertical: AppSpacing.lg,
        ),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.borderSoft)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppColors.textSecondary),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: Text(label, style: AppTypography.label)),
            if (trailing != null)
              Text(
                trailing!,
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            if (onTap != null) ...[
              const SizedBox(width: AppSpacing.sm),
              const Icon(
                Icons.chevron_right,
                size: 18,
                color: AppColors.textMuted,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SettingSwitch extends StatelessWidget {
  const _SettingSwitch({
    required this.label,
    required this.description,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final String description;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.page,
        vertical: AppSpacing.sm,
      ),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.borderSoft)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTypography.label),
                const SizedBox(height: 2),
                Text(description, style: AppTypography.bodySmall),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.onAccent,
            activeTrackColor: AppColors.accent,
          ),
        ],
      ),
    );
  }
}

class _ProfileSkeleton extends StatelessWidget {
  const _ProfileSkeleton();

  @override
  Widget build(BuildContext context) {
    return const SkeletonPulse(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.page),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SkeletonBox(height: 64, radius: AppSpacing.radiusPill),
            SizedBox(height: AppSpacing.xl),
            SkeletonBox(height: 48),
            SizedBox(height: AppSpacing.xl),
            SkeletonBox(height: 170),
            SizedBox(height: AppSpacing.md),
            SkeletonBox(height: 170),
          ],
        ),
      ),
    );
  }
}
