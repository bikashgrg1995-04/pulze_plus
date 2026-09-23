import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../models/donor_model.dart';

class RequestDonorSheet extends StatefulWidget {
  const RequestDonorSheet({
    super.key,
    required this.donor,
    this.onSubmit,
  });

  final DonorModel donor;
  final VoidCallback? onSubmit;

  @override
  State<RequestDonorSheet> createState() => _RequestDonorSheetState();
}

class _RequestDonorSheetState extends State<RequestDonorSheet> {
  final _unitsController = TextEditingController();
  final _locationController = TextEditingController();
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _unitsController.dispose();
    _locationController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.lg,
          AppSpacing.xl,
        ),
        child: Column(
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
              'Send a blood request to this available donor.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),

            const SizedBox(height: AppSpacing.lg),

            _DonorSummary(
              donor: widget.donor,
            ),

            const SizedBox(height: AppSpacing.xl),

            AppTextField(
              controller: _unitsController,
              label: 'Units Needed',
              hint: 'e.g. 2',
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: AppSpacing.md),

            AppTextField(
              controller: _locationController,
              label: 'Hospital / Location',
              hint: 'Enter hospital or treatment location',
            ),

            const SizedBox(height: AppSpacing.md),

            AppTextField(
              controller: _noteController,
              label: 'Additional Note',
              hint: 'Add any important information',
              maxLines: 3,
            ),

            const SizedBox(height: AppSpacing.xl),

            AppButton(
              label: 'Review Request',
              onPressed: () {
                widget.onSubmit?.call();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _DonorSummary extends StatelessWidget {
  const _DonorSummary({
    required this.donor,
  });

  final DonorModel donor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              donor.bloodGroup,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${donor.bloodGroup} Donor',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${donor.distance.toStringAsFixed(1)} km away • Eligible',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
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