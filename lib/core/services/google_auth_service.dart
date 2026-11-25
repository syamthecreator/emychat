import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../network/api_client.dart';
import '../network/api_constants.dart';
import '../utils/web_helper.dart';
import 'auth_api_service.dart';

class GoogleAuthService {
  GoogleAuthService._();
  static final GoogleAuthService instance = GoogleAuthService._();

  StreamSubscription<dynamic>? _messageSubscription;
  Completer<Map<String, dynamic>?>? _oauthCompleter;
  WebPopupHandle? _popupHandle;

  /// Initiate real Google OAuth 2.0 flow.
  /// Opens real Google accounts sign in window (accounts.google.com).
  Future<Map<String, dynamic>?> authenticateWithGoogle({
    required AuthApiService authApiService,
    bool? isPreConfigured,
  }) async {
    // 1. Check if backend Google OAuth is configured
    final bool isConfigured = isPreConfigured ??
        ((await authApiService.getGoogleConfig())['configured'] == true);

    if (!isConfigured) {
      // Backend doesn't have GOOGLE_CLIENT_ID configured yet
      return {'needsConfig': true};
    }

    // 2. On Web / Desktop: open real Google OAuth popup
    if (isWebPlatform) {
      return await _startWebOAuthPopup(authApiService);
    }

    // 3. On Mobile (Android / iOS): use GoogleSignIn SDK
    try {
      if (GoogleSignIn.instance.supportsAuthenticate()) {
        final account = await GoogleSignIn.instance.authenticate();
        final idToken = account.authentication.idToken;

        return await authApiService.googleAuth(
          idToken: idToken,
          email: account.email,
          name: account.displayName,
        );
      }
    } catch (e) {
      debugPrint('Native Google Sign-In error: $e');
    }

    // Fallback to web popup/browser redirect
    return await _startWebOAuthPopup(authApiService);
  }

  Future<Map<String, dynamic>?> _startWebOAuthPopup(
    AuthApiService authApiService,
  ) async {
    _oauthCompleter?.complete(null);
    _oauthCompleter = Completer<Map<String, dynamic>?>();

    final googleLoginUrl = '${ApiConstants.baseUrl}${ApiConstants.googleLogin}';

    // Start listening for popup message
    _messageSubscription?.cancel();
    _messageSubscription = listenWindowMessage((dynamic data) async {
      try {
        if (data is Map && data['type'] == 'GOOGLE_AUTH_SUCCESS') {
          final payload = Map<String, dynamic>.from(data['data'] as Map);
          await authApiService.saveGoogleSession(payload);
          _popupHandle?.close();
          if (!_oauthCompleter!.isCompleted) {
            _oauthCompleter!.complete(payload);
          }
        }
      } catch (e) {
        debugPrint('OAuth message processing error: $e');
        if (!_oauthCompleter!.isCompleted) {
          _oauthCompleter!.completeError(
            ApiException(message: 'Failed to process Google sign in response.'),
          );
        }
      }
    });

    _popupHandle = openPopup(
      googleLoginUrl,
      name: 'google_signin_popup',
      features:
          'width=600,height=750,left=300,top=100,resizable=yes,scrollbars=yes',
    );

    if (_popupHandle == null) {
      // If popup was blocked by browser, open in current tab or alert
      openBrowserUrl(googleLoginUrl, target: '_self');
      return null;
    }

    // Timeout after 3 minutes if user closes popup without logging in
    return await _oauthCompleter!.future.timeout(
      const Duration(minutes: 3),
      onTimeout: () {
        _popupHandle?.close();
        _messageSubscription?.cancel();
        return null;
      },
    );
  }

  void dispose() {
    _messageSubscription?.cancel();
    _popupHandle?.close();
  }
}
