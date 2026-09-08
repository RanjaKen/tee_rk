import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Product shot on a neutral backdrop, with a fallback when the asset
/// is missing so a bad path never crashes a grid.
class ProductImage extends StatelessWidget {
  const ProductImage({
    super.key,
    required this.path,
    this.fit = BoxFit.cover,
    this.heroTag,
  });

  final String path;
  final BoxFit fit;
  final Object? heroTag;

  @override
  Widget build(BuildContext context) {
    final image = Image.asset(
      path,
      fit: fit,
      filterQuality: FilterQuality.medium,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded) return child;
        return AnimatedOpacity(
          opacity: frame == null ? 0 : 1,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          child: child,
        );
      },
      errorBuilder: (_, _, _) => const ColoredBox(
        color: AppColors.imageBackdrop,
        child: Center(
          child: Icon(
            Icons.image_not_supported_outlined,
            color: AppColors.textMuted,
          ),
        ),
      ),
    );

    return ColoredBox(
      color: AppColors.imageBackdrop,
      child: SizedBox.expand(
        child: heroTag == null ? image : Hero(tag: heroTag!, child: image),
      ),
    );
  }
}
