import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pulze_plus/core/network/app_exception.dart';

import 'package:pulze_plus/core/theme/app_colors.dart';
import 'package:pulze_plus/core/theme/app_radius.dart';
import 'package:pulze_plus/core/theme/app_spacing.dart';
import 'package:pulze_plus/core/utils/form_validators.dart';
import 'package:pulze_plus/core/widgets/app_button.dart';
import 'package:pulze_plus/features/profile/providers/profile_provider.dart';
import 'package:pulze_plus/l10n/app_localizations.dart';

class ChangePasswordDialog extends ConsumerStatefulWidget {
  const ChangePasswordDialog({super.key});

  @override
  ConsumerState<ChangePasswordDialog> createState() =>
      _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends ConsumerState<ChangePasswordDialog> {
  final _formKey = GlobalKey<FormState>();

  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  bool _isLoading = false;

  String? _currentPasswordError;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validateCurrentPassword(String? value) {
    final l10n = AppLocalizations.of(context)!;

    return FormValidators.required(
      value,
      fieldName: l10n.currentPassword,
      errorMessage: l10n.currentPasswordRequired,
    );
  }

  String? _validateNewPassword(String? value) {
    final l10n = AppLocalizations.of(context)!;

    return FormValidators.password(
      value,
      requiredMessage: l10n.newPasswordRequired,
      minLengthMessage: l10n.passwordMinimumLength,
    );
  }

  String? _validateConfirmPassword(String? value) {
    final l10n = AppLocalizations.of(context)!;

    final requiredError = FormValidators.required(
      value,
      fieldName: l10n.confirmNewPassword,
      errorMessage: l10n.confirmPasswordRequired,
    );

    if (requiredError != null) {
      return requiredError;
    }

    if (value != _newPasswordController.text) {
      return l10n.passwordsDoNotMatch;
    }

    return null;
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    setState(() {
      _currentPasswordError = null;
    });

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await ref
          .read(profileProvider.notifier)
          .changePassword(
            currentPassword: _currentPasswordController.text,
            newPassword: _newPasswordController.text,
            confirmPassword: _confirmPasswordController.text,
          );

      if (!mounted) return;

      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;

        if (error is AppException) {
          _currentPasswordError = error.message;
        } else {
          _currentPasswordError = error.toString();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Dialog(
      backgroundColor: colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xl,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(
                            alpha: theme.brightness == Brightness.dark
                                ? 0.16
                                : 0.10,
                          ),
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: const Icon(
                          Icons.lock_reset_rounded,
                          color: AppColors.primary,
                          size: 25,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.changePassword,
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: colorScheme.onSurface,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xxs),
                            Text(
                              l10n.changePasswordDescription,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: MaterialLocalizations.of(context)
                            .closeButtonTooltip,
                        onPressed: _isLoading
                            ? null
                            : () => Navigator.of(context).pop(),
                        color: colorScheme.onSurfaceVariant,
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // Security Hint
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest.withValues(
                        alpha: theme.brightness == Brightness.dark
                            ? 0.45
                            : 0.55,
                      ),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(
                        color: colorScheme.outlineVariant.withValues(
                          alpha: theme.brightness == Brightness.dark
                              ? 0.8
                              : 0.6,
                        ),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          size: 20,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            l10n.changePasswordSecurityHint,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // Current Password
                  _PasswordField(
                    controller: _currentPasswordController,
                    label: l10n.currentPassword,
                    hintText: l10n.enterCurrentPassword,
                    obscureText: _obscureCurrentPassword,
                    enabled: !_isLoading,
                    validator: _validateCurrentPassword,
                    errorText: _currentPasswordError,
                    onChanged: (_) {
                      if (_currentPasswordError != null) {
                        setState(() {
                          _currentPasswordError = null;
                        });
                      }
                    },
                    onToggleVisibility: () {
                      setState(() {
                        _obscureCurrentPassword = !_obscureCurrentPassword;
                      });
                    },
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // New Password
                  _PasswordField(
                    controller: _newPasswordController,
                    label: l10n.newPassword,
                    hintText: l10n.enterNewPassword,
                    obscureText: _obscureNewPassword,
                    enabled: !_isLoading,
                    validator: _validateNewPassword,
                    onChanged: (_) {
                      if (_confirmPasswordController.text.isNotEmpty) {
                        _formKey.currentState?.validate();
                      }
                    },
                    onToggleVisibility: () {
                      setState(() {
                        _obscureNewPassword = !_obscureNewPassword;
                      });
                    },
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  Text(
                    l10n.passwordMinimumHint,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // Confirm Password
                  _PasswordField(
                    controller: _confirmPasswordController,
                    label: l10n.confirmNewPassword,
                    hintText: l10n.enterNewPasswordAgain,
                    obscureText: _obscureConfirmPassword,
                    enabled: !_isLoading,
                    validator: _validateConfirmPassword,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) {
                      if (!_isLoading) {
                        _submit();
                      }
                    },
                    onToggleVisibility: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // Actions
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AppButton(
                        label: l10n.updatePassword,
                        icon: Icons.check_rounded,
                        isLoading: _isLoading,
                        onPressed: _isLoading ? null : _submit,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      AppButton(
                        label: l10n.cancel,
                        variant: AppButtonVariant.secondary,
                        onPressed: _isLoading
                            ? null
                            : () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PasswordField extends StatelessWidget {
  const _PasswordField({
    required this.controller,
    required this.label,
    required this.hintText,
    required this.obscureText,
    required this.enabled,
    required this.validator,
    required this.onToggleVisibility,
    this.errorText,
    this.onChanged,
    this.textInputAction = TextInputAction.next,
    this.onFieldSubmitted,
  });

  final TextEditingController controller;
  final String label;
  final String hintText;
  final bool obscureText;
  final bool enabled;
  final String? Function(String?) validator;
  final VoidCallback onToggleVisibility;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onFieldSubmitted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      enabled: enabled,
      validator: validator,
      onChanged: onChanged,
      textInputAction: textInputAction,
      onFieldSubmitted: onFieldSubmitted,
      autocorrect: false,
      enableSuggestions: false,
      style: TextStyle(color: colorScheme.onSurface),
      cursorColor: AppColors.primary,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        errorText: errorText,
        labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
        hintStyle: TextStyle(
          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.75),
        ),
        prefixIcon: Icon(
          Icons.lock_outline_rounded,
          color: colorScheme.onSurfaceVariant,
        ),
        suffixIcon: IconButton(
          tooltip: obscureText ? l10n.showPassword : l10n.hidePassword,
          color: colorScheme.onSurfaceVariant,
          onPressed: enabled ? onToggleVisibility : null,
          icon: Icon(
            obscureText
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
          ),
        ),
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: colorScheme.error, width: 1.5),
        ),
      ),
    );
  }
}
