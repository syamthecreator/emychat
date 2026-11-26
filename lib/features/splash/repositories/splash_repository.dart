import '../../../core/network/auth_token_manager.dart';
import '../services/splash_service.dart';

class SplashRepository {
  SplashRepository({
    SplashService? splashService,
    AuthTokenManager? tokenManager,
  }) : _splashService = splashService ??
            SplashService(tokenManager: tokenManager);

  final SplashService _splashService;

  Future<bool> checkSession() => _splashService.hasValidSession();
}
