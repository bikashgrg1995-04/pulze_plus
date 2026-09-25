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
      tablet: AppSpacing.md,
      large: AppSpacing.md,
    );

    final iconContainerSize =
        ResponsiveUtils.value(
      context,
      mobile: 40.0,
      tablet: 44.0,
      large: 46.0,
    );

    final iconSize = ResponsiveUtils.value(
      context,
      mobile: 21.0,
      tablet: 22.0,
      large: 23.0,
    );

    final chevronSize = ResponsiveUtils.value(
      context,
      mobile: 22.0,
      tablet: 23.0,
      large: 24.0,
    );

    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
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
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius:
                          BorderRadius.circular(
                        AppRadius.md,
                      ),
                    ),
                    child: Icon(
                      icon,
                      size: iconSize,
                      color: AppColors.textSecondary,
                    ),
                  ),

                  SizedBox(
                    width: ResponsiveUtils.value(
                      context,
                      mobile: AppSpacing.md,
                      tablet: AppSpacing.lg,
                      large: AppSpacing.lg,
                    ),
                  ),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow:
                              TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(
                            color:
                                AppColors.textPrimary,
                            fontWeight:
                                FontWeight.w600,
                          ),
                        ),

                        if (subtitle != null &&
                            subtitle!
                                .trim()
                                .isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            subtitle!,
                            maxLines: 2,
                            overflow:
                                TextOverflow.ellipsis,
                            style: theme
                                .textTheme.bodySmall
                                ?.copyWith(
                              color: AppColors
                                  .textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(
                    width: AppSpacing.sm,
                  ),

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
          Divider(
            height: 1,
            indent: horizontalPadding +
                iconContainerSize +
                AppSpacing.md,
            color: AppColors.border,
          ),
      ],
    );
  }
}