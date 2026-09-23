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
    return Row(
      children: [
        Expanded(
          child: _EmergencyActionItem(
            icon: Icons.local_hospital_outlined,
            label: 'Ambulance',
            onPressed: onAmbulancePressed,
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: _EmergencyActionItem(
            icon: Icons.bloodtype_outlined,
            label: 'Blood Banks',
            onPressed: onBloodBankPressed,
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: _EmergencyActionItem(
            icon: Icons.local_police_outlined,
            label: 'Police',
            onPressed: onPolicePressed,
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: _EmergencyActionItem(
            icon: Icons.local_fire_department_outlined,
            label: 'Firefighters',
            onPressed: onFirefighterPressed,
          ),
        ),
      ],
    );
  }
}

class _EmergencyActionItem extends StatelessWidget {
  const _EmergencyActionItem({
    required this.icon,
    required this.label,
    this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xxs,
        vertical: AppSpacing.sm,
      ),
      borderRadius: AppRadius.lg,
      onTap: onPressed,
      child: SizedBox(
        height: 82,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(
                icon,
                size: 22,
                color: AppColors.navy,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            SizedBox(
              height: 30,
              child: Center(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    height: 1.25,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}