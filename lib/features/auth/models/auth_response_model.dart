import 'user_model.dart';

class AuthResponseModel {
  const AuthResponseModel({
    required this.message,
    required this.user,
    this.tokens,
  });

  final String message;
  final UserModel user;
  final AuthTokensModel? tokens;

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      message: json['message'] as String,
      user: UserModel.fromJson(Map<String, dynamic>.from(json['user'] as Map)),
      tokens: json['tokens'] == null
          ? null
          : AuthTokensModel.fromJson(
              Map<String, dynamic>.from(json['tokens'] as Map),
            ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'user': user.toJson(),
      if (tokens != null) 'tokens': tokens!.toJson(),
    };
  }

  AuthResponseModel copyWith({
    String? message,
    UserModel? user,
    AuthTokensModel? tokens,
  }) {
    return AuthResponseModel(
      message: message ?? this.message,
      user: user ?? this.user,
      tokens: tokens ?? this.tokens,
    );
  }

  @override
  String toString() {
    return 'AuthTokensModel(tokens: [protected])';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is AuthResponseModel &&
        other.message == message &&
        other.user == user &&
        other.tokens == tokens;
  }

  @override
  int get hashCode {
    return Object.hash(message, user, tokens);
  }
}

class AuthTokensModel {
  const AuthTokensModel({required this.access, required this.refresh});

  final String access;
  final String refresh;

  factory AuthTokensModel.fromJson(Map<String, dynamic> json) {
    return AuthTokensModel(
      access: json['access'] as String,
      refresh: json['refresh'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'access': access, 'refresh': refresh};
  }

  AuthTokensModel copyWith({String? access, String? refresh}) {
    return AuthTokensModel(
      access: access ?? this.access,
      refresh: refresh ?? this.refresh,
    );
  }

  @override
  String toString() {
    return 'AuthTokensModel('
        'access: $access, '
        'refresh: $refresh'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is AuthTokensModel &&
        other.access == access &&
        other.refresh == refresh;
  }

  @override
  int get hashCode {
    return Object.hash(access, refresh);
  }
}
