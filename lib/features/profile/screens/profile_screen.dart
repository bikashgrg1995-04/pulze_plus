import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pulze_plus/app/router/app_routes.dart';
import 'package:pulze_plus/core/preferences/app_preferences_provider.dart';
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
import 'package:pulze_plus/features/profile/widgets/about_pulze_dialog.dart';
import 'package:pulze_plus/features/profile/widgets/blood_donation_card.dart';
import 'package:pulze_plus/features/profile/widgets/preference_segmented_tile.dart';
import 'package:pulze_plus/features/profile/widgets/preference_switch_row.dart';
import 'package:pulze_plus/features/profile/widgets/support_request_dialog.dart';
import 'package:pulze_plus/features/profile/widgets/profile_completion_card.dart';
import 'package:pulze_plus/features/profile/widgets/profile_details_card.dart';
import 'package:pulze_plus/features/profile/widgets/profile_header.dart';
import 'package:pulze_plus/features/profile/widgets/profile_menu_item.dart';
import 'package:pulze_plus/features/profile/widgets/profile_section.dart';
import 'package:pulze_plus/features/profile/widgets/profile_settings_sheet.dart';
import 'package:pulze_plus/l10n/app_localizations.dart';

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

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    if (user == null) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: const Center(child: CircularProgressIndicator()),
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
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.only(bottom: bottomPadding),
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
                onAvailabilityChanged: (value) {
                  _updateDonorStatus(value, l10n);
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
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (profileCompletion < 1.0) ...[
                          ProfileCompletionCard(
                            completion: profileCompletion,
                            onPressed: () {
                              _openEditProfile(context, profile);
                            },
                          ),
                          const SizedBox(height: AppSpacing.md),
                        ],

                        ProfileUserCard(
                          user: user,
                          profile: profile,
                          onEdit: () {
                            _openEditProfile(context, profile);
                          },
                        ),

                        const SizedBox(height: AppSpacing.md),

                        BloodDonationCard(
                          bloodGroup:
                              profile?.bloodType ?? l10n.bloodGroupNotAdded,
                          lastDonation: l10n.notAvailable,
                          nextEligibleDate: l10n.notAvailable,
                        ),

                        const SizedBox(height: AppSpacing.xl),

                        // Activity
                        ProfileSection(
                          title: l10n.activity,
                          subtitle: l10n.viewRequestsAndDonations,
                          expandable: true,
                          children: [
                            ProfileMenuItem(
                              icon: Icons.description_outlined,
                              title: l10n.myRequests,
                            ),
                            ProfileMenuItem(
                              icon: Icons.volunteer_activism_outlined,
                              title: l10n.donationHistory,
                              showDivider: false,
                            ),
                          ],
                        ),

                        const SizedBox(height: AppSpacing.xl),

                        // Settings
                        ProfileSection(
                          title: l10n.settings,
                          subtitle: l10n.manageAccountAndPreferences,
                          expandable: true,
                          children: [
                            PreferenceSwitchRow(
                              icon: Icons.bloodtype_outlined,
                              title: l10n.isDonor,
                              subtitle: l10n.availableForBloodDonation,
                              value: profile?.isDonor ?? false,
                              onChanged: (value) {
                                _updateDonorStatus(value, l10n);
                              },
                            ),
                            ProfileMenuItem(
                              icon: Icons.lock_outline_rounded,
                              title: l10n.privacySecurity,
                              onTap: () {
                                _showPrivacySecuritySheet(context);
                              },
                            ),

                            ProfileMenuItem(
                              icon: Icons.tune_rounded,
                              title: l10n.appPreferences,
                              onTap: () {
                                _showAppPreferencesSheet(context);
                              },
                            ),
                            ProfileMenuItem(
                              icon: Icons.help_outline_rounded,
                              title: l10n.helpSupport,
                              showDivider: false,
                              onTap: () {
                                _showHelpSupportSheet(context);
                              },
                            ),
                          ],
                        ),

                        const SizedBox(height: AppSpacing.xl),

                        AppButton(
                          label: l10n.signOut,
                          icon: Icons.logout_rounded,
                          variant: AppButtonVariant.danger,
                          onPressed: () {
                            _showLogoutConfirmation(context);
                          },
                        ),

                        const SizedBox(height: AppSpacing.md),

                        Center(
                          child: Text(
                            'Pulze+',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colorScheme.onSurface.withValues(
                                alpha: 0.5,
                              ),
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

  // ---------------------------------------------------------------------------
  // Privacy & Security
  // ---------------------------------------------------------------------------

  Future<void> _showPrivacySecuritySheet(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;

    await AppBottomSheet.show<void>(
      context: context,
      title: l10n.privacySecurity,
      child: ProfileSettingsSheet(
        icon: Icons.lock_outline_rounded,
        title: l10n.privacySecurity,
        subtitle: l10n.managePrivacySecurity,
        children: [
          ProfileSettingsSheetItem(
            icon: Icons.lock_reset_rounded,
            title: l10n.changePassword,
            subtitle: l10n.updateAccountPassword,
            onTap: () {
              Navigator.of(context).pop();
            },
          ),
          ProfileSettingsSheetItem(
            icon: Icons.admin_panel_settings_outlined,
            title: l10n.appPermissions,
            subtitle: l10n.manageCameraLocationPermissions,
            onTap: () {
              Navigator.of(context).pop();
            },
          ),
          ProfileSettingsSheetItem(
            icon: Icons.privacy_tip_outlined,
            title: l10n.privacyPolicy,
            subtitle: l10n.learnHowPulzeHandlesInformation,
            onTap: () {
              Navigator.of(context).pop();
            },
          ),
          ProfileSettingsSheetItem(
            icon: Icons.description_outlined,
            title: l10n.termsConditions,
            subtitle: l10n.reviewPulzeTerms,
            showDivider: false,
            onTap: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // App Preferences
  // ---------------------------------------------------------------------------

  Future<void> _showAppPreferencesSheet(BuildContext context) async {
    await AppBottomSheet.show<void>(
      context: context,
      titleWidget: Builder(
        builder: (context) {
          final l10n = AppLocalizations.of(context)!;
          final theme = Theme.of(context);
          final colorScheme = theme.colorScheme;

          return Text(
            l10n.appPreferences,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleLarge?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          );
        },
      ),
      child: Consumer(
        builder: (context, ref, child) {
          final preferences = ref.watch(appPreferencesProvider);
          final l10n = AppLocalizations.of(context)!;

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PreferenceSwitchRow(
                icon: Icons.notifications_outlined,
                title: l10n.notifications,
                subtitle: l10n.receiveImportantNotifications,
                value: preferences.notificationsEnabled,
                onChanged: (value) {
                  ref
                      .read(appPreferencesProvider.notifier)
                      .setNotificationsEnabled(value);
                },
              ),
              PreferenceSwitchRow(
                icon: Icons.bloodtype_outlined,
                title: l10n.donationReminder,
                subtitle: l10n.getRemindedWhenCanDonate,
                value: preferences.donationRemindersEnabled,
                onChanged: (value) {
                  ref
                      .read(appPreferencesProvider.notifier)
                      .setDonationRemindersEnabled(value);
                },
              ),
              PreferenceSegmentedTile<String>(
                icon: Icons.palette_outlined,
                title: l10n.theme,
                subtitle: l10n.choosePreferredAppearance,
                value: preferences.theme,
                options: [
                  PreferenceSegment(
                    value: 'light',
                    label: l10n.light,
                    icon: Icons.light_mode_outlined,
                  ),
                  PreferenceSegment(
                    value: 'dark',
                    label: l10n.dark,
                    icon: Icons.dark_mode_outlined,
                  ),
                ],
                onChanged: (value) {
                  ref.read(appPreferencesProvider.notifier).setTheme(value);
                },
              ),
              PreferenceSegmentedTile<String>(
                icon: Icons.language_outlined,
                title: l10n.language,
                subtitle: l10n.choosePreferredLanguage,
                value: preferences.language,
                showDivider: false,
                options: [
                  PreferenceSegment(value: 'english', label: l10n.english),
                  PreferenceSegment(value: 'nepali', label: l10n.nepali),
                ],
                onChanged: (value) {
                  ref.read(appPreferencesProvider.notifier).setLanguage(value);
                },
              ),
            ],
          );
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Help & Support
  // ---------------------------------------------------------------------------

  Future<void> _showHelpSupportSheet(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;

    await AppBottomSheet.show<void>(
      context: context,
      title: l10n.helpSupport,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ProfileMenuItem(
            icon: Icons.quiz_outlined,
            title: l10n.faqs,
            subtitle: l10n.findAnswersCommonQuestions,
            onTap: () {
              Navigator.of(context).pop();

              context.push(AppRoutes.faqs);
            },
          ),
          ProfileMenuItem(
            icon: Icons.support_agent_outlined,
            title: l10n.contactSupport,
            subtitle: l10n.getHelpFromSupportTeam,
            onTap: () {
              showDialog<void>(
                context: context,
                builder: (_) => SupportRequestDialog(
                  parentContext: context,
                  type: SupportRequestType.contact,
                ),
              );
            },
          ),
          ProfileMenuItem(
            icon: Icons.bug_report_outlined,
            title: l10n.reportProblem,
            subtitle: l10n.tellUsAboutIssue,
            onTap: () {
              showDialog<void>(
                context: context,
                builder: (_) => SupportRequestDialog(
                  parentContext: context,
                  type: SupportRequestType.problem,
                ),
              );
            },
          ),
          ProfileMenuItem(
            icon: Icons.feedback_outlined,
            title: l10n.feedback,
            subtitle: l10n.shareIdeasSuggestions,
            onTap: () {
              showDialog<void>(
                context: context,
                builder: (_) => SupportRequestDialog(
                  parentContext: context,
                  type: SupportRequestType.feedback,
                ),
              );
            },
          ),
          ProfileMenuItem(
            icon: Icons.info_outline_rounded,
            title: l10n.aboutPulze,
            subtitle: l10n.learnMoreAboutPulze,
            showDivider: false,
            onTap: () {
              showDialog<void>(
                context: context,
                builder: (_) => const AboutPulzeDialog(),
              );
            },
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Avatar
  // ---------------------------------------------------------------------------

  Future<void> _showAvatarSourceDialog(BuildContext context) async {
    if (_isUploadingAvatar) return;

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    final source = await AppBottomSheet.show<ImageSource>(
      context: context,
      title: l10n.changeProfilePhoto,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.chooseProfilePhotoMethod,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _AvatarSourceOption(
            icon: Icons.camera_alt_rounded,
            title: l10n.takePhoto,
            subtitle: l10n.useCamera,
            onTap: () {
              Navigator.of(context).pop(ImageSource.camera);
            },
          ),
          const SizedBox(height: AppSpacing.sm),
          _AvatarSourceOption(
            icon: Icons.photo_library_rounded,
            title: l10n.chooseFromGallery,
            subtitle: l10n.selectExistingPhoto,
            onTap: () {
              Navigator.of(context).pop(ImageSource.gallery);
            },
          ),
          const SizedBox(height: AppSpacing.sm),
          AppButton(
            label: l10n.cancel,
            variant: AppButtonVariant.text,
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );

    if (!mounted || source == null) {
      return;
    }

    await _pickAndUploadAvatar(source);
  }

  Future<void> _updateDonorStatus(bool value, AppLocalizations l10n) async {
    try {
      await ref
          .read(profileProvider.notifier)
          .updateDonorStatus(isDonor: value);

      if (!mounted) return;

      AppSnackBar.success(
        context,
        value ? l10n.donorAvailableMessage : l10n.donorUnavailableMessage,
      );
    } catch (error) {
      if (!mounted) return;

      AppSnackBar.error(context, error.toString());
    }
  }

  Future<void> _pickAndUploadAvatar(ImageSource source) async {
    if (_isUploadingAvatar) return;

    final l10n = AppLocalizations.of(context)!;

    try {
      if (source == ImageSource.camera) {
        final permissionStatus = await Permission.camera.request();

        if (!mounted) return;

        if (!permissionStatus.isGranted) {
          if (permissionStatus.isPermanentlyDenied) {
            AppSnackBar.error(context, l10n.cameraPermissionRequiredSettings);

            await openAppSettings();
            return;
          }

          AppSnackBar.error(context, l10n.cameraPermissionRequired);

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

      if (!mounted || pickedFile == null) {
        return;
      }

      setState(() {
        _isUploadingAvatar = true;
      });

      await ref
          .read(profileProvider.notifier)
          .updateAvatar(avatarFile: File(pickedFile.path));

      if (!mounted) return;

      AppSnackBar.success(context, l10n.profilePhotoUpdated);
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

  // ---------------------------------------------------------------------------
  // Profile
  // ---------------------------------------------------------------------------

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

      if (profile.latitude != null && profile.longitude != null) {
        completedFields++;
      }
    }

    return completedFields / totalFields;
  }

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

  // ---------------------------------------------------------------------------
  // Logout
  // ---------------------------------------------------------------------------

  Future<void> _showLogoutConfirmation(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;

    final confirmed = await AppConfirmationDialog.show(
      context: context,
      title: l10n.signOut,
      description: l10n.signOutConfirmation,
      confirmLabel: l10n.signOut,
      cancelLabel: l10n.cancel,
      icon: Icons.logout_rounded,
      isDestructive: true,
    );

    if (confirmed != true || !mounted) {
      return;
    }

    await ref.read(authProvider.notifier).logout();
  }
}

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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: colorScheme.surface,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(icon, color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Icon(
                Icons.chevron_right_rounded,
                size: 22,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
