import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:pulze_plus/app/router/app_routes.dart';
import 'package:pulze_plus/core/theme/app_colors.dart';
import 'package:pulze_plus/core/theme/app_spacing.dart';
import 'package:pulze_plus/core/utils/responsive_utils.dart';
import 'package:pulze_plus/core/widgets/app_snack_bar.dart';

import '../providers/auth_provider.dart';
import '../widgets/auth_header.dart';
import '../widgets/otp_code_field.dart';

class VerifyPasswordResetScreen extends ConsumerStatefulWidget {
  const VerifyPasswordResetScreen({super.key, required this.email});

  final String email;

  @override
  ConsumerState<VerifyPasswordResetScreen> createState() =>
      _VerifyPasswordResetScreenState();
}

class _VerifyPasswordResetScreenState
    extends ConsumerState<VerifyPasswordResetScreen> {
  static const _resendCooldownSeconds = 60;
  final _otpController = TextEditingController();

  Timer? _timer;

  int _remainingSeconds = 0;
  bool _isVerifying = false;
  bool _isResending = false;

  bool get _isLoading => _isVerifying || _isResending;

  @override
  void initState() {
    super.initState();

    _startResendCooldown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  void _startResendCooldown() {
    _timer?.cancel();

    setState(() {
      _remainingSeconds = _resendCooldownSeconds;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_remainingSeconds <= 1) {
        timer.cancel();

        setState(() {
          _remainingSeconds = 0;
        });

        return;
      }

      setState(() {
        _remainingSeconds--;
      });
    });
  }

  Future<void> _verifyCode() async {
    if (_isLoading) {
      return;
    }

    final code = _otpController.text.trim();

    if (code.length != 6) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _isVerifying = true;
    });

    try {
      final resetToken = await ref
          .read(authProvider.notifier)
          .verifyPasswordReset(email: widget.email, code: code);

      if (!mounted) {
        return;
      }

      context.push(AppRoutes.resetPassword, extra: resetToken);
    } catch (error) {
      if (!mounted) {
        return;
      }

      AppSnackBar.error(context, error.toString());
    } finally {
      if (mounted) {
        setState(() {
          _isVerifying = false;
        });
      }
    }
  }

  Future<void> _resendCode() async {
    if (_isLoading || _remainingSeconds > 0) {
      return;
    }

    setState(() {
      _isResending = true;
    });

    try {
      await ref.read(authProvider.notifier).forgotPassword(email: widget.email);

      if (!mounted) {
        return;
      }

      AppSnackBar.success(
        context,
        'If an account exists with this email, '
        'a new password reset code has been sent.',
      );

      _startResendCooldown();
    } catch (error) {
      if (!mounted) {
        return;
      }

      AppSnackBar.error(context, error.toString());
    } finally {
      if (mounted) {
        setState(() {
          _isResending = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = ResponsiveUtils.value(
      context,
      mobile: AppSpacing.xl,
      tablet: AppSpacing.xxl,
      large: AppSpacing.xxxl,
    );

    final topPadding = ResponsiveUtils.value(
      context,
      mobile: AppSpacing.xl,
      tablet: AppSpacing.xxl,
      large: AppSpacing.xxxl,
    );

    final bottomPadding = ResponsiveUtils.value(
      context,
      mobile: AppSpacing.xxl,
      tablet: AppSpacing.xxxl,
      large: AppSpacing.xxxl,
    );

    final contentMaxWidth = ResponsiveUtils.value(
      context,
      mobile: 480.0,
      tablet: 520.0,
      large: 560.0,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          onPressed: _isLoading ? null : () => context.pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            topPadding,
            horizontalPadding,
            bottomPadding,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: contentMaxWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const AuthHeader(
                    title: 'Verify reset code',
                    subtitle: 'Enter the 6-digit code sent to your email.',
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  Text(
                    widget.email,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium
                        ?.copyWith(color: AppColors.textSecondary),
                  ),

                  const SizedBox(height: AppSpacing.xxl),

                  OtpCodeField(
                    controller: _otpController,
                    onCompleted: _verifyCode,
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  if (_isVerifying)
                    const Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(),
                      ),
                    ),

                  const SizedBox(height: AppSpacing.md),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _remainingSeconds > 0
                            ? 'Resend code in $_remainingSeconds s'
                            : 'Didn’t receive the code?',
                        style: Theme.of(context).textTheme.bodyMedium
                            ?.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),

                  if (_remainingSeconds == 0) ...[
                    const SizedBox(height: AppSpacing.xs),
                    TextButton(
                      onPressed: _isLoading ? null : _resendCode,
                      child: _isResending
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Resend code'),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
