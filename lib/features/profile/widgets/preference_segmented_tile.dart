import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/responsive_utils.dart';

class PreferenceSegmentedTile<T> extends StatelessWidget {
  const PreferenceSegmentedTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.options,
    required this.onChanged,
    this.showDivider = true,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final T value;
  final List<PreferenceSegment<T>> options;
  final ValueChanged<T> onChanged;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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

    final contentSpacing = ResponsiveUtils.value(
      context,
      mobile: AppSpacing.sm,
      tablet: AppSpacing.md,
      large: AppSpacing.md,
    );

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: verticalPadding,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: iconContainerSize,
                height: iconContainerSize,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(
                    AppRadius.md,
                  ),
                ),
                child: Icon(
                  icon,
                  size: iconSize,
                  color: colorScheme.onSurfaceVariant,
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
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: AppSpacing.xs),

              SizedBox(
                width: 112,
                height: 34,
                child: FittedBox(
                  fit: BoxFit.contain,
                  alignment: Alignment.centerRight,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(
                        AppRadius.lg,
                      ),
                      border: Border.all(
                        color: colorScheme.outline,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: options.map((option) {
                        final isSelected = option.value == value;

                        return GestureDetector(
                          onTap: isSelected
                              ? null
                              : () => onChanged(option.value),
                          child: AnimatedContainer(
                            duration: const Duration(
                              milliseconds: 180,
                            ),
                            curve: Curves.easeOut,
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: AppSpacing.xs,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(
                                AppRadius.md,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (option.icon != null) ...[
                                  Icon(
                                    option.icon,
                                    size: 15,
                                    color: isSelected
                                        ? Colors.white
                                        : colorScheme.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 4),
                                ],
                                Text(
                                  option.label,
                                  style:
                                      theme.textTheme.labelSmall?.copyWith(
                                    color: isSelected
                                        ? Colors.white
                                        : colorScheme.onSurfaceVariant,
                                    fontWeight: isSelected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        if (showDivider)
          Padding(
            padding: EdgeInsets.only(
              left: horizontalPadding +
                  iconContainerSize +
                  contentSpacing,
            ),
            child: Divider(
              height: 1,
              color: colorScheme.outline,
            ),
          ),
      ],
    );
  }
}

class PreferenceSegment<T> {
  const PreferenceSegment({
    required this.value,
    required this.label,
    this.icon,
  });

  final T value;
  final String label;
  final IconData? icon;
}