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
        final isSmallHeight = constraints.maxHeight < 620;

        final illustrationSize = ResponsiveUtils.value(
          context,
          mobile: ResponsiveUtils.isSmallMobile(context)
              ? 176
              : isSmallHeight
                  ? 190
                  : 210,
          tablet: 260,
          large: 300,
        );

        final contentSpacing = ResponsiveUtils.value(
          context,
          mobile: isSmallHeight
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
          tablet: 460,
          large: 540,
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

              SizedBox(
                height: contentSpacing,
              ),

              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: titleWidth,
                ),
                child: Text(
                  data.title,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: theme.brightness == Brightness.dark
                        ? AppColors.darkTextPrimary
                        : AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.sm),

              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: descriptionWidth,
                ),
                child: Text(
                  data.description,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.brightness == Brightness.dark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
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