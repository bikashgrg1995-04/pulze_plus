import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_section_header.dart';
import '../models/donor_model.dart';
import 'donor_list_item.dart';

class DonorListSection extends StatelessWidget {
  const DonorListSection({
    super.key,
    required this.donors,
    this.locationEnabled = false,
    this.onViewAll,
    this.onDonorRequest,
    this.onDonorTap,
  });

  final List<DonorModel> donors;
  final bool locationEnabled;
  final VoidCallback? onViewAll;
  final ValueChanged<DonorModel>? onDonorRequest;
  final ValueChanged<DonorModel>? onDonorTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSectionHeader(
          title: 'Available Donors',
          actionLabel: donors.isNotEmpty ? 'View All' : null,
          onActionPressed: donors.isNotEmpty ? onViewAll : null,
        ),

        const SizedBox(height: AppSpacing.sm),

        if (!locationEnabled) ...[
          const _LocationPrompt(),
          const SizedBox(height: AppSpacing.sm),
        ],

        if (donors.isEmpty)
          const _EmptyDonorSection()
        else
          _DonorPreviewList(
            donors: donors,
            locationEnabled: locationEnabled,
            onDonorRequest: onDonorRequest,
            onDonorTap: onDonorTap,
          ),
      ],
    );
  }
}

class _LocationPrompt extends StatelessWidget {
  const _LocationPrompt();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.location_on_outlined,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          const Expanded(
            child: Text(
              'Turn on location to see accurate donor distances near you.',
              style: TextStyle(
                fontSize: 12.5,
                height: 1.35,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DonorPreviewList extends StatelessWidget {
  const _DonorPreviewList({
    required this.donors,
    required this.locationEnabled,
    this.onDonorRequest,
    this.onDonorTap,
  });

  final List<DonorModel> donors;
  final bool locationEnabled;
  final ValueChanged<DonorModel>? onDonorRequest;
  final ValueChanged<DonorModel>? onDonorTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.xs),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 246,
            child: ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.xs),
              physics: const BouncingScrollPhysics(),
              itemCount: donors.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.xs),
              itemBuilder: (context, index) {
                final donor = donors[index];

                return DonorListItem(
                  donor: donor,
                  locationEnabled: locationEnabled,
                  onRequest: () {
                    onDonorRequest?.call(donor);
                  },
                  onTap: () {
                    onDonorTap?.call(donor);
                  },
                );
              },
            ),
          ),
          if (donors.length > 3)
            Padding(
              padding: const EdgeInsets.only(
                left: AppSpacing.sm,
                right: AppSpacing.sm,
                bottom: AppSpacing.sm,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.swipe_vertical_rounded,
                    size: 15,
                    color: AppColors.textSecondary.withValues(alpha: 0.75),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'Swipe to see more donors',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _EmptyDonorSection extends StatelessWidget {
  const _EmptyDonorSection();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: const SizedBox(
        height: 230,
        child: AppEmptyState(
          title: 'No donors available',
          description: 'There are no available donors to show right now.',
          icon: Icons.person_search_outlined,
        ),
      ),
    );
  }
}
