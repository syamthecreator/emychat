import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/network/auth_token_manager.dart';
import '../../../core/utils/web_helper.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/splash_destination.dart';
import '../repositories/splash_repository.dart';

class SplashProvider extends ChangeNotifier {
  SplashProvider({
    SplashRepository? splashRepository,
    AuthTokenManager? tokenManager,
    required this.authController,
  }) : _splashRepository =
           splashRepository ?? SplashRepository(tokenManager: tokenManager);

  final SplashRepository _splashRepository;
  final AuthController authController;

  String _statusText = 'Initializing workspace...';
  String get statusText => _statusText;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  void updateProgress(double progress) {
    final String newStatus;
    if (progress > 0.8) {
      newStatus = 'Workspace ready';
    } else if (progress > 0.4) {
      newStatus = 'Connecting WhatsApp Engine...';
    } else {
      newStatus = 'Initializing workspace...';
    }

    if (_statusText == newStatus) return;
    _statusText = newStatus;
    notifyListeners();
  }

  bool get isOAuthReturn {
    try {
      final uri = Uri.base;
      final href = uri.toString();

      return uri.queryParameters['tab'] == 'channel' ||
          uri.queryParameters.containsKey('connected') ||
          uri.fragment.contains('channel') ||
          href.contains('tab=channel') ||
          href.contains('connected=true');
    } catch (e) {
      debugPrint('Splash OAuth detection error: $e');
      return false;
    }
  }

  bool handleOAuthPopup() {
    if (!isOAuthReturn) return false;
    return handleOAuthPopupClose();
  }

  Future<SplashDestination> startFlow({required bool isOAuthReturn}) async {
    if (_isInitialized) {
      return SplashDestination.dashboard;
    }

    _isInitialized = true;

    try {
      final hasSession = await _splashRepository.checkSession();

      if (isOAuthReturn && hasSession) {
        await _initializeAuth();
        if (authController.isAuthenticated) {
          return SplashDestination.channel;
        }
      }

      await Future.delayed(const Duration(milliseconds: 2000));

      if (hasSession) {
        await _initializeAuth();
        if (authController.isAuthenticated) {
          return SplashDestination.dashboard;
        }
      }

      return SplashDestination.auth;
    } catch (e, stackTrace) {
      debugPrint('Splash initialization error: $e');
      debugPrintStack(stackTrace: stackTrace);
      return SplashDestination.auth;
    }
  }

  Future<void> _initializeAuth() async {
    if (!authController.isAuthenticated) {
      await authController.initialize();
    }
  }
}

// Backwards compatibility alias
typedef SplashController = SplashProvider;
