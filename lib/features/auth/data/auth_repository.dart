import '../../../core/network/api_endpoints.dart';
import '../../../core/network/api_service.dart';
import '../../../core/network/token_storage.dart';
import '../models/auth_response_model.dart';

class AuthRepository {
  AuthRepository({ApiService? apiService, TokenStorage? tokenStorage})
    : _apiService = apiService ?? ApiService(),
      _tokenStorage = tokenStorage ?? TokenStorage();

  final ApiService _apiService;
  final TokenStorage _tokenStorage;

  Future<AuthResponseModel> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final response = await _apiService.post(
      ApiEndpoints.register,
      data: {'full_name': fullName, 'email': email, 'password': password},
    );

    return AuthResponseModel.fromJson(Map<String, dynamic>.from(response.data));
  }

  Future<void> verifyEmail({
    required String email,
    required String code,
  }) async {
    await _apiService.post(
      ApiEndpoints.verifyEmail,
      data: {'email': email, 'code': code},
    );
  }

  Future<void> resendVerificationEmail({required String email}) async {
    await _apiService.post(
      ApiEndpoints.resendVerification,
      data: {'email': email},
    );
  }

  Future<void> forgotPassword({required String email}) async {
    await _apiService.post(ApiEndpoints.forgotPassword, data: {'email': email});
  }

  Future<String> verifyPasswordReset({
    required String email,
    required String code,
  }) async {
    final response = await _apiService.post(
      ApiEndpoints.verifyPasswordReset,
      data: {'email': email, 'code': code},
    );

    return response.data['reset_token'] as String;
  }

  Future<void> resetPassword({
    required String resetToken,
    required String newPassword,
    required String confirmPassword,
  }) async {
    await _apiService.post(
      ApiEndpoints.resetPassword,
      data: {
        'reset_token': resetToken,
        'new_password': newPassword,
        'confirm_password': confirmPassword,
      },
    );
  }

  Future<AuthResponseModel> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiService.post(
      ApiEndpoints.login,
      data: {'email': email, 'password': password},
    );

    final data = Map<String, dynamic>.from(response.data);

    final authResponse = AuthResponseModel.fromJson(data);

    final tokens = authResponse.tokens;

    if (tokens == null) {
      throw const FormatException(
        'Login response does not contain '
        'authentication tokens.',
      );
    }

    await _tokenStorage.saveTokens(
      accessToken: tokens.access,
      refreshToken: tokens.refresh,
    );

    return authResponse;
  }

  Future<void> logout() async {
    await _tokenStorage.clearTokens();
  }
}
