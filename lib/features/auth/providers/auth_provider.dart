import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/token_storage.dart';
import '../../profile/providers/profile_provider.dart';
import '../data/auth_repository.dart';
import '../models/user_model.dart';

enum AuthStatus {
  initial,
  loading,
  unauthenticated,
  needsVerification,
  needsProfile,
  authenticated,
}

class AuthState {
  const AuthState({required this.status, this.user, this.message});

  const AuthState.initial()
    : status = AuthStatus.initial,
      user = null,
      message = null;

  final AuthStatus status;
  final UserModel? user;
  final String? message;

  AuthState copyWith({
    AuthStatus? status,
    UserModel? user,
    String? message,
    bool clearUser = false,
    bool clearMessage = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: clearUser ? null : user ?? this.user,
      message: clearMessage ? null : message ?? this.message,
    );
  }

  @override
  String toString() {
    return 'AuthState('
        'status: $status, '
        'user: $user, '
        'message: $message'
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
        other.message == message;
  }

  @override
  int get hashCode {
    return Object.hash(status, user, message);
  }
}

class AuthNotifier extends Notifier<AuthState> {
  late final AuthRepository _authRepository;
  late final TokenStorage _tokenStorage;

  @override
  AuthState build() {
    _authRepository = ref.read(authRepositoryProvider);

    _tokenStorage = ref.read(tokenStorageProvider);

    return const AuthState.initial();
  }

  Future<void> checkAuth() async {
    state = state.copyWith(status: AuthStatus.loading, clearMessage: true);

    final accessToken = await _tokenStorage.getAccessToken();

    final refreshToken = await _tokenStorage.getRefreshToken();

    if (accessToken == null ||
        accessToken.isEmpty ||
        refreshToken == null ||
        refreshToken.isEmpty) {
      ref.read(profileProvider.notifier).clearProfile();

      state = const AuthState(status: AuthStatus.unauthenticated);

      return;
    }

    try {
      final response = await ref.read(profileProvider.notifier).loadProfile();

      if (response.profile == null) {
        state = AuthState(status: AuthStatus.needsProfile, user: response.user);

        return;
      }

      state = AuthState(status: AuthStatus.authenticated, user: response.user);
    } catch (_) {
      await _tokenStorage.clearTokens();

      ref.read(profileProvider.notifier).clearProfile();

      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  Future<String?> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, clearMessage: true);

    try {
      final response = await _authRepository.register(
        fullName: fullName,
        email: email,
        password: password,
      );

      ref.read(profileProvider.notifier).clearProfile();

      state = AuthState(
        status: AuthStatus.needsVerification,
        user: response.user,
        message: response.message,
      );

      return response.message;
    } catch (_) {
      state = const AuthState(status: AuthStatus.unauthenticated);

      rethrow;
    }
  }

  Future<void> verifyEmail({
    required String email,
    required String code,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, clearMessage: true);

    try {
      await _authRepository.verifyEmail(email: email, code: code);

      state = AuthState(
        status: AuthStatus.unauthenticated,
        user: state.user,
        message: 'Email verified successfully.',
      );
    } catch (_) {
      state = state.copyWith(status: AuthStatus.needsVerification);

      rethrow;
    }
  }

  Future<void> resendVerificationEmail({required String email}) async {
    try {
      await _authRepository.resendVerificationEmail(email: email);

      state = state.copyWith(
        message: 'If your email is not verified, a new verification email has been sent.',
        clearMessage: false,
      );
    } catch (_) {
      rethrow;
    }
  }

  void markProfileCompleted() {
    if (state.user == null) {
      return;
    }

    state = AuthState(status: AuthStatus.authenticated, user: state.user);
  }

  Future<void> login({required String email, required String password}) async {
    state = state.copyWith(status: AuthStatus.loading, clearMessage: true);

    try {
      await _authRepository.login(email: email, password: password);

      final response = await ref.read(profileProvider.notifier).loadProfile();

      if (response.profile == null) {
        state = AuthState(status: AuthStatus.needsProfile, user: response.user);

        return;
      }

      state = AuthState(status: AuthStatus.authenticated, user: response.user);
    } catch (_) {
      await _tokenStorage.clearTokens();

      ref.read(profileProvider.notifier).clearProfile();

      state = const AuthState(status: AuthStatus.unauthenticated);

      rethrow;
    }
  }

  Future<void> forgotPassword({required String email}) async {
    try {
      await _authRepository.forgotPassword(email: email);
    } catch (_) {
      rethrow;
    }
  }

  Future<String> verifyPasswordReset({
    required String email,
    required String code,
  }) async {
    try {
      return await _authRepository.verifyPasswordReset(
        email: email,
        code: code,
      );
    } catch (_) {
      rethrow;
    }
  }

  Future<void> resetPassword({
    required String resetToken,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      await _authRepository.resetPassword(
        resetToken: resetToken,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );
    } catch (_) {
      rethrow;
    }
  }

  Future<void> logout() async {
    await _authRepository.logout();

    ref.read(profileProvider.notifier).clearProfile();

    state = const AuthState(status: AuthStatus.unauthenticated);
  }
}

final tokenStorageProvider = Provider<TokenStorage>((ref) {
  return TokenStorage();
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(tokenStorage: ref.read(tokenStorageProvider));
});

final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);
