import '../services/dashboard_service.dart';

class DashboardRepository {
  DashboardRepository({DashboardService? dashboardService})
      : _dashboardService = dashboardService ?? DashboardService();

  final DashboardService _dashboardService;

  Future<Map<String, dynamic>> getStats() => _dashboardService.fetchOverviewStats();
}
