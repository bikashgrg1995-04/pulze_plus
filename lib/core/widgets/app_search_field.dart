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
    return TextField(
      controller: controller,
      focusNode: focusNode,
      enabled: enabled,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.search,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.textPrimary,
          ),
      cursorColor: AppColors.primary,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textTertiary,
            ),
        prefixIcon: const Icon(
          Icons.search_rounded,
          size: 22,
        ),
        suffixIcon: _buildSuffixIcon(),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 14,
        ),
        border: _border(),
        enabledBorder: _border(),
        focusedBorder: _border(
          color: AppColors.primary,
          width: 1.5,
        ),
        disabledBorder: _border(
          color: AppColors.border.withValues(alpha: 0.6),
        ),
      ),
    );
  }

  Widget? _buildSuffixIcon() {
    if (onClear == null) {
      return null;
    }

    return IconButton(
      onPressed: onClear,
      tooltip: 'Clear',
      icon: const Icon(
        Icons.close_rounded,
        size: 20,
      ),
    );
  }

  OutlineInputBorder _border({
    Color color = AppColors.border,
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