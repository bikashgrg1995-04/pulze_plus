import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class AppLoading extends StatelessWidget {
  const AppLoading({
    super.key,
    this.size = 24,
    this.strokeWidth = 2.5,
    this.color,
    this.center = false,
  });

  final double size;
  final double strokeWidth;
  final Color? color;
  final bool center;

  @override
  Widget build(BuildContext context) {
    final loading = SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
        color: color ?? AppColors.primary,
      ),
    );

    if (!center) {
      return loading;
    }

    return Center(
      child: loading,
    );
  }
}