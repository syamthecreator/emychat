import 'dart:async';
import 'package:flutter/material.dart';
import '../models/phone_demo_model.dart';

class PhoneDemoProvider extends ChangeNotifier {
  PhoneDemoProvider({
    this.platform = PhoneDemoPlatform.neutral,
    this.autoPlay = true,
  }) {
    if (autoPlay) {
      startConversationLoop();
    }
  }

  PhoneDemoPlatform platform;
  final bool autoPlay;

  int _currentStep = 0;
  bool _isTyping = false;
  Timer? _sequenceTimer;
  Timer? _loopTimer;
  final ScrollController scrollController = ScrollController();

  int get currentStep => _currentStep;
  bool get isTyping => _isTyping;

  void scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutQuad,
        );
      }
    });
  }

  void restartConversation() {
    _sequenceTimer?.cancel();
    _loopTimer?.cancel();
    _currentStep = 0;
    _isTyping = false;
    notifyListeners();
    startConversationLoop();
  }

  void startConversationLoop() {
    _sequenceTimer?.cancel();
    _loopTimer?.cancel();

    // T=0.5s: Customer sends message 1
    _sequenceTimer = Timer(const Duration(milliseconds: 500), () {
      _currentStep = 1;
      _isTyping = false;
      notifyListeners();
      scrollToBottom();

      // T=1.5s: AI starts typing
      _sequenceTimer = Timer(const Duration(milliseconds: 1000), () {
        _isTyping = true;
        notifyListeners();
        scrollToBottom();

        // T=2.7s: AI sends message 1
        _sequenceTimer = Timer(const Duration(milliseconds: 1200), () {
          _currentStep = 2;
          _isTyping = false;
          notifyListeners();
          scrollToBottom();

          // T=4.2s: Customer sends reply
          _sequenceTimer = Timer(const Duration(milliseconds: 1500), () {
            _currentStep = 3;
            _isTyping = false;
            notifyListeners();
            scrollToBottom();

            // T=5.4s: AI starts typing reply 2
            _sequenceTimer = Timer(const Duration(milliseconds: 1000), () {
              _isTyping = true;
              notifyListeners();
              scrollToBottom();

              // T=6.6s: AI sends message 2
              _sequenceTimer = Timer(const Duration(milliseconds: 1200), () {
                _currentStep = 4;
                _isTyping = false;
                notifyListeners();
                scrollToBottom();

                // T=11s: Loop restarts
                _loopTimer = Timer(const Duration(milliseconds: 4000), () {
                  _currentStep = 0;
                  _isTyping = false;
                  notifyListeners();
                  startConversationLoop();
                });
              });
            });
          });
        });
      });
    });
  }

  void onQuickReplyTap(String selection) {
    if (_currentStep == 2) {
      _sequenceTimer?.cancel();
      _currentStep = 3;
      _isTyping = true;
      notifyListeners();
      scrollToBottom();

      _sequenceTimer = Timer(const Duration(milliseconds: 1200), () {
        _currentStep = 4;
        _isTyping = false;
        notifyListeners();
        scrollToBottom();
      });
    }
  }

  void updatePlatform(PhoneDemoPlatform newPlatform) {
    if (platform != newPlatform) {
      platform = newPlatform;
      restartConversation();
    }
  }

  @override
  void dispose() {
    _sequenceTimer?.cancel();
    _loopTimer?.cancel();
    scrollController.dispose();
    super.dispose();
  }
}
