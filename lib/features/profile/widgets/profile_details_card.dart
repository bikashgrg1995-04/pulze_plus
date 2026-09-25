import 'package:flutter/material.dart';
import 'package:pulze_plus/core/widgets/app_section_header.dart';
import 'package:pulze_plus/features/auth/models/user_model.dart';
import 'package:pulze_plus/features/profile/models/profile_model.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';

class ProfileUserCard extends StatelessWidget {
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
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: AppSectionHeader(title: 'Personal Details'),
                    ),
                    if (onEdit != null)
                      IconButton(
                        onPressed: onEdit,
                        tooltip: 'Edit profile',
                        constraints: const BoxConstraints(
                          minWidth: 44,
                          minHeight: 44,
                        ),
                        icon: const Icon(Icons.edit_outlined, size: 21),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                _DetailRow(
                  icon: Icons.person_outline_rounded,
                  label: 'Full Name',
                  value: user.fullName,
                ),
                const SizedBox(height: AppSpacing.md),
                _DetailRow(
                  icon: Icons.email_outlined,
                  label: 'Email',
                  value: user.email,
                ),
                const SizedBox(height: AppSpacing.md),

                _DetailRow(
                  icon: Icons.phone_outlined,
                  label: 'Phone',
                  value: profile?.phoneNumber ?? 'Not added',
                ),
                Text(
                  profile?.isPhoneVerified == true ? 'Verified' : 'Unverified',
                ),

                const SizedBox(height: AppSpacing.md),
                _DetailRow(
                  icon: Icons.person_outline_rounded,
                  label: 'Gender',
                  value: _formatGender(profile?.gender),
                ),
                const SizedBox(height: AppSpacing.md),
                _DetailRow(
                  icon: Icons.calendar_today_outlined,
                  label: 'Date of Birth',
                  value: _formatDate(profile?.dateOfBirth),
                ),
                const SizedBox(height: AppSpacing.md),

                _DetailRow(
                  icon: Icons.location_city_outlined,
                  label: 'City',
                  value: profile?.city?.trim().isNotEmpty == true
                      ? profile!.city!
                      : 'Not added',
                ),
                const SizedBox(height: AppSpacing.lg),
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

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

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
            color: AppColors.primary.withValues(alpha: 0.08),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 19, color: AppColors.primary),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
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

    final topPath = Path();

    topPath.moveTo(size.width * 0.55, 0);

    topPath.cubicTo(
      size.width * 0.72,
      size.height * 0.08,
      size.width * 0.84,
      size.height * 0.18,
      size.width,
      size.height * 0.12,
    );

    topPath.lineTo(size.width, 0);

    topPath.close();

    canvas.drawPath(topPath, topPaint);

    final bottomPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.025)
      ..style = PaintingStyle.fill;

    final bottomPath = Path();

    bottomPath.moveTo(0, size.height * 0.90);

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

    bottomPath.lineTo(size.width, size.height);

    bottomPath.lineTo(0, size.height);

    bottomPath.close();

    canvas.drawPath(bottomPath, bottomPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
