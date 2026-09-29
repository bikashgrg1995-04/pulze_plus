import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pulze_plus/core/theme/app_radius.dart';
import 'package:pulze_plus/core/theme/app_spacing.dart';
import 'package:pulze_plus/core/widgets/app_button.dart';
import 'package:pulze_plus/core/widgets/app_snack_bar.dart';
import 'package:pulze_plus/features/profile/providers/profile_provider.dart';
import 'package:pulze_plus/l10n/app_localizations.dart';

class BloodRequestPhoneOtpDialog extends ConsumerStatefulWidget {
  const BloodRequestPhoneOtpDialog({
    super.key,
    required this.phoneNumber,
  });

  final String phoneNumber;

  @override
  ConsumerState<BloodRequestPhoneOtpDialog> createState() =>
      _BloodRequestPhoneOtpDialogState();
}

class _BloodRequestPhoneOtpDialogState
    extends ConsumerState<BloodRequestPhoneOtpDialog> {
  final _otpController = TextEditingController();

  Timer? _resendTimer;

  bool _isVerifying = false;
  bool _isResending = false;
  int _resendSeconds = 60;

  static const _purpose = 'BLOOD_REQUEST_CONTACT';

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _verifyOtp() async {
    final l10n = AppLocalizations.of(context)!;
    final code = _otpController.text.trim();

    FocusScope.of(context).unfocus();

    if (code.length != 6) {
      _showError(l10n.pleaseEnterSixDigitCode);
      return;
    }

    setState(() {
      _isVerifying = true;
    });

    try {
      await ref.read(profileProvider.notifier).verifyPhone(
            phoneNumber: widget.phoneNumber,
            code: code,
            purpose: _purpose,
          );

      if (!mounted) return;

      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;

      _showError(_cleanError(error));
    } finally {
      if (mounted) {
        setState(() {
          _isVerifying = false;
        });
      }
    }
  }

  Future<void> _resendOtp() async {
    if (_resendSeconds > 0 || _isResending || _isVerifying) {
      return;
    }

    final l10n = AppLocalizations.of(context)!;

    setState(() {
      _isResending = true;
    });

    try {
      await ref.read(profileProvider.notifier).resendPhoneVerification(
            phoneNumber: widget.phoneNumber,
            purpose: _purpose,
          );

      if (!mounted) return;

      _otpController.clear();
      _startResendTimer();

      AppSnackBar.success(
        context,
        l10n.newVerificationCodeSent,
      );
    } catch (error) {
      if (!mounted) return;

      _showError(_cleanError(error));
    } finally {
      if (mounted) {
        setState(() {
          _isResending = false;
        });
      }
    }
  }

  void _startResendTimer() {
    _resendTimer?.cancel();

    setState(() {
      _resendSeconds = 60;
    });

    _resendTimer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }

        if (_resendSeconds <= 1) {
          timer.cancel();

          setState(() {
            _resendSeconds = 0;
          });

          return;
        }

        setState(() {
          _resendSeconds--;
        });
      },
    );
  }

  void _showError(String message) {
    AppSnackBar.error(context, message);
  }

  String _cleanError(Object error) {
    return error.toString().replaceFirst('Exception: ', '');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xl,
      ),
      backgroundColor: colorScheme.surface,
      elevation: 8,
      shadowColor: colorScheme.shadow.withValues(alpha: 0.25),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(context),

              const SizedBox(height: AppSpacing.lg),

              _buildPhoneCard(context),

              const SizedBox(height: AppSpacing.lg),

              _buildOtpField(context),

              const SizedBox(height: AppSpacing.sm),

              _buildResendSection(context),

              const SizedBox(height: AppSpacing.lg),

              AppButton(
                label: l10n.verifyPhoneNumber,
                icon: Icons.verified_outlined,
                isLoading: _isVerifying,
                onPressed: _isVerifying ? null : _verifyOtp,
              ),

              const SizedBox(height: AppSpacing.xs),

              TextButton(
                onPressed: _isVerifying || _isResending
                    ? null
                    : () => Navigator.of(context).pop(false),
                child: Text(l10n.cancel),
              ),

              const SizedBox(height: AppSpacing.xs),

              Text(
                l10n.phoneVerificationSecurityMessage,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.sms_outlined,
            size: 30,
            color: colorScheme.primary,
          ),
        ),

        const SizedBox(height: AppSpacing.md),

        Text(
          l10n.verifyPhoneNumber,
          textAlign: TextAlign.center,
          style: theme.textTheme.titleLarge?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: AppSpacing.xs),

        Text(
          l10n.enterVerificationCode,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
            height: 1.45,
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneCard(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.14),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.phone_outlined,
              size: 19,
              color: colorScheme.primary,
            ),
          ),

          const SizedBox(width: AppSpacing.sm),

          Expanded(
            child: Text(
              widget.phoneNumber,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          Icon(
            Icons.lock_outline_rounded,
            size: 18,
            color: colorScheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }

  Widget _buildOtpField(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.verificationCode,
          style: theme.textTheme.labelLarge?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: AppSpacing.xs),

        TextField(
          controller: _otpController,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.done,
          enabled: !_isVerifying && !_isResending,
          maxLength: 6,
          textAlign: TextAlign.center,
          autofocus: true,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
          style: theme.textTheme.headlineSmall?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w700,
            letterSpacing: 8,
          ),
          cursorColor: colorScheme.primary,
          decoration: InputDecoration(
            hintText: '000000',
            hintStyle: TextStyle(
              color: colorScheme.onSurfaceVariant.withValues(
                alpha: 0.45,
              ),
              letterSpacing: 8,
            ),
            counterText: '',
            filled: true,
            fillColor: colorScheme.surfaceContainerHighest.withValues(
              alpha: 0.35,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: BorderSide(
                color: colorScheme.outline.withValues(alpha: 0.45),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: BorderSide(
                color: colorScheme.primary,
                width: 1.5,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: BorderSide(
                color: colorScheme.outline.withValues(alpha: 0.25),
              ),
            ),
          ),
          onSubmitted: (_) {
            if (!_isVerifying && !_isResending) {
              _verifyOtp();
            }
          },
        ),
      ],
    );
  }

  Widget _buildResendSection(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    if (_isResending) {
      return const SizedBox(
        height: 40,
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
            ),
          ),
        ),
      );
    }

    if (_resendSeconds > 0) {
      return Center(
        child: Text(
          l10n.resendCodeIn(_resendSeconds),
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    return Center(
      child: TextButton(
        onPressed: _isVerifying ? null : _resendOtp,
        child: Text(l10n.resendCode),
      ),
    );
  }
}