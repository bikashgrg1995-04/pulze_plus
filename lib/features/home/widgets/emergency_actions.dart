import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_card.dart';

class EmergencyActions extends StatelessWidget {
  const EmergencyActions({
    super.key,
    this.onAmbulancePressed,
    this.onBloodBankPressed,
    this.onPolicePressed,
    this.onFirefighterPressed,
  });

  final VoidCallback? onAmbulancePressed;
  final VoidCallback? onBloodBankPressed;
  final VoidCallback? onPolicePressed;
  final VoidCallback? onFirefighterPressed;

  @override
  Widget build(BuildContext context) {
    final actions = [
      _EmergencyActionData(
        icon: Icons.local_hospital_outlined,
        label: 'Ambulance',
        color: AppColors.primary,
        onPressed: onAmbulancePressed,
      ),
      _EmergencyActionData(
        icon: Icons.bloodtype_outlined,
        label: 'Blood banks',
        color: AppColors.error,
        onPressed: onBloodBankPressed,
      ),
      _EmergencyActionData(
        icon: Icons.local_police_outlined,
        label: 'Police',
        color: AppColors.navy,
        onPressed: onPolicePressed,
      ),
      _EmergencyActionData(
        icon: Icons.local_fire_department_outlined,
        label: 'Fire service',
        color: Colors.deepOrange,
        onPressed: onFirefighterPressed,
      ),
    ];

    return GridView.builder(
      itemCount: actions.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: AppSpacing.xs,
        mainAxisSpacing: AppSpacing.xs,
        mainAxisExtent: 82,
      ),
      itemBuilder: (context, index) {
        final action = actions[index];

        return _EmergencyActionItem(
          icon: action.icon,
          label: action.label,
          color: action.color,
          onPressed: action.onPressed,
        );
      },
    );
  }
}

class _EmergencyActionData {
  const _EmergencyActionData({
    required this.icon,
    required this.label,
    required this.color,
    this.onPressed,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onPressed;
}

class _EmergencyActionItem extends StatelessWidget {
  const _EmergencyActionItem({
    required this.icon,
    required this.label,
    required this.color,
    this.onPressed,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      padding: EdgeInsets.zero,
      borderRadius: AppRadius.lg,
      onTap: onPressed,
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          color: AppColors.surface,
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 4,
              vertical: AppSpacing.xs,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Icon(icon, size: 20, color: color),
                ),
                const SizedBox(height: 5),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}