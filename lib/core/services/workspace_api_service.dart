import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/workspace/models/workspace_model.dart';
import '../network/api_client.dart';
import '../network/api_constants.dart';
import '../network/auth_token_manager.dart';

class WorkspaceApiService {
  WorkspaceApiService({required this.apiClient, this.tokenManager});

  final ApiClient apiClient;
  final AuthTokenManager? tokenManager;

  String _userWorkspacesKey(String? uid) =>
      (uid != null && uid.isNotEmpty)
          ? 'emychat_local_ws_${uid}_v2'
          : 'emychat_local_ws_guest_v2';

  String _userActiveKey(String? uid) =>
      (uid != null && uid.isNotEmpty)
          ? 'emychat_active_ws_${uid}_v2'
          : 'emychat_active_ws_guest_v2';

  Future<String?> _resolveUserId(String? explicitId) async {
    if (explicitId != null && explicitId.isNotEmpty) return explicitId;
    return await tokenManager?.getUserId();
  }

  /// Fetch workspaces for the authenticated user
  Future<List<WorkspaceModel>> getMyWorkspaces({String? userId}) async {
    final uid = await _resolveUserId(userId);
    try {
      final response = await apiClient.get(
        ApiConstants.myWorkspaces,
        requiresAuth: true,
      );

      if (response['success'] == true && response['data'] is List) {
        final list = (response['data'] as List)
            .map(
              (item) => WorkspaceModel.fromJson(
                Map<String, dynamic>.from(item as Map),
              ),
            )
            .toList();
        if (list.isNotEmpty) {
          await _saveWorkspacesLocally(list, userId: uid);
          return list;
        }
      }
    } catch (e) {
      debugPrint(
        'Workspace API fetch error (using local storage fallback): $e',
      );
    }

    // Local storage fallback scoped to user ID
    return await _getLocalWorkspaces(userId: uid);
  }

  /// Create a new workspace
  Future<WorkspaceModel> createWorkspace({
    required String name,
    required String businessName,
    String? businessCategory,
    String? slug,
    String timezone = 'UTC',
    String country = 'United States',
    String? userId,
  }) async {
    final uid = await _resolveUserId(userId);
    try {
      final response = await apiClient.post(
        ApiConstants.workspaces,
        requiresAuth: true,
        body: {
          'name': name.trim(),
          'businessName': businessName.trim(),
          'businessCategory': businessCategory?.trim(),
          'slug': slug?.trim(),
          'timezone': timezone,
          'country': country,
        },
      );

      if (response['success'] == true && response['data'] is Map) {
        final created = WorkspaceModel.fromJson(
          Map<String, dynamic>.from(response['data'] as Map),
        );
        await _addLocalWorkspace(created, userId: uid);
        return created;
      }
    } catch (e) {
      debugPrint('Workspace API creation error (persisting locally): $e');
    }

    // Fallback workspace creation
    final fallbackSlug = (slug != null && slug.isNotEmpty)
        ? slug
        : name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '-');
    final uniqueId = 'ws_${DateTime.now().millisecondsSinceEpoch}';
    final fallback = WorkspaceModel(
      id: uniqueId,
      name: name,
      businessName: businessName,
      businessCategory: businessCategory,
      slug: fallbackSlug,
      timezone: timezone,
      country: country,
      ownerId: uid ?? 'current_user',
      createdAt: DateTime.now(),
    );

    await _addLocalWorkspace(fallback, userId: uid);
    return fallback;
  }

  Future<void> setActiveWorkspaceId(String workspaceId, {String? userId}) async {
    final uid = await _resolveUserId(userId);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userActiveKey(uid), workspaceId);
  }

  Future<String?> getActiveWorkspaceId({String? userId}) async {
    final uid = await _resolveUserId(userId);
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userActiveKey(uid));
  }

  Future<List<WorkspaceModel>> _getLocalWorkspaces({String? userId}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_userWorkspacesKey(userId));
      if (raw == null || raw.isEmpty) return [];

      final decoded = jsonDecode(raw) as List;
      return decoded
          .map(
            (item) =>
                WorkspaceModel.fromJson(Map<String, dynamic>.from(item as Map)),
          )
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _saveWorkspacesLocally(List<WorkspaceModel> workspaces, {String? userId}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = workspaces.map((w) => w.toJson()).toList();
      await prefs.setString(_userWorkspacesKey(userId), jsonEncode(list));
    } catch (_) {}
  }

  Future<void> _addLocalWorkspace(WorkspaceModel workspace, {String? userId}) async {
    final list = await _getLocalWorkspaces(userId: userId);
    list.removeWhere((w) => w.id == workspace.id || w.slug == workspace.slug);
    list.insert(0, workspace);
    await _saveWorkspacesLocally(list, userId: userId);
    await setActiveWorkspaceId(workspace.id, userId: userId);
  }
}
