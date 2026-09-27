import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:pulze_plus/app/router/app_routes.dart';
import 'package:pulze_plus/core/theme/app_colors.dart';
import 'package:pulze_plus/core/theme/app_radius.dart';
import 'package:pulze_plus/core/theme/app_spacing.dart';
import 'package:pulze_plus/core/utils/form_validators.dart';
import 'package:pulze_plus/core/utils/responsive_utils.dart';
import 'package:pulze_plus/core/widgets/app_button.dart';
import 'package:pulze_plus/core/widgets/app_snack_bar.dart';
import 'package:pulze_plus/core/widgets/app_text_field.dart';
import 'package:pulze_plus/features/auth/providers/auth_provider.dart';
import 'package:pulze_plus/features/profile/models/profile_model.dart';
import 'package:pulze_plus/features/profile/models/profile_state.dart';
import 'package:pulze_plus/features/profile/providers/profile_provider.dart';
import 'package:pulze_plus/l10n/app_localizations.dart';

enum ProfileFormMode { create, edit }

class ProfileFormScreen extends ConsumerStatefulWidget {
  const ProfileFormScreen({
    super.key,
    required this.mode,
    this.profile,
  });

  final ProfileFormMode mode;
  final ProfileModel? profile;

  @override
  ConsumerState<ProfileFormScreen> createState() =>
      _ProfileFormScreenState();
}

class _ProfileFormScreenState
    extends ConsumerState<ProfileFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _phoneController;
  late final TextEditingController _dateOfBirthController;
  late final TextEditingController _addressController;
  late final TextEditingController _cityController;

  String? _selectedGender;
  String? _selectedBloodType;
  DateTime? _selectedDateOfBirth;

  bool get _isCreate =>
      widget.mode == ProfileFormMode.create;

  ProfileState get _profileState =>
      ref.watch(profileProvider);

  bool get _isSubmitting =>
      _profileState.status == ProfileStatus.loading;

  @override
  void initState() {
    super.initState();

    final profile = widget.profile;

    _phoneController = TextEditingController(
      text: profile?.phoneNumber ?? '',
    );

    _selectedGender = profile?.gender;
    _selectedBloodType = profile?.bloodType;
    _selectedDateOfBirth = profile?.dateOfBirth;

    _dateOfBirthController = TextEditingController(
      text: _formatDate(_selectedDateOfBirth),
    );

    _addressController = TextEditingController(
      text: profile?.address ?? '',
    );

    _cityController = TextEditingController(
      text: profile?.city ?? '',
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _dateOfBirthController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  // ===========================================================================
  // Date of birth
  // ===========================================================================

  Future<void> _selectDateOfBirth() async {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();

    final initialDate = _selectedDateOfBirth ??
        DateTime(
          now.year - 18,
          now.month,
          now.day,
        );

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: now,
      helpText: l10n.selectDateOfBirth,
    );

    if (selectedDate == null || !mounted) {
      return;
    }

    setState(() {
      _selectedDateOfBirth = selectedDate;
      _dateOfBirthController.text =
          _formatDate(selectedDate);
    });
  }

  String _formatDate(DateTime? date) {
    if (date == null) {
      return '';
    }

    final year = date.year.toString().padLeft(4, '0');
    final month =
        date.month.toString().padLeft(2, '0');
    final day =
        date.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }

  // ===========================================================================
  // Location
  // ===========================================================================

  Future<void> _selectLocation() async {
    final l10n = AppLocalizations.of(context)!;

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.selectLocation),
          content: Text(
            l10n.mapLocationSelectionWillBeAvailable,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(l10n.ok),
            ),
          ],
        );
      },
    );
  }

  // ===========================================================================
  // Submit
  // ===========================================================================

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedDateOfBirth == null) {
      return;
    }

    try {
      final notifier =
          ref.read(profileProvider.notifier);

      final phoneNumber =
          _phoneController.text.trim();
      final address =
          _addressController.text.trim();
      final city =
          _cityController.text.trim();

      if (_isCreate) {
        await notifier.createProfile(
          gender: _selectedGender!,
          dateOfBirth: _selectedDateOfBirth!,
          bloodType: _selectedBloodType!,
          phoneNumber:
              phoneNumber.isEmpty ? null : phoneNumber,
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

        ref
            .read(authProvider.notifier)
            .markProfileCompleted();

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
        phoneNumber:
            phoneNumber.isEmpty ? null : phoneNumber,
        address: address,
        city: city,
        latitude: widget.profile?.latitude,
        longitude: widget.profile?.longitude,
      );

      if (!mounted) {
        return;
      }

      final l10n = AppLocalizations.of(context)!;

      AppSnackBar.success(
        context,
        l10n.profileUpdatedSuccessfully,
      );

      Navigator.of(context).pop(true);
    } catch (error) {
      debugPrint(
        'PROFILE SUBMIT ERROR: $error',
      );

      if (!mounted) {
        return;
      }

      AppSnackBar.error(
        context,
        error.toString(),
      );
    }
  }

  // ===========================================================================
  // Build
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    final horizontalPadding =
        ResponsiveUtils.value(
      context,
      mobile: AppSpacing.xl,
      tablet: AppSpacing.xxl,
      large: AppSpacing.xxxl,
    );

    return Scaffold(
      backgroundColor:
          theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          _isCreate
              ? l10n.completeYourProfile
              : l10n.editProfile,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics:
              const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            0,
            horizontalPadding,
            AppSpacing.xxl,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 520,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.stretch,
                  children: [
                    _buildHeader(),

                    const SizedBox(
                      height: AppSpacing.xl,
                    ),

                    _buildPhoneField(),

                    const SizedBox(
                      height: AppSpacing.md,
                    ),

                    _buildBloodTypeField(),

                    const SizedBox(
                      height: AppSpacing.md,
                    ),

                    _buildGenderField(),

                    const SizedBox(
                      height: AppSpacing.md,
                    ),

                    _buildDateOfBirthField(),

                    const SizedBox(
                      height: AppSpacing.md,
                    ),

                    AppTextField(
                      controller:
                          _addressController,
                      label: l10n.address,
                      hint: l10n.enterYourAddress,
                      prefixIcon:
                          Icons.location_on_outlined,
                      textInputAction:
                          TextInputAction.next,
                    ),

                    const SizedBox(
                      height: AppSpacing.md,
                    ),

                    AppTextField(
                      controller: _cityController,
                      label: l10n.city,
                      hint: l10n.enterYourCity,
                      prefixIcon:
                          Icons.location_city_outlined,
                      textInputAction:
                          TextInputAction.done,
                    ),

                    const SizedBox(
                      height: AppSpacing.md,
                    ),

                    _buildLocationSelector(),

                    const SizedBox(
                      height: AppSpacing.xl,
                    ),

                    AppButton(
                      label: _isCreate
                          ? l10n.completeProfile
                          : l10n.saveChanges,
                      icon: _isCreate
                          ? Icons.arrow_forward_rounded
                          : Icons.check_rounded,
                      onPressed:
                          _isSubmitting
                              ? null
                              : _submit,
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

  // ===========================================================================
  // Header
  // ===========================================================================

  Widget _buildHeader() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          _isCreate
              ? l10n.tellUsALittleAboutYou
              : l10n.updateYourProfile,
          style:
              theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
        Text(
          _isCreate
              ? l10n.completeYourProfileToStartUsingPulze
              : l10n.keepYourInformationUpToDate,
          style:
              theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // Phone
  // ===========================================================================

  Widget _buildPhoneField() {
    final l10n = AppLocalizations.of(context)!;

    return AppTextField(
      controller: _phoneController,
      label: l10n.phoneNumber,
      hint: l10n.enterYourPhoneNumber,
      prefixIcon: Icons.phone_outlined,
      keyboardType: TextInputType.phone,
      textInputAction: TextInputAction.next,
      validator: (value) {
        if (value == null ||
            value.trim().isEmpty) {
          return null;
        }

        return null;
      },
    );
  }

  // ===========================================================================
  // Blood type
  // ===========================================================================

  Widget _buildBloodTypeField() {
    final l10n = AppLocalizations.of(context)!;

    return DropdownButtonFormField<String>(
      initialValue: _selectedBloodType,
      decoration: InputDecoration(
        labelText: l10n.bloodType,
        hintText: l10n.selectYourBloodType,
        prefixIcon:
            const Icon(Icons.bloodtype_outlined),
      ),
      items: const [
        DropdownMenuItem(
          value: 'A+',
          child: Text('A+'),
        ),
        DropdownMenuItem(
          value: 'A-',
          child: Text('A-'),
        ),
        DropdownMenuItem(
          value: 'B+',
          child: Text('B+'),
        ),
        DropdownMenuItem(
          value: 'B-',
          child: Text('B-'),
        ),
        DropdownMenuItem(
          value: 'AB+',
          child: Text('AB+'),
        ),
        DropdownMenuItem(
          value: 'AB-',
          child: Text('AB-'),
        ),
        DropdownMenuItem(
          value: 'O+',
          child: Text('O+'),
        ),
        DropdownMenuItem(
          value: 'O-',
          child: Text('O-'),
        ),
      ],
      onChanged: _isSubmitting
          ? null
          : (value) {
              setState(() {
                _selectedBloodType = value;
              });
            },
      validator: (value) {
        return FormValidators.required(
          value,
          fieldName: l10n.bloodType,
        );
      },
    );
  }

  // ===========================================================================
  // Gender
  // ===========================================================================

  Widget _buildGenderField() {
    final l10n = AppLocalizations.of(context)!;

    return DropdownButtonFormField<String>(
      initialValue: _selectedGender,
      decoration: InputDecoration(
        labelText: l10n.gender,
        hintText: l10n.selectYourGender,
        prefixIcon:
            const Icon(Icons.person_outline_rounded),
      ),
      items: [
        DropdownMenuItem(
          value: 'male',
          child: Text(l10n.male),
        ),
        DropdownMenuItem(
          value: 'female',
          child: Text(l10n.female),
        ),
        DropdownMenuItem(
          value: 'other',
          child: Text(l10n.other),
        ),
        DropdownMenuItem(
          value: 'prefer_not_to_say',
          child: Text(l10n.preferNotToSay),
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
        return FormValidators.required(
          value,
          fieldName: l10n.gender,
        );
      },
    );
  }

  // ===========================================================================
  // Date of birth
  // ===========================================================================

  Widget _buildDateOfBirthField() {
    final l10n = AppLocalizations.of(context)!;

    return FormField<DateTime>(
      initialValue: _selectedDateOfBirth,
      validator: (_) {
        if (_selectedDateOfBirth == null) {
          return l10n.dateOfBirthIsRequired;
        }

        return null;
      },
      builder: (field) {
        final colorScheme =
            Theme.of(context).colorScheme;

        return Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: _isSubmitting
                  ? null
                  : () async {
                      await _selectDateOfBirth();

                      field.didChange(
                        _selectedDateOfBirth,
                      );
                    },
              child: AbsorbPointer(
                child: AppTextField(
                  controller:
                      _dateOfBirthController,
                  label: l10n.dateOfBirth,
                  hint:
                      l10n.selectYourDateOfBirth,
                  prefixIcon:
                      Icons.calendar_today_outlined,
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
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(
                    color: colorScheme.error,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  // ===========================================================================
  // Location
  // ===========================================================================

  Widget _buildLocationSelector() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    final hasLocation =
        widget.profile?.latitude != null &&
        widget.profile?.longitude != null;

    return Container(
      padding: const EdgeInsets.all(
        AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(
          AppRadius.lg,
        ),
        border: Border.all(
          color: colorScheme.outline,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: AppSpacing.huge,
                height: AppSpacing.huge,
                decoration: BoxDecoration(
                  color:
                      AppColors.primary.withValues(
                    alpha: 0.10,
                  ),
                  borderRadius:
                      BorderRadius.circular(
                    AppRadius.md,
                  ),
                ),
                child: const Icon(
                  Icons.location_on_outlined,
                  color: AppColors.primary,
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
                      l10n.location,
                      style: theme
                          .textTheme
                          .titleLarge
                          ?.copyWith(
                        fontSize: 16,
                        fontWeight:
                            FontWeight.w700,
                        color:
                            colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(
                      height: AppSpacing.xxs,
                    ),
                    Text(
                      hasLocation
                          ? l10n.locationSelected
                          : l10n.selectYourLocation,
                      style: theme
                          .textTheme
                          .bodySmall
                          ?.copyWith(
                        color: colorScheme
                            .onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(
            height: AppSpacing.md,
          ),
          AppButton(
            label: hasLocation
                ? l10n.changeLocation
                : l10n.selectLocation,
            icon: Icons.map_outlined,
            variant:
                AppButtonVariant.outlined,
            onPressed: _isSubmitting
                ? null
                : _selectLocation,
          ),
          const SizedBox(
            height: AppSpacing.xs,
          ),
          Text(
            l10n.mapSelectionWillBeConnectedLater,
            style: theme.textTheme.bodySmall
                ?.copyWith(
              color: colorScheme
                  .onSurfaceVariant
                  .withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}