import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';

class BloodDonationCard extends StatelessWidget {
  const BloodDonationCard({
    super.key,
    required this.bloodGroup,
    required this.lastDonation,
    required this.nextEligibleDate,
    this.onEdit,
  });

  final String bloodGroup;
  final String lastDonation;
  final String nextEligibleDate;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    // final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(
          AppRadius.xl,
        ),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Stack(
        children: [
          const Positioned.fill(
            child: _DetailsBackground(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                _DetailRow(
                  icon: Icons.bloodtype_outlined,
                  label: 'Blood Group',
                  value: bloodGroup,
                  valueColor: AppColors.primary,
                ),
                const SizedBox(
                  height: AppSpacing.md,
                ),
                _DetailRow(
                  icon: Icons.calendar_today_outlined,
                  label: 'Last Donation',
                  value: lastDonation,
                ),
                const SizedBox(
                  height: AppSpacing.md,
                ),
                _DetailRow(
                  icon: Icons.event_available_outlined,
                  label: 'Next Eligible Date',
                  value: nextEligibleDate,
                  valueColor: AppColors.success,
                ),
                const SizedBox(
                  height: AppSpacing.lg,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(
              alpha: 0.08,
            ),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 19,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(
          width: AppSpacing.md,
        ),
        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(
                height: AppSpacing.xxs,
              ),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color:
                      valueColor ??
                      AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DetailsBackground extends StatelessWidget {
  const _DetailsBackground();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DetailsBackgroundPainter(),
    );
  }
}

class _DetailsBackgroundPainter extends CustomPainter {
  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final topPaint = Paint()
      ..color = AppColors.primary.withValues(
        alpha: 0.035,
      )
      ..style = PaintingStyle.fill;

    final topPath = Path();

    topPath.moveTo(
      size.width * 0.55,
      0,
    );

    topPath.cubicTo(
      size.width * 0.72,
      size.height * 0.08,
      size.width * 0.84,
      size.height * 0.18,
      size.width,
      size.height * 0.12,
    );

    topPath.lineTo(
      size.width,
      0,
    );

    topPath.close();

    canvas.drawPath(
      topPath,
      topPaint,
    );

    final bottomPaint = Paint()
      ..color = AppColors.primary.withValues(
        alpha: 0.025,
      )
      ..style = PaintingStyle.fill;

    final bottomPath = Path();

    bottomPath.moveTo(
      0,
      size.height * 0.90,
    );

    bottomPath.cubicTo(
      size.width * 0.22,
      size.height * 0.80,
      size.width * 0.42,
      size.height * 0.94,
      size.width * 0.64,
      size.height * 0.86,
    );

    bottomPath.cubicTo(
      size.width * 0.80,
      size.height * 0.80,
      size.width * 0.90,
      size.height * 0.74,
      size.width,
      size.height * 0.78,
    );

    bottomPath.lineTo(
      size.width,
      size.height,
    );

    bottomPath.lineTo(
      0,
      size.height,
    );

    bottomPath.close();

    canvas.drawPath(
      bottomPath,
      bottomPaint,
    );
  }

  @override
  bool shouldRepaint(
    covariant CustomPainter oldDelegate,
  ) {
    return false;
  }
}