class ProfileModel {
  const ProfileModel({
    required this.gender,
    required this.dateOfBirth,
    this.phoneNumber,
    this.isPhoneVerified = false,
    this.avatar,
    this.isDonor = false,
    this.bloodType,
    this.address,
    this.city,
    this.latitude,
    this.longitude,
  });

  final String gender;
  final DateTime dateOfBirth;

  final String? phoneNumber;
  final bool isPhoneVerified;

  final String? avatar;
  final bool isDonor;

  final String? bloodType;

  final String? address;
  final String? city;

  final double? latitude;
  final double? longitude;

  factory ProfileModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return ProfileModel(
      phoneNumber: json['phone_number'] as String?,
      isPhoneVerified:
          json['is_phone_verified'] as bool? ?? false,
      avatar: json['avatar'] as String?,
      isDonor: json['is_donor'] as bool? ?? false,
      bloodType: json['blood_type'] as String?,
      gender: json['gender'] as String,
      dateOfBirth: DateTime.parse(
        json['date_of_birth'] as String,
      ),
      address: json['address'] as String?,
      city: json['city'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'phone_number': phoneNumber,
      'blood_type': bloodType,
      'gender': gender,
      'date_of_birth': _formatDate(dateOfBirth),
      'address': address,
      'city': city,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  ProfileModel copyWith({
    String? phoneNumber,
    bool? isPhoneVerified,
    String? avatar,
    bool? isDonor,
    String? bloodType,
    String? gender,
    DateTime? dateOfBirth,
    String? address,
    String? city,
    double? latitude,
    double? longitude,
  }) {
    return ProfileModel(
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isPhoneVerified:
          isPhoneVerified ?? this.isPhoneVerified,
      avatar: avatar ?? this.avatar,
      isDonor: isDonor ?? this.isDonor,
      bloodType: bloodType ?? this.bloodType,
      gender: gender ?? this.gender,
      dateOfBirth:
          dateOfBirth ?? this.dateOfBirth,
      address: address ?? this.address,
      city: city ?? this.city,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  static String _formatDate(DateTime date) {
    final year =
        date.year.toString().padLeft(4, '0');

    final month =
        date.month.toString().padLeft(2, '0');

    final day =
        date.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }

  @override
  String toString() {
    return 'ProfileModel('
        'phoneNumber: $phoneNumber, '
        'isPhoneVerified: $isPhoneVerified, '
        'avatar: $avatar, '
        'isDonor: $isDonor, '
        'bloodType: $bloodType, '
        'gender: $gender, '
        'dateOfBirth: $dateOfBirth, '
        'address: $address, '
        'city: $city, '
        'latitude: $latitude, '
        'longitude: $longitude'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is ProfileModel &&
        other.phoneNumber == phoneNumber &&
        other.isPhoneVerified == isPhoneVerified &&
        other.avatar == avatar &&
        other.isDonor == isDonor &&
        other.bloodType == bloodType &&
        other.gender == gender &&
        other.dateOfBirth == dateOfBirth &&
        other.address == address &&
        other.city == city &&
        other.latitude == latitude &&
        other.longitude == longitude;
  }

  @override
  int get hashCode {
    return Object.hash(
      phoneNumber,
      isPhoneVerified,
      avatar,
      isDonor,
      bloodType,
      gender,
      dateOfBirth,
      address,
      city,
      latitude,
      longitude,
    );
  }
}