import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class AppAvatar extends StatelessWidget {
  const AppAvatar({
    super.key,
    this.imageUrl,
    this.initials,
    this.icon = Icons.person_rounded,
    this.size = 48,
    this.backgroundColor,
    this.foregroundColor,
    this.showBorder = false,
    this.borderColor,
  });

  final String? imageUrl;
  final String? initials;
  final IconData icon;

  final double size;

  final Color? backgroundColor;
  final Color? foregroundColor;

  final bool showBorder;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final background = backgroundColor ?? AppColors.surfaceVariant;
    final foreground = foregroundColor ?? AppColors.textSecondary;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: background,
        shape: BoxShape.circle,
        border: showBorder
            ? Border.all(color: borderColor ?? AppColors.border)
            : null,
      ),
      clipBehavior: Clip.antiAlias,
      child: _buildContent(foreground),
    );
  }

  Widget _buildContent(Color foregroundColor) {
    if (imageUrl != null && imageUrl!.trim().isNotEmpty) {
      return Image.network(
        imageUrl!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) {
          return _fallback(foregroundColor);
        },
      );
    }

    return _fallback(foregroundColor);
  }

  Widget _fallback(Color foregroundColor) {
    if (initials != null && initials!.trim().isNotEmpty) {
      return Center(
        child: Text(
          initials!.trim().toUpperCase(),
          maxLines: 1,
          overflow: TextOverflow.clip,
          style: TextStyle(
            color: foregroundColor,
            fontSize: size * 0.32,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }

    return Icon(icon, size: size * 0.48, color: foregroundColor);
  }
}
