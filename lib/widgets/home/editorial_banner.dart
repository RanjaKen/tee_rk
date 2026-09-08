import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../product/product_image.dart';

/// Full bleed lookbook block: image, optional eyebrow, uppercase caption
/// underneath. The editorial rhythm of the home feed.
class EditorialBanner extends StatelessWidget {
  const EditorialBanner({
    super.key,
    required this.image,
    required this.caption,
    this.eyebrow,
    this.height = 340,
    this.onTap,
    this.overlayLabel,
  });

  final String image;
  final String caption;
  final String? eyebrow;
  final double height;
  final VoidCallback? onTap;

  /// Small tag drawn over the image, e.g. `DROP 02`.
  final String? overlayLabel;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: height,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                ProductImage(path: image),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Color(0x66000000)],
                      stops: [0.55, 1],
                    ),
                  ),
                ),
                if (overlayLabel != null)
                  Positioned(
                    left: AppSpacing.page,
                    top: AppSpacing.lg,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: 4,
                      ),
                      color: AppColors.accent,
                      child: Text(
                        overlayLabel!.toUpperCase(),
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.onAccent,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.page,
              AppSpacing.md,
              AppSpacing.page,
              AppSpacing.lg,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (eyebrow != null) ...[
                  Text(
                    eyebrow!.toUpperCase(),
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.accent,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                ],
                Text(caption.toUpperCase(), style: AppTypography.title),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
