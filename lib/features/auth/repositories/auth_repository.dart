import '../../../core/services/auth_api_service.dart';

class AuthRepository {
  AuthRepository({required this.apiService});

  final AuthApiService apiService;

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) =>
      apiService.login(email: email, password: password);

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) =>
      apiService.register(name: name, email: email, password: password);

  Future<String> forgotPassword(String email) =>
      apiService.forgotPassword(email);

  Future<bool> verifyOtp({
    required String email,
    required String otp,
  }) =>
      apiService.verifyOtp(email: email, otp: otp);

  Future<String> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) =>
      apiService.resetPassword(
        email: email,
        otp: otp,
        newPassword: newPassword,
      );

  Future<Map<String, dynamic>> verifyEmailOtp({
    required String email,
    required String otp,
  }) =>
      apiService.verifyEmailOtp(email: email, otp: otp);

  Future<String> resendVerificationOtp(String email) =>
      apiService.resendVerificationOtp(email);

  Future<Map<String, dynamic>> getProfile() => apiService.getProfile();

  Future<void> logout() => apiService.clearLocalSession();

  Future<bool> hasValidSession() => apiService.hasValidSession();
}
