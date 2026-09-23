import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';

enum AppStatusType {
  urgent,
  open,
  pending,
  accepted,
  completed,
  cancelled,
  available,
  unavailable,
  info,
}

class AppStatusBadge extends StatelessWidget {
  const AppStatusBadge({
    super.key,
    required this.label,
    required this.type,
    this.showIcon = false,
  });

  final String label;
  final AppStatusType type;
  final bool showIcon;

  @override
  Widget build(BuildContext context) {
    final style = _statusStyle();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: style.backgroundColor,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(
              style.icon,
              size: 14,
              color: style.foregroundColor,
            ),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: style.foregroundColor,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }

  _StatusStyle _statusStyle() {
    switch (type) {
      case AppStatusType.urgent:
        return const _StatusStyle(
          backgroundColor: Color(0xFFFEE2E2),
          foregroundColor: AppColors.error,
          icon: Icons.priority_high_rounded,
        );

      case AppStatusType.open:
        return const _StatusStyle(
          backgroundColor: Color(0xFFDCFCE7),
          foregroundColor: AppColors.success,
          icon: Icons.radio_button_checked_rounded,
        );

      case AppStatusType.pending:
        return const _StatusStyle(
          backgroundColor: Color(0xFFFEF3C7),
          foregroundColor: AppColors.warning,
          icon: Icons.schedule_rounded,
        );

      case AppStatusType.accepted:
        return const _StatusStyle(
          backgroundColor: Color(0xFFDBEAFE),
          foregroundColor: AppColors.info,
          icon: Icons.check_circle_outline_rounded,
        );

      case AppStatusType.completed:
        return const _StatusStyle(
          backgroundColor: Color(0xFFDCFCE7),
          foregroundColor: AppColors.success,
          icon: Icons.check_circle_rounded,
        );

      case AppStatusType.cancelled:
        return const _StatusStyle(
          backgroundColor: Color(0xFFF3F4F6),
          foregroundColor: AppColors.textSecondary,
          icon: Icons.cancel_outlined,
        );

      case AppStatusType.available:
        return const _StatusStyle(
          backgroundColor: Color(0xFFDCFCE7),
          foregroundColor: AppColors.success,
          icon: Icons.circle,
        );

      case AppStatusType.unavailable:
        return const _StatusStyle(
          backgroundColor: Color(0xFFF3F4F6),
          foregroundColor: AppColors.textSecondary,
          icon: Icons.circle,
        );

      case AppStatusType.info:
        return const _StatusStyle(
          backgroundColor: Color(0xFFDBEAFE),
          foregroundColor: AppColors.info,
          icon: Icons.info_outline_rounded,
        );
    }
  }
}

class _StatusStyle {
  const _StatusStyle({
    required this.backgroundColor,
    required this.foregroundColor,
    required this.icon,
  });

  final Color backgroundColor;
  final Color foregroundColor;
  final IconData icon;
}