import 'package:flutter/foundation.dart';

@immutable
class BloodRequestModel {
  const BloodRequestModel({
    required this.id,
    required this.requester,
    required this.requestType,
    required this.targetDonor,
    required this.patientType,
    required this.patientName,
    required this.requesterRelationship,
    required this.otherRelationship,
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
    required this.location,
    required this.contactType,
    required this.contactPhone,
    required this.contactVerifiedAt,
    required this.note,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final int requester;

  /// GENERAL or DIRECT.
  final String requestType;

  /// Only populated for DIRECT requests.
  final int? targetDonor;

  final String patientType;
  final String patientName;
  final String requesterRelationship;
  final String otherRelationship;

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
  final BloodRequestLocation? location;

  final String contactType;
  final String contactPhone;
  final DateTime? contactVerifiedAt;

  final String note;

  final String status;

  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isGeneral => requestType == 'GENERAL';

  bool get isDirect => requestType == 'DIRECT';

  bool get isActive => status == 'ACTIVE';

  bool get isFulfilled => status == 'FULFILLED';

  factory BloodRequestModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return BloodRequestModel(
      id: _parseInt(json['id']),
      requester: _parseInt(json['requester']),
      requestType:
          json['request_type']?.toString() ?? 'GENERAL',
      targetDonor: _parseNullableInt(
        json['target_donor'],
      ),
      patientType:
          json['patient_type']?.toString() ?? '',
      patientName:
          json['patient_name']?.toString() ?? '',
      requesterRelationship:
          json['requester_relationship']?.toString() ?? '',
      otherRelationship:
          json['other_relationship']?.toString() ?? '',
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
      location:
          BloodRequestLocation.fromJson(
        json['location'],
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'requester': requester,
      'request_type': requestType,
      'target_donor': targetDonor,
      'patient_type': patientType,
      'patient_name': patientName,
      'requester_relationship': requesterRelationship,
      'other_relationship': otherRelationship,
      'purpose': purpose,
      'purpose_other': purposeOther,
      'blood_group': bloodGroup,
      'units_required': unitsRequired,
      'units_fulfilled': unitsFulfilled,
      'units_remaining': unitsRemaining,
      'urgency': urgency,
      'required_at': requiredAt.toIso8601String(),
      'expires_at': expiresAt.toIso8601String(),
      'hospital_name': hospitalName,
      'location': location?.toJson(),
      'contact_type': contactType,
      'contact_phone': contactPhone,
      'contact_verified_at':
          contactVerifiedAt?.toIso8601String(),
      'note': note,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  BloodRequestModel copyWith({
    int? id,
    int? requester,
    String? requestType,
    int? targetDonor,
    String? patientType,
    String? patientName,
    String? requesterRelationship,
    String? otherRelationship,
    String? purpose,
    String? purposeOther,
    String? bloodGroup,
    int? unitsRequired,
    int? unitsFulfilled,
    int? unitsRemaining,
    String? urgency,
    DateTime? requiredAt,
    DateTime? expiresAt,
    String? hospitalName,
    BloodRequestLocation? location,
    String? contactType,
    String? contactPhone,
    DateTime? contactVerifiedAt,
    String? note,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BloodRequestModel(
      id: id ?? this.id,
      requester: requester ?? this.requester,
      requestType:
          requestType ?? this.requestType,
      targetDonor:
          targetDonor ?? this.targetDonor,
      patientType:
          patientType ?? this.patientType,
      patientName:
          patientName ?? this.patientName,
      requesterRelationship:
          requesterRelationship ??
          this.requesterRelationship,
      otherRelationship:
          otherRelationship ??
          this.otherRelationship,
      purpose:
          purpose ?? this.purpose,
      purposeOther:
          purposeOther ?? this.purposeOther,
      bloodGroup:
          bloodGroup ?? this.bloodGroup,
      unitsRequired:
          unitsRequired ?? this.unitsRequired,
      unitsFulfilled:
          unitsFulfilled ?? this.unitsFulfilled,
      unitsRemaining:
          unitsRemaining ?? this.unitsRemaining,
      urgency:
          urgency ?? this.urgency,
      requiredAt:
          requiredAt ?? this.requiredAt,
      expiresAt:
          expiresAt ?? this.expiresAt,
      hospitalName:
          hospitalName ?? this.hospitalName,
      location:
          location ?? this.location,
      contactType:
          contactType ?? this.contactType,
      contactPhone:
          contactPhone ?? this.contactPhone,
      contactVerifiedAt:
          contactVerifiedAt ??
          this.contactVerifiedAt,
      note:
          note ?? this.note,
      status:
          status ?? this.status,
      createdAt:
          createdAt ?? this.createdAt,
      updatedAt:
          updatedAt ?? this.updatedAt,
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

  static int? _parseNullableInt(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(
      value.toString(),
    );
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

    final stringValue = value.toString();

    if (stringValue.isEmpty) {
      return null;
    }

    return DateTime.tryParse(stringValue);
  }
}

@immutable
class BloodRequestLocation {
  const BloodRequestLocation({
    required this.latitude,
    required this.longitude,
  });

  final double latitude;
  final double longitude;

  static BloodRequestLocation? fromJson(
    dynamic json,
  ) {
    if (json == null) {
      return null;
    }

    if (json is Map) {
      final map = Map<String, dynamic>.from(json);

      // GeoJSON:
      // {
      //   "type": "Point",
      //   "coordinates": [longitude, latitude]
      // }
      final coordinates = map['coordinates'];

      if (coordinates is List &&
          coordinates.length >= 2) {
        return BloodRequestLocation(
          longitude: _parseDouble(
            coordinates[0],
          ),
          latitude: _parseDouble(
            coordinates[1],
          ),
        );
      }

      // Accepted connection detail:
      // {
      //   "latitude": ...,
      //   "longitude": ...
      // }
      final latitude = map['latitude'];
      final longitude = map['longitude'];

      if (latitude != null && longitude != null) {
        return BloodRequestLocation(
          latitude: _parseDouble(latitude),
          longitude: _parseDouble(longitude),
        );
      }
    }

    // Optional WKT support:
    // POINT(longitude latitude)
    if (json is String) {
      final match = RegExp(
        r'POINT\s*\(\s*([-+]?\d*\.?\d+)\s+([-+]?\d*\.?\d+)\s*\)',
        caseSensitive: false,
      ).firstMatch(json);

      if (match != null) {
        return BloodRequestLocation(
          longitude: double.parse(
            match.group(1)!,
          ),
          latitude: double.parse(
            match.group(2)!,
          ),
        );
      }
    }

    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'type': 'Point',
      'coordinates': [
        longitude,
        latitude,
      ],
    };
  }

  static double _parseDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }
}