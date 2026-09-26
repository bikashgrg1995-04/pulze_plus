import 'package:flutter/material.dart';
import 'package:pulze_plus/core/utils/responsive_utils.dart';
import 'package:pulze_plus/core/widgets/app_button.dart';
import 'package:pulze_plus/core/widgets/app_section_header.dart';
import 'package:pulze_plus/features/auth/models/user_model.dart';
import 'package:pulze_plus/features/profile/models/profile_model.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';

class ProfileUserCard extends StatefulWidget {
  const ProfileUserCard({
    super.key,
    required this.user,
    required this.profile,
    this.onEdit,
  });

  final UserModel user;
  final ProfileModel? profile;
  final VoidCallback? onEdit;

  @override
  State<ProfileUserCard> createState() => _ProfileUserCardState();
}

class _ProfileUserCardState extends State<ProfileUserCard> {
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
                            if (widget.onEdit != null) ...[
                              Align(
                                alignment: Alignment.centerRight,
                                child: SizedBox(
                                  width: ResponsiveUtils.widthPercent(
                                    context,
                                    0.28,
                                  ),
                                  height: ResponsiveUtils.heightPercent(
                                    context,
                                    0.04,
                                  ),
                                  child: AppButton(
                                    label: 'Edit',
                                    icon: Icons.edit_outlined,
                                    variant: AppButtonVariant.outlined,
                                    isExpanded: false,
                                    onPressed: widget.onEdit!,
                                  ),
                                ),
                              ),
                            ],

                            _DetailRow(
                              icon: Icons.person_outline_rounded,
                              label: 'Full Name',
                              value: widget.user.fullName,
                            ),

                            const SizedBox(height: AppSpacing.sm),

                            _DetailRow(
                              icon: Icons.email_outlined,
                              label: 'Email',
                              value: widget.user.email,
                              trailing: _VerificationStatus(
                                isVerified: widget.user.isEmailVerified,
                              ),
                            ),

                            const SizedBox(height: AppSpacing.sm),

                            _DetailRow(
                              icon: Icons.phone_outlined,
                              label: 'Phone',
                              value: widget.profile?.phoneNumber ?? 'Not added',
                              trailing: _VerificationStatus(
                                isVerified:
                                    widget.profile?.isPhoneVerified == true,
                              ),
                            ),

                            const SizedBox(height: AppSpacing.sm),

                            _DetailRow(
                              icon: Icons.person_outline_rounded,
                              label: 'Gender',
                              value: _formatGender(widget.profile?.gender),
                            ),

                            const SizedBox(height: AppSpacing.sm),

                            _DetailRow(
                              icon: Icons.calendar_today_outlined,
                              label: 'Date of Birth',
                              value: _formatDate(widget.profile?.dateOfBirth),
                            ),

                            const SizedBox(height: AppSpacing.sm),

                            _DetailRow(
                              icon: Icons.location_city_outlined,
                              label: 'City',
                              value:
                                  widget.profile?.city?.trim().isNotEmpty ==
                                      true
                                  ? widget.profile!.city!
                                  : 'Not added',
                            ),
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

  String _formatGender(String? gender) {
    switch (gender) {
      case 'male':
        return 'Male';
      case 'female':
        return 'Female';
      case 'other':
        return 'Other';
      case 'prefer_not_to_say':
        return 'Not specified';
      default:
        return 'Not specified';
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) {
      return 'Not added';
    }

    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
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
                  AppSectionHeader(title: 'Personal Details'),
                  SizedBox(height: AppSpacing.xxs),
                  Text(
                    'View your personal information',
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
    this.trailing,
  });

  final IconData icon;
  final String label;
  final String value;
  final Widget? trailing;

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
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (trailing != null) ...[const SizedBox(height: 2), trailing!],
            ],
          ),
        ),
      ],
    );
  }
}

class _VerificationStatus extends StatelessWidget {
  const _VerificationStatus({required this.isVerified});

  final bool isVerified;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isVerified ? Icons.verified_rounded : Icons.info_outline_rounded,
          size: 13,
          color: isVerified ? AppColors.success : AppColors.textTertiary,
        ),
        const SizedBox(width: 4),
        Text(
          isVerified ? 'Verified' : 'Unverified',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: isVerified ? AppColors.success : AppColors.textTertiary,
            fontWeight: FontWeight.w600,
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
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
