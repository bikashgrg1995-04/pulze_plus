import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pulze_plus/features/requests/providers/blood_request_provider.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_confirmation_dialog.dart';
import '../models/blood_request_model.dart';
import '../widgets/request_status_chip.dart';

class BloodRequestDetailArgs {
  const BloodRequestDetailArgs({
    required this.request,
    this.onEdit,
    this.onTerminate,
    this.onAccept,
    this.onDecline,
    this.onComplete,
    this.onConnection,
  });

  final BloodRequestModel request;

  final VoidCallback? onEdit;
  final VoidCallback? onTerminate;

  final VoidCallback? onAccept;
  final VoidCallback? onDecline;
  final VoidCallback? onComplete;
  final VoidCallback? onConnection;
}

class BloodRequestDetailScreen extends ConsumerWidget {
  const BloodRequestDetailScreen({
    super.key,
    required this.request,
    this.onEdit,
    this.onTerminate,
    this.onAccept,
    this.onDecline,
    this.onComplete,
    this.onConnection,
  });

  final BloodRequestModel request;

  final VoidCallback? onEdit;
  final VoidCallback? onTerminate;

  final VoidCallback? onAccept;
  final VoidCallback? onDecline;
  final VoidCallback? onComplete;
  final VoidCallback? onConnection;

  // ---------------------------------------------------------------------------
  // Request Management
  // ---------------------------------------------------------------------------

  bool _canManage(BloodRequestModel request) {
    return request.status.toUpperCase() == 'ACTIVE';
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final requestsAsync = ref.watch(bloodRequestsProvider);

    final currentRequest = requestsAsync.maybeWhen(
      data: (requests) {
        for (final item in requests) {
          if (item.id == request.id) {
            return item;
          }
        }

        return request;
      },
      orElse: () => request,
    );

    final hasManageActions =
        onEdit != null || onTerminate != null;

    final hasDonorActions =
        onAccept != null ||
        onDecline != null ||
        onComplete != null ||
        onConnection != null;

    final showActions =
        (hasManageActions && _canManage(currentRequest)) ||
        hasDonorActions;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Request Details'),
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.xs,
            AppSpacing.md,
            AppSpacing.md,
          ),
          child: Column(
            children: [
              _buildHero(
                context,
                currentRequest,
              ),
              const SizedBox(height: AppSpacing.sm),
              _buildRequestInfo(
                context,
                currentRequest,
              ),
              const SizedBox(height: AppSpacing.sm),
              _buildPatientAndHospital(
                context,
                currentRequest,
              ),
              if (currentRequest.note.trim().isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
                _buildNote(
                  context,
                  currentRequest,
                ),
              ],
              if (showActions) ...[
                const SizedBox(height: AppSpacing.md),
                _buildActions(context),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------------

  Widget _buildActions(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final hasDonorActions =
        onAccept != null ||
        onDecline != null ||
        onComplete != null ||
        onConnection != null;

    final hasManageActions =
        onEdit != null ||
        onTerminate != null;

    return AppCard(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          // ---------------------------------------------------------------
          // Accept / Decline
          // ---------------------------------------------------------------

          if (onAccept != null || onDecline != null)
            Row(
              children: [
                if (onAccept != null)
                  Expanded(
                    child: _ActionButton(
                      icon: Icons.check_circle_outline_rounded,
                      label: 'Accept',
                      backgroundColor:
                          colorScheme.primary.withValues(alpha: 0.08),
                      foregroundColor: colorScheme.primary,
                      onTap: () => onAccept?.call(),
                    ),
                  ),
                if (onAccept != null && onDecline != null)
                  const SizedBox(width: 8),
                if (onDecline != null)
                  Expanded(
                    child: _ActionButton(
                      icon: Icons.close_rounded,
                      label: 'Decline',
                      backgroundColor:
                          colorScheme.error.withValues(alpha: 0.08),
                      foregroundColor: colorScheme.error,
                      onTap: () => onDecline?.call(),
                    ),
                  ),
              ],
            ),

          // ---------------------------------------------------------------
          // Complete Donation
          // ---------------------------------------------------------------

          if (onComplete != null) ...[
            if (onAccept != null || onDecline != null)
              const SizedBox(height: 8),
            _ActionButton(
              icon: Icons.volunteer_activism_outlined,
              label: 'Complete Donation',
              backgroundColor:
                  colorScheme.primary.withValues(alpha: 0.08),
              foregroundColor: colorScheme.primary,
              onTap: () => onComplete?.call(),
            ),
          ],

          // ---------------------------------------------------------------
          // Connection
          // ---------------------------------------------------------------

          if (onConnection != null) ...[
            if (onAccept != null ||
                onDecline != null ||
                onComplete != null)
              const SizedBox(height: 8),
            _ActionButton(
              icon: Icons.link_rounded,
              label: 'View Connection',
              backgroundColor:
                  colorScheme.secondary.withValues(alpha: 0.08),
              foregroundColor: colorScheme.secondary,
              onTap: () => onConnection?.call(),
            ),
          ],

          // ---------------------------------------------------------------
          // Separator between donor and requester actions
          // ---------------------------------------------------------------

          if (hasDonorActions && hasManageActions)
            const SizedBox(height: 8),

          // ---------------------------------------------------------------
          // Edit / Terminate
          // ---------------------------------------------------------------

          if (hasManageActions)
            Row(
              children: [
                if (onEdit != null)
                  Expanded(
                    child: _ActionButton(
                      icon: Icons.edit_outlined,
                      label: 'Edit Request',
                      backgroundColor:
                          colorScheme.primary.withValues(alpha: 0.08),
                      foregroundColor: colorScheme.primary,
                      onTap: () => onEdit?.call(),
                    ),
                  ),
                if (onEdit != null && onTerminate != null)
                  const SizedBox(width: 8),
                if (onTerminate != null)
                  Expanded(
                    child: _ActionButton(
                      icon: Icons.stop_circle_outlined,
                      label: 'Terminate',
                      backgroundColor:
                          colorScheme.error.withValues(alpha: 0.08),
                      foregroundColor: colorScheme.error,
                      onTap: () => _showTerminateConfirmation(context),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Terminate Confirmation
  // ---------------------------------------------------------------------------

  Future<void> _showTerminateConfirmation(
    BuildContext context,
  ) async {
    final shouldTerminate = await AppConfirmationDialog.show(
      context: context,
      title: 'Terminate Blood Request?',
      description:
          'This will stop the request and prevent further donor matching. '
          'This action cannot be undone.',
      confirmLabel: 'Terminate',
      cancelLabel: 'Keep Request',
      icon: Icons.stop_circle_outlined,
      isDestructive: true,
    );

    if (shouldTerminate != true) return;

    onTerminate?.call();
  }

  // ---------------------------------------------------------------------------
  // Hero
  // ---------------------------------------------------------------------------

  Widget _buildHero(
    BuildContext context,
    BloodRequestModel request,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final urgencyColor = _urgencyColor(
      context,
      request.urgency,
    );

    final progress = request.unitsRequired <= 0
        ? 0.0
        : (request.unitsFulfilled / request.unitsRequired)
            .clamp(0.0, 1.0);

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 54,
                height: 54,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color:
                      colorScheme.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  request.bloodGroup,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${request.unitsRemaining} '
                      '${request.unitsRemaining == 1 ? 'Unit' : 'Units'} Needed',
                      style:
                          theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _purposeLabel(request),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style:
                          theme.textTheme.bodySmall?.copyWith(
                        color:
                            colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              RequestStatusChip(
                status: request.status,
              ),
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
                style:
                    theme.textTheme.labelMedium?.copyWith(
                  color: urgencyColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                '${request.unitsFulfilled}/${request.unitsRequired} '
                'fulfilled',
                style:
                    theme.textTheme.labelSmall?.copyWith(
                  color:
                      colorScheme.onSurfaceVariant,
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
              backgroundColor:
                  colorScheme.primary.withValues(alpha: 0.08),
              valueColor:
                  AlwaysStoppedAnimation<Color>(
                colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Request Information
  // ---------------------------------------------------------------------------

  Widget _buildRequestInfo(
    BuildContext context,
    BloodRequestModel request,
  ) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: [
          _sectionTitle(
            context,
            Icons.bloodtype_outlined,
            'Request',
          ),
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
                  value: _formatDateTime(
                    request.requiredAt,
                  ),
                ),
              ),
              Expanded(
                child: _compactInfo(
                  context,
                  icon: Icons.timer_outlined,
                  label: 'Expires',
                  value: _formatDateTime(
                    request.expiresAt,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Patient / Hospital
  // ---------------------------------------------------------------------------

  Widget _buildPatientAndHospital(
    BuildContext context,
    BloodRequestModel request,
  ) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: [
          _sectionTitle(
            context,
            Icons.info_outline,
            'Information',
          ),
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

  // ---------------------------------------------------------------------------
  // Note
  // ---------------------------------------------------------------------------

  Widget _buildNote(
    BuildContext context,
    BloodRequestModel request,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.notes_outlined,
            size: 19,
            color: colorScheme.primary,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Note',
                  style:
                      theme.textTheme.labelMedium?.copyWith(
                    color:
                        colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  request.note,
                  style:
                      theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface,
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

  // ---------------------------------------------------------------------------
  // Section Title
  // ---------------------------------------------------------------------------

  Widget _sectionTitle(
    BuildContext context,
    IconData icon,
    String title,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: colorScheme.primary,
        ),
        const SizedBox(width: 6),
        Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Compact Info
  // ---------------------------------------------------------------------------

  Widget _compactInfo(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 17,
          color: colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style:
                    theme.textTheme.labelSmall?.copyWith(
                  color:
                      colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style:
                    theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Compact Row
  // ---------------------------------------------------------------------------

  Widget _compactRow(
    BuildContext context,
    IconData icon,
    String label,
    String value, {
    bool showDivider = true,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 17,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 82,
                child: Text(
                  label,
                  style:
                      theme.textTheme.labelSmall?.copyWith(
                    color:
                        colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                  style:
                      theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if (showDivider)
            Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Divider(
                height: 1,
                color: colorScheme.outlineVariant,
              ),
            ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Labels
  // ---------------------------------------------------------------------------

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

  Color _urgencyColor(
    BuildContext context,
    String urgency,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    switch (urgency) {
      case 'EMERGENCY':
        return colorScheme.error;
      case 'URGENT':
        return colorScheme.primary;
      default:
        return colorScheme.onSurfaceVariant;
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

  String _relationshipLabel(
    BloodRequestModel request,
  ) {
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

    final hour =
        local.hour % 12 == 0 ? 12 : local.hour % 12;

    final minute =
        local.minute.toString().padLeft(2, '0');

    final period =
        local.hour >= 12 ? 'PM' : 'AM';

    return '${local.day}/${local.month} '
        '$hour:$minute $period';
  }
}

// =============================================================================
// Action Button
// =============================================================================

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color backgroundColor;
  final Color foregroundColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 10,
            horizontal: 8,
          ),
          child: Row(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 17,
                color: foregroundColor,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: foregroundColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
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