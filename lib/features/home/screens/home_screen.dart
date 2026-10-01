import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pulze_plus/core/location/location_providers.dart';
import 'package:pulze_plus/core/location/location_service.dart';
import 'package:pulze_plus/core/preferences/app_preferences_provider.dart';
import 'package:pulze_plus/core/theme/app_colors.dart';
import 'package:pulze_plus/core/theme/app_spacing.dart';
import 'package:pulze_plus/core/utils/responsive_utils.dart';
import 'package:pulze_plus/core/widgets/app_section_header.dart';
import 'package:pulze_plus/features/home/widgets/emergency_actions.dart';
import 'package:pulze_plus/features/home/widgets/home_header.dart';
import 'package:pulze_plus/features/home/widgets/home_recommendation.dart';
import 'package:pulze_plus/features/home/widgets/home_request_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key, this.isGuest = true});

  final bool isGuest;

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestInitialLocation();
    });
  }

  Future<void> _requestInitialLocation() async {
    final preferences = ref.read(appPreferencesProvider);

    // The initial location request has already been handled.
    if (preferences.hasCompletedLocationSetup) {
      return;
    }

    await _showLocationPermissionDialog();
  }

  Future<void> _showLocationPermissionDialog() async {
    if (!mounted) {
      return;
    }

    final shouldAllow = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          titlePadding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.sm,
          ),
          contentPadding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            0,
            AppSpacing.lg,
            AppSpacing.sm,
          ),
          actionsPadding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.sm,
            AppSpacing.lg,
            AppSpacing.md,
          ),
          title: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.location_on_outlined,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'Use your location?',
                  style: Theme.of(dialogContext).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            'Pulze+ uses your location to find nearby blood donors and '
            'show accurate distances from you. Your location is not '
            'shown publicly to other users.',
            style: Theme.of(dialogContext).textTheme.bodyMedium
                ?.copyWith(height: 1.5, color: AppColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Not now'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text('Allow Location'),
            ),
          ],
        );
      },
    );

    if (!mounted) {
      return;
    }

    final preferencesNotifier = ref.read(appPreferencesProvider.notifier);

    // User declined our explanation dialog.
    if (shouldAllow != true) {
      await preferencesNotifier.setLocationEnabled(false);
      await preferencesNotifier.completeLocationSetup();
      return;
    }

    await _requestDeviceLocationPermission();
  }

  Future<void> _requestDeviceLocationPermission() async {
    final preferencesNotifier = ref.read(appPreferencesProvider.notifier);

    try {
      final locationService = ref.read(locationServiceProvider);

      // This opens the native Android/iOS permission dialog.
      await locationService.ensurePermission();

      await preferencesNotifier.setLocationEnabled(true);
    } on LocationServiceDisabledException {
      await preferencesNotifier.setLocationEnabled(false);

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location services are turned off on your device.'),
        ),
      );
    } on LocationPermissionDeniedException {
      await preferencesNotifier.setLocationEnabled(false);

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location permission was denied.')),
      );
    } on LocationPermissionPermanentlyDeniedException {
      await preferencesNotifier.setLocationEnabled(false);

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Location permission is permanently denied. '
            'Please enable it from device settings.',
          ),
        ),
      );
    } catch (_) {
      await preferencesNotifier.setLocationEnabled(false);

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not access your location right now.'),
        ),
      );
    } finally {
      await preferencesNotifier.completeLocationSetup();
    }
  }

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = ResponsiveUtils.value(
      context,
      mobile: AppSpacing.md,
      tablet: AppSpacing.xxl,
      large: AppSpacing.xxxl,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                AppSpacing.lg,
                horizontalPadding,
                120,
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  HomeHeader(isGuest: widget.isGuest),

                  const SizedBox(height: AppSpacing.md),

                  const AppSectionHeader(title: 'Emergency'),

                  const SizedBox(height: AppSpacing.sm),

                  const EmergencyActions(),

                  const SizedBox(height: AppSpacing.sm),

                  const AppSectionHeader(
                    title: 'Urgent Requests',
                    actionLabel: 'See all',
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  const HomeRequestCard(
                    bloodGroup: 'O+',
                    units: '2 units',
                    location: 'Bharatpur Hospital',
                    distance: '3.2 km away',
                    isUrgent: true,
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  const AppSectionHeader(
                    title: 'Requests Near You',
                    actionLabel: 'See all',
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  const HomeRequestCard(
                    bloodGroup: 'A+',
                    units: '1 unit',
                    location: 'Chitwan Medical College',
                    distance: '5.4 km away',
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  AppSectionHeader(
                    title: widget.isGuest
                        ? 'Why join Pulze+'
                        : 'Recommended for you',
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  HomeRecommendation(isGuest: widget.isGuest),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
