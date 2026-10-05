import 'package:flutter/foundation.dart';

import 'accepted_blood_request_connection_model.dart';
import 'blood_request_model.dart';

@immutable
class AcceptedBloodRequestDetailModel {
  const AcceptedBloodRequestDetailModel({
    required this.id,
    required this.requestType,
    required this.requesterName,
    required this.acceptedConnections,
    required this.patientType,
    required this.patientName,
    required this.requesterRelationship,
    required this.purpose,
    required this.purposeOther,
    required this.bloodGroup,
    required this.unitsRequired,
    required this.unitsFulfilled,
    required this.unitsRemaining,
    required this.urgency,
    required this.requiredAt,
    required this.expiresAt,
    required this.hospitalName,
    required this.requestLocation,
    required this.contactType,
    required this.contactPhone,
    required this.contactVerifiedAt,
    required this.note,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final String requestType;

  final String requesterName;

  final List<AcceptedBloodRequestConnectionModel>
      acceptedConnections;

  final String patientType;
  final String patientName;
  final String requesterRelationship;

  final String purpose;
  final String purposeOther;

  final String bloodGroup;

  final int unitsRequired;
  final int unitsFulfilled;
  final int unitsRemaining;

  final String urgency;

  final DateTime requiredAt;
  final DateTime expiresAt;

  final String hospitalName;
  final BloodRequestLocation? requestLocation;

  final String contactType;
  final String contactPhone;
  final DateTime? contactVerifiedAt;

  final String note;
  final String status;

  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isFulfilled =>
      status == 'FULFILLED';

  factory AcceptedBloodRequestDetailModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final connections =
        json['accepted_connections'];

    return AcceptedBloodRequestDetailModel(
      id: _parseInt(json['id']),
      requestType:
          json['request_type']?.toString() ?? '',
      requesterName:
          json['requester_name']?.toString() ?? '',
      acceptedConnections:
          connections is List
              ? connections
                  .map(
                    (item) =>
                        AcceptedBloodRequestConnectionModel
                            .fromJson(
                      Map<String, dynamic>.from(
                        item as Map,
                      ),
                    ),
                  )
                  .toList()
              : const [],
      patientType:
          json['patient_type']?.toString() ?? '',
      patientName:
          json['patient_name']?.toString() ?? '',
      requesterRelationship:
          json['requester_relationship']?.toString() ?? '',
      purpose:
          json['purpose']?.toString() ?? '',
      purposeOther:
          json['purpose_other']?.toString() ?? '',
      bloodGroup:
          json['blood_group']?.toString() ?? '',
      unitsRequired:
          _parseInt(json['units_required']),
      unitsFulfilled:
          _parseInt(json['units_fulfilled']),
      unitsRemaining:
          _parseInt(json['units_remaining']),
      urgency:
          json['urgency']?.toString() ?? '',
      requiredAt:
          _parseDateTime(json['required_at']),
      expiresAt:
          _parseDateTime(json['expires_at']),
      hospitalName:
          json['hospital_name']?.toString() ?? '',
      requestLocation:
          BloodRequestLocation.fromJson(
        json['request_location'],
      ),
      contactType:
          json['contact_type']?.toString() ?? '',
      contactPhone:
          json['contact_phone']?.toString() ?? '',
      contactVerifiedAt:
          _parseNullableDateTime(
        json['contact_verified_at'],
      ),
      note:
          json['note']?.toString() ?? '',
      status:
          json['status']?.toString() ?? '',
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

  static DateTime _parseDateTime(dynamic value) {
    final parsed = DateTime.tryParse(
      value?.toString() ?? '',
    );

    return parsed ??
        DateTime.fromMillisecondsSinceEpoch(0);
  }

  static DateTime? _parseNullableDateTime(
    dynamic value,
  ) {
    if (value == null) {
      return null;
    }

    final valueString = value.toString();

    if (valueString.isEmpty) {
      return null;
    }

    return DateTime.tryParse(valueString);
  }
}