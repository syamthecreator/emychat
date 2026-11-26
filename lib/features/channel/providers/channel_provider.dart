import 'package:emychat/features/channel/models/whatsapp_channel_model.dart';
import 'package:emychat/features/channel/services/channel_service.dart';
import 'package:flutter/foundation.dart';

class ChannelController extends ChangeNotifier {
  ChannelController({required ChannelApiService channelApiService})
    : _apiService = channelApiService;

  final ChannelApiService _apiService;

  // Channel states
  bool _isLoading = false;
  final bool _isConnecting = false;
  bool _isSyncing = false;
  bool _hasLoadedOnce = false;

  String? _errorMessage;
  String? _successMessage;

  // WhatsApp Accounts (Linked Device Web QR & Pairing Code)
  List<WhatsAppChannelModel> _whatsAppAccounts = [];

  // Channel screen UI states
  int _selectedFilter = 0;

  // Getters
  bool get isLoading => _isLoading;
  bool get isConnecting => _isConnecting;
  bool get isSyncing => _isSyncing;
  bool get hasLoadedOnce => _hasLoadedOnce;

  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  // WhatsApp Getters
  List<WhatsAppChannelModel> get whatsAppAccounts =>
      List.unmodifiable(_whatsAppAccounts);

  bool get isWhatsAppConnected => _whatsAppAccounts.any((c) => c.isConnected);

  WhatsAppChannelModel? get primaryWhatsAppAccount {
    final connected = _whatsAppAccounts.where((c) => c.isConnected);
    if (connected.isNotEmpty) return connected.first;
    return _whatsAppAccounts.isNotEmpty ? _whatsAppAccounts.first : null;
  }

  int get totalConnectedChannels =>
      _whatsAppAccounts.where((c) => c.isConnected).length;

  int get selectedFilter => _selectedFilter;

  // UI actions
  void selectFilter(int index) {
    if (_selectedFilter == index) return;
    _selectedFilter = index;
    notifyListeners();
  }

  // Message handling
  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  void reset() {
    _whatsAppAccounts = [];
    _selectedFilter = 0;
    _isLoading = false;
    _isSyncing = false;
    _hasLoadedOnce = false;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  // Load connected WhatsApp channels
  Future<void> loadChannels({bool force = false}) async {
    if (_isLoading) return;

    if (!force && _hasLoadedOnce) {
      // Silent background refresh if already loaded once
      try {
        _whatsAppAccounts = await _apiService.getWhatsAppChannels();
        notifyListeners();
      } catch (e) {
        debugPrint('ChannelController.loadChannels silent error: $e');
      }
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _whatsAppAccounts = await _apiService.getWhatsAppChannels();
    } catch (e) {
      debugPrint('ChannelController.loadChannels error: $e');
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      _hasLoadedOnce = true;
      notifyListeners();
    }
  }

  // ════════════════════════════════════════════════════════════════════════════
  //  WHATSAPP METHODS (LINKED DEVICE WEB QR CODE & PAIRING CODE)
  // ════════════════════════════════════════════════════════════════════════════

  /// Initialize a new WhatsApp connection session (returns QR code or Pairing code).
  Future<Map<String, dynamic>> connectWhatsApp({
    String? channelId,
    String? phoneNumber,
  }) async {
    try {
      return await _apiService.connectWhatsApp(
        channelId: channelId,
        phoneNumber: phoneNumber,
      );
    } catch (e) {
      debugPrint('ChannelController.connectWhatsApp error: $e');
      rethrow;
    }
  }

  /// Poll status for WhatsApp session.
  Future<Map<String, dynamic>> getWhatsAppStatus(String channelId) async {
    try {
      return await _apiService.getWhatsAppStatus(channelId);
    } catch (e) {
      debugPrint('ChannelController.getWhatsAppStatus error: $e');
      rethrow;
    }
  }

  /// Disconnect a WhatsApp channel.
  Future<bool> disconnectWhatsApp(String channelId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _apiService.disconnectWhatsApp(channelId);

      _whatsAppAccounts = _whatsAppAccounts
          .where((account) => account.id != channelId)
          .toList();

      _successMessage = 'WhatsApp channel disconnected successfully';
      return true;
    } catch (e) {
      debugPrint('ChannelController.disconnectWhatsApp error: $e');
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ════════════════════════════════════════════════════════════════════════════
  //  SYNC ALL CHANNELS
  // ════════════════════════════════════════════════════════════════════════════

  Future<void> syncChannels() async {
    _isSyncing = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _whatsAppAccounts = await _apiService.getWhatsAppChannels();
      _successMessage = 'Channels synchronized successfully';
    } catch (e) {
      debugPrint('ChannelController.syncChannels error: $e');
      _errorMessage = 'Synchronization failed: $e';
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }
}
