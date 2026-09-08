import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../product/product_grid.dart';

/// Softly pulsing placeholder block. Lightweight on purpose: one
/// animation controller drives the whole subtree via [_SkeletonPulse].
class SkeletonBox extends StatelessWidget {
  const SkeletonBox({
    super.key,
    this.height,
    this.width,
    this.radius = AppSpacing.radiusSm,
  });

  final double? height;
  final double? width;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

/// Wraps a skeleton subtree in a slow opacity pulse.
class SkeletonPulse extends StatefulWidget {
  const SkeletonPulse({super.key, required this.child});

  final Widget child;

  @override
  State<SkeletonPulse> createState() => _SkeletonPulseState();
}

class _SkeletonPulseState extends State<SkeletonPulse>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.45, end: 1).animate(_controller),
      child: widget.child,
    );
  }
}

/// Loading state for any product grid.
class SliverProductGridSkeleton extends StatelessWidget {
  const SliverProductGridSkeleton({super.key, this.itemCount = 6});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
      sliver: SliverGrid.builder(
        gridDelegate: SliverProductGrid.delegate,
        itemCount: itemCount,
        itemBuilder: (context, index) => const SkeletonPulse(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: SkeletonBox()),
              SizedBox(height: AppSpacing.sm),
              SkeletonBox(height: 10, width: 70),
              SizedBox(height: AppSpacing.xs),
              SkeletonBox(height: 9),
            ],
          ),
        ),
      ),
    );
  }
}
