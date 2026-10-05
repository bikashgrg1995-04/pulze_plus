import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:pulze_plus/app/app_startup_screen.dart';
import 'package:pulze_plus/app/router/app_routes.dart';
import 'package:pulze_plus/app/router/router_refresh_notifier.dart';
import 'package:pulze_plus/core/preferences/app_preferences_provider.dart';
import 'package:pulze_plus/features/auth/models/auth_state.dart';
import 'package:pulze_plus/features/auth/providers/auth_provider.dart';
import 'package:pulze_plus/features/auth/screens/auth_screen.dart';
import 'package:pulze_plus/features/auth/screens/forgot_password_screen.dart';
import 'package:pulze_plus/features/auth/screens/reset_password_screen.dart';
import 'package:pulze_plus/features/auth/screens/verify_email_screen.dart';
import 'package:pulze_plus/features/auth/screens/verify_password_reset_screen.dart';
import 'package:pulze_plus/features/navigation/screens/main_navigation_screen.dart';
import 'package:pulze_plus/features/onboarding/screens/onboarding_screen.dart';
import 'package:pulze_plus/features/profile/screens/faq_screen.dart';
import 'package:pulze_plus/features/profile/screens/legal_document_screen.dart';
import 'package:pulze_plus/features/profile/screens/profile_form_screen.dart';
import 'package:pulze_plus/features/profile/screens/profile_screen.dart';
import 'package:pulze_plus/features/requests/screens/blood_request_detail_screen.dart';
import 'package:pulze_plus/features/donors/screens/donor_list_screen.dart';
import 'package:pulze_plus/features/donors/screens/incoming_blood_requests_screen.dart';
import 'package:pulze_plus/features/requests/screens/my_blood_requests_screen.dart';
import 'package:pulze_plus/features/requests/screens/requests_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final routerRefreshNotifier = RouterRefreshNotifier(ref);

  final router = GoRouter(
    initialLocation: AppRoutes.startup,

    refreshListenable: routerRefreshNotifier,

    redirect: (context, state) {
      final authStatus = ref.read(authProvider).status;
      final preferences = ref.read(appPreferencesProvider);

      final hasCompletedEntry = preferences.hasCompletedEntry;

      final location = state.matchedLocation;

      final isAuthRoute =
          location == AppRoutes.auth ||
          location == AppRoutes.verifyEmail ||
          location == AppRoutes.forgotPassword ||
          location == AppRoutes.verifyPasswordReset ||
          location == AppRoutes.resetPassword;

      final isLegalRoute =
          location == AppRoutes.privacyPolicy ||
          location == AppRoutes.termsConditions;

      final isPublicRoute =
          location == AppRoutes.startup ||
          location == AppRoutes.onboarding ||
          isAuthRoute ||
          isLegalRoute ||
          location == AppRoutes.home ||
          location == AppRoutes.requests ||
          location == AppRoutes.donors;

      if (authStatus == AuthStatus.initial ||
          authStatus == AuthStatus.loading) {
        return null;
      }

      // ------------------------------------------------------------
      // Startup / first-entry flow
      // ------------------------------------------------------------

      if (location == AppRoutes.startup) {
        if (!hasCompletedEntry) {
          return AppRoutes.onboarding;
        }

        return AppRoutes.home;
      }

      // ------------------------------------------------------------
      // Onboarding
      // ------------------------------------------------------------

      if (location == AppRoutes.onboarding) {
        if (hasCompletedEntry) {
          return AppRoutes.home;
        }

        return null;
      }

      // ------------------------------------------------------------
      // Unauthenticated / Guest
      // ------------------------------------------------------------

      if (authStatus == AuthStatus.unauthenticated) {
        if (isPublicRoute) {
          return null;
        }

        return AppRoutes.auth;
      }

      // ------------------------------------------------------------
      // Email verification
      // ------------------------------------------------------------

      if (authStatus == AuthStatus.needsVerification) {
        if (location == AppRoutes.auth || location == AppRoutes.verifyEmail) {
          return null;
        }

        return AppRoutes.verifyEmail;
      }

      // ------------------------------------------------------------
      // Profile setup
      // ------------------------------------------------------------

      if (authStatus == AuthStatus.needsProfile) {
        if (location == AppRoutes.profileSetup) {
          return null;
        }

        return AppRoutes.profileSetup;
      }

      // ------------------------------------------------------------
      // Authenticated user
      // ------------------------------------------------------------

      if (authStatus == AuthStatus.authenticated) {
        if (isAuthRoute ||
            location == AppRoutes.startup ||
            location == AppRoutes.onboarding) {
          return AppRoutes.home;
        }
      }

      return null;
    },

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
          final email = state.extra as String?;

          if (email == null || email.isEmpty) {
            return const AuthScreen();
          }

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
        path: AppRoutes.donors,
        builder: (context, state) {
          return const DonorListScreen();
        },
      ),

      // GoRoute(
      //   path: AppRoutes.donorDetail,
      //   builder: (context, state) {
      //     final donor = state.extra as DonorModel;
      //     return DonorDetailScreen(donor: donor);
      //   },

      GoRoute(
        path: AppRoutes.myBloodRequests,
        builder: (context, state) {
          return const MyBloodRequestsScreen();
        },
      ),

      GoRoute(
        path: AppRoutes.incomingBloodRequests,
        builder: (context, state) {
          return const IncomingBloodRequestsScreen();
        },
      ),

      GoRoute(
        path: AppRoutes.bloodRequestDetail,
        builder: (context, state) {
          final args = state.extra as BloodRequestDetailArgs;

          return BloodRequestDetailScreen(
            request: args.request,
            onEdit: args.onEdit,
            onTerminate: args.onTerminate,
            onAccept: args.onAccept,
            onDecline: args.onDecline,
            onComplete: args.onComplete,
            onConnection: args.onConnection,
          );
        },
      ),

      // GoRoute(
      //   path: AppRoutes.chatDetail,
      //   builder: (context, state) {
      //     final chat = state.extra as ChatModel;

      //     return ChatDetailScreen(chat: chat);
      //   },
      // ),

      GoRoute(
        path: AppRoutes.privacyPolicy,
        builder: (context, state) {
          return const LegalDocumentScreen(
            type: LegalDocumentType.privacyPolicy,
          );
        },
      ),

      GoRoute(
        path: AppRoutes.termsConditions,
        builder: (context, state) {
          return const LegalDocumentScreen(
            type: LegalDocumentType.termsConditions,
          );
        },
      ),

      GoRoute(
        path: AppRoutes.faqs,
        builder: (context, state) {
          return const FaqScreen();
        },
      ),
    ],
  );

  ref.onDispose(() {
    routerRefreshNotifier.dispose();
    router.dispose();
  });

  return router;
});
