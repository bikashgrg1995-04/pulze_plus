import 'package:go_router/go_router.dart';
import 'package:pulze_plus/app/app_startup_screen.dart';
import 'package:pulze_plus/features/navigation/screens/main_navigation_screen.dart';
import 'package:pulze_plus/features/onboarding/screens/onboarding_screen.dart';

import 'app_routes.dart';

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
      path: AppRoutes.home,
      builder: (context, state) {
        return const MainNavigationScreen();
      },
    ),

    GoRoute(
      path: AppRoutes.auth,
      builder: (context, state) {
        throw UnimplementedError();
      },
    ),
  ],
);