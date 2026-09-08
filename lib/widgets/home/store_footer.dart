import 'package:flutter/material.dart';

import '../../core/constants/app_assets.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';

/// Newsletter block closing the home feed, mirroring the reference layout.
class StoreFooter extends StatefulWidget {
  const StoreFooter({super.key});

  @override
  State<StoreFooter> createState() => _StoreFooterState();
}

class _StoreFooterState extends State<StoreFooter> {
  final TextEditingController _email = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  void _subscribe() {
    final value = _email.text.trim();
    final valid = value.contains('@') && value.contains('.');

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            valid
                ? 'Subscribed. Welcome to the TEE_RK list.'
                : 'Enter a valid email address.',
          ),
        ),
      );

    if (valid) _email.clear();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.page,
        AppSpacing.xxl,
        AppSpacing.page,
        AppSpacing.xxl,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('SUBSCRIBE TO NEWSLETTER', style: AppTypography.label),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _subscribe(),
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  decoration: const InputDecoration(hintText: 'EMAIL'),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              IconButton(
                onPressed: _subscribe,
                icon: const Icon(Icons.north_east),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),
          Image.asset(AppAssets.logoWhite, height: 20),
          const SizedBox(height: AppSpacing.md),
          Text(
            '${AppStrings.appName} — ${AppStrings.tagline}',
            style: AppTypography.labelSmall,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '© 2026 RanjaKen. All rights reserved.',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textMuted,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
