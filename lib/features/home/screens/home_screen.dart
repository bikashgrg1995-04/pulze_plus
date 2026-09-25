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
  const HomeScreen({super.key, this.isGuest = true});

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
                  HomeHeader(isGuest: isGuest),

                  const SizedBox(height: AppSpacing.sm),

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
                    title: isGuest ? 'Why join Pulze+?' : 'Recommended for you',
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  HomeRecommendation(isGuest: isGuest),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
