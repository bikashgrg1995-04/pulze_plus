import 'package:flutter/material.dart';

import '../../../core/widgets/app_status_badge.dart';
import '../models/blood_request_model.dart';

class RequestStatusChip extends StatelessWidget {
  const RequestStatusChip({
    super.key,
    required this.status,
  });

  final BloodRequestStatus status;

  @override
  Widget build(BuildContext context) {
    return AppStatusBadge(
      label: _label,
      type: _statusType,
      showIcon: true,
    );
  }

  String get _label {
    switch (status) {
      case BloodRequestStatus.pending:
        return 'Pending';

      case BloodRequestStatus.matched:
        return 'Matched';

      case BloodRequestStatus.accepted:
        return 'Accepted';

      case BloodRequestStatus.completed:
        return 'Completed';

      case BloodRequestStatus.cancelled:
        return 'Cancelled';
    }
  }

  AppStatusType get _statusType {
    switch (status) {
      case BloodRequestStatus.pending:
        return AppStatusType.pending;

      case BloodRequestStatus.matched:
        return AppStatusType.open;

      case BloodRequestStatus.accepted:
        return AppStatusType.accepted;

      case BloodRequestStatus.completed:
        return AppStatusType.completed;

      case BloodRequestStatus.cancelled:
        return AppStatusType.cancelled;
    }
  }
}