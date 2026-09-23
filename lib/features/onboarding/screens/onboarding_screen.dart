import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:pulze_plus/app/router/app_routes.dart';
import 'package:pulze_plus/features/onboarding/model/onboarding_data.dart';
import 'package:pulze_plus/features/onboarding/widgets/onboarding_bottom_action.dart';
import 'package:pulze_plus/features/onboarding/widgets/onboarding_page.dart';
import 'package:pulze_plus/features/onboarding/widgets/onboarding_page_indicator.dart';
import 'package:pulze_plus/features/onboarding/widgets/onboarding_top_bar.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/responsive_utils.dart';
import '../providers/onboarding_provider.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();

  static const List<OnboardingData> _pages = [
    OnboardingData(
      title: 'Find the right connection.',
      description: 'Connect with people who need blood and donors who are ready to help.',
      icon: Icons.people_outline_rounded,
    ),
    OnboardingData(
      title: 'Your donation can make a difference.',
      description: 'Discover blood requests around you and help when you are eligible to donate.',
      icon: Icons.volunteer_activism_outlined,
    ),
    OnboardingData(
      title: 'Be there when it matters.',
      description: 'Get notified about relevant blood requests and stay connected with your community.',
      icon: Icons.notifications_none_rounded,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _nextPage() async {
    final currentPage = ref.read(onboardingProvider);

    if (currentPage < _pages.length - 1) {
      await _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
      return;
    }

    await _finishOnboarding();
  }

  Future<void> _skipOnboarding() async {
    await _finishOnboarding();
  }

  Future<void> _finishOnboarding() async {
    await ref.read(onboardingProvider.notifier).complete();

    if (!mounted) return;

    context.go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    final currentPage = ref.watch(onboardingProvider);

    final horizontalPadding = ResponsiveUtils.value(
      context,
      mobile: AppSpacing.xl,
      tablet: AppSpacing.xxl,
      large: AppSpacing.xxxl,
    );

    final topSpacing = ResponsiveUtils.value(
      context,
      mobile: AppSpacing.xs,
      tablet: AppSpacing.sm,
      large: AppSpacing.md,
    );

    final indicatorSpacing = ResponsiveUtils.value(
      context,
      mobile: AppSpacing.md,
      tablet: AppSpacing.lg,
      large: AppSpacing.xl,
    );

    final actionSpacing = ResponsiveUtils.value(
      context,
      mobile: AppSpacing.lg,
      tablet: AppSpacing.xl,
      large: AppSpacing.xxl,
    );

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: topSpacing),

            OnboardingTopBar(
              currentPage: currentPage,
              totalPages: _pages.length,
              horizontalPadding: horizontalPadding,
              onSkip: _skipOnboarding,
            ),

            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                physics: const BouncingScrollPhysics(),
                onPageChanged: (index) {
                  ref.read(onboardingProvider.notifier).setPage(index);
                },
                itemBuilder: (context, index) {
                  return OnboardingPage(
                    data: _pages[index],
                    horizontalPadding: horizontalPadding,
                  );
                },
              ),
            ),

            SizedBox(height: indicatorSpacing),

            OnboardingPageIndicator(
              currentPage: currentPage,
              pageCount: _pages.length,
            ),

            SizedBox(height: actionSpacing),

            OnboardingBottomAction(
              currentPage: currentPage,
              lastPage: _pages.length - 1,
              onPressed: _nextPage,
              horizontalPadding: horizontalPadding,
            ),

            SizedBox(height: actionSpacing),
          ],
        ),
      ),
    );
  }
}
