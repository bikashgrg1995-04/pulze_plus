import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pulze_plus/features/auth/providers/auth_provider.dart';

import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../profile/providers/profile_provider.dart';

class CreateBloodRequestSheet extends ConsumerStatefulWidget {
  const CreateBloodRequestSheet({super.key, required this.onCreate});

  final Future<void> Function(Map<String, dynamic> data) onCreate;

  @override
  ConsumerState<CreateBloodRequestSheet> createState() =>
      _CreateBloodRequestSheetState();
}

class _CreateBloodRequestSheetState
    extends ConsumerState<CreateBloodRequestSheet> {
  final _patientNameController = TextEditingController();
  final _otherRelationshipController = TextEditingController();
  final _purposeOtherController = TextEditingController();
  final _unitsController = TextEditingController(text: '1');
  final _hospitalController = TextEditingController();
  final _contactPhoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _noteController = TextEditingController();

  int _currentStep = 0;

  String? _patientType;
  String? _relationship;
  String _purpose = 'TREATMENT';
  String _bloodGroup = 'O+';
  String _urgency = 'URGENT';

  DateTime? _requiredAt;
  DateTime? _expiresAt;

  double? _latitude;
  double? _longitude;

  bool _isSubmitting = false;
  bool _isGettingLocation = false;

  bool _phoneVerificationSent = false;
  bool _phoneVerified = false;
  bool _isSendingOtp = false;
  bool _isVerifyingOtp = false;

  String? _phoneError;
  String? _otpError;
  String? _submitError;

  Timer? _resendTimer;
  int _resendSeconds = 0;

  final Map<String, String?> _errors = {};

  static const _stepTitles = [
    'Patient & Contact',
    'Purpose',
    'Blood Requirement',
    'Schedule & Note',
    'Hospital & Location',
    'Review',
  ];

  static const _stepSubtitles = [
    'Who needs the blood and how can donors contact you?',
    'Why is blood needed?',
    'Specify blood type, quantity and urgency.',
    'When is blood needed and is there anything else to know?',
    'Where should donors respond?',
    'Review your request before creating it.',
  ];

  static const _bloodGroups = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
  ];

  static const _relationships = [
    ('PARENT', 'Parent'),
    ('SPOUSE', 'Spouse'),
    ('CHILD', 'Child'),
    ('SIBLING', 'Sibling'),
    ('RELATIVE', 'Relative'),
    ('FRIEND', 'Friend'),
    ('OTHER', 'Other'),
  ];

  static const _purposes = [
    ('SURGERY', 'Surgery'),
    ('ACCIDENT', 'Accident'),
    ('EMERGENCY', 'Emergency'),
    ('TREATMENT', 'Treatment'),
    ('CHILDBIRTH', 'Childbirth'),
    ('OTHER', 'Other'),
  ];

  static const _urgencies = [
    ('EMERGENCY', 'Emergency'),
    ('URGENT', 'Urgent'),
    ('SCHEDULED', 'Scheduled'),
  ];

  bool get _hasLocation => _latitude != null && _longitude != null;

  bool get _isUsingVerifiedProfilePhone {
    final profile = ref.read(profileProvider).profile;
    final profilePhone = profile?.phoneNumber?.trim();
    final contactPhone = _contactPhoneController.text.trim();

    return profile != null &&
        profile.isPhoneVerified &&
        profilePhone != null &&
        profilePhone.isNotEmpty &&
        profilePhone == contactPhone;
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeFromProfile();
    });
  }

  void _initializeFromProfile() {
    final profile = ref.read(profileProvider).profile;

    if (profile == null) return;

    final phone = profile.phoneNumber?.trim();

    if (phone != null && phone.isNotEmpty) {
      _contactPhoneController.text = phone;

      if (profile.isPhoneVerified && mounted) {
        setState(() {
          _phoneVerified = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _resendTimer?.cancel();

    _patientNameController.dispose();
    _otherRelationshipController.dispose();
    _purposeOtherController.dispose();
    _unitsController.dispose();
    _hospitalController.dispose();
    _contactPhoneController.dispose();
    _otpController.dispose();
    _noteController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Material(
      color: colors.surface,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTopBar(context),
              _buildStepIndicator(context),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.md,
                    AppSpacing.lg,
                    AppSpacing.md,
                  ),
                  child: _buildCurrentStep(context),
                ),
              ),
              _buildBottomActions(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.sm,
        AppSpacing.sm,
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(
              Icons.bloodtype_rounded,
              color: colors.primary,
              size: 23,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Create Request',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Step ${_currentStep + 1} of ${_stepTitles.length} · '
                  '${_stepTitles[_currentStep]}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Close',
            onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close_rounded),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        children: List.generate(_stepTitles.length, (index) {
          final completed = index < _currentStep;
          final active = index == _currentStep;

          return Expanded(
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: active ? 28 : 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: completed || active
                        ? colors.primary
                        : colors.outline.withValues(alpha: 0.30),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: completed
                      ? Icon(
                          Icons.check_rounded,
                          size: 8,
                          color: colors.onPrimary,
                        )
                      : null,
                ),
                if (index != _stepTitles.length - 1)
                  Expanded(
                    child: Container(
                      height: 2,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      color: index < _currentStep
                          ? colors.primary
                          : colors.outline.withValues(alpha: 0.20),
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCurrentStep(BuildContext context) {
    switch (_currentStep) {
      case 0:
        return _buildPatientStep(context);
      case 1:
        return _buildPurposeStep(context);
      case 2:
        return _buildBloodStep(context);
      case 3:
        return _buildScheduleStep(context);
      case 4:
        return _buildHospitalStep(context);
      case 5:
        return _buildReviewStep(context);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildStepHeader(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _stepTitles[_currentStep],
            style: theme.textTheme.headlineSmall?.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            _stepSubtitles[_currentStep],
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientStep(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepHeader(context),

        _buildFieldLabel(context, 'Who is this request for?'),
        const SizedBox(height: AppSpacing.sm),

        Row(
          children: [
            Expanded(
              child: _SelectionTile(
                label: 'Myself',
                icon: Icons.person_outline_rounded,
                selected: _patientType == 'MYSELF',
                onTap: _selectMyself,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _SelectionTile(
                label: 'Someone Else',
                icon: Icons.people_outline_rounded,
                selected: _patientType == 'SOMEONE_ELSE',
                onTap: _selectSomeoneElse,
              ),
            ),
          ],
        ),

        if (_errors['patientType'] != null)
          _buildInlineError(_errors['patientType']!),

        if (_patientType != null) ...[
          const SizedBox(height: AppSpacing.lg),

          AppTextField(
            controller: _patientNameController,
            label: 'Patient Name',
            hint: _patientType == 'MYSELF'
                ? 'Your full name'
                : 'Enter patient name',
            errorText: _errors['patient'],
            onChanged: (_) => _clearError('patient'),
          ),
        ],

        if (_patientType == 'SOMEONE_ELSE') ...[
          const SizedBox(height: AppSpacing.lg),

          _buildFieldLabel(context, 'Relationship'),
          const SizedBox(height: AppSpacing.sm),

          _ChoiceWrap(
            items: _relationships,
            selectedValue: _relationship,
            onSelected: (value) {
              setState(() {
                _relationship = value;
                _clearError('relationship');

                if (value != 'OTHER') {
                  _otherRelationshipController.clear();
                  _clearError('otherRelationship');
                }
              });
            },
          ),

          if (_errors['relationship'] != null)
            _buildInlineError(_errors['relationship']!),
        ],

        if (_relationship == 'OTHER' && _patientType == 'SOMEONE_ELSE') ...[
          const SizedBox(height: AppSpacing.lg),

          AppTextField(
            controller: _otherRelationshipController,
            label: 'Specify Relationship',
            hint: 'e.g. Uncle, Grandparent',
            errorText: _errors['otherRelationship'],
            onChanged: (_) => _clearError('otherRelationship'),
          ),
        ],

        if (_patientType != null) ...[
          const SizedBox(height: AppSpacing.xl),

          _buildContactSection(context),
        ],
      ],
    );
  }

  void _selectMyself() {
    final user = ref.read(authProvider).user;
    final profile = ref.read(profileProvider).profile;

    final fullName = user?.fullName.trim() ?? '';
    final profilePhone = profile?.phoneNumber?.trim();

    setState(() {
      _patientType = 'MYSELF';
      _relationship = 'SELF';

      _patientNameController.text = fullName;
      _otherRelationshipController.clear();

      if (profilePhone != null && profilePhone.isNotEmpty) {
        _contactPhoneController.text = profilePhone;
        _phoneVerified = profile?.isPhoneVerified ?? false;
      }

      _phoneVerificationSent = false;
      _otpController.clear();
      _phoneError = null;
      _otpError = null;

      _errors.remove('patientType');
      _errors.remove('patient');
      _errors.remove('relationship');
      _errors.remove('otherRelationship');
    });
  }

  void _selectSomeoneElse() {
    final profile = ref.read(profileProvider).profile;
    final profilePhone = profile?.phoneNumber?.trim();

    setState(() {
      _patientType = 'SOMEONE_ELSE';
      _relationship = null;

      _patientNameController.clear();
      _otherRelationshipController.clear();

      // Contact remains the logged-in user's contact number.
      if (profilePhone != null && profilePhone.isNotEmpty) {
        _contactPhoneController.text = profilePhone;
        _phoneVerified = profile?.isPhoneVerified ?? false;
      }

      _phoneVerificationSent = false;
      _otpController.clear();
      _phoneError = null;
      _otpError = null;

      _errors.remove('patientType');
      _errors.remove('patient');
      _errors.remove('relationship');
      _errors.remove('otherRelationship');
    });
  }

  Widget _buildContactSection(BuildContext context) {
    final profile = ref.watch(profileProvider).profile;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(context, 'Contact Phone'),
        const SizedBox(height: AppSpacing.xs),

        Text(
          'This number will be shared with donors for this request.',
          style: Theme.of(context).textTheme.bodySmall
              ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),

        const SizedBox(height: AppSpacing.sm),

        AppTextField(
          controller: _contactPhoneController,
          label: 'Phone Number',
          hint: 'Enter phone number',
          keyboardType: TextInputType.phone,
          errorText: _phoneError,
          onChanged: _onPhoneChanged,
        ),

        const SizedBox(height: AppSpacing.sm),

        if (_phoneVerified)
          _buildVerifiedBanner(context)
        else
          _buildVerifyPhoneCard(context),

        if (_phoneVerificationSent && !_phoneVerified) ...[
          const SizedBox(height: AppSpacing.md),

          AppTextField(
            controller: _otpController,
            label: 'Verification Code',
            hint: 'Enter 6-digit OTP',
            keyboardType: TextInputType.number,
            errorText: _otpError,
            maxLength: 6,
            onChanged: (_) => _clearOtpError(),
          ),

          const SizedBox(height: AppSpacing.sm),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _isVerifyingOtp ? null : _verifyPhone,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(46),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                  ),
                  child: _isVerifyingOtp
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Verify OTP'),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              TextButton(
                onPressed: _resendSeconds > 0 || _isSendingOtp
                    ? null
                    : _sendPhoneVerification,
                child: Text(
                  _resendSeconds > 0
                      ? 'Resend in ${_resendSeconds}s'
                      : 'Resend OTP',
                ),
              ),
            ],
          ),
        ],

        if (profile?.phoneNumber != null &&
            profile!.phoneNumber!.trim().isNotEmpty &&
            profile.isPhoneVerified &&
            profile.phoneNumber != _contactPhoneController.text.trim()) ...[
          const SizedBox(height: AppSpacing.md),
          _buildInfoBanner(
            context,
            icon: Icons.info_outline_rounded,
            text:
                'You are using a different phone number. '
                'This number must be verified for this request.',
          ),
        ],
      ],
    );
  }

  Widget _buildPurposeStep(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepHeader(context),

        _buildFieldLabel(context, 'Purpose'),
        const SizedBox(height: AppSpacing.sm),

        _ChoiceWrap(
          items: _purposes,
          selectedValue: _purpose,
          onSelected: (value) {
            setState(() {
              _purpose = value;
              _clearError('purpose');

              if (value != 'OTHER') {
                _purposeOtherController.clear();
                _clearError('purposeOther');
              }
            });
          },
        ),

        if (_errors['purpose'] != null) _buildInlineError(_errors['purpose']!),

        if (_purpose == 'OTHER') ...[
          const SizedBox(height: AppSpacing.lg),

          AppTextField(
            controller: _purposeOtherController,
            label: 'Specify Purpose',
            hint: 'Enter the purpose',
            errorText: _errors['purposeOther'],
            onChanged: (_) => _clearError('purposeOther'),
          ),
        ],
      ],
    );
  }

  Widget _buildBloodStep(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepHeader(context),
        _buildFieldLabel(context, 'Blood Group'),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: _bloodGroups.map((group) {
            return _BloodGroupChip(
              bloodGroup: group,
              selected: _bloodGroup == group,
              onTap: () {
                setState(() {
                  _bloodGroup = group;
                  _clearError('bloodGroup');
                });
              },
            );
          }).toList(),
        ),
        if (_errors['bloodGroup'] != null)
          _buildInlineError(_errors['bloodGroup']!),
        const SizedBox(height: AppSpacing.lg),
        AppTextField(
          controller: _unitsController,
          label: 'Units Needed',
          hint: 'e.g. 2',
          keyboardType: TextInputType.number,
          errorText: _errors['units'],
          onChanged: (_) => _clearError('units'),
        ),
        const SizedBox(height: AppSpacing.lg),
        _buildFieldLabel(context, 'Urgency'),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: _urgencies.map((item) {
            final value = item.$1;
            final label = item.$2;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: value == _urgencies.last.$1 ? 0 : AppSpacing.xs,
                ),
                child: _UrgencyTile(
                  label: label,
                  selected: _urgency == value,
                  accentColor: value == 'EMERGENCY'
                      ? Theme.of(context).colorScheme.error
                      : Theme.of(context).colorScheme.primary,
                  onTap: () {
                    setState(() {
                      _urgency = value;
                      _clearError('urgency');
                    });
                  },
                ),
              ),
            );
          }).toList(),
        ),
        if (_errors['urgency'] != null) _buildInlineError(_errors['urgency']!),
      ],
    );
  }

  Widget _buildScheduleStep(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepHeader(context),
        _buildFieldLabel(context, 'When is blood required?'),
        const SizedBox(height: AppSpacing.sm),
        _DateTimeField(
          label: 'Required Date & Time',
          value: _requiredAt,
          icon: Icons.event_available_outlined,
          errorText: _errors['requiredAt'],
          onTap: () => _selectDateTime(isRequiredDate: true),
        ),
        const SizedBox(height: AppSpacing.md),
        _DateTimeField(
          label: 'Request Expiry',
          value: _expiresAt,
          icon: Icons.timer_outlined,
          errorText: _errors['expiresAt'],
          onTap: () => _selectDateTime(isRequiredDate: false),
        ),
        const SizedBox(height: AppSpacing.md),
        _buildInfoBanner(
          context,
          icon: Icons.info_outline_rounded,
          text: 'Expiry time must be later than the required time.',
        ),
        const SizedBox(height: AppSpacing.xl),
        _buildFieldLabel(context, 'Additional Note'),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Add any useful information for donors or hospitals.',
          style: Theme.of(context).textTheme.bodySmall
              ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: AppSpacing.sm),
        AppTextField(
          controller: _noteController,
          label: 'Optional Note',
          hint: 'e.g. Blood is needed for surgery...',
          maxLines: 5,
          maxLength: 500,
          errorText: _errors['note'],
          onChanged: (_) => _clearError('note'),
        ),
      ],
    );
  }

  Widget _buildHospitalStep(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepHeader(context),

        AppTextField(
          controller: _hospitalController,
          label: 'Hospital / Medical Center',
          hint: 'Enter hospital name',
          errorText: _errors['hospital'],
          onChanged: (_) => _clearError('hospital'),
        ),

        const SizedBox(height: AppSpacing.lg),

        _LocationPickerCard(
          latitude: _latitude,
          longitude: _longitude,
          isLoading: _isGettingLocation,
          errorText: _errors['location'],
          onUseCurrentLocation: _useCurrentLocation,
        ),
      ],
    );
  }

  Widget _buildReviewStep(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepHeader(context),

        _ReviewCard(
          title: 'Patient & Contact',
          icon: Icons.person_outline_rounded,
          rows: [
            _ReviewRow('Patient', _patientNameController.text.trim()),
            _ReviewRow(
              'Request for',
              _patientType == 'MYSELF' ? 'Myself' : 'Someone Else',
            ),
            if (_patientType == 'SOMEONE_ELSE')
              _ReviewRow(
                'Relationship',
                _relationship == 'OTHER'
                    ? _otherRelationshipController.text.trim()
                    : _relationshipLabel(_relationship!),
              ),
            _ReviewRow('Phone', _contactPhoneController.text.trim()),
            const _ReviewRow('Verification', 'Verified', isVerified: true),
          ],
        ),

        const SizedBox(height: AppSpacing.sm),

        _ReviewCard(
          title: 'Purpose & Blood',
          icon: Icons.bloodtype_outlined,
          rows: [
            _ReviewRow(
              'Purpose',
              _purpose == 'OTHER'
                  ? _purposeOtherController.text.trim()
                  : _purposeLabel(_purpose),
            ),
            _ReviewRow('Blood Group', _bloodGroup),
            _ReviewRow('Units', _unitsController.text.trim()),
            _ReviewRow('Urgency', _urgencyLabel(_urgency)),
          ],
        ),

        const SizedBox(height: AppSpacing.sm),

        _ReviewCard(
          title: 'Schedule',
          icon: Icons.schedule_outlined,
          rows: [
            _ReviewRow(
              'Required',
              _requiredAt == null
                  ? 'Not selected'
                  : _formatDateTime(_requiredAt!),
            ),
            _ReviewRow(
              'Expires',
              _expiresAt == null
                  ? 'Not selected'
                  : _formatDateTime(_expiresAt!),
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.sm),

        _ReviewCard(
          title: 'Hospital',
          icon: Icons.local_hospital_outlined,
          rows: [
            _ReviewRow('Hospital', _hospitalController.text.trim()),
            _ReviewRow(
              'Location',
              _hasLocation
                  ? '${_latitude!.toStringAsFixed(5)}, '
                        '${_longitude!.toStringAsFixed(5)}'
                  : 'Not selected',
            ),
          ],
        ),

        if (_noteController.text.trim().isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          _ReviewCard(
            title: 'Additional Note',
            icon: Icons.notes_outlined,
            rows: [_ReviewRow('Note', _noteController.text.trim())],
          ),
        ],

        const SizedBox(height: AppSpacing.md),

        _buildInfoBanner(
          context,
          icon: Icons.check_circle_outline_rounded,
          text:
              'Everything looks ready. Tap "Create Blood Request" '
              'to submit your request.',
        ),

        if (_submitError != null) ...[
          const SizedBox(height: AppSpacing.md),
          _buildErrorBanner(_submitError!),
        ],
      ],
    );
  }

  Future<void> _submitRequest() async {
    FocusScope.of(context).unfocus();

    // Final validation before submitting.
    final patientValid = _validatePatientStep();
    final purposeValid = _validatePurposeStep();
    final bloodValid = _validateBloodStep();
    final scheduleValid = _validateScheduleStep();
    final hospitalValid = _validateHospitalStep();
    final reviewValid = _validateReviewStep();

    if (!patientValid ||
        !purposeValid ||
        !bloodValid ||
        !scheduleValid ||
        !hospitalValid ||
        !reviewValid) {
      if (mounted) {
        setState(() {
          _submitError = 'Please review the required fields before submitting.';
        });
      }
      return;
    }

    final units = int.tryParse(_unitsController.text.trim());

    if (units == null || units < 1) {
      setState(() {
        _submitError = 'Please enter a valid number of blood units.';
      });
      return;
    }

    if (!_hasLocation || _latitude == null || _longitude == null) {
      setState(() {
        _submitError = 'Please select the hospital/request location.';
      });
      return;
    }

    if (_requiredAt == null || _expiresAt == null) {
      setState(() {
        _submitError = 'Please select the required and expiry times.';
      });
      return;
    }

    if (!_phoneVerified) {
      setState(() {
        _submitError = 'Please verify the contact phone number.';
      });
      return;
    }

    final patientName = _patientNameController.text.trim();
    final hospitalName = _hospitalController.text.trim();
    final contactPhone = _contactPhoneController.text.trim();
    final note = _noteController.text.trim();

    final isUsingProfilePhone = _isUsingVerifiedProfilePhone;

    final data = <String, dynamic>{
      'patient_type': _patientType,
      'patient_name': patientName,
      'requester_relationship': _patientType == 'MYSELF'
          ? 'SELF'
          : _relationship,
      'other_relationship': _relationship == 'OTHER'
          ? _otherRelationshipController.text.trim()
          : '',
      'purpose': _purpose,
      'purpose_other': _purpose == 'OTHER'
          ? _purposeOtherController.text.trim()
          : '',
      'blood_group': _bloodGroup,
      'units_required': units,
      'urgency': _urgency,
      'required_at': _requiredAt!.toUtc().toIso8601String(),
      'expires_at': _expiresAt!.toUtc().toIso8601String(),
      'hospital_name': hospitalName,
      'location': {
        'type': 'Point',
        'coordinates': [_longitude, _latitude],
      },
      'contact_type': isUsingProfilePhone ? 'MY_PHONE' : 'OTHER_PHONE',
      'contact_phone': contactPhone,
      'note': note,
    };

    setState(() {
      _isSubmitting = true;
      _submitError = null;
    });

    try {
      await widget.onCreate(data);

      if (!mounted) return;

      setState(() {
        _isSubmitting = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isSubmitting = false;
        _submitError = _cleanError(error);
      });
    }
  }

  Widget _buildBottomActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outline
                .withValues(alpha: 0.15),
          ),
        ),
      ),
      child: Row(
        children: [
          if (_currentStep > 0) ...[
            Expanded(
              flex: 2,
              child: OutlinedButton.icon(
                onPressed: _isSubmitting ? null : _previousStep,
                icon: const Icon(Icons.arrow_back_rounded, size: 18),
                label: const Text('Back'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
          ],
          Expanded(
            flex: 3,
            child: _currentStep == _stepTitles.length - 1
                ? AppButton(
                    label: _isSubmitting ? 'Creating...' : 'Create Request',
                    icon: Icons.bloodtype_outlined,
                    isLoading: _isSubmitting,
                    onPressed: _isSubmitting ? null : _submitRequest,
                  )
                : AppButton(
                    label: 'Continue',
                    icon: Icons.arrow_forward_rounded,
                    onPressed: _isSubmitting ? null : _nextStep,
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerifyPhoneCard(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: 0.30),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: _phoneError != null
              ? colors.error.withValues(alpha: 0.5)
              : colors.outline.withValues(alpha: 0.20),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(
              Icons.verified_user_outlined,
              color: colors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Phone verification required',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Verify this number with OTP before continuing.',
                  style: Theme.of(context).textTheme.labelSmall
                      ?.copyWith(color: colors.onSurfaceVariant),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          TextButton(
            onPressed: _isSendingOtp ? null : _sendPhoneVerification,
            child: _isSendingOtp
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Verify'),
          ),
        ],
      ),
    );
  }

  Widget _buildVerifiedBanner(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: colors.primary.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Icon(Icons.verified_rounded, color: colors.primary, size: 21),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Phone number verified',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _isUsingVerifiedProfilePhone
                      ? 'Using your verified profile phone.'
                      : 'Verified for this blood request.',
                  style: Theme.of(context).textTheme.labelSmall
                      ?.copyWith(color: colors.onSurfaceVariant),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Change phone',
            visualDensity: VisualDensity.compact,
            onPressed: _isSubmitting
                ? null
                : () {
                    setState(() {
                      _phoneVerified = false;
                      _phoneVerificationSent = false;
                      _otpController.clear();
                      _otpError = null;
                      _phoneError = null;
                    });
                  },
            icon: Icon(
              Icons.edit_outlined,
              size: 18,
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(BuildContext context, String label) {
    final colors = Theme.of(context).colorScheme;

    return Text(
      label,
      style: Theme.of(context).textTheme.labelLarge
          ?.copyWith(color: colors.onSurface, fontWeight: FontWeight.w600),
    );
  }

  Widget _buildInlineError(String message) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xs, left: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline_rounded, size: 15, color: colors.error),
          const SizedBox(width: 5),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: colors.error, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorBanner(String message) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: colors.error.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: colors.error.withValues(alpha: 0.20)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline_rounded, size: 20, color: colors.error),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: colors.error, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBanner(
    BuildContext context, {
    required IconData icon,
    required String text,
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: colors.primary.withValues(alpha: 0.12)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: colors.primary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _nextStep() {
    FocusScope.of(context).unfocus();

    final valid = _validateCurrentStep();

    if (!valid) return;

    if (_currentStep < _stepTitles.length - 1) {
      setState(() {
        _currentStep++;
      });
    }
  }

  void _previousStep() {
    FocusScope.of(context).unfocus();

    if (_currentStep == 0) return;

    setState(() {
      _currentStep--;
    });
  }

  bool _validateCurrentStep() {
    setState(() {
      _errors.clear();
      _submitError = null;
    });
    switch (_currentStep) {
      case 0:
        return _validatePatientStep();
      case 1:
        return _validatePurposeStep();
      case 2:
        return _validateBloodStep();
      case 3:
        return _validateScheduleStep();
      case 4:
        return _validateHospitalStep();
      case 5:
        return _validateReviewStep();
      default:
        return true;
    }
  }

  bool _validatePatientStep() {
    var valid = true;

    if (_patientType == null) {
      _errors['patientType'] = 'Please select who the request is for.';
      valid = false;
    }

    if (_patientType != null && _patientNameController.text.trim().isEmpty) {
      _errors['patient'] = 'Patient name is required.';
      valid = false;
    }

    if (_patientType == 'SOMEONE_ELSE') {
      if (_relationship == null) {
        _errors['relationship'] = 'Please select a relationship.';
        valid = false;
      }

      if (_relationship == 'OTHER' &&
          _otherRelationshipController.text.trim().isEmpty) {
        _errors['otherRelationship'] = 'Please specify the relationship.';
        valid = false;
      }
    }

    final phone = _contactPhoneController.text.trim();

    if (phone.isEmpty) {
      _phoneError = 'Contact phone is required.';
      valid = false;
    } else if (phone.length < 7) {
      _phoneError = 'Enter a valid phone number.';
      valid = false;
    } else if (!_phoneVerified) {
      _phoneError = 'Please verify this phone number before continuing.';
      valid = false;
    }

    setState(() {});

    return valid;
  }

  bool _validatePurposeStep() {
    var valid = true;

    if (_purpose.isEmpty) {
      _errors['purpose'] = 'Please select a purpose.';
      valid = false;
    }

    if (_purpose == 'OTHER' && _purposeOtherController.text.trim().isEmpty) {
      _errors['purposeOther'] = 'Please specify the purpose.';
      valid = false;
    }

    setState(() {});

    return valid;
  }

  bool _validateBloodStep() {
    var valid = true;

    final units = int.tryParse(_unitsController.text.trim());

    if (_bloodGroup.isEmpty) {
      _errors['bloodGroup'] = 'Please select a blood group.';
      valid = false;
    }

    if (units == null || units < 1) {
      _errors['units'] = 'Enter at least 1 blood unit.';
      valid = false;
    }

    if (_urgency.isEmpty) {
      _errors['urgency'] = 'Please select urgency.';
      valid = false;
    }

    setState(() {});

    return valid;
  }

  bool _validateScheduleStep() {
    var valid = true;
    final now = DateTime.now();
    if (_requiredAt == null) {
      _errors['requiredAt'] = 'Please select when blood is required.';
      valid = false;
    } else if (!_requiredAt!.isAfter(now)) {
      _errors['requiredAt'] = 'Required time must be in the future.';
      valid = false;
    }
    if (_expiresAt == null) {
      _errors['expiresAt'] = 'Please select request expiry.';
      valid = false;
    } else if (!_expiresAt!.isAfter(now)) {
      _errors['expiresAt'] = 'Expiry time must be in the future.';
      valid = false;
    }
    if (_requiredAt != null &&
        _expiresAt != null &&
        !_expiresAt!.isAfter(_requiredAt!)) {
      _errors['expiresAt'] = 'Expiry must be later than required time.';
      valid = false;
    }
    final note = _noteController.text.trim();
    if (note.length > 500) {
      _errors['note'] = 'Note cannot exceed 500 characters.';
      valid = false;
    }
    setState(() {});
    return valid;
  }

  bool _validateHospitalStep() {
    var valid = true;

    if (_hospitalController.text.trim().isEmpty) {
      _errors['hospital'] = 'Hospital / medical center is required.';
      valid = false;
    }

    if (!_hasLocation) {
      _errors['location'] = 'Please select the hospital/request location.';
      valid = false;
    }

    setState(() {});

    return valid;
  }

  bool _validateReviewStep() {
    if (_patientType == null) {
      setState(() {
        _submitError = 'Please complete the patient information.';
      });
      return false;
    }

    if (!_phoneVerified) {
      setState(() {
        _submitError = 'Please verify the contact phone number.';
      });
      return false;
    }

    return true;
  }

  void _clearError(String key) {
    if (_errors[key] == null) return;

    setState(() {
      _errors[key] = null;
    });
  }

  void _onPhoneChanged(String value) {
    final profile = ref.read(profileProvider).profile;
    final profilePhone = profile?.phoneNumber?.trim();

    final normalized = value.trim();

    final isSameAsVerifiedProfilePhone =
        profile != null &&
        profile.isPhoneVerified &&
        profilePhone != null &&
        profilePhone.isNotEmpty &&
        profilePhone == normalized;

    setState(() {
      _phoneError = null;
      _otpError = null;
      _phoneVerificationSent = false;
      _otpController.clear();

      _phoneVerified = isSameAsVerifiedProfilePhone;
    });
  }

  Future<void> _sendPhoneVerification() async {
    final phone = _contactPhoneController.text.trim();

    if (phone.isEmpty) {
      setState(() {
        _phoneError = 'Contact phone is required.';
      });
      return;
    }

    if (phone.length < 7) {
      setState(() {
        _phoneError = 'Enter a valid phone number.';
      });
      return;
    }

    setState(() {
      _phoneError = null;
      _otpError = null;
      _isSendingOtp = true;
    });

    try {
      await ref
          .read(profileProvider.notifier)
          .sendPhoneVerification(
            phoneNumber: phone,
            purpose: 'BLOOD_REQUEST_CONTACT',
          );

      if (!mounted) return;

      setState(() {
        _phoneVerificationSent = true;
        _phoneVerified = false;
        _otpController.clear();
      });

      _startResendTimer();
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _phoneError = _cleanError(error);
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSendingOtp = false;
        });
      }
    }
  }

  Future<void> _verifyPhone() async {
    final phone = _contactPhoneController.text.trim();
    final code = _otpController.text.trim();

    if (code.isEmpty) {
      setState(() {
        _otpError = 'Please enter the verification code.';
      });
      return;
    }

    if (code.length != 6) {
      setState(() {
        _otpError = 'Enter the 6-digit verification code.';
      });
      return;
    }

    setState(() {
      _otpError = null;
      _isVerifyingOtp = true;
    });

    try {
      await ref
          .read(profileProvider.notifier)
          .verifyPhone(
            phoneNumber: phone,
            code: code,
            purpose: 'BLOOD_REQUEST_CONTACT',
          );

      if (!mounted) return;

      _resendTimer?.cancel();

      setState(() {
        _phoneVerified = true;
        _phoneVerificationSent = false;
        _otpController.clear();
        _otpError = null;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _otpError = _cleanError(error);
      });
    } finally {
      if (mounted) {
        setState(() {
          _isVerifyingOtp = false;
        });
      }
    }
  }

  void _startResendTimer() {
    _resendTimer?.cancel();

    setState(() {
      _resendSeconds = 60;
    });

    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_resendSeconds <= 1) {
        timer.cancel();

        setState(() {
          _resendSeconds = 0;
        });

        return;
      }

      setState(() {
        _resendSeconds--;
      });
    });
  }

  void _clearOtpError() {
    if (_otpError == null) return;

    setState(() {
      _otpError = null;
    });
  }

  String _cleanError(Object error) {
    final message = error.toString();

    if (message.startsWith('Exception: ')) {
      return message.substring('Exception: '.length);
    }

    return message;
  }

  Future<void> _selectDateTime({required bool isRequiredDate}) async {
    final now = DateTime.now();

    final initialDate = isRequiredDate
        ? (_requiredAt ?? now.add(const Duration(hours: 1)))
        : (_expiresAt ??
              (_requiredAt ?? now.add(const Duration(hours: 1))).add(
                const Duration(hours: 24),
              ));

    final date = await showDatePicker(
      context: context,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 2),
      initialDate: initialDate.isBefore(now) ? now : initialDate,
    );

    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDate),
    );

    if (time == null || !mounted) return;

    final selected = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    setState(() {
      if (isRequiredDate) {
        _requiredAt = selected;
        _errors['requiredAt'] = null;

        if (_expiresAt != null && !_expiresAt!.isAfter(selected)) {
          _expiresAt = selected.add(const Duration(hours: 24));
          _errors['expiresAt'] = null;
        }
      } else {
        _expiresAt = selected;
        _errors['expiresAt'] = null;
      }
    });
  }

  Future<void> _useCurrentLocation() async {
    if (_isGettingLocation) return;

    setState(() {
      _isGettingLocation = true;
      _errors['location'] = null;
    });

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        setState(() {
          _errors['location'] =
              'Location service is turned off. '
              'Please enable GPS.';
        });
        return;
      }

      var permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        setState(() {
          _errors['location'] = 'Location permission is required.';
        });
        return;
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _errors['location'] =
              'Location permission is permanently denied. '
              'Please enable it from app settings.';
        });
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      if (!mounted) return;

      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
        _errors['location'] = null;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _errors['location'] =
            'Unable to get your current location. '
            'Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isGettingLocation = false;
        });
      }
    }
  }

  String _relationshipLabel(String value) {
    for (final item in _relationships) {
      if (item.$1 == value) {
        return item.$2;
      }
    }

    return value;
  }

  String _purposeLabel(String value) {
    for (final item in _purposes) {
      if (item.$1 == value) {
        return item.$2;
      }
    }

    return value;
  }

  String _urgencyLabel(String value) {
    for (final item in _urgencies) {
      if (item.$1 == value) {
        return item.$2;
      }
    }

    return value;
  }

  static String _formatDateTime(DateTime value) {
    final local = value.toLocal();

    final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;

    final minute = local.minute.toString().padLeft(2, '0');

    final period = local.hour >= 12 ? 'PM' : 'AM';

    return '${local.day}/${local.month}/${local.year} '
        '$hour:$minute $period';
  }
}

class _SelectionTile extends StatelessWidget {
  const _SelectionTile({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Material(
      color: selected
          ? colors.primary.withValues(alpha: 0.09)
          : colors.surfaceContainerHighest.withValues(alpha: 0.35),
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: selected
                  ? colors.primary
                  : colors.outline.withValues(alpha: 0.28),
              width: selected ? 1.4 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 19,
                color: selected ? colors.primary : colors.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChoiceWrap extends StatelessWidget {
  const _ChoiceWrap({
    required this.items,
    required this.selectedValue,
    required this.onSelected,
  });

  final List<(String, String)> items;
  final String? selectedValue;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: items.map((item) {
        final value = item.$1;
        final label = item.$2;
        final selected = selectedValue == value;

        return ChoiceChip(
          label: Text(label),
          selected: selected,
          onSelected: (_) => onSelected(value),
          backgroundColor: colors.surfaceContainerHighest.withValues(
            alpha: 0.35,
          ),
          selectedColor: colors.primary,
          side: BorderSide(
            color: selected
                ? colors.primary
                : colors.outline.withValues(alpha: 0.25),
          ),
          labelStyle: TextStyle(
            color: selected ? colors.onPrimary : colors.onSurface,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          showCheckmark: false,
        );
      }).toList(),
    );
  }
}

class _BloodGroupChip extends StatelessWidget {
  const _BloodGroupChip({
    required this.bloodGroup,
    required this.selected,
    required this.onTap,
  });

  final String bloodGroup;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Material(
      color: selected
          ? colors.primary
          : colors.surfaceContainerHighest.withValues(alpha: 0.35),
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          width: 58,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: selected
                  ? colors.primary
                  : colors.outline.withValues(alpha: 0.25),
            ),
          ),
          child: Text(
            bloodGroup,
            style: theme.textTheme.labelLarge?.copyWith(
              color: selected ? colors.onPrimary : colors.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _UrgencyTile extends StatelessWidget {
  const _UrgencyTile({
    required this.label,
    required this.selected,
    required this.accentColor,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color accentColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Material(
      color: selected
          ? accentColor
          : colors.surfaceContainerHighest.withValues(alpha: 0.35),
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: selected
                  ? accentColor
                  : colors.outline.withValues(alpha: 0.25),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: selected ? colors.onPrimary : colors.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _DateTimeField extends StatelessWidget {
  const _DateTimeField({
    required this.label,
    required this.value,
    required this.icon,
    required this.errorText,
    required this.onTap,
  });

  final String label;
  final DateTime? value;
  final IconData icon;
  final String? errorText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final hasValue = value != null;
    final hasError = errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Material(
          color: colors.surfaceContainerHighest.withValues(alpha: 0.30),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                border: Border.all(
                  color: hasError
                      ? colors.error
                      : hasValue
                      ? colors.primary.withValues(alpha: 0.35)
                      : colors.outline.withValues(alpha: 0.25),
                ),
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Icon(icon, size: 20, color: colors.primary),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colors.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          hasValue ? _format(value!) : 'Select date & time',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: hasValue
                                ? colors.onSurface
                                : colors.onSurfaceVariant,
                            fontWeight: hasValue
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: colors.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xs, left: 4),
            child: Row(
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  size: 15,
                  color: colors.error,
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    errorText!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.error,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  static String _format(DateTime value) {
    final local = value.toLocal();

    final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;

    final minute = local.minute.toString().padLeft(2, '0');

    final period = local.hour >= 12 ? 'PM' : 'AM';

    return '${local.day}/${local.month}/${local.year} '
        '$hour:$minute $period';
  }
}

class _LocationPickerCard extends StatelessWidget {
  const _LocationPickerCard({
    required this.latitude,
    required this.longitude,
    required this.isLoading,
    required this.errorText,
    required this.onUseCurrentLocation,
  });

  final double? latitude;
  final double? longitude;
  final bool isLoading;
  final String? errorText;
  final VoidCallback onUseCurrentLocation;

  bool get hasLocation => latitude != null && longitude != null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: hasLocation
                ? colors.primary.withValues(alpha: 0.05)
                : colors.surfaceContainerHighest.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: errorText != null
                  ? colors.error
                  : hasLocation
                  ? colors.primary.withValues(alpha: 0.35)
                  : colors.outline.withValues(alpha: 0.22),
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: 0.09),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Icon(
                      hasLocation
                          ? Icons.location_on_rounded
                          : Icons.location_on_outlined,
                      color: colors.primary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          hasLocation
                              ? 'Request Location Selected'
                              : 'Request Location',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colors.onSurface,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          hasLocation
                              ? '${latitude!.toStringAsFixed(6)}, '
                                    '${longitude!.toStringAsFixed(6)}'
                              : 'Select the hospital/request location',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (hasLocation)
                    Icon(
                      Icons.check_circle_rounded,
                      size: 20,
                      color: colors.primary,
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: isLoading ? null : onUseCurrentLocation,
                      icon: isLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.my_location_rounded, size: 18),
                      label: Text(isLoading ? 'Getting...' : 'Use Current'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(44),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: null,
                      icon: const Icon(Icons.map_outlined, size: 18),
                      label: const Text('Select on Map'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(44),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xs, left: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  size: 15,
                  color: colors.error,
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    errorText!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.error,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({
    required this.title,
    required this.icon,
    required this.rows,
  });

  final String title;
  final IconData icon;
  final List<_ReviewRow> rows;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: colors.outline.withValues(alpha: 0.18)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(icon, size: 18, color: colors.primary),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ...rows.map(
            (row) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 92,
                    child: Text(
                      row.label,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            row.value,
                            textAlign: TextAlign.end,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colors.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (row.isVerified) ...[
                          const SizedBox(width: 5),
                          Icon(
                            Icons.verified_rounded,
                            size: 15,
                            color: colors.primary,
                          ),
                        ],
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

class _ReviewRow {
  const _ReviewRow(this.label, this.value, {this.isVerified = false});

  final String label;
  final String value;
  final bool isVerified;
}
