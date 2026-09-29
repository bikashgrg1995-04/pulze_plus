import 'package:flutter/material.dart';

import '../../../core/widgets/app_status_badge.dart';

class RequestStatusChip extends StatelessWidget {
  const RequestStatusChip({
    super.key,
    required this.status,
  });

  final String status;

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
      case 'ACTIVE':
        return 'Active';

      case 'FULFILLED':
        return 'Fulfilled';

      case 'CANCELLED':
        return 'Cancelled';

      case 'EXPIRED':
        return 'Expired';

      default:
        return status.isEmpty ? 'Unknown' : status;
    }
  }

  AppStatusType get _statusType {
    switch (status) {
      case 'ACTIVE':
        return AppStatusType.open;

      case 'FULFILLED':
        return AppStatusType.completed;

      case 'CANCELLED':
        return AppStatusType.cancelled;

      case 'EXPIRED':
        return AppStatusType.pending;

      default:
        return AppStatusType.pending;
    }
  }
}