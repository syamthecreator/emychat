import 'package:emychat/features/workspace/models/workspace_model.dart';

import '../../../core/services/workspace_api_service.dart';

class WorkspaceRepository {
  WorkspaceRepository({required this.apiService});

  final WorkspaceApiService apiService;

  Future<List<WorkspaceModel>> getMyWorkspaces() =>
      apiService.getMyWorkspaces();

  Future<String?> getActiveWorkspaceId() => apiService.getActiveWorkspaceId();

  Future<void> setActiveWorkspaceId(String id) =>
      apiService.setActiveWorkspaceId(id);

  Future<WorkspaceModel> createWorkspace({
    required String name,
    required String businessName,
    String? businessCategory,
    String? slug,
    String timezone = 'UTC',
    String country = 'US',
  }) => apiService.createWorkspace(
    name: name,
    businessName: businessName,
    businessCategory: businessCategory,
    slug: slug,
    timezone: timezone,
    country: country,
  );
}
