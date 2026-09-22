import 'package:flutter/material.dart';
import 'package:pulze_plus/features/onboarding/model/onboarding_data.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/responsive_utils.dart';
import 'onboarding_illustration.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({
    super.key,
    required this.data,
    required this.horizontalPadding,
  });

  final OnboardingData data;
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final illustrationSize = ResponsiveUtils.value(
          context,
          mobile: ResponsiveUtils.isSmallMobile(context) ? 180 : 210,
          tablet: 260,
          large: 300,
        );

        final titleSpacing = ResponsiveUtils.value(
          context,
          mobile: constraints.maxHeight < 620
              ? AppSpacing.lg
              : AppSpacing.xxl,
          tablet: AppSpacing.xxl,
          large: AppSpacing.xxxl,
        );

        final titleWidth = ResponsiveUtils.value(
          context,
          mobile: 340,
          tablet: 520,
          large: 620,
        );

        final descriptionWidth = ResponsiveUtils.value(
          context,
          mobile: 340,
          tablet: 440,
          large: 520,
        );

        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
          ),
          child: Column(
            children: [
              const Spacer(),

              OnboardingIllustration(
                icon: data.icon,
                size: illustrationSize,
              ),

              SizedBox(height: titleSpacing),

              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: titleWidth,
                ),
                child: Text(
                  data.title,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: descriptionWidth,
                ),
                child: Text(
                  data.description,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),

              const Spacer(),
            ],
          ),
        );
      },
    );
  }
}