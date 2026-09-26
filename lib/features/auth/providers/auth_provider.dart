import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pulze_plus/features/auth/models/auth_state.dart';

import '../../../core/network/network_providers.dart';
import '../../../core/network/token_storage.dart';
import '../../profile/providers/profile_provider.dart';
import '../data/auth_repository.dart';

class AuthNotifier extends Notifier<AuthState> {
  late final AuthRepository _authRepository;
  late final TokenStorage _tokenStorage;

  @override
  AuthState build() {
    _authRepository = ref.read(authRepositoryProvider);
    _tokenStorage = ref.read(tokenStorageProvider);

    ref.listen<int>(sessionExpirySignalProvider, (previous, next) {
      if (previous == next) {
        return;
      }

      handleSessionExpired();
    });

    return const AuthState.initial();
  }

  // ===========================================================================
  // Session expired
  // ===========================================================================

  Future<void> handleSessionExpired() async {
    await _tokenStorage.clearTokens();

    ref.read(profileProvider.notifier).clearProfile();

    state = const AuthState(
      status: AuthStatus.unauthenticated,
      message: 'Your session has expired. Please log in again.',
      messageType: AuthMessageType.warning,
    );
  }

  // ===========================================================================
  // Check auth
  // ===========================================================================

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

  // ===========================================================================
  // Register
  // ===========================================================================

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
        messageType: AuthMessageType.success,
      );

      return response.message;
    } catch (_) {
      state = const AuthState(status: AuthStatus.unauthenticated);

      rethrow;
    }
  }

  // ===========================================================================
  // Email verification
  // ===========================================================================

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
        message: 'Email verified successfully. You can now log in.',
        messageType: AuthMessageType.success,
      );
    } catch (_) {
      state = state.copyWith(status: AuthStatus.needsVerification);

      rethrow;
    }
  }

  // ===========================================================================
  // Resend verification email
  // ===========================================================================

  Future<void> resendVerificationEmail({required String email}) async {
    try {
      await _authRepository.resendVerificationEmail(email: email);

      state = state.copyWith(
        message:
            'Verification email sent successfully. Please check your inbox.',
        messageType: AuthMessageType.success,
      );
    } catch (_) {
      rethrow;
    }
  }

  // ===========================================================================
  // Profile
  // ===========================================================================

  void markProfileCompleted() {
    if (state.user == null) {
      return;
    }

    state = AuthState(status: AuthStatus.authenticated, user: state.user);
  }

  // ===========================================================================
  // Login
  // ===========================================================================

  Future<void> login({required String email, required String password}) async {
    state = state.copyWith(status: AuthStatus.loading, clearMessage: true);

    try {
      await _authRepository.login(email: email, password: password);

      final response = await ref.read(profileProvider.notifier).loadProfile();

      if (response.profile == null) {
        state = AuthState(
          status: AuthStatus.needsProfile,
          user: response.user,
          message: 'Login successful. Please complete your profile.',
          messageType: AuthMessageType.success,
        );

        return;
      }

      state = AuthState(
        status: AuthStatus.authenticated,
        user: response.user,
        message: 'Login successful. Welcome back!',
        messageType: AuthMessageType.success,
      );
    } catch (_) {
      await _tokenStorage.clearTokens();

      ref.read(profileProvider.notifier).clearProfile();

      state = const AuthState(status: AuthStatus.unauthenticated);

      rethrow;
    }
  }

  // ===========================================================================
  // Forgot password
  // ===========================================================================

  Future<void> forgotPassword({required String email}) async {
    try {
      await _authRepository.forgotPassword(email: email);

      state = state.copyWith(
        message:
            'If an account exists with this email, '
            'a password reset code has been sent.',
        messageType: AuthMessageType.info,
      );
    } catch (_) {
      rethrow;
    }
  }

  // ===========================================================================
  // Verify password reset
  // ===========================================================================

  Future<String> verifyPasswordReset({
    required String email,
    required String code,
  }) async {
    try {
      final resetToken = await _authRepository.verifyPasswordReset(
        email: email,
        code: code,
      );

      state = state.copyWith(
        message: 'Code verified successfully. You can reset your password.',
        messageType: AuthMessageType.success,
      );

      return resetToken;
    } catch (_) {
      rethrow;
    }
  }

  // ===========================================================================
  // Reset password
  // ===========================================================================

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

      state = state.copyWith(
        message:
            'Password reset successfully. '
            'You can now log in with your new password.',
        messageType: AuthMessageType.success,
      );
    } catch (_) {
      rethrow;
    }
  }

  // ===========================================================================
  // Logout
  // ===========================================================================

  Future<void> logout() async {
    await _authRepository.logout();

    ref.read(profileProvider.notifier).clearProfile();

    state = const AuthState(
      status: AuthStatus.unauthenticated,
      message: 'You have been logged out successfully.',
      messageType: AuthMessageType.success,
    );
  }
}

// ============================================================================
// Auth repository provider
// ============================================================================

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    apiService: ref.read(apiServiceProvider),
    tokenStorage: ref.read(tokenStorageProvider),
  );
});

// ============================================================================
// Auth provider
// ============================================================================

final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);
