import 'package:flutter/foundation.dart';

@immutable
class BloodRequestResponseModel {
  const BloodRequestResponseModel({
    required this.id,
    required this.bloodRequest,
    required this.donor,
    required this.status,
    required this.unitsCompleted,
    required this.unitsRemaining,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final int bloodRequest;
  final int donor;
  final String status;
  final int unitsCompleted;
  final int unitsRemaining;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isAccepted => status == 'ACCEPTED';

  bool get isDeclined => status == 'DECLINED';

  bool get isCompleted => status == 'COMPLETED';

  factory BloodRequestResponseModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return BloodRequestResponseModel(
      id: _parseInt(json['id']),
      bloodRequest: _parseInt(
        json['blood_request'],
      ),
      donor: _parseInt(
        json['donor'],
      ),
      status: json['status']?.toString() ?? '',
      unitsCompleted: _parseInt(
        json['units_completed'],
      ),
      unitsRemaining: _parseInt(
        json['units_remaining'],
      ),
      createdAt: _parseDateTime(
        json['created_at'],
      ),
      updatedAt: _parseDateTime(
        json['updated_at'],
      ),
    );
  }

  static int _parseInt(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }

  static DateTime _parseDateTime(
    dynamic value,
  ) {
    final parsed = DateTime.tryParse(
      value?.toString() ?? '',
    );

    return parsed ??
        DateTime.fromMillisecondsSinceEpoch(0);
  }
}