import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../../core/widgets/app_card.dart';
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
    final isSmallMobile = ResponsiveUtils.isSmallMobile(context);

    return AppCard(
      padding: EdgeInsets.all(isSmallMobile ? AppSpacing.sm : AppSpacing.md),
      onTap: onTap,
      child: isSmallMobile
          ? _SmallMobileLayout(donor: donor, onRequest: onRequest)
          : _RegularLayout(donor: donor, onRequest: onRequest),
    );
  }
}

class _RegularLayout extends StatelessWidget {
  const _RegularLayout({required this.donor, required this.onRequest});

  final DonorModel donor;
  final VoidCallback? onRequest;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _BloodGroupBadge(bloodGroup: donor.bloodGroup),
        const SizedBox(width: AppSpacing.sm),
        Expanded(child: _DonorInfo(donor: donor)),
        const SizedBox(width: AppSpacing.sm),
        _RequestButton(onPressed: onRequest),
      ],
    );
  }
}

class _SmallMobileLayout extends StatelessWidget {
  const _SmallMobileLayout({required this.donor, required this.onRequest});

  final DonorModel donor;
  final VoidCallback? onRequest;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _BloodGroupBadge(bloodGroup: donor.bloodGroup, size: 46),
        const SizedBox(width: AppSpacing.sm),
        Expanded(child: _DonorInfo(donor: donor)),
        const SizedBox(width: AppSpacing.xs),
        _CompactRequestButton(onPressed: onRequest),
      ],
    );
  }
}

class _DonorInfo extends StatelessWidget {
  const _DonorInfo({required this.donor});

  final DonorModel donor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(
                'Blood Donor',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (donor.isPhoneVerified) ...[
              const SizedBox(width: 5),
              const Icon(
                Icons.verified_rounded,
                size: 15,
                color: AppColors.primary,
              ),
            ],
          ],
        ),
        const SizedBox(height: 4),
        _DonorMetaRow(donor: donor),
      ],
    );
  }
}

class _DonorMetaRow extends StatelessWidget {
  const _DonorMetaRow({required this.donor});

  final DonorModel donor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasDistance = donor.distance != null;

    if (!hasDistance && !donor.isPhoneVerified) {
      return const SizedBox.shrink();
    }

    return Row(
      children: [
        if (hasDistance) ...[
          const Icon(
            Icons.location_on_outlined,
            size: 15,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 3),
          Flexible(
            child: Text(
              '${donor.distance!.toStringAsFixed(1)} km away',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ),
        ],
        if (hasDistance && donor.isPhoneVerified) ...[
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
        ],
        if (donor.isPhoneVerified)
          Flexible(
            child: Text(
              'Verified',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.success,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }
}

class _BloodGroupBadge extends StatelessWidget {
  const _BloodGroupBadge({required this.bloodGroup, this.size = 50});

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
        borderRadius: BorderRadius.circular(13),
      ),
      child: Text(
        bloodGroup,
        style: Theme.of(context).textTheme.titleSmall
            ?.copyWith(color: AppColors.primary, fontWeight: FontWeight.w800),
      ),
    );
  }
}

class _RequestButton extends StatelessWidget {
  const _RequestButton({this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          minimumSize: const Size(72, 36),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
          textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
        child: const Text('Request'),
      ),
    );
  }
}

class _CompactRequestButton extends StatelessWidget {
  const _CompactRequestButton({this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 64,
      height: 34,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: EdgeInsets.zero,
          minimumSize: const Size(64, 34),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
          textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        ),
        child: const Text('Request'),
      ),
    );
  }
}
