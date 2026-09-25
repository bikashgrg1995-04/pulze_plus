import 'package:go_router/go_router.dart';

import 'package:pulze_plus/app/app_startup_screen.dart';
import 'package:pulze_plus/app/router/app_routes.dart';
import 'package:pulze_plus/features/auth/screens/auth_screen.dart';
import 'package:pulze_plus/features/auth/screens/forgot_password_screen.dart';
import 'package:pulze_plus/features/auth/screens/reset_password_screen.dart';
import 'package:pulze_plus/features/auth/screens/verify_email_screen.dart';
import 'package:pulze_plus/features/auth/screens/verify_password_reset_screen.dart';
import 'package:pulze_plus/features/chat/models/chat_model.dart';
import 'package:pulze_plus/features/chat/screens/chat_detail_screen.dart';
import 'package:pulze_plus/features/chat/screens/chats_screen.dart';
import 'package:pulze_plus/features/navigation/screens/main_navigation_screen.dart';
import 'package:pulze_plus/features/onboarding/screens/onboarding_screen.dart';
import 'package:pulze_plus/features/profile/screens/profile_form_screen.dart';
import 'package:pulze_plus/features/profile/screens/profile_screen.dart';
import 'package:pulze_plus/features/requests/screens/requests_screen.dart';

final appRouter = GoRouter(
  initialLocation: AppRoutes.startup,
  routes: [
    GoRoute(
      path: AppRoutes.startup,
      builder: (context, state) {
        return const AppStartupScreen();
      },
    ),

    GoRoute(
      path: AppRoutes.onboarding,
      builder: (context, state) {
        return const OnboardingScreen();
      },
    ),

    GoRoute(
      path: AppRoutes.auth,
      builder: (context, state) {
        return const AuthScreen();
      },
    ),

    GoRoute(
      path: AppRoutes.verifyEmail,
      builder: (context, state) {
        final email = state.extra as String;

        return VerifyEmailScreen(email: email);
      },
    ),

    GoRoute(
      path: AppRoutes.forgotPassword,
      builder: (context, state) {
        final email = state.extra as String?;

        return ForgotPasswordScreen(email: email);
      },
    ),

    GoRoute(
      path: AppRoutes.verifyPasswordReset,
      builder: (context, state) {
        final email = state.extra as String;

        return VerifyPasswordResetScreen(email: email);
      },
    ),

    GoRoute(
      path: AppRoutes.resetPassword,
      builder: (context, state) {
        final resetToken = state.extra as String;

        return ResetPasswordScreen(resetToken: resetToken);
      },
    ),

    GoRoute(
      path: AppRoutes.profile,
      builder: (context, state) {
        return const ProfileScreen();
      },
    ),

    GoRoute(
      path: AppRoutes.profileSetup,
      builder: (context, state) {
        return const ProfileFormScreen(mode: ProfileFormMode.create);
      },
    ),

    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) {
        return const MainNavigationScreen();
      },
    ),

    GoRoute(
      path: AppRoutes.requests,
      builder: (context, state) {
        return const RequestsScreen();
      },
    ),

    GoRoute(
      path: AppRoutes.chat,
      builder: (context, state) {
        return const ChatsScreen();
      },
    ),

    GoRoute(
      path: AppRoutes.chatDetail,
      builder: (context, state) {
        final chat = state.extra as ChatModel;

        return ChatDetailScreen(chat: chat);
      },
    ),
  ],
);
