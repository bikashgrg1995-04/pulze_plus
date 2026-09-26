import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pulze_plus/features/auth/models/auth_state.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_snack_bar.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_header.dart';
import '../widgets/otp_code_field.dart';

class VerifyEmailScreen extends ConsumerStatefulWidget {
  const VerifyEmailScreen({super.key, required this.email});

  final String email;

  @override
  ConsumerState<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends ConsumerState<VerifyEmailScreen> {
  final _codeController = TextEditingController();

  Timer? _resendTimer;

  int _resendSecondsRemaining = 60;

  bool get _isLoading => ref.watch(authProvider).status == AuthStatus.loading;

  bool get _canResend => _resendSecondsRemaining == 0 && !_isLoading;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _startResendTimer();
      }
    });
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _verifyEmail() async {
    if (_isLoading) {
      return;
    }

    final code = _codeController.text.trim();

    if (!RegExp(r'^\d{6}$').hasMatch(code)) {
      AppSnackBar.error(
        context,
        'Please enter a valid 6-digit verification code.',
      );
      return;
    }

    FocusScope.of(context).unfocus();

    try {
      await ref
          .read(authProvider.notifier)
          .verifyEmail(email: widget.email, code: code);

      if (!mounted) {
        return;
      }

      context.pop();
    } catch (error) {
      if (!mounted) {
        return;
      }

      AppSnackBar.error(context, error.toString());
    }
  }

  Future<void> _resendCode() async {
    if (!_canResend) {
      return;
    }

    FocusScope.of(context).unfocus();

    try {
      await ref
          .read(authProvider.notifier)
          .resendVerificationEmail(email: widget.email);

      if (!mounted) {
        return;
      }

      _startResendTimer();

      _codeController.clear();
    } catch (error) {
      if (!mounted) {
        return;
      }

      AppSnackBar.error(context, error.toString());
    }
  }

  void _startResendTimer() {
    _resendTimer?.cancel();

    setState(() {
      _resendSecondsRemaining = 60;
    });

    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_resendSecondsRemaining <= 1) {
        timer.cancel();

        setState(() {
          _resendSecondsRemaining = 0;
        });

        return;
      }

      setState(() {
        _resendSecondsRemaining--;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = ResponsiveUtils.value(
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
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: _isLoading ? null : () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            AppSpacing.lg,
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
                    title: 'Verify your email',
                    subtitle:
                        'Enter the 6-digit verification code '
                        'we sent to your email address.',
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.email_outlined,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            widget.email,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  OtpCodeField(
                    controller: _codeController,
                    enabled: !_isLoading,
                    onCompleted: _verifyEmail,
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  AppButton(
                    label: 'Verify email',
                    icon: Icons.check_circle_outline_rounded,
                    isLoading: _isLoading,
                    onPressed: _verifyEmail,
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  Text(
                    'Didn’t receive the code?',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium
                        ?.copyWith(color: AppColors.textSecondary),
                  ),

                  const SizedBox(height: AppSpacing.xs),

                  Center(
                    child: TextButton(
                      onPressed: _canResend ? _resendCode : null,
                      child: Text(
                        _resendSecondsRemaining > 0
                            ? 'Resend code in '
                                  '$_resendSecondsRemaining s'
                            : 'Resend code',
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  Text(
                    'The verification code expires in 10 minutes.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall
                        ?.copyWith(color: AppColors.textSecondary),
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
