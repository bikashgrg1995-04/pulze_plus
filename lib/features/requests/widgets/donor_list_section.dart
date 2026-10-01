
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
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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
              size: 22,
            ),
          ),

          const SizedBox(width: AppSpacing.sm + 2),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Turn on location',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Enable location to see accurate donor distances near you.',
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.4,
                    color: AppColors.textSecondary,
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

class _DonorPreviewList extends StatelessWidget {
  const _DonorPreviewList({
    required this.donors,
    this.onDonorRequest,
    this.onDonorTap,
  });

  final List<DonorModel> donors;
  final ValueChanged<DonorModel>? onDonorRequest;
  final ValueChanged<DonorModel>? onDonorTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: SizedBox(
        height: 250,
        child: ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.sm),
          physics: const BouncingScrollPhysics(),
          itemCount: donors.length,
          separatorBuilder: (_, _) =>
              const SizedBox(height: AppSpacing.xs),
          itemBuilder: (context, index) {
            final donor = donors[index];

            return DonorListItem(
              donor: donor,
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
          description:
              'There are no available donors to show right now.',
          icon: Icons.person_search_outlined,
        ),
      ),
    );
  }
}