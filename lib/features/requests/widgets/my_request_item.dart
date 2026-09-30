import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:pulze_plus/core/theme/app_colors.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_card.dart';
import '../models/blood_request_model.dart';
import 'request_status_chip.dart';

class MyRequestItem extends StatelessWidget {
  const MyRequestItem({
    super.key,
    required this.request,
    this.onTap,
    this.onEdit,
    this.onTerminate,
  });

  final BloodRequestModel request;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onTerminate;

  bool get _canManage {
    final status = request.status.toUpperCase();

    return status != 'COMPLETED' &&
        status != 'CANCELLED' &&
        status != 'EXPIRED' &&
        status != 'FAILED' &&
        status != 'NO_SHOW';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final card = AppCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 10,
      ),
      onTap: onTap,
      child: Row(
        children: [
          _BloodGroupBadge(
            bloodGroup: request.bloodGroup,
          ),
          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${request.bloodGroup} • '
                        '${request.unitsRequired} '
                        '${request.unitsRequired == 1 ? 'Unit' : 'Units'}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    RequestStatusChip(
                      status: request.status,
                    ),
                  ],
                ),

                const SizedBox(height: 5),

                // Hospital
                Row(
                  children: [
                    Icon(
                      Icons.local_hospital_outlined,
                      size: 14,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        request.hospitalName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 3),

                // Required time + arrow
                Row(
                  children: [
                    Icon(
                      Icons.schedule_outlined,
                      size: 14,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        'Required ${_formatDateTime(request.requiredAt)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 19,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );

    // Don't show slide actions for terminal requests.
    if (!_canManage || (onEdit == null && onTerminate == null)) {
      return card;
    }

    return Slidable(
      key: ValueKey(request.id),
      groupTag: 'my-blood-requests',
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.42,
        children: [
          if (onEdit != null)
            SlidableAction(
              onPressed: (_) => onEdit?.call(),
              backgroundColor: AppColors.info,
              foregroundColor: colorScheme.onPrimary,
              icon: Icons.edit_outlined,
              label: 'Edit',
              // borderRadius: const BorderRadius.horizontal(
              //   right: Radius.circular(14),
              // ),
            ),
          if (onTerminate != null)
            SlidableAction(
              onPressed: (_) => onTerminate?.call(),
              backgroundColor: colorScheme.error,
              foregroundColor: colorScheme.onError,
              icon: Icons.stop_circle_outlined,
              label: 'Terminate',
              borderRadius: const BorderRadius.horizontal(
                right: Radius.circular(14),
              ),
            ),
        ],
      ),
      child: card,
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final local = dateTime.toLocal();

    final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final minute = local.minute.toString().padLeft(2, '0');
    final period = local.hour >= 12 ? 'PM' : 'AM';

    return '${local.day}/${local.month}/${local.year} '
        '$hour:$minute $period';
  }
}

class _BloodGroupBadge extends StatelessWidget {
  const _BloodGroupBadge({
    required this.bloodGroup,
  });

  final String bloodGroup;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: 46,
      height: 46,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.12),
        ),
      ),
      child: Text(
        bloodGroup,
        style: theme.textTheme.titleSmall?.copyWith(
          color: colorScheme.primary,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}