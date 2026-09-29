import 'package:flutter/material.dart';

import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_switch.dart';

class PreferenceSwitchRow extends StatelessWidget {
  const PreferenceSwitchRow({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.isLoading = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(
                    AppRadius.md,
                  ),
                ),
                child: Icon(
                  icon,
                  size: 22,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),

              const SizedBox(width: AppSpacing.sm),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 2),

                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: AppSpacing.xs),

              SizedBox(
                width: 70,
                height: 50,
                child: isLoading
                    ? Center(
                        child: SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: colorScheme.primary,
                          ),
                        ),
                      )
                    : FittedBox(
                        fit: BoxFit.contain,
                        child: AppSwitch(
                          value: value,
                          onChanged: onChanged,
                          scale: 0.75,
                        ),
                      ),
              ),
            ],
          ),
        ),

        Padding(
          padding: const EdgeInsets.only(
            left: 36 + AppSpacing.md + AppSpacing.sm,
          ),
          child: Divider(
            height: 1,
            color: colorScheme.outline,
          ),
        ),
      ],
    );
  }
}