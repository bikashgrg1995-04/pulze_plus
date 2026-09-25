import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pulze_plus/app/router/app_routes.dart';
import 'package:pulze_plus/core/widgets/app_snack_bar.dart';
import 'package:pulze_plus/features/auth/providers/auth_provider.dart';
import 'package:pulze_plus/features/profile/models/profile_state.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/form_validators.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../models/profile_model.dart';
import '../providers/profile_provider.dart';

enum ProfileFormMode { create, edit }

class ProfileFormScreen extends ConsumerStatefulWidget {
  const ProfileFormScreen({super.key, required this.mode, this.profile});

  final ProfileFormMode mode;
  final ProfileModel? profile;

  @override
  ConsumerState<ProfileFormScreen> createState() => _ProfileFormScreenState();
}

class _ProfileFormScreenState extends ConsumerState<ProfileFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _phoneController;
  late final TextEditingController _dateOfBirthController;
  late final TextEditingController _addressController;
  late final TextEditingController _cityController;

  String? _selectedGender;
  String? _selectedBloodType;
  DateTime? _selectedDateOfBirth;

  bool get _isCreate => widget.mode == ProfileFormMode.create;

  ProfileState get _profileState => ref.watch(profileProvider);

  bool get _isSubmitting => _profileState.status == ProfileStatus.loading;

  @override
  void initState() {
    super.initState();

    final profile = widget.profile;

    _phoneController = TextEditingController(text: profile?.phoneNumber ?? '');

    _selectedGender = profile?.gender;
    _selectedBloodType = profile?.bloodType;
    _selectedDateOfBirth = profile?.dateOfBirth;

    _dateOfBirthController = TextEditingController(
      text: _formatDate(_selectedDateOfBirth),
    );

    _addressController = TextEditingController(text: profile?.address ?? '');

    _cityController = TextEditingController(text: profile?.city ?? '');
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _dateOfBirthController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _selectDateOfBirth() async {
    final now = DateTime.now();

    final initialDate =
        _selectedDateOfBirth ?? DateTime(now.year - 18, now.month, now.day);

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: now,
      helpText: 'Select date of birth',
    );

    if (selectedDate == null || !mounted) {
      return;
    }

    setState(() {
      _selectedDateOfBirth = selectedDate;
      _dateOfBirthController.text = _formatDate(selectedDate);
    });
  }

  String _formatDate(DateTime? date) {
    if (date == null) {
      return '';
    }

    final year = date.year.toString().padLeft(4, '0');

    final month = date.month.toString().padLeft(2, '0');

    final day = date.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }

  Future<void> _selectLocation() async {
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select location'),
          content: const Text(
            'Map location selection will be available '
            'once map integration is added.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Ok'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedDateOfBirth == null) {
      return;
    }

    try {
      final notifier = ref.read(profileProvider.notifier);

      final phoneNumber = _phoneController.text.trim();
      final address = _addressController.text.trim();
      final city = _cityController.text.trim();

      if (_isCreate) {
        await notifier.createProfile(
          gender: _selectedGender!,
          dateOfBirth: _selectedDateOfBirth!,
          bloodType: _selectedBloodType!,
          phoneNumber: phoneNumber.isEmpty ? null : phoneNumber,
          address: address,
          city: city,
          latitude: widget.profile?.latitude,
          longitude: widget.profile?.longitude,
        );

        if (!mounted) {
          return;
        }

        await notifier.loadProfile();

        if (!mounted) {
          return;
        }

        // Profile creation is complete.
        ref.read(authProvider.notifier).markProfileCompleted();

        if (!mounted) {
          return;
        }

        context.go(AppRoutes.home);
        return;
      }

      await notifier.updateProfile(
        gender: _selectedGender,
        dateOfBirth: _selectedDateOfBirth,
        bloodType: _selectedBloodType,
        phoneNumber: phoneNumber.isEmpty ? null : phoneNumber,
        address: address,
        city: city,
        latitude: widget.profile?.latitude,
        longitude: widget.profile?.longitude,
      );

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop(true);
    } catch (error) {
      debugPrint('PROFILE SUBMIT ERROR: $error');

      if (!mounted) {
        return;
      }

      AppSnackBar.error(context, error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = ResponsiveUtils.value(
      context,
      mobile: AppSpacing.xl,
      tablet: AppSpacing.xxl,
      large: AppSpacing.xxxl,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_isCreate ? 'Complete your profile' : 'Edit profile'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            AppSpacing.lg,
            horizontalPadding,
            AppSpacing.xxl,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeader(),

                    const SizedBox(height: AppSpacing.xl),

                    _buildPhoneField(),

                    const SizedBox(height: AppSpacing.md),

                    _buildBloodTypeField(),

                    const SizedBox(height: AppSpacing.md),

                    _buildGenderField(),

                    const SizedBox(height: AppSpacing.md),

                    _buildDateOfBirthField(),

                    const SizedBox(height: AppSpacing.md),

                    AppTextField(
                      controller: _addressController,
                      label: 'Address',
                      hint: 'Enter your address',
                      prefixIcon: Icons.location_on_outlined,
                      textInputAction: TextInputAction.next,
                    ),

                    const SizedBox(height: AppSpacing.md),

                    AppTextField(
                      controller: _cityController,
                      label: 'City',
                      hint: 'Enter your city',
                      prefixIcon: Icons.location_city_outlined,
                      textInputAction: TextInputAction.done,
                    ),

                    const SizedBox(height: AppSpacing.md),

                    _buildLocationSelector(),

                    const SizedBox(height: AppSpacing.xl),

                    AppButton(
                      label: _isCreate ? 'Complete profile' : 'Save changes',
                      icon: _isCreate
                          ? Icons.arrow_forward_rounded
                          : Icons.check_rounded,
                      onPressed: _isSubmitting ? null : _submit,
                      isLoading: _isSubmitting,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _isCreate ? 'Tell us a little about you' : 'Update your profile',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          _isCreate
              ? 'Complete your profile to start using Pulze+.'
              : 'Keep your information up to date.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneField() {
    return AppTextField(
      controller: _phoneController,
      label: 'Phone number',
      hint: 'Enter your phone number',
      prefixIcon: Icons.phone_outlined,
      keyboardType: TextInputType.phone,
      textInputAction: TextInputAction.next,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return null;
        }

        return null;
      },
    );
  }

  Widget _buildBloodTypeField() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedBloodType,
      decoration: const InputDecoration(
        labelText: 'Blood type',
        hintText: 'Select your blood type',
        prefixIcon: Icon(Icons.bloodtype_outlined),
      ),
      items: const [
        DropdownMenuItem(value: 'A+', child: Text('A+')),
        DropdownMenuItem(value: 'A-', child: Text('A-')),
        DropdownMenuItem(value: 'B+', child: Text('B+')),
        DropdownMenuItem(value: 'B-', child: Text('B-')),
        DropdownMenuItem(value: 'AB+', child: Text('AB+')),
        DropdownMenuItem(value: 'AB-', child: Text('AB-')),
        DropdownMenuItem(value: 'O+', child: Text('O+')),
        DropdownMenuItem(value: 'O-', child: Text('O-')),
      ],
      onChanged: _isSubmitting
          ? null
          : (value) {
              setState(() {
                _selectedBloodType = value;
              });
            },
      validator: (value) {
        return FormValidators.required(value, fieldName: 'Blood type');
      },
    );
  }

  Widget _buildGenderField() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedGender,
      decoration: const InputDecoration(
        labelText: 'Gender',
        hintText: 'Select your gender',
        prefixIcon: Icon(Icons.person_outline_rounded),
      ),
      items: const [
        DropdownMenuItem(value: 'male', child: Text('Male')),
        DropdownMenuItem(value: 'female', child: Text('Female')),

        DropdownMenuItem(value: 'other', child: Text('Other')),
        DropdownMenuItem(
          value: 'prefer_not_to_say',
          child: Text('Prefer not to say'),
        ),
      ],
      onChanged: _isSubmitting
          ? null
          : (value) {
              setState(() {
                _selectedGender = value;
              });
            },
      validator: (value) {
        return FormValidators.required(value, fieldName: 'Gender');
      },
    );
  }

  Widget _buildDateOfBirthField() {
    return FormField<DateTime>(
      initialValue: _selectedDateOfBirth,
      validator: (_) {
        if (_selectedDateOfBirth == null) {
          return 'Date of birth is required.';
        }

        return null;
      },
      builder: (field) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: _isSubmitting
                  ? null
                  : () async {
                      await _selectDateOfBirth();

                      field.didChange(_selectedDateOfBirth);
                    },
              child: AbsorbPointer(
                child: AppTextField(
                  controller: _dateOfBirthController,
                  label: 'Date of birth',
                  hint: 'Select your date of birth',
                  prefixIcon: Icons.calendar_today_outlined,
                  readOnly: true,
                ),
              ),
            ),
            if (field.hasError)
              Padding(
                padding: const EdgeInsets.only(
                  left: AppSpacing.md,
                  top: AppSpacing.xs,
                ),
                child: Text(
                  field.errorText!,
                  style: Theme.of(context).textTheme.bodySmall
                      ?.copyWith(color: AppColors.error),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildLocationSelector() {
    final hasLocation =
        widget.profile?.latitude != null && widget.profile?.longitude != null;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.location_on_outlined,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Location',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      hasLocation
                          ? 'Location selected'
                          : 'Select your location',
                      style: Theme.of(context).textTheme.bodySmall
                          ?.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _isSubmitting ? null : _selectLocation,
              icon: const Icon(Icons.map_outlined),
              label: Text(hasLocation ? 'Change location' : 'Select location'),
            ),
          ),

          const SizedBox(height: AppSpacing.xs),

          Text(
            'Map selection will be connected later.',
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(color: AppColors.textTertiary),
          ),
        ],
      ),
    );
  }
}
