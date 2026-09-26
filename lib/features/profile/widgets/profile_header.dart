import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/responsive_utils.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    super.key,
    required this.name,
    required this.bloodGroup,
    required this.address,
    this.avatarUrl,
    this.isUploadingAvatar = false,
    this.isAvailable = true,
    this.onAvatarTap,
    this.onAvailabilityChanged,
  });

  final String name;
  final String bloodGroup;
  final String address;
  final String? avatarUrl;
  final bool isUploadingAvatar;
  final bool isAvailable;
  final VoidCallback? onAvatarTap;
  final ValueChanged<bool>? onAvailabilityChanged;

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = ResponsiveUtils.value(
      context,
      mobile: AppSpacing.lg,
      tablet: AppSpacing.xxl,
      large: AppSpacing.xxxl,
    );

    final verticalPadding = ResponsiveUtils.value(
      context,
      mobile: AppSpacing.md,
      tablet: AppSpacing.lg,
      large: AppSpacing.lg,
    );

    final headerHeight = ResponsiveUtils.value(
      context,
      mobile: 164.0,
      tablet: 169.0,
      large: 179.0,
    );

    return SizedBox(
      width: double.infinity,
      height: headerHeight,
      child: Stack(
        children: [
          const Positioned.fill(
            child: CustomPaint(painter: _ProfileHeaderWavePainter()),
          ),
    
          Positioned(
            top: ResponsiveUtils.value(
              context,
              mobile: AppSpacing.sm,
              tablet: AppSpacing.md,
              large: AppSpacing.lg,
            ),
            right: ResponsiveUtils.value(
              context,
              mobile: AppSpacing.lg,
              tablet: AppSpacing.xl,
              large: AppSpacing.xxl,
            ),
            child: Opacity(
              opacity: 0.08,
              child: Icon(
                Icons.favorite_rounded,
                size: ResponsiveUtils.value(
                  context,
                  mobile: 82.0,
                  tablet: 92.0,
                  large: 100.0,
                ),
                color: AppColors.primary,
              ),
            ),
          ),
    
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: verticalPadding,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _ProfileAvatar(
                    avatarUrl: avatarUrl,
                    onTap: onAvatarTap,
                    isUploading: isUploadingAvatar,
                  ),
    
                  SizedBox(
                    width: ResponsiveUtils.value(
                      context,
                      mobile: AppSpacing.md,
                      tablet: AppSpacing.lg,
                      large: AppSpacing.xl,
                    ),
                  ),
    
                  Expanded(
                    child: _ProfileInformation(
                      name: name,
                      bloodGroup: bloodGroup,
                      address: address,
                      isAvailable: isAvailable,
                      onAvailabilityChanged: onAvailabilityChanged,
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

// =============================================================================
// Profile information
// =============================================================================

class _ProfileInformation extends StatelessWidget {
  const _ProfileInformation({
    required this.name,
    required this.bloodGroup,
    required this.address,
    required this.isAvailable,
    this.onAvailabilityChanged,
  });

  final String name;
  final String bloodGroup;
  final String address;
  final bool isAvailable;
  final ValueChanged<bool>? onAvailabilityChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final nameFontSize = ResponsiveUtils.value(
      context,
      mobile: 24.0,
      tablet: 27.0,
      large: 29.0,
    );

    final cleanName = name.trim();
    final cleanAddress = address.trim();
    final cleanBloodGroup = bloodGroup.trim();

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          cleanName.isNotEmpty ? cleanName : 'User',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.headlineSmall?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: nameFontSize,
          ),
        ),

        const SizedBox(height: AppSpacing.xxs),

        Row(
          children: [
            const Icon(
              Icons.location_on_outlined,
              size: 15,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: AppSpacing.xxs),
            Expanded(
              child: Text(
                cleanAddress.isNotEmpty ? cleanAddress : 'Address not added',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.xs),

        _BloodGroupBadge(bloodGroup: cleanBloodGroup),

        const SizedBox(height: AppSpacing.xs),

        _AvailabilityStatus(
          isAvailable: isAvailable,
          onChanged: onAvailabilityChanged,
        ),
      ],
    );
  }
}

// =============================================================================
// Blood group badge
// =============================================================================

class _BloodGroupBadge extends StatelessWidget {
  const _BloodGroupBadge({required this.bloodGroup});

  final String bloodGroup;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        bloodGroup.isNotEmpty ? bloodGroup : '--',
        style: theme.textTheme.labelLarge?.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// =============================================================================
// Profile avatar
// =============================================================================

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({this.avatarUrl, this.onTap, this.isUploading = false});

  final String? avatarUrl;
  final VoidCallback? onTap;
  final bool isUploading;

  @override
  Widget build(BuildContext context) {
    final avatarSize = ResponsiveUtils.value(
      context,
      mobile: 88.0,
      tablet: 96.0,
      large: 104.0,
    );

    final iconSize = ResponsiveUtils.value(
      context,
      mobile: 42.0,
      tablet: 46.0,
      large: 50.0,
    );

    final editSize = ResponsiveUtils.value(
      context,
      mobile: 30.0,
      tablet: 32.0,
      large: 34.0,
    );

    final editIconSize = ResponsiveUtils.value(
      context,
      mobile: 15.0,
      tablet: 16.0,
      large: 17.0,
    );

    final cleanAvatarUrl = avatarUrl?.trim();
    final hasAvatar = cleanAvatarUrl != null && cleanAvatarUrl.isNotEmpty;

    return GestureDetector(
      onTap: isUploading ? null : onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: avatarSize,
            height: avatarSize,
            padding: const EdgeInsets.all(AppSpacing.xxs),
            decoration: BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.navy.withValues(alpha: 0.10),
                  blurRadius: AppSpacing.md,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ClipOval(
              child: Container(
                color: AppColors.surfaceVariant,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (hasAvatar)
                      Image.network(
                        cleanAvatarUrl,
                        width: avatarSize,
                        height: avatarSize,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.person_rounded,
                            size: iconSize,
                            color: AppColors.textSecondary,
                          );
                        },
                      )
                    else
                      Icon(
                        Icons.person_rounded,
                        size: iconSize,
                        color: AppColors.textSecondary,
                      ),

                    if (isUploading)
                      Positioned.fill(
                        child: Container(
                          color: Colors.black.withValues(alpha: 0.38),
                          child: Center(
                            child: SizedBox(
                              width: avatarSize * 0.28,
                              height: avatarSize * 0.28,
                              child: const CircularProgressIndicator(
                                strokeWidth: 3,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),

          Positioned(
            right: -AppSpacing.xxs,
            bottom: AppSpacing.xxs,
            child: Container(
              width: editSize,
              height: editSize,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.surface,
                  width: AppSpacing.xxs - 1,
                ),
              ),
              child: isUploading
                  ? SizedBox(
                      width: editIconSize,
                      height: editIconSize,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Icon(
                      Icons.edit_outlined,
                      size: editIconSize,
                      color: Colors.white,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Availability
// =============================================================================

class _AvailabilityStatus extends StatelessWidget {
  const _AvailabilityStatus({required this.isAvailable, this.onChanged});

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
          width: AppSpacing.xxs,
          height: AppSpacing.xxs,
          decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
        ),

        const SizedBox(width: AppSpacing.xs),

        Text(
          isAvailable ? 'Available' : 'Unavailable',
          style: Theme.of(context).textTheme.bodySmall
              ?.copyWith(color: statusColor, fontWeight: FontWeight.w600),
        ),

        const SizedBox(width: AppSpacing.xs),

        SizedBox(
          height: AppSpacing.xxl,
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

// =============================================================================
// Header wave painter
// =============================================================================

class _ProfileHeaderWavePainter extends CustomPainter {
  const _ProfileHeaderWavePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPaint = Paint()
      ..color = AppColors.background
      ..style = PaintingStyle.fill;

    canvas.drawRect(Offset.zero & size, backgroundPaint);

    final wavePaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.07)
      ..style = PaintingStyle.fill;

    final wavePath = Path()
      ..moveTo(0, size.height * 0.55)
      ..cubicTo(
        size.width * 0.18,
        size.height * 0.68,
        size.width * 0.38,
        size.height * 0.80,
        size.width * 0.58,
        size.height * 0.64,
      )
      ..cubicTo(
        size.width * 0.76,
        size.height * 0.50,
        size.width * 0.88,
        size.height * 0.40,
        size.width,
        size.height * 0.34,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(wavePath, wavePaint);

    final softWavePaint = Paint()
      ..color = AppColors.surface.withValues(alpha: 0.75)
      ..style = PaintingStyle.fill;

    final softWavePath = Path()
      ..moveTo(0, size.height * 0.68)
      ..cubicTo(
        size.width * 0.22,
        size.height * 0.78,
        size.width * 0.42,
        size.height * 0.84,
        size.width * 0.60,
        size.height * 0.72,
      )
      ..cubicTo(
        size.width * 0.78,
        size.height * 0.60,
        size.width * 0.90,
        size.height * 0.52,
        size.width,
        size.height * 0.47,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(softWavePath, softWavePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
