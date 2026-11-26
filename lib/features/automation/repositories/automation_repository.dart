import 'package:emychat/features/automation/services/automation_service.dart';

import '../models/automation_enums.dart';
import '../models/automation_model.dart';

class AutomationRepository {
  AutomationRepository({required this.apiService});

  final AutomationApiService apiService;

  Future<List<Automation>> getAutomations() => apiService.getAutomations();
  Future<Automation> getAutomationById(String id) =>
      apiService.getAutomationById(id);
  Future<Automation> createAutomation(Automation automation) =>
      apiService.createAutomation(automation);
  Future<Automation> updateAutomation(String id, Automation automation) =>
      apiService.updateAutomation(id, automation);
  Future<void> deleteAutomation(String id) => apiService.deleteAutomation(id);
  Future<AutomationStatus> toggleAutomation(String id) =>
      apiService.toggleAutomation(id);
}
