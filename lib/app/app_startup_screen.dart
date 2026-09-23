import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import 'router/app_routes.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/utils/responsive_utils.dart';
import '../core/widgets/app_loading.dart';
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
      isCompleted ? AppRoutes.home : AppRoutes.onboarding,
    );
  }

  @override
  Widget build(BuildContext context) {
    final logoSize = ResponsiveUtils.value(
      context,
      mobile: 88,
      tablet: 104,
      large: 112,
    );

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _BrandLogo(
                  size: logoSize,
                ),

                const SizedBox(height: AppSpacing.xl),

                Text(
                  'Pulze+',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        color: AppColors.navy,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1,
                      ),
                ),

                const SizedBox(height: AppSpacing.xs),

                Text(
                  'Connect. Give. Live.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.2,
                      ),
                ),

                const SizedBox(height: AppSpacing.huge),

                const AppLoading(
                  size: 26,
                  strokeWidth: 2.5,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BrandLogo extends StatelessWidget {
  const _BrandLogo({
    required this.size,
  });

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: SvgPicture.asset(
        'assets/branding/app_icon.svg',
        fit: BoxFit.contain,
      ),
    );
  }
}