import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';

class AppDivider extends StatelessWidget {
  const AppDivider({
    super.key,
    this.label,
    this.padding,
    this.color,
    this.thickness = 1,
  });

  final String? label;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final double thickness;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final dividerColor = color ?? colorScheme.outline;

    if (label == null) {
      return Padding(
        padding: padding ?? EdgeInsets.zero,
        child: Divider(
          color: dividerColor,
          thickness: thickness,
          height: thickness,
        ),
      );
    }

    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: Row(
        children: [
          Expanded(
            child: Divider(
              color: dividerColor,
              thickness: thickness,
              height: thickness,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
            ),
            child: Text(
              label!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
          Expanded(
            child: Divider(
              color: dividerColor,
              thickness: thickness,
              height: thickness,
            ),
          ),
        ],
      ),
    );
  }
}