import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_section_header.dart';
import '../models/external_donor_model.dart';
import 'external_donor_list_item.dart';

class ExternalDonorListSection extends StatelessWidget {
  const ExternalDonorListSection({
    super.key,
    required this.donors,
    this.onViewAll,
    this.onDonorTap,
  });

  final List<ExternalDonorModel> donors;
  final VoidCallback? onViewAll;
  final ValueChanged<ExternalDonorModel>? onDonorTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSectionHeader(
          title: 'External Donors',
          actionLabel: donors.isNotEmpty ? 'View All' : null,
          onActionPressed: donors.isNotEmpty ? onViewAll : null,
        ),
        const SizedBox(height: AppSpacing.sm),
        if (donors.isEmpty)
          const _EmptyExternalDonorSection()
        else
          _ExternalDonorPreviewList(
            donors: donors,
            onDonorTap: onDonorTap,
          ),
      ],
    );
  }
}

class _ExternalDonorPreviewList extends StatelessWidget {
  const _ExternalDonorPreviewList({
    required this.donors,
    this.onDonorTap,
  });

  final List<ExternalDonorModel> donors;
  final ValueChanged<ExternalDonorModel>? onDonorTap;

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
              separatorBuilder: (_, _) =>
                  const SizedBox(height: AppSpacing.xs),
              itemBuilder: (context, index) {
                final donor = donors[index];

                return ExternalDonorListItem(
                  donor: donor,
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

class _EmptyExternalDonorSection extends StatelessWidget {
  const _EmptyExternalDonorSection();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: const SizedBox(
        height: 230,
        child: AppEmptyState(
          title: 'No external donors available',
          description:
              'There are no external donors to show right now.',
          icon: Icons.people_outline,
        ),
      ),
    );
  }
}