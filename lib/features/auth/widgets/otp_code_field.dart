import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';

class OtpCodeField extends StatefulWidget {
  const OtpCodeField({
    super.key,
    required this.controller,
    required this.onCompleted,
    this.enabled = true,
  });

  final TextEditingController controller;
  final VoidCallback onCompleted;
  final bool enabled;

  @override
  State<OtpCodeField> createState() => _OtpCodeFieldState();
}

class _OtpCodeFieldState extends State<OtpCodeField> {
  bool _hasCompleted = false;

  void _handleChanged(String value) {
    final code = value.trim();

    final isComplete = code.length == 6 && RegExp(r'^\d{6}$').hasMatch(code);

    if (isComplete && !_hasCompleted) {
      _hasCompleted = true;
      widget.onCompleted();
    }

    if (!isComplete && _hasCompleted) {
      _hasCompleted = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      enabled: widget.enabled,
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.done,
      textAlign: TextAlign.center,
      maxLength: 6,
      onChanged: _handleChanged,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(6),
      ],
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: 8,
        color: AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        labelText: 'Verification code',
        hintText: '123456',
        hintStyle: TextStyle(color: AppColors.darkTextSecondary.withValues(alpha: 0.4)),
        counterText: '',
        prefixIcon: const Icon(Icons.verified_outlined),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.lg,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: AppColors.border),
        ),
      ),
    );
  }
}
