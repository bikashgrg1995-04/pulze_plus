import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    super.key,
    this.name = 'Bikash Gurung',
    this.bloodGroup = 'O+',
    this.location = 'Bharatpur, Nepal',
    this.isAvailable = true,
    this.onAvatarTap,
    this.onAvailabilityChanged,
  });

  final String name;
  final String bloodGroup;
  final String location;
  final bool isAvailable;
  final VoidCallback? onAvatarTap;
  final ValueChanged<bool>? onAvailabilityChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: double.infinity,
      height: 150,
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _ProfileHeaderWavePainter(),
            ),
          ),

          Positioned(
            top: 16,
            right: 20,
            child: Opacity(
              opacity: 0.08,
              child: Icon(
                Icons.favorite_rounded,
                size: 82,
                color: AppColors.primary,
              ),
            ),
          ),

          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _ProfileAvatar(
                    onTap: onAvatarTap,
                  ),

                  const SizedBox(width: AppSpacing.lg),

                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name.trim().isNotEmpty
                              ? name.trim()
                              : 'Donor',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                          ),
                        ),

                        const SizedBox(height: AppSpacing.xs),

                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm,
                                vertical: AppSpacing.xxs,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(
                                  alpha: 0.10,
                                ),
                                borderRadius: BorderRadius.circular(
                                  AppRadius.pill,
                                ),
                              ),
                              child: Text(
                                bloodGroup,
                                style: theme.textTheme.labelLarge?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),

                            const SizedBox(width: AppSpacing.sm),

                            Expanded(
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.location_on_outlined,
                                    size: 15,
                                    color: AppColors.textSecondary,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      location,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: AppSpacing.xs),

                        _AvailabilityStatus(
                          isAvailable: isAvailable,
                          onChanged: onAvailabilityChanged,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({
    this.onTap,
  });

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.surface,
                width: 4,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.navy.withValues(
                    alpha: 0.10,
                  ),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person_rounded,
                size: 42,
                color: AppColors.textSecondary,
              ),
            ),
          ),

          Positioned(
            right: -2,
            bottom: 2,
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.surface,
                  width: 3,
                ),
              ),
              child: const Icon(
                Icons.edit_outlined,
                size: 15,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AvailabilityStatus extends StatelessWidget {
  const _AvailabilityStatus({
    required this.isAvailable,
    this.onChanged,
  });

  final bool isAvailable;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final statusColor = isAvailable
        ? AppColors.success
        : AppColors.textSecondary;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: statusColor,
            shape: BoxShape.circle,
          ),
        ),

        const SizedBox(width: AppSpacing.xs),

        Text(
          isAvailable ? 'Available' : 'Unavailable',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: statusColor,
                fontWeight: FontWeight.w600,
              ),
        ),

        const SizedBox(width: AppSpacing.xs),

        SizedBox(
          height: 28,
          child: Transform.scale(
            scale: 0.75,
            alignment: Alignment.centerLeft,
            child: Switch.adaptive(
              value: isAvailable,
              onChanged: onChanged,
              activeTrackColor: AppColors.success,
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfileHeaderWavePainter extends CustomPainter {
  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final backgroundPaint = Paint()
      ..color = AppColors.background
      ..style = PaintingStyle.fill;

    canvas.drawRect(
      Offset.zero & size,
      backgroundPaint,
    );

    final wavePaint = Paint()
      ..color = AppColors.primary.withValues(
        alpha: 0.07,
      )
      ..style = PaintingStyle.fill;

    final wavePath = Path();

    wavePath.moveTo(
      0,
      size.height * 0.55,
    );

    wavePath.cubicTo(
      size.width * 0.18,
      size.height * 0.68,
      size.width * 0.38,
      size.height * 0.80,
      size.width * 0.58,
      size.height * 0.64,
    );

    wavePath.cubicTo(
      size.width * 0.76,
      size.height * 0.50,
      size.width * 0.88,
      size.height * 0.40,
      size.width,
      size.height * 0.34,
    );

    wavePath.lineTo(
      size.width,
      size.height,
    );

    wavePath.lineTo(
      0,
      size.height,
    );

    wavePath.close();

    canvas.drawPath(
      wavePath,
      wavePaint,
    );

    final softWavePaint = Paint()
      ..color = AppColors.surface.withValues(
        alpha: 0.75,
      )
      ..style = PaintingStyle.fill;

    final softWavePath = Path();

    softWavePath.moveTo(
      0,
      size.height * 0.68,
    );

    softWavePath.cubicTo(
      size.width * 0.22,
      size.height * 0.78,
      size.width * 0.42,
      size.height * 0.84,
      size.width * 0.60,
      size.height * 0.72,
    );

    softWavePath.cubicTo(
      size.width * 0.78,
      size.height * 0.60,
      size.width * 0.90,
      size.height * 0.52,
      size.width,
      size.height * 0.47,
    );

    softWavePath.lineTo(
      size.width,
      size.height,
    );

    softWavePath.lineTo(
      0,
      size.height,
    );

    softWavePath.close();

    canvas.drawPath(
      softWavePath,
      softWavePaint,
    );
  }

  @override
  bool shouldRepaint(
    covariant CustomPainter oldDelegate,
  ) {
    return false;
  }
}