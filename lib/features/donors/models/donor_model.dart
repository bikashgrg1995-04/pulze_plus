class DonorModel {
  const DonorModel({
    required this.id,
    required this.bloodGroup,
    required this.phoneNumber,
    required this.isPhoneVerified,
    required this.distance,
    required this.isAvailable,
    required this.isEligible,
    this.lastDonation,
  });

  final int id;
  final String bloodGroup;
  final String? phoneNumber;
  final bool isPhoneVerified;
  final double? distance;

  /// Whether the donor is currently available for donation.
  final bool isAvailable;

  /// Whether the donor is currently eligible to donate.
  final bool isEligible;

  /// Last donation date, if available.
  final String? lastDonation;

  factory DonorModel.fromJson(Map<String, dynamic> json) {
    return DonorModel(
      id: json['id'] as int,
      bloodGroup: json['blood_type'] as String,
      phoneNumber: json['phone_number'] as String?,
      isPhoneVerified: json['is_phone_verified'] as bool? ?? false,
      distance: (json['distance_km'] as num?)?.toDouble(),
      isAvailable: json['is_available'] as bool? ?? false,
      isEligible: json['is_eligible'] as bool? ?? false,
      lastDonation: json['last_donation'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'blood_type': bloodGroup,
      'phone_number': phoneNumber,
      'is_phone_verified': isPhoneVerified,
      'distance_km': distance,
      'is_available': isAvailable,
      'is_eligible': isEligible,
      'last_donation': lastDonation,
    };
  }

  DonorModel copyWith({
    int? id,
    String? bloodGroup,
    String? phoneNumber,
    bool? isPhoneVerified,
    double? distance,
    bool? isAvailable,
    bool? isEligible,
    String? lastDonation,
  }) {
    return DonorModel(
      id: id ?? this.id,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
      distance: distance ?? this.distance,
      isAvailable: isAvailable ?? this.isAvailable,
      isEligible: isEligible ?? this.isEligible,
      lastDonation: lastDonation ?? this.lastDonation,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is DonorModel &&
        other.id == id &&
        other.bloodGroup == bloodGroup &&
        other.phoneNumber == phoneNumber &&
        other.isPhoneVerified == isPhoneVerified &&
        other.distance == distance &&
        other.isAvailable == isAvailable &&
        other.isEligible == isEligible &&
        other.lastDonation == lastDonation;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      bloodGroup,
      phoneNumber,
      isPhoneVerified,
      distance,
      isAvailable,
      isEligible,
      lastDonation,
    );
  }

  @override
  String toString() {
    return 'DonorModel('
        'id: $id, '
        'bloodGroup: $bloodGroup, '
        'phoneNumber: $phoneNumber, '
        'isPhoneVerified: $isPhoneVerified, '
        'distance: $distance, '
        'isAvailable: $isAvailable, '
        'isEligible: $isEligible, '
        'lastDonation: $lastDonation'
        ')';
  }
}