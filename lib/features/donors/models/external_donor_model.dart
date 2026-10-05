import 'package:flutter/foundation.dart';

@immutable
class ExternalDonorModel {
  const ExternalDonorModel({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.bloodGroup,
    required this.address,
    required this.city,
    required this.source,
  });

  final int id;
  final String name;
  final String? phoneNumber;
  final String bloodGroup;
  final String address;
  final String city;
  final String source;

  factory ExternalDonorModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return ExternalDonorModel(
      id: _parseInt(json['id']),
      name: json['name']?.toString() ?? '',
      phoneNumber: json['phone_number']?.toString(),
      bloodGroup: json['blood_type']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      source: json['source']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone_number': phoneNumber,
      'blood_type': bloodGroup,
      'address': address,
      'city': city,
      'source': source,
    };
  }

  ExternalDonorModel copyWith({
    int? id,
    String? name,
    String? phoneNumber,
    String? bloodGroup,
    String? address,
    String? city,
    String? source,
  }) {
    return ExternalDonorModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      address: address ?? this.address,
      city: city ?? this.city,
      source: source ?? this.source,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is ExternalDonorModel &&
        other.id == id &&
        other.name == name &&
        other.phoneNumber == phoneNumber &&
        other.bloodGroup == bloodGroup &&
        other.address == address &&
        other.city == city &&
        other.source == source;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      name,
      phoneNumber,
      bloodGroup,
      address,
      city,
      source,
    );
  }

  @override
  String toString() {
    return 'ExternalDonorModel('
        'id: $id, '
        'name: $name, '
        'phoneNumber: $phoneNumber, '
        'bloodGroup: $bloodGroup, '
        'address: $address, '
        'city: $city, '
        'source: $source'
        ')';
  }

  static int _parseInt(dynamic value) {
    if (value is int) {
      return value;
    }

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}