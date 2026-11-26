import 'package:emychat/core/network/api_client.dart';
import '../models/workspace_settings_model.dart';

class SettingsService {
  SettingsService({this.apiClient});

  // ignore: unused_field
  final ApiClient? apiClient;

  Future<WorkspaceSettingsModel> fetchSettings(String defaultName) async {
    return WorkspaceSettingsModel(
      name: defaultName,
      webhookUrl: 'https://api.emychat.com/webhooks/events',
      isWebhookVerified: true,
    );
  }

  Future<bool> saveSettings({required String name}) async {
    return true;
  }
}
