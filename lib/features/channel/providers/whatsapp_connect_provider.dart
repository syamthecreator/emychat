import 'dart:async';
import 'dart:convert';

import 'package:emychat/features/channel/models/whatsapp_channel_model.dart';
import 'package:emychat/features/channel/providers/channel_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class WhatsAppConnectProvider extends ChangeNotifier {
  WhatsAppConnectProvider({
    required this.channelController,
    String? initialChannelId,
    String? initialPhoneNumber,
    this.onConnectedSuccess,
  }) : _channelId = initialChannelId {
    if (initialPhoneNumber != null && initialPhoneNumber.isNotEmpty) {
      phoneController.text = initialPhoneNumber;
    }
    startSession();
  }

  final ChannelController channelController;
  final void Function(WhatsAppChannelModel? channel)? onConnectedSuccess;

  int _selectedTab = 0; // 0 = QR Code, 1 = Phone Pairing Code
  bool _isLoading = true;
  String? _errorMessage;
  String? _channelId;
  String? _status;
  String? _qrCodeBase64;
  String? _pairingCode;
  Timer? _pollTimer;
  WhatsAppChannelModel? _connectedChannel;
  bool _isRequestingPairing = false;
  bool _isDisposed = false;

  final TextEditingController phoneController = TextEditingController();

  int get selectedTab => _selectedTab;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get channelId => _channelId;
  String? get status => _status;
  String? get qrCodeBase64 => _qrCodeBase64;
  String? get pairingCode => _pairingCode;
  WhatsAppChannelModel? get connectedChannel => _connectedChannel;
  bool get isRequestingPairing => _isRequestingPairing;
  bool get isConnected => _status == 'CONNECTED';

  void selectTab(int index) {
    if (_selectedTab == index) return;
    _selectedTab = index;
    notifyListeners();
  }

  Future<void> startSession({String? phoneNumber}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await channelController.connectWhatsApp(
        channelId: _channelId,
        phoneNumber: phoneNumber,
      );

      if (_isDisposed) return;

      _isLoading = false;
      _channelId = res['channelId'] as String?;
      _status = res['status'] as String? ?? 'SCAN_QR';
      _qrCodeBase64 = res['qrCodeBase64'] as String?;
      _pairingCode = res['pairingCode'] as String?;
      notifyListeners();

      _startPolling();
    } catch (e) {
      if (_isDisposed) return;
      _isLoading = false;
      _errorMessage = e.toString().replaceAll('ApiException: ', '');
      notifyListeners();
    }
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 2), (timer) async {
      if (_channelId == null || _isDisposed) {
        timer.cancel();
        return;
      }

      try {
        final res = await channelController.getWhatsAppStatus(_channelId!);

        if (_isDisposed) {
          timer.cancel();
          return;
        }

        final status = res['status'] as String?;
        final qr = res['qrCodeBase64'] as String?;
        final pair = res['pairingCode'] as String?;

        bool changed = false;

        if (qr != null && qr != _qrCodeBase64) {
          _qrCodeBase64 = qr;
          changed = true;
        }
        if (pair != null && _pairingCode == null) {
          _pairingCode = pair;
          changed = true;
        }

        if (status == 'CONNECTED') {
          timer.cancel();
          _status = 'CONNECTED';
          if (res['channel'] != null) {
            _connectedChannel = WhatsAppChannelModel.fromJson(
              Map<String, dynamic>.from(res['channel'] as Map),
            );
          }
          notifyListeners();

          // Refresh channel state in background
          channelController.loadChannels();
          onConnectedSuccess?.call(_connectedChannel);
          return;
        }

        if (changed) {
          notifyListeners();
        }
      } catch (_) {}
    });
  }

  Uint8List? decodeQrBytes() {
    if (_qrCodeBase64 == null || _qrCodeBase64!.isEmpty) return null;
    try {
      final commaIdx = _qrCodeBase64!.indexOf(',');
      final cleanBase64 = commaIdx != -1
          ? _qrCodeBase64!.substring(commaIdx + 1)
          : _qrCodeBase64!;
      return base64Decode(cleanBase64.replaceAll(RegExp(r'\s+'), ''));
    } catch (e) {
      debugPrint('QR decode error: $e');
      return null;
    }
  }

  Future<void> requestPairingCode({
    bool forceNew = false,
    required void Function(String error) onError,
  }) async {
    final phone = phoneController.text.trim();
    if (phone.isEmpty) {
      onError('Please enter your phone number with country code');
      return;
    }

    if (forceNew) {
      _pairingCode = null;
      notifyListeners();
    }

    _isRequestingPairing = true;
    notifyListeners();

    await startSession(phoneNumber: phone);

    if (!_isDisposed) {
      _isRequestingPairing = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _pollTimer?.cancel();
    phoneController.dispose();
    super.dispose();
  }
}
