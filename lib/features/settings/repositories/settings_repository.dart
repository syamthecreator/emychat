import '../models/workspace_settings_model.dart';
import '../services/settings_service.dart';

class SettingsRepository {
  SettingsRepository({SettingsService? settingsService})
      : _settingsService = settingsService ?? SettingsService();

  final SettingsService _settingsService;

  Future<WorkspaceSettingsModel> getSettings(String defaultName) {
    return _settingsService.fetchSettings(defaultName);
  }

  Future<bool> updateSettings({required String name}) {
    return _settingsService.saveSettings(name: name);
  }
}
