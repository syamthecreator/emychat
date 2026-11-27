import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../core/network/api_client.dart';
import '../../../core/network/api_constants.dart';
import '../../../core/network/auth_token_manager.dart';
import '../models/emy_models.dart';

class EmyApiService {
  EmyApiService({
    required this.apiClient,
    required this.tokenManager,
  });

  final ApiClient apiClient;
  final AuthTokenManager tokenManager;

  Future<EmyMessage> sendMessage({
    required String message,
    required bool isAuthenticated,
    List<EmyMessage> guestHistory = const [],
  }) async {
    final body = <String, dynamic>{
      'message': message,
      if (!isAuthenticated && guestHistory.isNotEmpty)
        'history': guestHistory
            .map((m) => {'role': m.role, 'content': m.content})
            .toList(),
    };

    final response = await apiClient.post(
      ApiConstants.emyChat,
      body: body,
      requiresAuth: isAuthenticated,
    );

    final data = response['data'] as Map<String, dynamic>? ?? {};
    final reply = (data['reply'] ?? '').toString();
    final rawSources = data['sources'];
    final sources = rawSources is List
        ? rawSources.map((e) => e.toString()).toList()
        : <String>[];

    return EmyMessage(
      id: (data['assistantMessageId'] ??
              DateTime.now().microsecondsSinceEpoch.toString())
          .toString(),
      role: 'assistant',
      content: reply,
      sources: sources,
      createdAt: data['createdAt'] != null
          ? DateTime.tryParse(data['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Future<List<EmyMessage>> getHistory() async {
    final response = await apiClient.get(
      ApiConstants.emyHistory,
      requiresAuth: true,
    );
    final rawList = response['data'];
    if (rawList is! List) return [];
    return rawList
        .whereType<Map<String, dynamic>>()
        .map(EmyMessage.fromJson)
        .toList();
  }

  Future<void> clearHistory() async {
    await apiClient.delete(
      ApiConstants.emyHistory,
      requiresAuth: true,
    );
  }

  Future<List<EmyDocument>> listDocuments() async {
    final response = await apiClient.get(
      ApiConstants.emyDocuments,
      requiresAuth: true,
    );
    final rawList = response['data'];
    if (rawList is! List) return [];
    return rawList
        .whereType<Map<String, dynamic>>()
        .map(EmyDocument.fromJson)
        .toList();
  }

  Future<EmyDocument> uploadDocument({
    required String fileName,
    required List<int> bytes,
  }) async {
    final token = await tokenManager.getAccessToken();
    if (token == null || token.isEmpty) {
      throw Exception('Please log in to upload documents.');
    }

    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.emyDocuments}');
    final request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $token'
      ..headers['Accept'] = 'application/json'
      ..files.add(
        http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: fileName,
        ),
      );

    final streamed = await request.send().timeout(ApiConstants.receiveTimeout);
    final response = await http.Response.fromStream(streamed);
    final decoded = response.body.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode >= 200 &&
        response.statusCode < 300 &&
        decoded['success'] == true) {
      final data = decoded['data'] as Map<String, dynamic>? ?? {};
      return EmyDocument.fromJson(data);
    }

    throw Exception(
      decoded['message']?.toString() ??
          'Upload failed (${response.statusCode})',
    );
  }

  Future<void> deleteDocument(String documentId) async {
    await apiClient.delete(
      '${ApiConstants.emyDocuments}/$documentId',
      requiresAuth: true,
    );
  }
}
