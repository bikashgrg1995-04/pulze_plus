import 'package:flutter/material.dart';

import 'package:pulze_plus/core/theme/app_colors.dart';
import 'package:pulze_plus/core/theme/app_spacing.dart';
import 'package:pulze_plus/core/utils/responsive_utils.dart';
import 'package:pulze_plus/core/widgets/app_section_header.dart';
import 'package:pulze_plus/features/home/widgets/emergency_actions.dart';
import 'package:pulze_plus/features/home/widgets/home_header.dart';
import 'package:pulze_plus/features/home/widgets/home_recommendation.dart';
import 'package:pulze_plus/features/home/widgets/home_request_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    this.isGuest = true,
  });

  final bool isGuest;

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
                  HomeHeader(
                    isGuest: isGuest,
                  ),


                  const SizedBox(height: AppSpacing.sm),

                  const AppSectionHeader(
                    title: 'Emergency',
                  ),

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
                    title: isGuest
                        ? 'Why join Pulze+?'
                        : 'Recommended for you',
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  HomeRecommendation(
                    isGuest: isGuest,
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRequestBloodSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return const _RequestBloodSheet();
      },
    );
  }
}

class _RequestBloodSheet extends StatelessWidget {
  const _RequestBloodSheet();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.md,
        AppSpacing.xl,
        AppSpacing.xl,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.xl),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.xl),

          Text(
            'Request Blood',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
          ),

          const SizedBox(height: AppSpacing.xs),

          Text(
            'Tell us what blood you need and where it is required.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),

          const SizedBox(height: AppSpacing.xl),

          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Blood Group',
            ),
            items: const [
              DropdownMenuItem(
                value: 'A+',
                child: Text('A+'),
              ),
              DropdownMenuItem(
                value: 'A-',
                child: Text('A-'),
              ),
              DropdownMenuItem(
                value: 'B+',
                child: Text('B+'),
              ),
              DropdownMenuItem(
                value: 'B-',
                child: Text('B-'),
              ),
              DropdownMenuItem(
                value: 'O+',
                child: Text('O+'),
              ),
              DropdownMenuItem(
                value: 'O-',
                child: Text('O-'),
              ),
              DropdownMenuItem(
                value: 'AB+',
                child: Text('AB+'),
              ),
              DropdownMenuItem(
                value: 'AB-',
                child: Text('AB-'),
              ),
            ],
            onChanged: (_) {},
          ),

          const SizedBox(height: AppSpacing.md),

          TextFormField(
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Units needed',
              hintText: 'e.g. 2',
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Hospital / Location',
              hintText: 'Where is blood needed?',
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title: const Text('Urgent request'),
            subtitle: const Text(
              'Notify matching donors as soon as possible.',
            ),
            value: true,
            onChanged: (_) {},
            activeTrackColor: AppColors.primary,
          ),

          const SizedBox(height: AppSpacing.md),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Create Request'),
            ),
          ),
        ],
      ),
    );
  }
}