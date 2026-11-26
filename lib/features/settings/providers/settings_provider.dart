import 'package:flutter/material.dart';
import '../repositories/settings_repository.dart';

class SettingsProvider extends ChangeNotifier {
  SettingsProvider({SettingsRepository? settingsRepository})
      : _settingsRepository = settingsRepository ?? SettingsRepository() {
    nameController = TextEditingController(text: 'My Workspace');
    webhookController = TextEditingController(
      text: 'https://api.emychat.com/webhooks/events',
    );
  }

  final SettingsRepository _settingsRepository;

  late final TextEditingController nameController;
  late final TextEditingController webhookController;

  bool _isSaving = false;
  String? _statusMessage;

  bool get isSaving => _isSaving;
  String? get statusMessage => _statusMessage;

  void initFromWorkspaceName(String? name) {
    if (name != null && name.isNotEmpty && nameController.text == 'My Workspace') {
      nameController.text = name;
      notifyListeners();
    }
  }

  Future<void> saveSettings() async {
    _isSaving = true;
    _statusMessage = null;
    notifyListeners();

    try {
      final success = await _settingsRepository.updateSettings(
        name: nameController.text.trim(),
      );
      if (success) {
        _statusMessage = 'Settings saved successfully';
      }
    } catch (e) {
      _statusMessage = 'Error saving settings: $e';
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    webhookController.dispose();
    super.dispose();
  }
}
