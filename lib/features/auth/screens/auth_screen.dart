import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:pulze_plus/app/router/app_routes.dart';
import 'package:pulze_plus/core/preferences/app_preferences_provider.dart';
import 'package:pulze_plus/core/widgets/app_divider.dart';
import 'package:pulze_plus/core/widgets/app_snack_bar.dart';
import 'package:pulze_plus/features/auth/models/auth_state.dart';
import 'package:pulze_plus/l10n/app_localizations.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/form_validators.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_header.dart';
import '../widgets/google_auth_button.dart';

enum AuthMode { login, signup }

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _loginFormKey = GlobalKey<FormState>();
  final _signupFormKey = GlobalKey<FormState>();

  // Login controllers.
  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();

  // Signup controllers.
  final _signupNameController = TextEditingController();
  final _signupEmailController = TextEditingController();
  final _signupPasswordController = TextEditingController();

  AuthMode _mode = AuthMode.login;

  bool _obscureLoginPassword = true;
  bool _obscureSignupPassword = true;
  bool _acceptedLegalDocuments = false;

  bool get _isLogin => _mode == AuthMode.login;

  bool get _isLoading => ref.watch(authProvider).status == AuthStatus.loading;

  @override
  void dispose() {
    _loginEmailController.dispose();
    _loginPasswordController.dispose();

    _signupNameController.dispose();
    _signupEmailController.dispose();
    _signupPasswordController.dispose();

    super.dispose();
  }

  Future<void> _continueAsGuest() async {
    if (_isLoading) {
      return;
    }

    FocusScope.of(context).unfocus();

    await ref.read(appPreferencesProvider.notifier).completeEntry();

    if (!mounted) {
      return;
    }
    AppSnackBar.success(context, 'Continuing as a guest.');
    context.go(AppRoutes.home);
  }

  void _continueWithGoogle() {
    if (_isLoading) {
      return;
    }

    // Google authentication will be connected later.
  }

  void _openForgotPassword() {
    if (_isLoading) {
      return;
    }

    FocusScope.of(context).unfocus();

    context.push(
      AppRoutes.forgotPassword,
      extra: _loginEmailController.text.trim(),
    );
  }

  Future<void> _signIn() async {
    if (_isLoading) {
      return;
    }

    FocusScope.of(context).unfocus();

    if (!_loginFormKey.currentState!.validate()) {
      return;
    }

    try {
      await ref
          .read(authProvider.notifier)
          .login(
            email: _loginEmailController.text.trim(),
            password: _loginPasswordController.text,
          );

      if (!mounted) {
        return;
      }

      final authState = ref.read(authProvider);

      switch (authState.status) {
        case AuthStatus.needsProfile:
          await ref.read(appPreferencesProvider.notifier).completeEntry();

          if (!mounted) {
            return;
          }

          context.go(AppRoutes.profileSetup);
          return;

        case AuthStatus.authenticated:
          await ref.read(appPreferencesProvider.notifier).completeEntry();

          if (!mounted) {
            return;
          }

          context.go(AppRoutes.home);
          return;

        case AuthStatus.unauthenticated:
        case AuthStatus.needsVerification:
        case AuthStatus.initial:
        case AuthStatus.loading:
          return;
      }
    } catch (error) {
      if (!mounted) {
        return;
      }

      AppSnackBar.error(context, error.toString());
    }
  }

  Future<void> _createAccount() async {
    if (_isLoading) {
      return;
    }

    FocusScope.of(context).unfocus();

    if (!_signupFormKey.currentState!.validate()) {
      return;
    }

    final email = _signupEmailController.text.trim();

    try {
      await ref
          .read(authProvider.notifier)
          .register(
            fullName: _signupNameController.text.trim(),
            email: email,
            password: _signupPasswordController.text,
            termsAccepted: _acceptedLegalDocuments,
            privacyPolicyAccepted: _acceptedLegalDocuments,
          );

      // Registration was successful, so the user has completed
      // the first-entry decision.
      await ref.read(appPreferencesProvider.notifier).completeEntry();

      if (!mounted) {
        return;
      }

      // Prepare the login screen for after email verification.
      setState(() {
        _mode = AuthMode.login;
        _loginEmailController.text = email;

        _clearSignupForm();

        _obscureSignupPassword = true;
      });

      context.push(AppRoutes.verifyEmail, extra: email);
    } catch (error) {
      if (!mounted) {
        return;
      }

      AppSnackBar.error(context, error.toString());
    }
  }

  void _toggleMode() {
    if (_isLoading) {
      return;
    }

    setState(() {
      _clearLoginForm();
      _clearSignupForm();

      _mode = _isLogin ? AuthMode.signup : AuthMode.login;

      _obscureLoginPassword = true;
      _obscureSignupPassword = true;
    });
  }

  void _clearLoginForm() {
    _loginEmailController.clear();
    _loginPasswordController.clear();

    _loginFormKey.currentState?.reset();
  }

  void _clearSignupForm() {
    _signupNameController.clear();
    _signupEmailController.clear();
    _signupPasswordController.clear();
    _acceptedLegalDocuments = false;
    _signupFormKey.currentState?.reset();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final preferences = ref.watch(appPreferencesProvider);

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
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
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
                  AuthHeader(
                    title: _isLogin ? l10n.welcomeBack : l10n.createYourAccount,
                    subtitle: _isLogin
                        ? l10n.signInToContinueHelpingYourCommunity
                        : l10n.joinPulzeAndBeThereWhenSomeoneNeedsBlood,
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  if (_isLogin) _buildLoginForm() else _buildSignupForm(),

                  const SizedBox(height: AppSpacing.lg),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          _isLogin
                              ? l10n.dontHaveAnAccount
                              : l10n.alreadyHaveAnAccount,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: _isLoading ? null : _toggleMode,
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          padding: const EdgeInsets.only(
                            left: AppSpacing.xs,
                            right: AppSpacing.xxs,
                          ),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          _isLogin ? l10n.createAccount : l10n.signIn,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  const AppDivider(),

                  const SizedBox(height: AppSpacing.lg),

                  GoogleAuthButton(
                    label: _isLogin
                        ? l10n.continueWithGoogle
                        : l10n.signUpWithGoogle,
                    onPressed: _continueWithGoogle,
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  if (!preferences.hasCompletedEntry)
                    Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.sm),
                      child: AppButton(
                        label: l10n.continueAsGuest,
                        icon: Icons.person_outline_rounded,
                        variant: AppButtonVariant.outlined,
                        onPressed: () {
                          _continueAsGuest();
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    final l10n = AppLocalizations.of(context)!;

    return Form(
      key: _loginFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppTextField(
            controller: _loginEmailController,
            label: l10n.email,
            hint: l10n.enterYourEmail,
            prefixIcon: Icons.alternate_email_rounded,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            validator: (value) {
              return FormValidators.email(
                value,
                requiredMessage: l10n.emailIsRequired,
                invalidMessage: l10n.invalidEmail,
              );
            },
          ),

          const SizedBox(height: AppSpacing.md),

          AppTextField(
            controller: _loginPasswordController,
            label: l10n.password,
            hint: l10n.enterYourPassword,
            prefixIcon: Icons.lock_outline_rounded,
            obscureText: _obscureLoginPassword,
            textInputAction: TextInputAction.done,
            validator: (value) {
              return FormValidators.password(
                value,
                requiredMessage: l10n.passwordIsRequired,
                minLengthMessage: l10n.passwordMustBeAtLeast8Characters,
              );
            },
            suffixIcon: _obscureLoginPassword
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            onSuffixPressed: () {
              if (_isLoading) {
                return;
              }

              setState(() {
                _obscureLoginPassword = !_obscureLoginPassword;
              });
            },
          ),

          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _isLoading ? null : _openForgotPassword,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xxs,
                  vertical: AppSpacing.xs,
                ),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(l10n.forgotPassword),
            ),
          ),

          const SizedBox(height: AppSpacing.sm),

          AppButton(
            label: l10n.signIn,
            icon: Icons.arrow_forward_rounded,
            isLoading: _isLoading,
            onPressed: _signIn,
          ),
        ],
      ),
    );
  }

  Widget _buildSignupForm() {
    final l10n = AppLocalizations.of(context)!;

    return Form(
      key: _signupFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppTextField(
            controller: _signupNameController,
            label: l10n.fullName,
            hint: l10n.enterYourFullName,
            prefixIcon: Icons.person_outline_rounded,
            textInputAction: TextInputAction.next,
            validator: (value) {
              return FormValidators.fullName(
                value,
                requiredMessage: l10n.fullNameIsRequired,
                minLengthMessage: l10n.fullNameMustBeAtLeast2Characters,
              );
            },
          ),

          const SizedBox(height: AppSpacing.md),

          AppTextField(
            controller: _signupEmailController,
            label: l10n.email,
            hint: l10n.enterYourEmail,
            prefixIcon: Icons.alternate_email_rounded,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            validator: (value) {
              return FormValidators.email(
                value,
                requiredMessage: l10n.emailIsRequired,
                invalidMessage: l10n.invalidEmail,
              );
            },
          ),

          const SizedBox(height: AppSpacing.md),

          AppTextField(
            controller: _signupPasswordController,
            label: l10n.password,
            hint: l10n.createAPassword,
            prefixIcon: Icons.lock_outline_rounded,
            obscureText: _obscureSignupPassword,
            textInputAction: TextInputAction.done,
            validator: (value) {
              return FormValidators.password(
                value,
                requiredMessage: l10n.passwordIsRequired,
                minLengthMessage: l10n.passwordMustBeAtLeast8Characters,
              );
            },
            suffixIcon: _obscureSignupPassword
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            onSuffixPressed: () {
              if (_isLoading) {
                return;
              }

              setState(() {
                _obscureSignupPassword = !_obscureSignupPassword;
              });
            },
          ),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: _acceptedLegalDocuments,
                onChanged: _isLoading
                    ? null
                    : (value) {
                        setState(() {
                          _acceptedLegalDocuments = value ?? false;
                        });
                      },
                activeColor: AppColors.primary,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.xs),
                  child: RichText(
                    text: TextSpan(
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                      children: [
                        TextSpan(text: l10n.legalAgreementPrefix),
                        TextSpan(
                          text: l10n.termsConditions,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              context.push(AppRoutes.termsConditions);
                            },
                        ),
                        TextSpan(text: l10n.legalAgreementConnector),
                        TextSpan(
                          text: l10n.privacyPolicy,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              context.push(AppRoutes.privacyPolicy);
                            },
                        ),
                        TextSpan(text: l10n.legalAgreementSuffix),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),

          AppButton(
            label: l10n.createAccount,
            icon: Icons.arrow_forward_rounded,
            isLoading: _isLoading,
            onPressed: _acceptedLegalDocuments ? _createAccount : null,
          ),
        ],
      ),
    );
  }
}
