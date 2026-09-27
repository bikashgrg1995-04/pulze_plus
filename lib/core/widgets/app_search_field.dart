import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';

class AppSearchField extends StatelessWidget {
  const AppSearchField({
    super.key,
    this.controller,
    this.hint = 'Search...',
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.focusNode,
    this.enabled = true,
  });

  final TextEditingController? controller;
  final String hint;

  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;

  final FocusNode? focusNode;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return TextField(
      controller: controller,
      focusNode: focusNode,
      enabled: enabled,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.search,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      style: theme.textTheme.bodyMedium?.copyWith(
        color: colorScheme.onSurface,
      ),
      cursorColor: AppColors.primary,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: theme.textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
        prefixIcon: Icon(
          Icons.search_rounded,
          size: 22,
          color: colorScheme.onSurfaceVariant,
        ),
        suffixIcon: _buildSuffixIcon(context),
        filled: true,
        fillColor: colorScheme.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 14,
        ),
        border: _border(
          color: colorScheme.outline,
        ),
        enabledBorder: _border(
          color: colorScheme.outline,
        ),
        focusedBorder: _border(
          color: AppColors.primary,
          width: 1.5,
        ),
        disabledBorder: _border(
          color: colorScheme.outline.withValues(alpha: 0.6),
        ),
      ),
    );
  }

  Widget? _buildSuffixIcon(BuildContext context) {
    if (onClear == null) {
      return null;
    }

    final colorScheme = Theme.of(context).colorScheme;

    return IconButton(
      onPressed: onClear,
      tooltip: 'Clear',
      icon: Icon(
        Icons.close_rounded,
        size: 20,
        color: colorScheme.onSurfaceVariant,
      ),
    );
  }

  OutlineInputBorder _border({
    required Color color,
    double width = 1,
  }) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      borderSide: BorderSide(
        color: color,
        width: width,
      ),
    );
  }
}