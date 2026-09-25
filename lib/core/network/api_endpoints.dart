class ApiEndpoints {
  ApiEndpoints._();

  static const baseUrl = 'http://192.168.1.69:8000/api/v1/';

  // Authentication
  static const register = 'auth/register/';
  static const login = 'auth/login/';
  static const me = 'auth/me/';
  static const tokenRefresh = 'auth/token/refresh/';

  // Email verification
  static const verifyEmail = 'auth/verify-email/';
  static const resendVerification = 'auth/resend-verification/';

  //reset-passsword
  static const forgotPassword = 'auth/forgot-password/';
  static const verifyPasswordReset = 'auth/verify-password-reset/';
  static const resetPassword = 'auth/reset-password/';

  // Profile
  static const profile = 'auth/profile/';
  static const profileAvatar = 'auth/profile/avatar/';
  static const profileDonor = 'auth/profile/donor/';
}
