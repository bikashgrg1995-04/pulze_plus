import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_icon_button.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
    required this.isGuest,
    this.isAvailable = true,
    this.onAvailabilityChanged,
    this.onNotificationPressed,
  });

  final bool isGuest;
  final bool isAvailable;
  final ValueChanged<bool>? onAvailabilityChanged;
  final VoidCallback? onNotificationPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isGuest
                        ? 'Welcome to Pulze+ 👋'
                        : 'Good morning, Bikash 👋',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 15,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Bharatpur, Nepal',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            AppIconButton(
              icon: Icons.notifications_none_rounded,
              onPressed: onNotificationPressed,
              tooltip: 'Notifications',
              size: 44,
              iconSize: 23,
              backgroundColor: AppColors.surface,
              foregroundColor: AppColors.textPrimary,
              borderColor: AppColors.border,
              borderRadius: 14,
            ),
          ],
        ),

        if (!isGuest) ...[
          const SizedBox(height: AppSpacing.sm),
          _AvailabilityRow(
            isAvailable: isAvailable,
            onChanged: onAvailabilityChanged,
          ),
        ],
      ],
    );
  }
}

class _AvailabilityRow extends StatelessWidget {
  const _AvailabilityRow({
    required this.isAvailable,
    this.onChanged,
  });

  final bool isAvailable;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          isAvailable
              ? Icons.volunteer_activism_outlined
              : Icons.notifications_off_outlined,
          size: 18,
          color: isAvailable
              ? AppColors.success
              : AppColors.textSecondary,
        ),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text(
            isAvailable
                ? 'Available to donate'
                : 'Not available to donate',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        Text(
          isAvailable ? 'Available' : 'Unavailable',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isAvailable
                    ? AppColors.success
                    : AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(width: AppSpacing.xxs),
        Switch.adaptive(
          value: isAvailable,
          onChanged: onChanged,
          activeTrackColor: AppColors.success,
        ),
      ],
    );
  }
}