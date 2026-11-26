import 'package:emychat/core/network/api_client.dart';

class DashboardService {
  DashboardService({this.apiClient});

  // ignore: unused_field
  final ApiClient? apiClient;

  Future<Map<String, dynamic>> fetchOverviewStats() async {
    return {
      'status': 'healthy',
      'lastSync': DateTime.now().toIso8601String(),
    };
  }
}
