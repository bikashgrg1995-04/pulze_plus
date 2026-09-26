import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_section_header.dart';

class BloodDonationCard extends StatefulWidget {
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
  State<BloodDonationCard> createState() => _BloodDonationCardState();
}

class _BloodDonationCardState extends State<BloodDonationCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.border),
      ),
      child: Stack(
        children: [
          const Positioned.fill(child: _DetailsBackground()),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionHeader(
                  isExpanded: _isExpanded,
                  onTap: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  },
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeInOut,
                  alignment: Alignment.topCenter,
                  child: _isExpanded
                      ? Column(
                          children: [
                            const SizedBox(height: AppSpacing.md),
                            _DetailRow(
                              icon: Icons.bloodtype_outlined,
                              label: 'Blood Group',
                              value: widget.bloodGroup,
                              valueColor: AppColors.primary,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            _DetailRow(
                              icon: Icons.calendar_today_outlined,
                              label: 'Last Donation',
                              value: widget.lastDonation,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            _DetailRow(
                              icon: Icons.event_available_outlined,
                              label: 'Next Eligible Date',
                              value: widget.nextEligibleDate,
                              valueColor: AppColors.success,
                            ),
                            if (widget.onEdit != null) ...[
                              const SizedBox(height: AppSpacing.md),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton.icon(
                                  onPressed: widget.onEdit,
                                  icon: const Icon(
                                    Icons.edit_outlined,
                                    size: 18,
                                  ),
                                  label: const Text('Edit donation details'),
                                ),
                              ),
                            ],
                          ],
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.isExpanded, required this.onTap});

  final bool isExpanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        child: Row(
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppSectionHeader(title: 'Blood & Donations'),
                  SizedBox(height: AppSpacing.xxs),
                  Text(
                    'View your blood donation information',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            AnimatedRotation(
              turns: isExpanded ? 0.5 : 0,
              duration: const Duration(milliseconds: 280),
              child: const Icon(
                Icons.expand_more_rounded,
                size: 24,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
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
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 18, color: AppColors.primary),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.4,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: valueColor ?? AppColors.textPrimary,
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
    return CustomPaint(painter: _DetailsBackgroundPainter());
  }
}

class _DetailsBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final topPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.035)
      ..style = PaintingStyle.fill;

    final topPath = Path()
      ..moveTo(size.width * 0.55, 0)
      ..cubicTo(
        size.width * 0.72,
        size.height * 0.08,
        size.width * 0.84,
        size.height * 0.18,
        size.width,
        size.height * 0.12,
      )
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(topPath, topPaint);

    final bottomPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.025)
      ..style = PaintingStyle.fill;

    final bottomPath = Path()
      ..moveTo(0, size.height * 0.90)
      ..cubicTo(
        size.width * 0.22,
        size.height * 0.80,
        size.width * 0.42,
        size.height * 0.94,
        size.width * 0.64,
        size.height * 0.86,
      )
      ..cubicTo(
        size.width * 0.80,
        size.height * 0.80,
        size.width * 0.90,
        size.height * 0.74,
        size.width,
        size.height * 0.78,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(bottomPath, bottomPaint);

    canvas.drawPath(bottomPath, bottomPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
