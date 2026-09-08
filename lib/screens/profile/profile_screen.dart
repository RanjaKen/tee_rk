import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/rk_app_bar.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const RkAppBar(title: AppStrings.profileTitle),
      body: const EmptyState(
        icon: Icons.person_outline,
        title: 'Profile',
        message: 'Mock account, orders and settings arrive in Step 8.',
      ),
    );
  }
}
