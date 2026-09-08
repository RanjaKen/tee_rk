import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/rk_app_bar.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const RkAppBar(title: AppStrings.favoritesTitle),
      body: const EmptyState(
        icon: Icons.favorite_border,
        title: 'No favorites yet',
        message: 'Saved products will be stored on this device (Step 6).',
      ),
    );
  }
}
