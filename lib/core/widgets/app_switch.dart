import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class AppSwitch extends StatelessWidget {
  const AppSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.activeTrackColor,
    this.activeThumbColor,
    this.inactiveTrackColor,
    this.inactiveThumbColor,
    this.scale = 1.0,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;

  final Color? activeTrackColor;
  final Color? activeThumbColor;
  final Color? inactiveTrackColor;
  final Color? inactiveThumbColor;

  final double scale;

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: scale,
      alignment: Alignment.center,
      child: Switch.adaptive(
        value: value,
        onChanged: onChanged,
        activeTrackColor: activeTrackColor ?? AppColors.primary,
        activeThumbColor: activeThumbColor ?? Colors.white,
        inactiveTrackColor:
            inactiveTrackColor ?? AppColors.surfaceVariant,
        inactiveThumbColor:
            inactiveThumbColor ?? AppColors.textTertiary,
      ),
    );
  }
}