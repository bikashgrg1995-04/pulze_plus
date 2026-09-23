import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
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
    if (label == null) {
      return Padding(
        padding: padding ?? EdgeInsets.zero,
        child: Divider(
          color: color ?? AppColors.border,
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
              color: color ?? AppColors.border,
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
                    color: AppColors.textTertiary,
                  ),
            ),
          ),
          Expanded(
            child: Divider(
              color: color ?? AppColors.border,
              thickness: thickness,
              height: thickness,
            ),
          ),
        ],
      ),
    );
  }
}