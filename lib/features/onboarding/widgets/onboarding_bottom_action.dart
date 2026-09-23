import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/responsive_utils.dart';

class OnboardingBottomAction extends StatelessWidget {
  const OnboardingBottomAction({
    super.key,
    required this.currentPage,
    required this.lastPage,
    required this.onPressed,
    required this.horizontalPadding,
  });

  final int currentPage;
  final int lastPage;
  final VoidCallback onPressed;
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    final isLastPage = currentPage == lastPage;

    final buttonWidth = ResponsiveUtils.value(
      context,
      mobile: double.infinity,
      tablet: 420,
      large: 480,
    );

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveUtils.isMobile(context)
            ? horizontalPadding
            : 0,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: buttonWidth,
        ),
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  AppRadius.md,
                ),
              ),
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              child: Text(
                isLastPage ? 'Get Started' : 'Next',
                key: ValueKey(isLastPage),
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}