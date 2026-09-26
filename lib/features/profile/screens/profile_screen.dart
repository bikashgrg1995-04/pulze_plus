import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:pulze_plus/core/theme/app_colors.dart';
import 'package:pulze_plus/core/theme/app_radius.dart';
import 'package:pulze_plus/core/theme/app_spacing.dart';
import 'package:pulze_plus/core/utils/responsive_utils.dart';
import 'package:pulze_plus/core/widgets/app_bottom_sheet.dart';
import 'package:pulze_plus/core/widgets/app_button.dart';
import 'package:pulze_plus/core/widgets/app_confirmation_dialog.dart';
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
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
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
          padding: EdgeInsets.only(
            bottom: bottomPadding,
          ),
          child: Column(
            children: [
              ProfileHeader(
                name: user.fullName,
                bloodGroup: profile?.bloodType ?? '',
                address: profile?.address ?? '',
                avatarUrl: profile?.avatar,
                isUploadingAvatar: _isUploadingAvatar,
                isAvailable: profile?.isDonor ?? false,
                onAvatarTap: _isUploadingAvatar
                    ? null
                    : () => _showAvatarSourceDialog(context),
                onAvailabilityChanged: (value) async {
                  try {
                    await ref
                        .read(profileProvider.notifier)
                        .updateDonorStatus(
                          isDonor: value,
                        );
                  } catch (error) {
                    if (!context.mounted) return;

                    AppSnackBar.error(
                      context,
                      error.toString(),
                    );
                  }
                },
              ),

              Padding(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  AppSpacing.md,
                  horizontalPadding,
                  0,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 720,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (profileCompletion < 1.0) ...[
                          ProfileCompletionCard(
                            completion: profileCompletion,
                            onPressed: () {
                              _openEditProfile(
                                context,
                                profile,
                              );
                            },
                          ),
                          const SizedBox(
                            height: AppSpacing.md,
                          ),
                        ],

                        ProfileUserCard(
                          user: user,
                          profile: profile,
                          onEdit: () {
                            _openEditProfile(
                              context,
                              profile,
                            );
                          },
                        ),

                        const SizedBox(
                          height: AppSpacing.md,
                        ),

                        BloodDonationCard(
                          bloodGroup: profile?.bloodType ?? 'Not added',
                          lastDonation: 'Not available',
                          nextEligibleDate: 'Not available',
                        ),

                        const SizedBox(
                          height: AppSpacing.xl,
                        ),

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

                        const SizedBox(
                          height: AppSpacing.xl,
                        ),

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

                        const SizedBox(
                          height: AppSpacing.xl,
                        ),

                        AppButton(
                          label: 'Sign out',
                          icon: Icons.logout_rounded,
                          variant: AppButtonVariant.danger,
                          onPressed: () {
                            _showLogoutConfirmation(context);
                          },
                        ),

                        const SizedBox(
                          height: AppSpacing.md,
                        ),

                        Center(
                          child: Text(
                            'Pulze+',
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  color: AppColors.textTertiary,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.3,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // Avatar source
  // ===========================================================================

  Future<void> _showAvatarSourceDialog(
    BuildContext context,
  ) async {
    if (_isUploadingAvatar) return;

    final source = await AppBottomSheet.show<ImageSource>(
      context: context,
      title: 'Change profile photo',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Choose how you want to update your profile photo.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),

          const SizedBox(
            height: AppSpacing.md,
          ),

          _AvatarSourceOption(
            icon: Icons.camera_alt_rounded,
            title: 'Take a photo',
            subtitle: 'Use your camera',
            onTap: () {
              Navigator.of(context).pop(
                ImageSource.camera,
              );
            },
          ),

          const SizedBox(
            height: AppSpacing.sm,
          ),

          _AvatarSourceOption(
            icon: Icons.photo_library_rounded,
            title: 'Choose from gallery',
            subtitle: 'Select an existing photo',
            onTap: () {
              Navigator.of(context).pop(
                ImageSource.gallery,
              );
            },
          ),

          const SizedBox(
            height: AppSpacing.sm,
          ),

          AppButton(
            label: 'Cancel',
            variant: AppButtonVariant.text,
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );

    if (!mounted || source == null) return;

    await _pickAndUploadAvatar(source);
  }

  // ===========================================================================
  // Avatar upload
  // ===========================================================================

  Future<void> _pickAndUploadAvatar(
    ImageSource source,
  ) async {
    if (_isUploadingAvatar) return;

    try {
      if (source == ImageSource.camera) {
        final permissionStatus =
            await Permission.camera.request();

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

      final picker = ImagePicker();

      final pickedFile = await picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1200,
        maxHeight: 1200,
      );

      if (!mounted || pickedFile == null) return;

      setState(() {
        _isUploadingAvatar = true;
      });

      await ref
          .read(profileProvider.notifier)
          .updateAvatar(
            avatarFile: File(pickedFile.path),
          );

      if (!mounted) return;

      AppSnackBar.success(
        context,
        'Profile photo updated successfully.',
      );
    } catch (error) {
      if (!mounted) return;

      AppSnackBar.error(
        context,
        error.toString(),
      );
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

    if (user.fullName.trim().isNotEmpty) {
      completedFields++;
    }

    if (user.email.trim().isNotEmpty) {
      completedFields++;
    }

    if (user.phoneNumber?.trim().isNotEmpty ?? false) {
      completedFields++;
    }

    if (profile != null) {
      if (profile.gender.trim().isNotEmpty) {
        completedFields++;
      }

      completedFields++;

      if (profile.address?.trim().isNotEmpty ?? false) {
        completedFields++;
      }

      if (profile.city?.trim().isNotEmpty ?? false) {
        completedFields++;
      }

      if (profile.latitude != null &&
          profile.longitude != null) {
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
            return const ProfileFormScreen(
              mode: ProfileFormMode.create,
            );
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

  Future<void> _showLogoutConfirmation(
    BuildContext context,
  ) async {
    final confirmed = await AppConfirmationDialog.show(
      context: context,
      title: 'Sign out',
      description:
          'Are you sure you want to sign out of Pulze+?',
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
      borderRadius: BorderRadius.circular(
        AppRadius.lg,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(
          AppRadius.lg,
        ),
        child: Padding(
          padding: const EdgeInsets.all(
            AppSpacing.md,
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(
                    alpha: 0.08,
                  ),
                  borderRadius: BorderRadius.circular(
                    AppRadius.md,
                  ),
                ),
                child: Icon(
                  icon,
                  color: AppColors.primary,
                  size: 22,
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
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(
                            color:
                                AppColors.textPrimary,
                            fontWeight:
                                FontWeight.w600,
                          ),
                    ),
                    const SizedBox(
                      height: AppSpacing.xxs,
                    ),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(
                            color:
                                AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),

              const SizedBox(
                width: AppSpacing.sm,
              ),

              const Icon(
                Icons.chevron_right_rounded,
                size: 22,
                color: AppColors.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}