import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class OnboardingIllustration extends StatelessWidget {
  const OnboardingIllustration({
    super.key,
    required this.icon,
    required this.size,
  });

  final IconData icon;
  final double size;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurface
            : AppColors.surface,
        shape: BoxShape.circle,
        border: Border.all(
          color: isDark
              ? AppColors.darkBorder
              : AppColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(
              alpha: isDark ? 0.10 : 0.08,
            ),
            blurRadius: size * 0.12,
            spreadRadius: 0,
            offset: Offset(
              0,
              size * 0.04,
            ),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: size * 0.74,
            height: size * 0.74,
            decoration: BoxDecoration(
              color: AppColors.coral.withValues(
                alpha: isDark ? 0.14 : 0.10,
              ),
              shape: BoxShape.circle,
            ),
          ),
          Container(
            width: size * 0.50,
            height: size * 0.50,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: size * 0.23,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}