import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_section_header.dart';
import '../models/donor_model.dart';
import 'donor_list_item.dart';

class DonorListSection extends StatelessWidget {
  const DonorListSection({
    super.key,
    required this.donors,
    this.onViewAll,
    this.onDonorRequest,
    this.onDonorTap,
  });

  final List<DonorModel> donors;
  final VoidCallback? onViewAll;
  final ValueChanged<DonorModel>? onDonorRequest;
  final ValueChanged<DonorModel>? onDonorTap;

  @override
  Widget build(BuildContext context) {
    final visibleDonors = donors.take(3).toList();

    return Column(
      children: [
        AppSectionHeader(
          title: 'Available Donors',
          actionLabel: donors.length > 3 ? 'View All' : null,
          onActionPressed: onViewAll,
        ),
        const SizedBox(height: AppSpacing.sm),
        if (visibleDonors.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(
              vertical: AppSpacing.xl,
            ),
            child: Text(
              'No matching donors found.',
            ),
          )
        else
          ...visibleDonors.map(
            (donor) => Padding(
              padding: const EdgeInsets.only(
                bottom: AppSpacing.sm,
              ),
              child: DonorListItem(
                donor: donor,
                onRequest: () {
                  onDonorRequest?.call(donor);
                },
                onTap: () {
                  onDonorTap?.call(donor);
                },
              ),
            ),
          ),
      ],
    );
  }
}