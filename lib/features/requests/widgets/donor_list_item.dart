import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_status_badge.dart';
import '../models/donor_model.dart';

class DonorListItem extends StatelessWidget {
  const DonorListItem({
    super.key,
    required this.donor,
    this.onRequest,
    this.onTap,
  });

  final DonorModel donor;
  final VoidCallback? onRequest;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final canRequest = donor.isAvailable && donor.isEligible;
    final isSmallMobile = ResponsiveUtils.isSmallMobile(context);

    return AppCard(
      padding: EdgeInsets.all(
        isSmallMobile
            ? AppSpacing.sm
            : AppSpacing.md,
      ),
      onTap: onTap,
      child: isSmallMobile
          ? _SmallMobileLayout(
              donor: donor,
              canRequest: canRequest,
              onRequest: onRequest,
              theme: theme,
            )
          : _RegularLayout(
              donor: donor,
              canRequest: canRequest,
              onRequest: onRequest,
              theme: theme,
            ),
    );
  }
}

class _RegularLayout extends StatelessWidget {
  const _RegularLayout({
    required this.donor,
    required this.canRequest,
    required this.onRequest,
    required this.theme,
  });

  final DonorModel donor;
  final bool canRequest;
  final VoidCallback? onRequest;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _BloodGroupBadge(
          bloodGroup: donor.bloodGroup,
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _DonorInfo(
            donor: donor,
            theme: theme,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        _RequestButton(
          enabled: canRequest,
          onPressed: canRequest ? onRequest : null,
        ),
      ],
    );
  }
}

class _SmallMobileLayout extends StatelessWidget {
  const _SmallMobileLayout({
    required this.donor,
    required this.canRequest,
    required this.onRequest,
    required this.theme,
  });

  final DonorModel donor;
  final bool canRequest;
  final VoidCallback? onRequest;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _BloodGroupBadge(
              bloodGroup: donor.bloodGroup,
              size: 48,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _DonorInfo(
                donor: donor,
                theme: theme,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        _RequestButton(
          enabled: canRequest,
          onPressed: canRequest ? onRequest : null,
          fullWidth: true,
        ),
      ],
    );
  }
}

class _DonorInfo extends StatelessWidget {
  const _DonorInfo({
    required this.donor,
    required this.theme,
  });

  final DonorModel donor;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '${donor.bloodGroup} Donor',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (donor.isAvailable && donor.isEligible) ...[
              const SizedBox(width: AppSpacing.xs),
              const AppStatusBadge(
                label: 'Available',
                type: AppStatusType.available,
              ),
            ],
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        _DonorMetaRow(
          donor: donor,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          donor.lastDonation == null
              ? 'Donation history unavailable'
              : 'Last donation ${donor.lastDonation}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.textTertiary,
          ),
        ),
      ],
    );
  }
}

class _DonorMetaRow extends StatelessWidget {
  const _DonorMetaRow({
    required this.donor,
  });

  final DonorModel donor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        const Icon(
          Icons.location_on_outlined,
          size: 16,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            '${donor.distance.toStringAsFixed(1)} km away',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Container(
          width: 3,
          height: 3,
          decoration: const BoxDecoration(
            color: AppColors.textTertiary,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Flexible(
          child: Text(
            donor.isEligible
                ? 'Eligible'
                : 'Not eligible',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: donor.isEligible
                  ? AppColors.success
                  : AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _BloodGroupBadge extends StatelessWidget {
  const _BloodGroupBadge({
    required this.bloodGroup,
    this.size = 52,
  });

  final String bloodGroup;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        bloodGroup,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w800,
            ),
      ),
    );
  }
}

class _RequestButton extends StatelessWidget {
  const _RequestButton({
    required this.enabled,
    this.onPressed,
    this.fullWidth = false,
  });

  final bool enabled;
  final VoidCallback? onPressed;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: fullWidth ? double.infinity : null,
      height: 40,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.surfaceVariant,
          disabledForegroundColor: AppColors.textTertiary,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: const Text('Request'),
      ),
    );
  }
}