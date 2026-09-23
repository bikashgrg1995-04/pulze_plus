import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';

class AppIconButton extends StatelessWidget {
  const AppIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.size = 44,
    this.iconSize = 22,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.borderRadius,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;

  final double size;
  final double iconSize;

  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? borderColor;
  final double? borderRadius;

  @override
  Widget build(BuildContext context) {
    final button = Material(
      color: backgroundColor ?? Colors.transparent,
      borderRadius: BorderRadius.circular(
        borderRadius ?? AppRadius.md,
      ),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(
          borderRadius ?? AppRadius.md,
        ),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              borderRadius ?? AppRadius.md,
            ),
            border: borderColor == null
                ? null
                : Border.all(
                    color: borderColor!,
                  ),
          ),
          child: Icon(
            icon,
            size: iconSize,
            color: foregroundColor ?? AppColors.textPrimary,
          ),
        ),
      ),
    );

    if (tooltip == null) {
      return button;
    }

    return Tooltip(
      message: tooltip!,
      child: button,
    );
  }
}