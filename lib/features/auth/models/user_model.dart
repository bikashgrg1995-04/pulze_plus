
class UserModel {
  const UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    this.phoneNumber,
    required this.isEmailVerified,
  });

  final int id;
  final String fullName;
  final String email;
  final String? phoneNumber;
  final bool isEmailVerified;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      fullName: json['full_name'] as String,
      email: json['email'] as String,
      phoneNumber: json['phone_number'] as String?,
      isEmailVerified: json['is_email_verified'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'phone_number': phoneNumber,
      'is_email_verified': isEmailVerified,
    };
  }

  UserModel copyWith({
    int? id,
    String? fullName,
    String? email,
    String? phoneNumber,
    bool? isEmailVerified,
  }) {
    return UserModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isEmailVerified:
          isEmailVerified ?? this.isEmailVerified,
    );
  }

  @override
  String toString() {
    return 'UserModel('
        'id: $id, '
        'fullName: $fullName, '
        'email: $email, '
        'phoneNumber: $phoneNumber, '
        'isEmailVerified: $isEmailVerified'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is UserModel &&
        other.id == id &&
        other.fullName == fullName &&
        other.email == email &&
        other.phoneNumber == phoneNumber &&
        other.isEmailVerified == isEmailVerified;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      fullName,
      email,
      phoneNumber,
      isEmailVerified,
    );
  }
}