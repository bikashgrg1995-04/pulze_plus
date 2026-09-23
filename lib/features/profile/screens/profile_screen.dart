import 'package:flutter/material.dart';
import 'package:pulze_plus/core/widgets/app_section_header.dart';
import 'package:pulze_plus/features/profile/widgets/blood_donation_card.dart';

import 'package:pulze_plus/features/profile/widgets/profile_details_card.dart';
import 'package:pulze_plus/features/profile/widgets/profile_completion_card.dart';
import 'package:pulze_plus/features/profile/widgets/profile_header.dart';
import 'package:pulze_plus/features/profile/widgets/profile_menu_item.dart';
import 'package:pulze_plus/features/profile/widgets/profile_section.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/responsive_utils.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Demo profile data.
  String _name = 'Bikash Gurung';
  final String _email = 'bikash.gurung@example.com';
  String _phone = '+977 98XXXXXXXX';
  String _location = 'Bharatpur, Nepal';
  final String _bloodGroup = 'O+';

  bool _isAvailable = true;
  final double _profileCompletion = 0.8;

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = ResponsiveUtils.value(
      context,
      mobile: AppSpacing.md,
      tablet: AppSpacing.xxl,
      large: AppSpacing.xxxl,
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
            120,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ProfileHeader(
                name: _name,
                bloodGroup: _bloodGroup,
                location: _location,
                isAvailable: _isAvailable,
                onAvatarTap: () {
                  _openEditProfile(context);
                },
                onAvailabilityChanged: (value) {
                  setState(() {
                    _isAvailable = value;
                  });
                },
              ),

              if (_profileCompletion < 1.0) ...[
                const SizedBox(height: AppSpacing.sm),
                ProfileCompletionCard(
                  completion: _profileCompletion,
                  onPressed: () {
                    _openEditProfile(context);
                  },
                ),
              ],

              const SizedBox(height: AppSpacing.sm),

              ProfileUserCard(
                onEdit: () {
                  _openEditProfile(context);
                },
              ),

              const SizedBox(height: AppSpacing.sm),

              AppSectionHeader(title: "Blood & Donations"),

              const SizedBox(height: AppSpacing.sm),

              BloodDonationCard(
                bloodGroup: _bloodGroup,
                lastDonation: '12 June 2026',
                nextEligibleDate: '12 September 2026',
              ),
              const SizedBox(height: AppSpacing.sm),

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
                  ),
                 
                ],
              ),

              const SizedBox(height: AppSpacing.sm),

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

              const SizedBox(height: AppSpacing.sm),

              SizedBox(
                height: 48,
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
    );
  }

  Future<void> _openSettings(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.xxl),
        ),
      ),
      builder: (context) {
        return const _ProfileSettingsSheet();
      },
    );
  }

  Future<void> _openEditProfile(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (context) {
        return _EditProfileDialog(
          name: _name,
          email: _email,
          phone: _phone,
          location: _location,
          onSave:
              ({
                required String name,
                required String phone,
                required String location,
              }) {
                setState(() {
                  _name = name;
                  _phone = phone;
                  _location = location;
                });
              },
        );
      },
    );
  }

  Future<void> _showLogoutConfirmation(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Sign out'),
          content: const Text('Are you sure you want to sign out of Pulze+?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              style: FilledButton.styleFrom(backgroundColor: AppColors.error),
              child: const Text('Sign out'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) {
      return;
    }

    // Sign out will be connected later.
  }
}

class _ProfileSettingsSheet extends StatelessWidget {
  const _ProfileSettingsSheet();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.md,
        AppSpacing.xl,
        AppSpacing.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.xl),

          Text(
            'Settings',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          const ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.notifications_none_rounded),
            title: Text('Notifications'),
            trailing: Icon(Icons.chevron_right_rounded),
          ),

          const ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.lock_outline_rounded),
            title: Text('Privacy & Security'),
            trailing: Icon(Icons.chevron_right_rounded),
          ),

          const ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.help_outline_rounded),
            title: Text('Help & Support'),
            trailing: Icon(Icons.chevron_right_rounded),
          ),
        ],
      ),
    );
  }
}

class _EditProfileDialog extends StatefulWidget {
  const _EditProfileDialog({
    required this.name,
    required this.email,
    required this.phone,
    required this.location,
    required this.onSave,
  });

  final String name;
  final String email;
  final String phone;
  final String location;

  final void Function({
    required String name,
    required String phone,
    required String location,
  })
  onSave;

  @override
  State<_EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<_EditProfileDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _locationController;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(text: widget.name);

    _phoneController = TextEditingController(text: widget.phone);

    _locationController = TextEditingController(text: widget.location);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _locationController.dispose();

    super.dispose();
  }

  void _save() {
    widget.onSave(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      location: _locationController.text.trim(),
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Profile'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Full Name'),
            ),

            const SizedBox(height: AppSpacing.md),

            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Phone'),
            ),

            const SizedBox(height: AppSpacing.md),

            TextField(
              controller: _locationController,
              decoration: const InputDecoration(labelText: 'Location'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _save, child: const Text('Save')),
      ],
    );
  }
}
