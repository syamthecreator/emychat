import '../../../core/network/auth_token_manager.dart';

class SplashService {
  SplashService({AuthTokenManager? tokenManager})
      : _tokenManager = tokenManager ?? AuthTokenManager();

  final AuthTokenManager _tokenManager;

  Future<bool> hasValidSession() => _tokenManager.hasValidSession();
}
