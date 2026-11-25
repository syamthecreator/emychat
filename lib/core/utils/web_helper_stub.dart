import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

bool get isWebPlatform => false;

String get currentHref => Uri.base.toString();

void openBrowserUrl(String url, {String target = '_blank'}) {
  try {
    launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  } catch (e) {
    debugPrint('openBrowserUrl stub error: $e');
  }
}

class WebPopupHandle {
  WebPopupHandle();

  void close() {}

  void setLocation(String url) {
    openBrowserUrl(url);
  }
}

WebPopupHandle? openPopup(
  String url, {
  String name = 'emychat_popup',
  String features = 'width=650,height=820,left=250,top=80,resizable=yes,scrollbars=yes',
}) {
  if (url.isNotEmpty && url != 'about:blank') {
    openBrowserUrl(url);
  }
  return WebPopupHandle();
}

StreamSubscription<dynamic>? listenWindowMessage(void Function(dynamic data) onMessage) {
  return null;
}

bool handleOAuthPopupClose({String message = 'EMYCHAT_CONNECTED'}) {
  return false;
}

void pickMediaFile({
  String? type,
  required void Function(String fileBase64, String fileName, String mimeType) onLoaded,
}) {
  debugPrint('pickMediaFile is not supported in non-web stub');
}

class PlatformAudioPlayer {
  void play(String url, {required VoidCallback onEnded, required VoidCallback onError}) {}
  void pause() {}
  void dispose() {}
}

PlatformAudioPlayer createAudioPlayer() => PlatformAudioPlayer();
