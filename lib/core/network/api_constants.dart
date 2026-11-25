import 'package:flutter/foundation.dart';

abstract final class ApiConstants {
  ApiConstants._();

  static String get baseUrl {
    const fromEnv = String.fromEnvironment('API_BASE_URL');
    if (fromEnv.isNotEmpty) return fromEnv;
    if (kIsWeb) {
      try {
        final host = Uri.base.host;
        if (host == 'localhost' || host == '127.0.0.1') {
          return 'http://localhost:5001/api/v1';
        }
      } catch (_) {}
    }
    return 'https://emychat-backend.onrender.com/api/v1';
  }

  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 60);

  static const String auth = '/auth';
  static const String register = '$auth/register';
  static const String verifyEmailOtp = '$auth/verify-email-otp';
  static const String resendVerificationOtp = '$auth/resend-verification-otp';
  static const String login = '$auth/login';
  static const String refresh = '$auth/refresh';
  static const String logout = '$auth/logout';
  static const String me = '$auth/me';
  static const String forgotPassword = '$auth/forgot-password';
  static const String verifyOtp = '$auth/verify-otp';
  static const String resetPassword = '$auth/reset-password';

  static const String plans = '/plans';
  static const String workspaces = '/workspaces';
  static const String myWorkspaces = '$workspaces/me';
  static const String subscriptions = '/subscriptions';
  static const String checkout = '$subscriptions/checkout';
  static const String verifyPayment = '$subscriptions/verify';
  static const String currentSubscription = '$subscriptions/current';
}
