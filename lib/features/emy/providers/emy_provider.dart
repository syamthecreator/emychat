import 'package:flutter/foundation.dart';

import '../models/emy_models.dart';
import '../services/emy_api_service.dart';

class EmyProvider extends ChangeNotifier {
  EmyProvider({required this.emyApiService});

  final EmyApiService emyApiService;

  static const String welcomeText =
      "Hi! I'm **Emy**, your EmyChat platform & company knowledge assistant.\n\n"
      'Ask me how to use Dashboard, Inbox, WhatsApp Channels, Automations, or Settings — '
      'or upload your company documents in **Settings** so I can answer company-specific questions privately for your account.';

  bool _isOpen = false;
  bool _isSending = false;
  bool _isLoadingHistory = false;
  bool _isLoadingDocs = false;
  bool _isUploadingDoc = false;
  bool _hasLoadedHistoryForAuth = false;
  bool _wasAuthenticated = false;
  String? _docError;
  String? _docSuccess;

  final List<EmyMessage> _messages = [];
  List<EmyDocument> _documents = [];

  bool get isOpen => _isOpen;
  bool get isSending => _isSending;
  bool get isLoadingHistory => _isLoadingHistory;
  bool get isLoadingDocs => _isLoadingDocs;
  bool get isUploadingDoc => _isUploadingDoc;
  String? get docError => _docError;
  String? get docSuccess => _docSuccess;
  List<EmyDocument> get documents => List.unmodifiable(_documents);

  List<EmyMessage> get messages {
    if (_messages.isEmpty) {
      return [
        EmyMessage(
          id: 'welcome',
          role: 'assistant',
          content: welcomeText,
          createdAt: DateTime.now(),
        ),
      ];
    }
    return List.unmodifiable(_messages);
  }

  bool get hasUserMessages => _messages.any((m) => m.isUser);

  void toggleOpen() {
    _isOpen = !_isOpen;
    notifyListeners();
  }

  void openChat() {
    if (!_isOpen) {
      _isOpen = true;
      notifyListeners();
    }
  }

  void closeChat() {
    if (_isOpen) {
      _isOpen = false;
      notifyListeners();
    }
  }

  void syncAuthState(bool isAuthenticated) {
    if (isAuthenticated && !_wasAuthenticated) {
      _wasAuthenticated = true;
      _hasLoadedHistoryForAuth = false;
      loadHistory();
      loadDocuments();
    } else if (!isAuthenticated && _wasAuthenticated) {
      _wasAuthenticated = false;
      _hasLoadedHistoryForAuth = false;
      _messages.clear();
      _documents = [];
      notifyListeners();
    }
  }

  Future<void> loadHistory() async {
    if (!_wasAuthenticated || _hasLoadedHistoryForAuth || _isLoadingHistory) {
      return;
    }
    _isLoadingHistory = true;
    notifyListeners();

    try {
      final history = await emyApiService.getHistory();
      _messages
        ..clear()
        ..addAll(history);
      _hasLoadedHistoryForAuth = true;
    } catch (_) {
      // Keep welcome state if history fails to load
    } finally {
      _isLoadingHistory = false;
      notifyListeners();
    }
  }

  Future<void> sendMessage(
    String rawText, {
    required bool isAuthenticated,
  }) async {
    final text = rawText.trim();
    if (text.isEmpty || _isSending) return;

    final userMessage = EmyMessage(
      id: 'local_user_${DateTime.now().microsecondsSinceEpoch}',
      role: 'user',
      content: text,
      createdAt: DateTime.now(),
    );

    final guestContext = isAuthenticated
        ? const <EmyMessage>[]
        : List<EmyMessage>.from(_messages);

    _messages.add(userMessage);
    _isSending = true;
    notifyListeners();

    try {
      final reply = await emyApiService.sendMessage(
        message: text,
        isAuthenticated: isAuthenticated,
        guestHistory: guestContext,
      );
      _messages.add(reply);
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      _messages.add(
        EmyMessage(
          id: 'err_${DateTime.now().microsecondsSinceEpoch}',
          role: 'assistant',
          content: msg.isNotEmpty
              ? msg
              : 'Sorry, I encountered a connection issue. Please try again.',
          createdAt: DateTime.now(),
          isError: true,
        ),
      );
    } finally {
      _isSending = false;
      notifyListeners();
    }
  }

  Future<void> clearChat({required bool isAuthenticated}) async {
    _messages.clear();
    notifyListeners();

    if (isAuthenticated) {
      try {
        await emyApiService.clearHistory();
      } catch (_) {}
    }
  }

  Future<void> loadDocuments() async {
    if (!_wasAuthenticated) return;
    _isLoadingDocs = true;
    _docError = null;
    notifyListeners();

    try {
      _documents = await emyApiService.listDocuments();
    } catch (e) {
      _docError = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoadingDocs = false;
      notifyListeners();
    }
  }

  Future<bool> uploadDocument({
    required String fileName,
    required List<int> bytes,
  }) async {
    _isUploadingDoc = true;
    _docError = null;
    _docSuccess = null;
    notifyListeners();

    try {
      final doc = await emyApiService.uploadDocument(
        fileName: fileName,
        bytes: bytes,
      );
      _documents = [doc, ..._documents];
      _docSuccess = '"${doc.fileName}" uploaded (${doc.chunkCount} knowledge chunks).';
      return true;
    } catch (e) {
      _docError = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isUploadingDoc = false;
      notifyListeners();
    }
  }

  Future<void> deleteDocument(String documentId) async {
    _docError = null;
    _docSuccess = null;
    try {
      await emyApiService.deleteDocument(documentId);
      _documents = _documents.where((d) => d.id != documentId).toList();
      _docSuccess = 'Document removed from your knowledge base.';
    } catch (e) {
      _docError = e.toString().replaceFirst('Exception: ', '');
    }
    notifyListeners();
  }

  void clearDocNotices() {
    _docError = null;
    _docSuccess = null;
    notifyListeners();
  }
}
