import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';

class ProfileCompletionCard extends StatefulWidget {
  const ProfileCompletionCard({
    super.key,
    required this.completion,
    this.onPressed,
  });

  final double completion;
  final VoidCallback? onPressed;

  @override
  State<ProfileCompletionCard> createState() => _ProfileCompletionCardState();
}

class _ProfileCompletionCardState extends State<ProfileCompletionCard> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final normalizedCompletion = widget.completion.clamp(0.0, 1.0);

    final percentage = (normalizedCompletion * 100).round();

    final title = percentage < 50 ? 'Complete your profile' : 'Almost there!';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onPressed,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.14),
            ),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 28,
                height: 28,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: normalizedCompletion,
                      strokeWidth: 2.5,
                      backgroundColor: AppColors.primary.withValues(
                        alpha: 0.12,
                      ),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                    ),
                    Text(
                      '$percentage',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: AppSpacing.sm),

              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xxs),

                    Text(
                      'Add your details to get the most from Pulze+.',
                      maxLines: 1,
                      softWrap: false,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: AppSpacing.xs),

              Icon(
                Icons.arrow_forward_rounded,
                size: AppSpacing.lg,
                color: AppColors.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
