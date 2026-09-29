import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pulze_plus/core/theme/app_radius.dart';
import 'package:pulze_plus/core/theme/app_spacing.dart';
import 'package:pulze_plus/core/widgets/app_button.dart';
import 'package:pulze_plus/core/widgets/app_snack_bar.dart';
import 'package:pulze_plus/features/profile/providers/profile_provider.dart';
import 'package:pulze_plus/l10n/app_localizations.dart';

class ChangePhoneDialog extends ConsumerStatefulWidget {
  const ChangePhoneDialog({super.key});

  @override
  ConsumerState<ChangePhoneDialog> createState() => _ChangePhoneDialogState();
}

class _ChangePhoneDialogState extends ConsumerState<ChangePhoneDialog> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();

  bool _otpSent = false;
  bool _isLoading = false;
  int _resendSeconds = 0;

  Timer? _resendTimer;

  @override
  void dispose() {
    _resendTimer?.cancel();
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    final l10n = AppLocalizations.of(context)!;
    final phoneNumber = _phoneController.text.trim();

    if (phoneNumber.isEmpty) {
      _showError(l10n.pleaseEnterPhoneNumber);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await ref
          .read(profileProvider.notifier)
          .sendPhoneVerification(phoneNumber: phoneNumber);

      if (!mounted) return;

      setState(() {
        _otpSent = true;
        _resendSeconds = 60;
      });

      _startResendTimer();

      AppSnackBar.success(context, l10n.verificationCodeSentSuccessfully);
    } catch (error) {
      if (!mounted) return;

      _showError(error.toString());
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _verifyOtp() async {
    final l10n = AppLocalizations.of(context)!;
    final phoneNumber = _phoneController.text.trim();
    final code = _otpController.text.trim();

    if (code.length != 6) {
      _showError(l10n.pleaseEnterSixDigitCode);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await ref
          .read(profileProvider.notifier)
          .verifyPhone(phoneNumber: phoneNumber, code: code);

      if (!mounted) return;

      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;

      _showError(error.toString());
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _resendOtp() async {
    if (_resendSeconds > 0 || _isLoading) {
      return;
    }

    final l10n = AppLocalizations.of(context)!;
    final phoneNumber = _phoneController.text.trim();

    setState(() {
      _isLoading = true;
    });

    try {
      await ref
          .read(profileProvider.notifier)
          .resendPhoneVerification(phoneNumber: phoneNumber);

      if (!mounted) return;

      setState(() {
        _resendSeconds = 60;
      });

      _startResendTimer();

      AppSnackBar.success(context, l10n.newVerificationCodeSent);
    } catch (error) {
      if (!mounted) return;

      _showError(error.toString());
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _startResendTimer() {
    _resendTimer?.cancel();

    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
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
    });
  }

  void _showError(String message) {
    AppSnackBar.error(context, message);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final profile = ref.watch(profileProvider).profile;
    final currentPhone = profile?.phoneNumber;

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
              _buildHeader(context, currentPhone: currentPhone),

              const SizedBox(height: AppSpacing.lg),

              AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                child: _otpSent
                    ? _buildOtpStep(context)
                    : _buildPhoneStep(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, {required String? currentPhone}) {
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
            Icons.phone_rounded,
            size: 30,
            color: colorScheme.primary,
          ),
        ),

        const SizedBox(height: AppSpacing.md),

        Text(
          _otpSent ? l10n.verifyPhoneNumber : l10n.changePhoneNumber,
          textAlign: TextAlign.center,
          style: theme.textTheme.titleLarge?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: AppSpacing.xs),

        Text(
          _otpSent
              ? l10n.enterVerificationCode
              : currentPhone == null || currentPhone.isEmpty
              ? l10n.addPhoneSecurityDescription
              : l10n.changeNumberDescription,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
            height: 1.45,
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneStep(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.phoneNumber,
          style: theme.textTheme.labelLarge?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: AppSpacing.xs),

        TextField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.done,
          enabled: !_isLoading,
          maxLength: 20,
          style: TextStyle(color: colorScheme.onSurface),
          cursorColor: colorScheme.primary,
          decoration: InputDecoration(
            hintText: l10n.enterPhoneNumber,
            hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
            prefixIcon: Icon(
              Icons.phone_outlined,
              color: colorScheme.onSurfaceVariant,
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
              borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: BorderSide(
                color: colorScheme.outline.withValues(alpha: 0.25),
              ),
            ),
          ),
        ),

        const SizedBox(height: AppSpacing.md),

        _buildSecurityInfo(
          context,
          text: l10n.phoneVerificationSecurityMessage,
        ),

        const SizedBox(height: AppSpacing.lg),

        AppButton(
          label: l10n.sendVerificationCode,
          icon: Icons.sms_outlined,
          isLoading: _isLoading,
          onPressed: _sendOtp,
        ),

        const SizedBox(height: AppSpacing.xs),

        TextButton(
          onPressed: _isLoading
              ? null
              : () {
                  Navigator.of(context).pop();
                },
          child: Text(l10n.cancel),
        ),
      ],
    );
  }

  Widget _buildOtpStep(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    final phoneNumber = _phoneController.text.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
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
                  Icons.sms_outlined,
                  size: 19,
                  color: colorScheme.primary,
                ),
              ),

              const SizedBox(width: AppSpacing.sm),

              Expanded(
                child: Text(
                  phoneNumber,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              IconButton(
                tooltip: l10n.changeNumber,
                onPressed: _isLoading
                    ? null
                    : () {
                        _resendTimer?.cancel();

                        setState(() {
                          _otpSent = false;
                          _otpController.clear();
                          _resendSeconds = 0;
                        });
                      },
                icon: Icon(
                  Icons.edit_outlined,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.lg),

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
          enabled: !_isLoading,
          maxLength: 6,
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineSmall?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w700,
            letterSpacing: 8,
          ),
          cursorColor: colorScheme.primary,
          decoration: InputDecoration(
            hintText: '000000',
            hintStyle: TextStyle(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.45),
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
              borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
            ),
          ),
          onSubmitted: (_) {
            if (!_isLoading) {
              _verifyOtp();
            }
          },
        ),

        const SizedBox(height: AppSpacing.sm),

        Center(
          child: _resendSeconds > 0
              ? Text(
                  l10n.resendCodeIn(_resendSeconds),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                )
              : TextButton(
                  onPressed: _isLoading ? null : _resendOtp,
                  child: Text(l10n.resendCode),
                ),
        ),

        const SizedBox(height: AppSpacing.md),

        AppButton(
          label: l10n.verifyPhoneNumber,
          icon: Icons.verified_outlined,
          isLoading: _isLoading,
          onPressed: _verifyOtp,
        ),

        const SizedBox(height: AppSpacing.xs),

        TextButton(
          onPressed: _isLoading
              ? null
              : () {
                  Navigator.of(context).pop();
                },
          child: Text(l10n.cancel),
        ),
      ],
    );
  }

  Widget _buildSecurityInfo(BuildContext context, {required String text}) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.12)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.verified_user_outlined,
            size: 20,
            color: colorScheme.primary,
          ),

          const SizedBox(width: AppSpacing.sm),

          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
