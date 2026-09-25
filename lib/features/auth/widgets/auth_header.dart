import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/responsive_utils.dart';

class AuthHeader extends StatelessWidget {
  const AuthHeader({
    super.key,
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final logoSize = ResponsiveUtils.value(
      context,
      mobile: 64.0,
      tablet: 72.0,
      large: 80.0,
    );

    final titleSpacing = ResponsiveUtils.value(
      context,
      mobile: AppSpacing.lg,
      tablet: AppSpacing.xl,
      large: AppSpacing.xl,
    );

    final subtitleMaxWidth = ResponsiveUtils.value(
      context,
      mobile: 340.0,
      tablet: 400.0,
      large: 440.0,
    );

    return Column(
      children: [
        Container(
          width: logoSize,
          height: logoSize,
          decoration: BoxDecoration(
            color: AppColors.surface,
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.border,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(
              logoSize * 0.16,
            ),
            child: SvgPicture.asset(
              'assets/branding/app_icon.svg',
              fit: BoxFit.contain,
            ),
          ),
        ),

        SizedBox(
          height: titleSpacing,
        ),

        Text(
          title,
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineMedium?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),

        const SizedBox(
          height: AppSpacing.xs,
        ),

        ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: subtitleMaxWidth,
          ),
          child: Text(
            subtitle,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}