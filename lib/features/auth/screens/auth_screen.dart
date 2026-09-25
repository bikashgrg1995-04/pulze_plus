import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:pulze_plus/app/router/app_routes.dart';
import 'package:pulze_plus/core/widgets/app_divider.dart';
import 'package:pulze_plus/core/widgets/app_snack_bar.dart';

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
          context.go(AppRoutes.profileSetup);
          return;

        case AuthStatus.authenticated:
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
          );

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

    _signupFormKey.currentState?.reset();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
                    title: _isLogin ? 'Welcome back' : 'Create your account',
                    subtitle: _isLogin
                        ? 'Sign in to continue helping your community.'
                        : 'Join Pulze+ and be there when someone needs blood.',
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  GoogleAuthButton(
                    label: _isLogin
                        ? 'Continue with Google'
                        : 'Sign up with Google',
                    onPressed: _continueWithGoogle,
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  const AppDivider(),

                  const SizedBox(height: AppSpacing.lg),

                  if (_isLogin) _buildLoginForm() else _buildSignupForm(),

                  const SizedBox(height: AppSpacing.lg),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          _isLogin
                              ? "Don't have an account?"
                              : 'Already have an account?',
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
                        child: Text(_isLogin ? 'Create account' : 'Sign in'),
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

  Widget _buildLoginForm() {
    return Form(
      key: _loginFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppTextField(
            controller: _loginEmailController,
            label: 'Email',
            hint: 'Enter your email',
            prefixIcon: Icons.alternate_email_rounded,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            validator: FormValidators.email,
          ),

          const SizedBox(height: AppSpacing.md),

          AppTextField(
            controller: _loginPasswordController,
            label: 'Password',
            hint: 'Enter your password',
            prefixIcon: Icons.lock_outline_rounded,
            obscureText: _obscureLoginPassword,
            textInputAction: TextInputAction.done,
            validator: FormValidators.password,
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
              child: const Text('Forgot password?'),
            ),
          ),

          const SizedBox(height: AppSpacing.sm),

          AppButton(
            label: 'Sign in',
            icon: Icons.arrow_forward_rounded,
            isLoading: _isLoading,
            onPressed: _signIn,
          ),
        ],
      ),
    );
  }

  Widget _buildSignupForm() {
    return Form(
      key: _signupFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppTextField(
            controller: _signupNameController,
            label: 'Full name',
            hint: 'Enter your full name',
            prefixIcon: Icons.person_outline_rounded,
            textInputAction: TextInputAction.next,
            validator: FormValidators.fullName,
          ),

          const SizedBox(height: AppSpacing.md),

          AppTextField(
            controller: _signupEmailController,
            label: 'Email',
            hint: 'Enter your email',
            prefixIcon: Icons.alternate_email_rounded,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            validator: FormValidators.email,
          ),

          const SizedBox(height: AppSpacing.md),

          AppTextField(
            controller: _signupPasswordController,
            label: 'Password',
            hint: 'Create a password',
            prefixIcon: Icons.lock_outline_rounded,
            obscureText: _obscureSignupPassword,
            textInputAction: TextInputAction.done,
            validator: FormValidators.password,
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

          const SizedBox(height: AppSpacing.lg),

          AppButton(
            label: 'Create account',
            icon: Icons.arrow_forward_rounded,
            isLoading: _isLoading,
            onPressed: _createAccount,
          ),
        ],
      ),
    );
  }
}
