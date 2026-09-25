import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/responsive_utils.dart';

class ProfileCompletionCard extends StatelessWidget {
  const ProfileCompletionCard({
    super.key,
    required this.completion,
    this.onPressed,
  });

  final double completion;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final percentage =
        (completion.clamp(0.0, 1.0) * 100).round();

    final horizontalPadding = ResponsiveUtils.value(
      context,
      mobile: AppSpacing.sm,
      tablet: AppSpacing.md,
      large: AppSpacing.lg,
    );

    final verticalPadding = ResponsiveUtils.value(
      context,
      mobile: AppSpacing.xs,
      tablet: AppSpacing.sm,
      large: AppSpacing.sm,
    );

    final contentSpacing = ResponsiveUtils.value(
      context,
      mobile: AppSpacing.xs,
      tablet: AppSpacing.sm,
      large: AppSpacing.sm,
    );

    final iconSize = ResponsiveUtils.value(
      context,
      mobile: 19.0,
      tablet: 20.0,
      large: 21.0,
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(
          AppRadius.md,
        ),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: verticalPadding,
          ),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(
              alpha: 0.05,
            ),
            borderRadius: BorderRadius.circular(
              AppRadius.md,
            ),
            border: Border.all(
              color: AppColors.primary.withValues(
                alpha: 0.12,
              ),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Complete your profile',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),

              SizedBox(
                width: contentSpacing,
              ),

              Text(
                '$percentage%',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
              ),

              const SizedBox(
                width: AppSpacing.xxs,
              ),

              Icon(
                Icons.chevron_right_rounded,
                size: iconSize,
                color: AppColors.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}