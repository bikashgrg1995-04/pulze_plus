import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pulze_plus/app/router/app_router.dart';
import 'package:pulze_plus/core/theme/app_theme.dart';
import 'package:pulze_plus/core/widgets/app_snack_bar.dart';
import 'package:pulze_plus/features/auth/models/auth_state.dart';
import 'package:pulze_plus/features/auth/providers/auth_provider.dart';

class PulzeApp extends ConsumerWidget {
  const PulzeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Pulze+',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      routerConfig: router,
      builder: (context, child) {
        return _AuthMessageListener(child: child ?? const SizedBox.shrink());
      },
    );
  }
}

class _AuthMessageListener extends ConsumerWidget {
  const _AuthMessageListener({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AuthState>(authProvider, (previous, next) {
      final message = next.message;

      if (message == null || message.isEmpty) {
        return;
      }

      switch (next.messageType) {
        case AuthMessageType.success:
          AppSnackBar.success(context, message);
          break;

        case AuthMessageType.info:
          AppSnackBar.info(context, message);
          break;

        case AuthMessageType.warning:
          AppSnackBar.warning(context, message);
          break;

        case null:
          break;
      }
    });

    return child;
  }
}
