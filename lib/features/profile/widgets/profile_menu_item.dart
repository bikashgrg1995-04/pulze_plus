import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/responsive_utils.dart';

class ProfileMenuItem extends StatelessWidget {
  const ProfileMenuItem({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
    this.showDivider = true,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final horizontalPadding = ResponsiveUtils.value(
      context,
      mobile: AppSpacing.md,
      tablet: AppSpacing.lg,
      large: AppSpacing.xl,
    );

    final verticalPadding = ResponsiveUtils.value(
      context,
      mobile: AppSpacing.sm,
      tablet: AppSpacing.sm,
      large: AppSpacing.md,
    );

    final iconContainerSize = ResponsiveUtils.value(
      context,
      mobile: 36.0,
      tablet: 40.0,
      large: 42.0,
    );

    final iconSize = ResponsiveUtils.value(
      context,
      mobile: 19.0,
      tablet: 20.0,
      large: 21.0,
    );

    final chevronSize = ResponsiveUtils.value(
      context,
      mobile: 20.0,
      tablet: 21.0,
      large: 22.0,
    );

    final contentSpacing = ResponsiveUtils.value(
      context,
      mobile: AppSpacing.sm,
      tablet: AppSpacing.md,
      large: AppSpacing.md,
    );

    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: verticalPadding,
              ),
              child: Row(
                children: [
                  Container(
                    width: iconContainerSize,
                    height: iconContainerSize,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(
                        AppRadius.md,
                      ),
                    ),
                    child: Icon(
                      icon,
                      size: iconSize,
                      color: AppColors.textSecondary,
                    ),
                  ),

                  SizedBox(width: contentSpacing),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (subtitle != null &&
                            subtitle!.trim().isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            subtitle!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(width: AppSpacing.xs),

                  Icon(
                    Icons.chevron_right_rounded,
                    size: chevronSize,
                    color: AppColors.textTertiary,
                  ),
                ],
              ),
            ),
          ),
        ),

        if (showDivider)
          Padding(
            padding: EdgeInsets.only(
              left: horizontalPadding +
                  iconContainerSize +
                  contentSpacing,
            ),
            child: const Divider(
              height: 1,
              color: AppColors.border,
            ),
          ),
      ],
    );
  }
}