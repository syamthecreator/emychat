import 'package:flutter/foundation.dart';
import '../repositories/dashboard_repository.dart';

class DashboardProvider extends ChangeNotifier {
  DashboardProvider({DashboardRepository? dashboardRepository})
      : _dashboardRepository = dashboardRepository ?? DashboardRepository();

  final DashboardRepository _dashboardRepository;

  bool _isRefreshing = false;
  bool get isRefreshing => _isRefreshing;

  Future<void> refresh() async {
    _isRefreshing = true;
    notifyListeners();
    try {
      await _dashboardRepository.getStats();
    } catch (_) {}
    _isRefreshing = false;
    notifyListeners();
  }
}
