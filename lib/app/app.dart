import 'package:flutter/material.dart';
import 'package:pulze_plus/app/router/app_router.dart';
import 'package:pulze_plus/core/theme/app_theme.dart';

class PulzeApp extends StatelessWidget {
  const PulzeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Pulze+',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      routerConfig: appRouter,
    );
  }
}
