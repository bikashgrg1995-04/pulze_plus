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
    this.onSettingsPressed,
  });

  final bool isGuest;
  final bool isAvailable;
  final ValueChanged<bool>? onAvailabilityChanged;
  final VoidCallback? onNotificationPressed;
  final VoidCallback? onSettingsPressed;

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
                    isGuest ? 'Welcome to Pulze+ 👋' : 'Good morning, Bikash 👋',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 3),
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
            const SizedBox(width: AppSpacing.xs),
            AppIconButton(
              icon: Icons.notifications_none_rounded,
              onPressed: onNotificationPressed,
              tooltip: 'Notifications',
              size: 40,
              iconSize: 21,
              backgroundColor: AppColors.surface,
              foregroundColor: AppColors.textPrimary,
              borderColor: AppColors.border,
              borderRadius: 12,
            ),
            const SizedBox(width: 8),
            AppIconButton(
              icon: Icons.settings_outlined,
              onPressed: onSettingsPressed,
              tooltip: 'Settings',
              size: 40,
              iconSize: 20,
              backgroundColor: AppColors.surface,
              foregroundColor: AppColors.textPrimary,
              borderColor: AppColors.border,
              borderRadius: 12,
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
    final statusColor =
        isAvailable ? AppColors.success : AppColors.textSecondary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(
            isAvailable
                ? Icons.volunteer_activism_outlined
                : Icons.notifications_off_outlined,
            size: 18,
            color: statusColor,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              isAvailable ? 'Available to donate' : 'Not available to donate',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          Text(
            isAvailable ? 'Available' : 'Unavailable',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: statusColor,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(width: 4),
          Switch.adaptive(
            value: isAvailable,
            onChanged: onChanged,
            activeTrackColor: AppColors.success,
          ),
        ],
      ),
    );
  }
}