import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:pulze_plus/core/theme/app_colors.dart';
import 'package:pulze_plus/core/theme/app_radius.dart';
import 'package:pulze_plus/core/theme/app_spacing.dart';
import 'package:pulze_plus/core/utils/responsive_utils.dart';
import 'package:pulze_plus/core/widgets/app_confirmation_dialog.dart';
import 'package:pulze_plus/core/widgets/app_section_header.dart';
import 'package:pulze_plus/core/widgets/app_snack_bar.dart';
import 'package:pulze_plus/features/auth/models/user_model.dart';
import 'package:pulze_plus/features/auth/providers/auth_provider.dart';
import 'package:pulze_plus/features/profile/models/profile_model.dart';
import 'package:pulze_plus/features/profile/providers/profile_provider.dart';
import 'package:pulze_plus/features/profile/widgets/blood_donation_card.dart';
import 'package:pulze_plus/features/profile/widgets/profile_completion_card.dart';
import 'package:pulze_plus/features/profile/widgets/profile_details_card.dart';
import 'package:pulze_plus/features/profile/widgets/profile_header.dart';
import 'package:pulze_plus/features/profile/widgets/profile_menu_item.dart';
import 'package:pulze_plus/features/profile/widgets/profile_section.dart';

import 'profile_form_screen.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isUploadingAvatar = false;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final profileState = ref.watch(profileProvider);

    final user = authState.user;
    final profile = profileState.profile;

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final profileCompletion = _calculateProfileCompletion(
      user: user,
      profile: profile,
    );

    final horizontalPadding = ResponsiveUtils.value(
      context,
      mobile: AppSpacing.md,
      tablet: AppSpacing.xxl,
      large: AppSpacing.xxxl,
    );

    final bottomPadding = ResponsiveUtils.value(
      context,
      mobile: 120.0,
      tablet: 80.0,
      large: 80.0,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            AppSpacing.lg,
            horizontalPadding,
            bottomPadding,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // -----------------------------------------------------------------
                  // Profile header
                  // -----------------------------------------------------------------
                  ProfileHeader(
                    name: user.fullName,
                    bloodGroup: profile?.bloodType ?? '',
                    address: profile?.address ?? '',
                    avatarUrl: profile?.avatar,
                    isUploadingAvatar: _isUploadingAvatar,
                    isAvailable: profile?.isDonor ?? false,
                    onAvatarTap: _isUploadingAvatar
                        ? null
                        : () {
                            _showAvatarSourceDialog(context);
                          },
                    onAvailabilityChanged: (value) async {
                      try {
                        await ref
                            .read(profileProvider.notifier)
                            .updateDonorStatus(isDonor: value);
                      } catch (error) {
                        if (!context.mounted) return;

                        AppSnackBar.error(context, error.toString());
                      }
                    },
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  // -----------------------------------------------------------------
                  // Profile completion
                  // -----------------------------------------------------------------
                  if (profileCompletion < 1.0)
                    ProfileCompletionCard(
                      completion: profileCompletion,
                      onPressed: () {
                        _openEditProfile(context, profile);
                      },
                    ),

                  const SizedBox(height: AppSpacing.sm),

                  // -----------------------------------------------------------------
                  // User details
                  // -----------------------------------------------------------------
                  ProfileUserCard(
                    user: user,
                    profile: profile,
                    onEdit: () {
                      _openEditProfile(context, profile);
                    },
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // -----------------------------------------------------------------
                  // Blood & donations
                  // -----------------------------------------------------------------
                  const AppSectionHeader(title: 'Blood & Donations'),

                  const SizedBox(height: AppSpacing.sm),

                  BloodDonationCard(
                    bloodGroup: profile?.bloodType ?? '   ',
                    lastDonation: 'Not available',
                    nextEligibleDate: 'Not available',
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // -----------------------------------------------------------------
                  // Activity
                  // -----------------------------------------------------------------
                  ProfileSection(
                    title: 'Activity',
                    children: const [
                      ProfileMenuItem(
                        icon: Icons.description_outlined,
                        title: 'My Requests',
                      ),
                      ProfileMenuItem(
                        icon: Icons.volunteer_activism_outlined,
                        title: 'Donation History',
                        showDivider: false,
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // -----------------------------------------------------------------
                  // Settings
                  // -----------------------------------------------------------------
                  ProfileSection(
                    title: 'Settings',
                    children: const [
                      ProfileMenuItem(
                        icon: Icons.notifications_none_rounded,
                        title: 'Notifications',
                      ),
                      ProfileMenuItem(
                        icon: Icons.lock_outline_rounded,
                        title: 'Privacy & Security',
                      ),
                      ProfileMenuItem(
                        icon: Icons.help_outline_rounded,
                        title: 'Help & Support',
                        showDivider: false,
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // -----------------------------------------------------------------
                  // Sign out
                  // -----------------------------------------------------------------
                  SizedBox(
                    height: ResponsiveUtils.value(
                      context,
                      mobile: 48.0,
                      tablet: 50.0,
                      large: 52.0,
                    ),
                    child: OutlinedButton.icon(
                      onPressed: () {
                        _showLogoutConfirmation(context);
                      },
                      icon: const Icon(Icons.logout_rounded, size: 20),
                      label: const Text('Sign out'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        backgroundColor: AppColors.surface,
                        side: BorderSide(
                          color: AppColors.error.withValues(alpha: 0.25),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  Center(
                    child: Text(
                      'Pulze+',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textTertiary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // Avatar
  // ===========================================================================

  Future<void> _showAvatarSourceDialog(BuildContext context) async {
    if (_isUploadingAvatar) return;

    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Container(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.lg,
            ),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // -----------------------------------------------------------------
                // Drag handle
                // -----------------------------------------------------------------
                Container(
                  width: 42,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.textTertiary.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),

                // -----------------------------------------------------------------
                // Header
                // -----------------------------------------------------------------
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.10),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.photo_camera_outlined,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Change profile photo',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Choose a photo from your camera or gallery',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.xl),

                // -----------------------------------------------------------------
                // Camera
                // -----------------------------------------------------------------
                _AvatarSourceOption(
                  icon: Icons.camera_alt_rounded,
                  title: 'Take a photo',
                  subtitle: 'Use your camera',
                  onTap: () {
                    Navigator.of(sheetContext).pop(ImageSource.camera);
                  },
                ),

                const SizedBox(height: AppSpacing.sm),

                // -----------------------------------------------------------------
                // Gallery
                // -----------------------------------------------------------------
                _AvatarSourceOption(
                  icon: Icons.photo_library_rounded,
                  title: 'Choose from gallery',
                  subtitle: 'Select an existing photo',
                  onTap: () {
                    Navigator.of(sheetContext).pop(ImageSource.gallery);
                  },
                ),

                const SizedBox(height: AppSpacing.md),

                // -----------------------------------------------------------------
                // Cancel
                // -----------------------------------------------------------------
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(sheetContext).pop();
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (!mounted || source == null) return;

    await _pickAndUploadAvatar(source);
  }

  // ===========================================================================
  // Pick & upload avatar
  // ===========================================================================

  Future<void> _pickAndUploadAvatar(ImageSource source) async {
    if (_isUploadingAvatar) return;

    try {
      // -------------------------------------------------------------------------
      // Camera permission
      // -------------------------------------------------------------------------
      if (source == ImageSource.camera) {
        final permissionStatus = await Permission.camera.request();

        if (!mounted) return;

        if (!permissionStatus.isGranted) {
          if (permissionStatus.isPermanentlyDenied) {
            AppSnackBar.error(
              context,
              'Camera permission is required. Please enable it in Settings.',
            );

            await openAppSettings();
            return;
          }

          AppSnackBar.error(
            context,
            'Camera permission is required to take a photo.',
          );

          return;
        }
      }

      // -------------------------------------------------------------------------
      // Pick image
      //
      // Gallery does NOT request Permission.photos here.
      // Android's system Photo Picker handles photo selection.
      // -------------------------------------------------------------------------
      final picker = ImagePicker();

      final pickedFile = await picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1200,
        maxHeight: 1200,
      );

      // User cancelled the picker.
      if (!mounted || pickedFile == null) return;

      // -------------------------------------------------------------------------
      // Start upload loading
      // -------------------------------------------------------------------------
      setState(() {
        _isUploadingAvatar = true;
      });

      // -------------------------------------------------------------------------
      // Upload
      // -------------------------------------------------------------------------
      await ref
          .read(profileProvider.notifier)
          .updateAvatar(avatarFile: File(pickedFile.path));

      if (!mounted) return;

      AppSnackBar.success(context, 'Profile photo updated successfully.');
    } catch (error) {
      if (!mounted) return;

      AppSnackBar.error(context, error.toString());
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingAvatar = false;
        });
      }
    }
  }
  // ===========================================================================
  // Profile completion
  // ===========================================================================

  double _calculateProfileCompletion({
    required UserModel user,
    required ProfileModel? profile,
  }) {
    const totalFields = 8;

    var completedFields = 0;

    // 1. Full name
    if (user.fullName.trim().isNotEmpty) {
      completedFields++;
    }

    // 2. Email
    if (user.email.trim().isNotEmpty) {
      completedFields++;
    }

    // 3. Phone
    if (user.phoneNumber?.trim().isNotEmpty ?? false) {
      completedFields++;
    }

    if (profile != null) {
      // 4. Gender
      if (profile.gender.trim().isNotEmpty) {
        completedFields++;
      }

      // 5. Date of birth
      completedFields++;

      // 6. Address
      if (profile.address?.trim().isNotEmpty ?? false) {
        completedFields++;
      }

      // 7. City
      if (profile.city?.trim().isNotEmpty ?? false) {
        completedFields++;
      }

      // 8. Location coordinates
      if (profile.latitude != null && profile.longitude != null) {
        completedFields++;
      }
    }

    return completedFields / totalFields;
  }

  // ===========================================================================
  // Edit profile
  // ===========================================================================

  Future<void> _openEditProfile(
    BuildContext context,
    ProfileModel? profile,
  ) async {
    if (profile == null) {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) {
            return const ProfileFormScreen(mode: ProfileFormMode.create);
          },
        ),
      );

      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) {
          return ProfileFormScreen(
            mode: ProfileFormMode.edit,
            profile: profile,
          );
        },
      ),
    );
  }

  // ===========================================================================
  // Logout
  // ===========================================================================

  Future<void> _showLogoutConfirmation(BuildContext context) async {
    final confirmed = await AppConfirmationDialog.show(
      context: context,
      title: 'Sign out',
      description: 'Are you sure you want to sign out of Pulze+?',
      confirmLabel: 'Sign out',
      cancelLabel: 'Cancel',
      icon: Icons.logout_rounded,
      isDestructive: true,
    );

    if (confirmed != true || !mounted) {
      return;
    }

    await ref.read(authProvider.notifier).logout();
  }
}

// =============================================================================
// Avatar source option
// =============================================================================

class _AvatarSourceOption extends StatelessWidget {
  const _AvatarSourceOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.background,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(icon, color: AppColors.primary, size: 24),
              ),

              const SizedBox(width: AppSpacing.md),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall
                          ?.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
