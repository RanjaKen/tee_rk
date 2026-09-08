import 'package:flutter/material.dart';

import '../../core/errors/app_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';

/// Error state with a retry action.
///
/// Knows how to unwrap an [AppException] so the user sees a readable
/// sentence instead of a stack trace.
class ErrorView extends StatelessWidget {
  const ErrorView({
    super.key,
    required this.error,
    this.onRetry,
    this.title = 'SOMETHING WENT WRONG',
  });

  final Object error;
  final VoidCallback? onRetry;
  final String title;

  String get _message => switch (error) {
    final AppException e => e.message,
    _ => 'Unexpected error. Please try again.',
  };

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.wifi_tethering_error_rounded,
              size: 30,
              color: AppColors.accent,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(title, style: AppTypography.label, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.sm),
            Text(
              _message,
              textAlign: TextAlign.center,
              style: AppTypography.bodySmall,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.xl),
              SizedBox(
                width: 200,
                child: OutlinedButton(
                  onPressed: onRetry,
                  child: const Text('RETRY'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
