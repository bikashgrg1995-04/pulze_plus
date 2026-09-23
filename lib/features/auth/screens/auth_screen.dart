import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../widgets/auth_divider.dart';
import '../widgets/auth_header.dart';
import '../widgets/google_auth_button.dart';

enum AuthMode {
  login,
  signup,
}

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
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
    // Google authentication will be connected later.
  }

  void _signIn() {
    // Authentication will be connected later.
  }

  void _createAccount() {
    // Account creation will be connected later.
  }

  void _toggleMode() {
    setState(() {
      _clearLoginForm();
      _clearSignupForm();

      _mode = _isLogin
          ? AuthMode.signup
          : AuthMode.login;

      _obscureLoginPassword = true;
      _obscureSignupPassword = true;
    });
  }

  void _clearLoginForm() {
    _loginEmailController.clear();
    _loginPasswordController.clear();
  }

  void _clearSignupForm() {
    _signupNameController.clear();
    _signupEmailController.clear();
    _signupPasswordController.clear();
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

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          keyboardDismissBehavior:
              ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            AppSpacing.xl,
            horizontalPadding,
            AppSpacing.xxl,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 480,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AuthHeader(
                    title: _isLogin
                        ? 'Welcome back'
                        : 'Create your account',
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

                  const AuthDivider(),

                  const SizedBox(height: AppSpacing.lg),

                  if (_isLogin)
                    _buildLoginForm()
                  else
                    _buildSignupForm(),

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
                        onPressed: _toggleMode,
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          padding: const EdgeInsets.only(
                            left: AppSpacing.xs,
                            right: AppSpacing.xxs,
                          ),
                          minimumSize: Size.zero,
                          tapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          _isLogin
                              ? 'Create account'
                              : 'Sign in',
                        ),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppTextField(
          controller: _loginEmailController,
          label: 'Email or phone',
          hint: 'Enter your email or phone',
          prefixIcon: Icons.person_outline_rounded,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
        ),

        const SizedBox(height: AppSpacing.md),

        AppTextField(
          controller: _loginPasswordController,
          label: 'Password',
          hint: 'Enter your password',
          prefixIcon: Icons.lock_outline_rounded,
          obscureText: _obscureLoginPassword,
          textInputAction: TextInputAction.done,
          suffixIcon: _obscureLoginPassword
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined,
          onSuffixPressed: () {
            setState(() {
              _obscureLoginPassword =
                  !_obscureLoginPassword;
            });
          },
        ),

        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {
              // Forgot password will be connected later.
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xxs,
                vertical: AppSpacing.xs,
              ),
              minimumSize: Size.zero,
              tapTargetSize:
                  MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text('Forgot password?'),
          ),
        ),

        const SizedBox(height: AppSpacing.sm),

        AppButton(
          label: 'Sign in',
          icon: Icons.arrow_forward_rounded,
          onPressed: _signIn,
        ),
      ],
    );
  }

  Widget _buildSignupForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppTextField(
          controller: _signupNameController,
          label: 'Full name',
          hint: 'Enter your full name',
          prefixIcon: Icons.person_outline_rounded,
          textInputAction: TextInputAction.next,
        ),

        const SizedBox(height: AppSpacing.md),

        AppTextField(
          controller: _signupEmailController,
          label: 'Email or phone',
          hint: 'Enter your email or phone',
          prefixIcon: Icons.alternate_email_rounded,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
        ),

        const SizedBox(height: AppSpacing.md),

        AppTextField(
          controller: _signupPasswordController,
          label: 'Password',
          hint: 'Create a password',
          prefixIcon: Icons.lock_outline_rounded,
          obscureText: _obscureSignupPassword,
          textInputAction: TextInputAction.done,
          suffixIcon: _obscureSignupPassword
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined,
          onSuffixPressed: () {
            setState(() {
              _obscureSignupPassword =
                  !_obscureSignupPassword;
            });
          },
        ),

        const SizedBox(height: AppSpacing.lg),

        AppButton(
          label: 'Create account',
          icon: Icons.arrow_forward_rounded,
          onPressed: _createAccount,
        ),
      ],
    );
  }
}