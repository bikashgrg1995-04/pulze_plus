import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_card.dart';
import '../models/blood_request_model.dart';
import '../widgets/request_status_chip.dart';

class BloodRequestDetailScreen extends StatelessWidget {
  const BloodRequestDetailScreen({
    super.key,
    required this.request,
  });

  final BloodRequestModel request;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Request Details'),
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.xs,
            AppSpacing.md,
            AppSpacing.xl,
          ),
          child: Column(
            children: [
              _buildHero(context),
              const SizedBox(height: AppSpacing.sm),
              _buildRequestInfo(context),
              const SizedBox(height: AppSpacing.sm),
              _buildPatientAndHospital(context),
              if (request.note.trim().isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
                _buildNote(context),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHero(BuildContext context) {
    final theme = Theme.of(context);
    final urgencyColor = _urgencyColor(request.urgency);

    final progress = request.unitsRequired <= 0
        ? 0.0
        : (request.unitsFulfilled / request.unitsRequired).clamp(0.0, 1.0);

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 58,
                height: 58,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  request.bloodGroup,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${request.unitsRemaining} '
                      '${request.unitsRemaining == 1 ? 'Unit' : 'Units'} Needed',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _purposeLabel(request),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              RequestStatusChip(status: request.status),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Icon(
                Icons.priority_high_rounded,
                size: 15,
                color: urgencyColor,
              ),
              const SizedBox(width: 3),
              Text(
                _urgencyLabel(request.urgency),
                style: theme.textTheme.labelMedium?.copyWith(
                  color: urgencyColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                '${request.unitsFulfilled}/${request.unitsRequired} fulfilled',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 5,
              backgroundColor: AppColors.primary.withValues(alpha: 0.08),
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestInfo(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: [
          _sectionTitle(context, Icons.bloodtype_outlined, 'Request'),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: _compactInfo(
                  context,
                  icon: Icons.bloodtype_outlined,
                  label: 'Blood',
                  value: request.bloodGroup,
                ),
              ),
              Expanded(
                child: _compactInfo(
                  context,
                  icon: Icons.format_list_numbered_rounded,
                  label: 'Units',
                  value: '${request.unitsRequired}',
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: _compactInfo(
                  context,
                  icon: Icons.schedule_outlined,
                  label: 'Required',
                  value: _formatDateTime(request.requiredAt),
                ),
              ),
              Expanded(
                child: _compactInfo(
                  context,
                  icon: Icons.timer_outlined,
                  label: 'Expires',
                  value: _formatDateTime(request.expiresAt),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPatientAndHospital(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: [
          _sectionTitle(context, Icons.info_outline, 'Information'),
          const SizedBox(height: AppSpacing.xs),
          _compactRow(
            context,
            Icons.person_outline,
            'Patient',
            request.patientName,
          ),
          _compactRow(
            context,
            Icons.people_outline,
            'Relationship',
            _relationshipLabel(request),
          ),
          _compactRow(
            context,
            Icons.local_hospital_outlined,
            'Hospital',
            request.hospitalName,
          ),
          if (request.location != null)
            _compactRow(
              context,
              Icons.location_on_outlined,
              'Location',
              '${request.location!.latitude.toStringAsFixed(4)}, '
                  '${request.location!.longitude.toStringAsFixed(4)}',
            ),
          _compactRow(
            context,
            Icons.phone_outlined,
            'Contact',
            request.contactPhone,
            showDivider: false,
          ),
        ],
      ),
    );
  }

  Widget _buildNote(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.notes_outlined,
            size: 19,
            color: AppColors.primary,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Note',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 3),
                Text(
                  request.note,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textPrimary,
                        height: 1.35,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(
    BuildContext context,
    IconData icon,
    String title,
  ) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: AppColors.primary,
        ),
        const SizedBox(width: 6),
        Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _compactInfo(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 17,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _compactRow(
    BuildContext context,
    IconData icon,
    String label,
    String value, {
    bool showDivider = true,
  }) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 17,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 82,
                child: Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if (showDivider)
            const Padding(
              padding: EdgeInsets.only(top: 5),
              child: Divider(height: 1),
            ),
        ],
      ),
    );
  }

  String _urgencyLabel(String urgency) {
    switch (urgency) {
      case 'EMERGENCY':
        return 'Emergency';
      case 'URGENT':
        return 'Urgent';
      case 'SCHEDULED':
        return 'Scheduled';
      default:
        return urgency;
    }
  }

  Color _urgencyColor(String urgency) {
    switch (urgency) {
      case 'EMERGENCY':
        return AppColors.error;
      case 'URGENT':
        return AppColors.primary;
      default:
        return AppColors.textSecondary;
    }
  }

  String _purposeLabel(BloodRequestModel request) {
    if (request.purpose == 'OTHER' &&
        request.purposeOther.trim().isNotEmpty) {
      return request.purposeOther;
    }

    switch (request.purpose) {
      case 'SURGERY':
        return 'Surgery';
      case 'ACCIDENT':
        return 'Accident';
      case 'EMERGENCY':
        return 'Emergency';
      case 'TREATMENT':
        return 'Treatment';
      case 'CHILDBIRTH':
        return 'Childbirth';
      case 'OTHER':
        return 'Other';
      default:
        return request.purpose;
    }
  }

  String _relationshipLabel(BloodRequestModel request) {
    switch (request.requesterRelationship) {
      case 'SELF':
        return 'Self';
      case 'PARENT':
        return 'Parent';
      case 'SPOUSE':
        return 'Spouse';
      case 'CHILD':
        return 'Child';
      case 'SIBLING':
        return 'Sibling';
      case 'RELATIVE':
        return 'Relative';
      case 'FRIEND':
        return 'Friend';
      case 'OTHER':
        return request.otherRelationship.trim().isEmpty
            ? 'Other'
            : request.otherRelationship;
      default:
        return request.requesterRelationship;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final local = dateTime.toLocal();

    final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final minute = local.minute.toString().padLeft(2, '0');
    final period = local.hour >= 12 ? 'PM' : 'AM';

    return '${local.day}/${local.month} '
        '$hour:$minute $period';
  }
}