import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../providers/navigation_provider.dart';

/// Minimal bottom navigation: hairline top border, small caps labels,
/// accent underline on the active destination.
class RkBottomNav extends StatelessWidget {
  const RkBottomNav({
    super.key,
    required this.current,
    required this.onSelect,
    this.cartCount = 0,
  });

  final AppTab current;
  final ValueChanged<AppTab> onSelect;

  /// Badge shown on the bag destination (wired to the cart in Step 5).
  final int cartCount;

  static const List<(AppTab, IconData, String)> _items = [
    (AppTab.home, Icons.home_outlined, AppStrings.navHome),
    (AppTab.shop, Icons.grid_view_outlined, AppStrings.navSearch),
    (AppTab.favorites, Icons.favorite_border, AppStrings.navFavorites),
    (AppTab.cart, Icons.shopping_bag_outlined, AppStrings.navCart),
    (AppTab.profile, Icons.person_outline, AppStrings.navProfile),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Row(
            children: [
              for (final (tab, icon, label) in _items)
                Expanded(
                  child: _NavItem(
                    icon: icon,
                    label: label,
                    selected: tab == current,
                    badge: tab == AppTab.cart ? cartCount : 0,
                    onTap: () => onSelect(tab),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.badge,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final int badge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.textPrimary : AppColors.textMuted;

    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            height: 2,
            width: selected ? 18 : 0,
            color: AppColors.accent,
          ),
          const SizedBox(height: AppSpacing.sm),
          Badge(
            isLabelVisible: badge > 0,
            label: Text('$badge'),
            backgroundColor: AppColors.accent,
            textColor: AppColors.onAccent,
            child: Icon(icon, size: 21, color: color),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}
