import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pulze_plus/core/location/location_providers.dart';
import 'package:pulze_plus/core/location/location_service.dart';
import 'package:pulze_plus/core/preferences/app_preferences_provider.dart';
import 'package:pulze_plus/core/theme/app_colors.dart';
import 'package:pulze_plus/core/theme/app_spacing.dart';
import 'package:pulze_plus/core/utils/responsive_utils.dart';
import 'package:pulze_plus/core/widgets/app_card.dart';
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

    final preferencesNotifier = ref.read(appPreferencesProvider.notifier);

    try {
      final locationService = ref.read(locationServiceProvider);

      await locationService.ensurePermission();

      await preferencesNotifier.setLocationEnabled(true);
    } on LocationServiceDisabledException {
      await preferencesNotifier.setLocationEnabled(false);
    } on LocationPermissionDeniedException {
      await preferencesNotifier.setLocationEnabled(false);
    } on LocationPermissionPermanentlyDeniedException {
      await preferencesNotifier.setLocationEnabled(false);
    } catch (_) {
      await preferencesNotifier.setLocationEnabled(false);
    } finally {
      await preferencesNotifier.completeLocationSetup();
    }
  }

  Future<void> _toggleLocation(
    BuildContext context,
    WidgetRef ref,
    bool value,
  ) async {
    final preferencesNotifier = ref.read(appPreferencesProvider.notifier);

    if (!value) {
      await preferencesNotifier.setLocationEnabled(false);
      return;
    }

    try {
      final locationService = ref.read(locationServiceProvider);

      await locationService.ensurePermission();

      await preferencesNotifier.setLocationEnabled(true);
    } on LocationServiceDisabledException {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location services are turned off on your device.'),
        ),
      );
    } on LocationPermissionDeniedException {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location permission was denied.')),
      );
    } on LocationPermissionPermanentlyDeniedException {
      if (!context.mounted) {
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
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not access your location right now.'),
        ),
      );
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

    final locationEnabled = ref.watch(appPreferencesProvider).locationEnabled;

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

                  const SizedBox(height: AppSpacing.sm),

                  AppCard(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.location_on_outlined,
                            color: AppColors.primary,
                            size: 23,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm + 2),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Location',
                                style: Theme.of(context).textTheme.titleSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                locationEnabled
                                    ? 'Used to find nearby donors'
                                    : 'Location is turned off',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                        Switch.adaptive(
                          value: locationEnabled,
                          onChanged: (value) {
                            _toggleLocation(context, ref, value);
                          },
                        ),
                      ],
                    ),
                  ),

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
