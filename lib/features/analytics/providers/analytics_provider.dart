import 'package:flutter/foundation.dart';
import '../models/analytics_model.dart';
import '../repositories/analytics_repository.dart';

class AnalyticsProvider extends ChangeNotifier {
  AnalyticsProvider({AnalyticsRepository? analyticsRepository})
      : _analyticsRepository = analyticsRepository ?? AnalyticsRepository() {
    loadAnalytics();
  }

  final AnalyticsRepository _analyticsRepository;

  String _selectedRange = '30d';
  bool _isLoading = false;
  AnalyticsOverviewModel? _overview;

  String get selectedRange => _selectedRange;
  bool get isLoading => _isLoading;
  AnalyticsOverviewModel? get overview => _overview;

  List<MetricStatModel> get stats => _overview?.stats ?? const [];
  ChannelVolumeModel? get channelVolume => _overview?.channelVolume;

  Future<void> loadAnalytics() async {
    _isLoading = true;
    notifyListeners();
    try {
      _overview = await _analyticsRepository.getAnalytics(_selectedRange);
    } catch (_) {}
    _isLoading = false;
    notifyListeners();
  }

  void setSelectedRange(String range) {
    if (_selectedRange == range) return;
    _selectedRange = range;
    notifyListeners();
    loadAnalytics();
  }
}
