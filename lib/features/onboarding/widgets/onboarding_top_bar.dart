import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

class OnboardingTopBar extends StatelessWidget {
  const OnboardingTopBar({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.horizontalPadding,
    required this.onSkip,
  });

  final int currentPage;
  final int totalPages;
  final double horizontalPadding;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: AppSpacing.sm,
      ),
      child: SizedBox(
        height: 40,
        child: Align(
          alignment: Alignment.centerRight,
          child: currentPage < totalPages - 1
              ? TextButton(
                  onPressed: onSkip,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                  ),
                  child: const Text('Skip'),
                )
              : null,
        ),
      ),
    );
  }
}