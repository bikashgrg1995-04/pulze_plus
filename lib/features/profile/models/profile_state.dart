import 'package:pulze_plus/features/profile/models/profile_model.dart';

enum ProfileStatus {
  initial,
  loading,
  loaded,
  error,
}

class ProfileState {
  const ProfileState({
    required this.status,
    this.profile,
    this.message,
  });

  const ProfileState.initial()
      : status = ProfileStatus.initial,
        profile = null,
        message = null;

  final ProfileStatus status;
  final ProfileModel? profile;
  final String? message;

  ProfileState copyWith({
    ProfileStatus? status,
    ProfileModel? profile,
    String? message,
    bool clearProfile = false,
    bool clearMessage = false,
  }) {
    return ProfileState(
      status: status ?? this.status,
      profile: clearProfile
          ? null
          : profile ?? this.profile,
      message: clearMessage
          ? null
          : message ?? this.message,
    );
  }

  @override
  String toString() {
    return 'ProfileState('
        'status: $status, '
        'profile: $profile, '
        'message: $message'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is ProfileState &&
        other.status == status &&
        other.profile == profile &&
        other.message == message;
  }

  @override
  int get hashCode {
    return Object.hash(
      status,
      profile,
      message,
    );
  }
}