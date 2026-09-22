import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'router/app_routes.dart';
import '../features/onboarding/providers/onboarding_provider.dart';

class AppStartupScreen extends ConsumerStatefulWidget {
  const AppStartupScreen({super.key});

  @override
  ConsumerState<AppStartupScreen> createState() => _AppStartupScreenState();
}

class _AppStartupScreenState extends ConsumerState<AppStartupScreen> {
  @override
  void initState() {
    super.initState();

    _checkAppState();
  }

  Future<void> _checkAppState() async {
    final isCompleted = await ref
        .read(onboardingProvider.notifier)
        .isCompleted();

    if (!mounted) return;

    context.go(
      isCompleted
          ? AppRoutes.home
          : AppRoutes.onboarding,
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}