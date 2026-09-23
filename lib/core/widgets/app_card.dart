import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.gradient,
    this.borderColor,
    this.borderRadius,
    this.onTap,
    this.showBorder = true,
    this.elevation = 0,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final Gradient? gradient;
  final Color? borderColor;
  final double? borderRadius;
  final VoidCallback? onTap;
  final bool showBorder;
  final double elevation;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(
      borderRadius ?? AppRadius.lg,
    );

    final card = Material(
      color: Colors.transparent,
      elevation: elevation,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      borderRadius: radius,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Container(
          width: double.infinity,
          padding: padding ?? const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: gradient == null
                ? backgroundColor ?? AppColors.surface
                : null,
            gradient: gradient,
            borderRadius: radius,
            border: showBorder
                ? Border.all(
                    color: borderColor ?? AppColors.border,
                  )
                : null,
          ),
          child: child,
        ),
      ),
    );

    if (margin == null) {
      return card;
    }

    return Padding(
      padding: margin!,
      child: card,
    );
  }
}