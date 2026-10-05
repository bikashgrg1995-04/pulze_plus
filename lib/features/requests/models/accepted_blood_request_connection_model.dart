import 'package:flutter/foundation.dart';

@immutable
class AcceptedBloodRequestConnectionModel {
  const AcceptedBloodRequestConnectionModel({
    required this.id,
    required this.donorId,
    required this.donorName,
    required this.donorPhone,
    required this.responseStatus,
    required this.unitsCompleted,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final int donorId;
  final String donorName;
  final String? donorPhone;
  final String responseStatus;
  final int unitsCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isAccepted =>
      responseStatus == 'ACCEPTED';

  bool get isCompleted =>
      responseStatus == 'COMPLETED';

  factory AcceptedBloodRequestConnectionModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return AcceptedBloodRequestConnectionModel(
      id: _parseInt(json['id']),
      donorId: _parseInt(json['donor_id']),
      donorName:
          json['donor_name']?.toString() ?? '',
      donorPhone:
          json['donor_phone']?.toString(),
      responseStatus:
          json['response_status']?.toString() ?? '',
      unitsCompleted:
          _parseInt(json['units_completed']),
      createdAt:
          _parseDateTime(json['created_at']),
      updatedAt:
          _parseDateTime(json['updated_at']),
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