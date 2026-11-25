import 'package:emychat/core/network/api_client.dart';
import 'package:emychat/core/network/api_constants.dart';
import 'package:emychat/core/network/auth_token_manager.dart';

class AuthApiService {
  AuthApiService({required this._apiClient, required this._tokenManager});

  final ApiClient _apiClient;
  final AuthTokenManager _tokenManager;

  /// Register a new user account.
  /// Sends an email verification OTP code.
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.post(
      ApiConstants.register,
      body: {
        'name': name.trim(),
        'email': email.trim().toLowerCase(),
        'password': password,
      },
    );

    if (response['success'] != true) {
      throw ApiException(
        message: response['message']?.toString() ?? 'Registration failed',
      );
    }

    final rawData = response['data'];
    if (rawData is Map) {
      final data = Map<String, dynamic>.from(rawData);

      // If tokens returned directly
      final accessToken = data['accessToken'] as String?;
      final refreshToken = data['refreshToken'] as String?;
      if (accessToken != null &&
          accessToken.isNotEmpty &&
          refreshToken != null &&
          refreshToken.isNotEmpty) {
        await _tokenManager.saveTokens(
          accessToken: accessToken,
          refreshToken: refreshToken,
        );
      }

      return data;
    }

    return {
      'requiresVerification': true,
      'email': email.trim().toLowerCase(),
      'message': response['message']?.toString() ?? 'Verification code sent.',
    };
  }

  /// Verify registration email OTP to activate account and acquire session tokens.
  Future<Map<String, dynamic>> verifyEmailOtp({
    required String email,
    required String otp,
  }) async {
    final response = await _apiClient.post(
      ApiConstants.verifyEmailOtp,
      body: {'email': email.trim().toLowerCase(), 'otp': otp.trim()},
    );

    if (response['success'] != true) {
      throw ApiException(
        message:
            response['message']?.toString() ??
            'Invalid or expired verification code.',
      );
    }

    final data = Map<String, dynamic>.from(response['data'] as Map);
    final accessToken = data['accessToken'] as String?;
    final refreshToken = data['refreshToken'] as String?;

    if (accessToken == null ||
        accessToken.isEmpty ||
        refreshToken == null ||
        refreshToken.isEmpty) {
      throw ApiException(
        message: 'Authentication tokens were not received from the server.',
      );
    }

    await _tokenManager.saveTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );

    return data;
  }

  /// Resend registration verification OTP code.
  Future<String> resendVerificationOtp(String email) async {
    final response = await _apiClient.post(
      ApiConstants.resendVerificationOtp,
      body: {'email': email.trim().toLowerCase()},
    );

    if (response['success'] != true) {
      throw ApiException(
        message:
            response['message']?.toString() ??
            'Failed to resend verification code.',
      );
    }

    return response['message']?.toString() ??
        'A new verification code has been sent to your email.';
  }

  /// Login using backend credentials.
  /// Saves access and refresh tokens after successful authentication.
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.post(
      ApiConstants.login,
      body: {'email': email.trim().toLowerCase(), 'password': password},
    );

    if (response['success'] != true) {
      throw ApiException(
        message: response['message']?.toString() ?? 'Login failed',
      );
    }

    final data = Map<String, dynamic>.from(response['data'] as Map);

    final accessToken = data['accessToken'] as String?;
    final refreshToken = data['refreshToken'] as String?;

    if (accessToken == null ||
        accessToken.isEmpty ||
        refreshToken == null ||
        refreshToken.isEmpty) {
      throw ApiException(
        message: 'Authentication tokens were not received from the server.',
      );
    }

    await _tokenManager.saveTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );

    return data;
  }

  /// Check whether an access token is stored locally.
  Future<bool> hasAccessToken() {
    return _tokenManager.hasAccessToken();
  }

  /// Check whether a valid session (access token or refresh token) exists.
  Future<bool> hasValidSession() {
    return _tokenManager.hasValidSession();
  }

  /// Retrieve the authenticated user's profile.
  Future<Map<String, dynamic>> getProfile() async {
    final response = await _apiClient.get(ApiConstants.me, requiresAuth: true);

    if (response['success'] != true) {
      throw ApiException(
        message:
            response['message']?.toString() ??
            'Unable to retrieve user profile',
      );
    }

    final data = response['data'];

    if (data is! Map || data['user'] is! Map) {
      throw ApiException(message: 'Invalid user profile response from server.');
    }

    return Map<String, dynamic>.from(data);
  }

  /// Retrieve the saved refresh token.
  Future<String?> getRefreshToken() {
    return _tokenManager.getRefreshToken();
  }

  /// Clear locally stored authentication tokens.
  Future<void> clearLocalSession() {
    return _tokenManager.clearTokens();
  }

  /// Request a password reset OTP for the given email.
  Future<String> forgotPassword(String email) async {
    final response = await _apiClient.post(
      ApiConstants.forgotPassword,
      body: {'email': email.trim().toLowerCase()},
    );

    if (response['success'] != true) {
      throw ApiException(
        message:
            response['message']?.toString() ??
            'Failed to send verification code.',
      );
    }

    return response['message']?.toString() ??
        'Verification code sent successfully.';
  }

  /// Verify the OTP entered by the user.
  Future<bool> verifyOtp({required String email, required String otp}) async {
    final response = await _apiClient.post(
      ApiConstants.verifyOtp,
      body: {'email': email.trim().toLowerCase(), 'otp': otp.trim()},
    );

    if (response['success'] != true) {
      throw ApiException(
        message:
            response['message']?.toString() ??
            'Invalid or expired verification code.',
      );
    }

    return true;
  }

  /// Reset the password using the verified OTP.
  Future<String> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    final response = await _apiClient.post(
      ApiConstants.resetPassword,
      body: {
        'email': email.trim().toLowerCase(),
        'otp': otp.trim(),
        'password': newPassword,
      },
    );

    if (response['success'] != true) {
      throw ApiException(
        message:
            response['message']?.toString() ??
            'Failed to reset password. Please try again.',
      );
    }

    return response['message']?.toString() ??
        'Password reset successfully! Please sign in.';
  }

  /// Logout from the backend and clear the local session.
  Future<void> logout() async {
    final refreshToken = await _tokenManager.getRefreshToken();

    try {
      if (refreshToken != null && refreshToken.isNotEmpty) {
        await _apiClient.post(
          ApiConstants.logout,
          body: {'refreshToken': refreshToken},
        );
      }
    } finally {
      await clearLocalSession();
    }
  }
}
