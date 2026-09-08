import 'package:flutter/material.dart';

import '../../core/constants/app_assets.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';

/// Branded app bar: RanjaKen logo on the left, actions on the right,
/// thin announcement strip underneath.
class RkAppBar extends StatelessWidget implements PreferredSizeWidget {
  const RkAppBar({
    super.key,
    this.title,
    this.actions = const <Widget>[],
    this.showAnnouncement = true,
    this.showLogo = true,
    this.leading,
  });

  /// Uppercase screen title. When null the logo stands alone.
  final String? title;
  final List<Widget> actions;
  final bool showAnnouncement;
  final bool showLogo;
  final Widget? leading;

  static const double _announcementHeight = 26;
  static const double _barHeight = 56;

  @override
  Size get preferredSize => Size.fromHeight(
    _barHeight + (showAnnouncement ? _announcementHeight : 0) + 1,
  );

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: leading,
      automaticallyImplyLeading: leading != null,
      titleSpacing: leading != null ? 0 : AppSpacing.page,
      toolbarHeight: _barHeight,
      title: showLogo
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  AppAssets.logoWhite,
                  height: 22,
                  filterQuality: FilterQuality.medium,
                ),
                if (title != null) ...[
                  const SizedBox(width: AppSpacing.md),
                  Container(width: 1, height: 16, color: AppColors.border),
                  const SizedBox(width: AppSpacing.md),
                  Text(title!.toUpperCase(), style: AppTypography.label),
                ],
              ],
            )
          : Text(title?.toUpperCase() ?? '', style: AppTypography.label),
      actions: [
        ...actions,
        const SizedBox(width: AppSpacing.sm),
      ],
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(
          (showAnnouncement ? _announcementHeight : 0) + 1,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showAnnouncement)
              Container(
                height: _announcementHeight,
                width: double.infinity,
                alignment: Alignment.center,
                color: AppColors.surfaceAlt,
                child: Text(
                  AppStrings.announcement,
                  style: AppTypography.labelSmall,
                ),
              ),
            Container(height: 1, color: AppColors.border),
          ],
        ),
      ),
    );
  }
}
