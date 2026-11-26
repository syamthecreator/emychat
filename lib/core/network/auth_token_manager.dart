import 'package:shared_preferences/shared_preferences.dart';

class AuthTokenManager {
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userIdKey = 'current_user_id';
  static const String _userEmailKey = 'current_user_email';
  static const String _userNameKey = 'current_user_name';

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    String? userId,
    String? email,
    String? name,
  }) async {
    final preferences = await SharedPreferences.getInstance();

    await preferences.setString(_accessTokenKey, accessToken);
    await preferences.setString(_refreshTokenKey, refreshToken);
    if (userId != null && userId.isNotEmpty) {
      await preferences.setString(_userIdKey, userId);
    }
    if (email != null && email.isNotEmpty) {
      await preferences.setString(_userEmailKey, email);
    }
    if (name != null && name.isNotEmpty) {
      await preferences.setString(_userNameKey, name);
    }
  }

  Future<String?> getAccessToken() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString(_accessTokenKey);
  }

  Future<String?> getRefreshToken() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString(_refreshTokenKey);
  }

  Future<String?> getUserId() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString(_userIdKey);
  }

  Future<String?> getUserEmail() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString(_userEmailKey);
  }

  Future<String?> getUserName() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString(_userNameKey);
  }

  Future<bool> hasAccessToken() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  Future<bool> hasValidSession() async {
    final token = await getAccessToken();
    if (token != null && token.isNotEmpty) return true;
    final refresh = await getRefreshToken();
    return refresh != null && refresh.isNotEmpty;
  }

  Future<void> clearTokens() async {
    final preferences = await SharedPreferences.getInstance();

    await preferences.remove(_accessTokenKey);
    await preferences.remove(_refreshTokenKey);
    await preferences.remove(_userIdKey);
    await preferences.remove(_userEmailKey);
    await preferences.remove(_userNameKey);
  }
}
