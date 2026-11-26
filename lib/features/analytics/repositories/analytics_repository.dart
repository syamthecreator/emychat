import '../models/analytics_model.dart';
import '../services/analytics_service.dart';

class AnalyticsRepository {
  AnalyticsRepository({AnalyticsService? analyticsService})
      : _analyticsService = analyticsService ?? AnalyticsService();

  final AnalyticsService _analyticsService;

  Future<AnalyticsOverviewModel> getAnalytics(String range) {
    return _analyticsService.fetchAnalyticsOverview(range);
  }
}
