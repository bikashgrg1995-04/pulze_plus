import 'package:pulze_plus/features/auth/models/user_model.dart';

enum AuthStatus {
  initial,
  loading,
  unauthenticated,
  needsVerification,
  needsProfile,
  authenticated,
}

enum AuthMessageType { success, info, warning }

class AuthState {
  const AuthState({
    required this.status,
    this.user,
    this.message,
    this.messageType,
  });

  const AuthState.initial()
    : status = AuthStatus.initial,
      user = null,
      message = null,
      messageType = null;

  final AuthStatus status;
  final UserModel? user;
  final String? message;
  final AuthMessageType? messageType;

  AuthState copyWith({
    AuthStatus? status,
    UserModel? user,
    String? message,
    AuthMessageType? messageType,
    bool clearUser = false,
    bool clearMessage = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: clearUser ? null : user ?? this.user,
      message: clearMessage ? null : message ?? this.message,
      messageType: clearMessage ? null : messageType ?? this.messageType,
    );
  }

  @override
  String toString() {
    return 'AuthState('
        'status: $status, '
        'user: $user, '
        'message: $message, '
        'messageType: $messageType'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is AuthState &&
        other.status == status &&
        other.user == user &&
        other.message == message &&
        other.messageType == messageType;
  }

  @override
  int get hashCode {
    return Object.hash(status, user, message, messageType);
  }
}

