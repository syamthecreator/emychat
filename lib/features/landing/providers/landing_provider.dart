import 'package:flutter/material.dart';
import '../repositories/landing_repository.dart';

class LandingProvider extends ChangeNotifier {
  LandingProvider({
    required this.landingRepository,
    int initialTab = 0,
  }) : _activeTab = initialTab;

  // ignore: unused_field
  final LandingRepository landingRepository;

  int _activeTab = 0;
  final ScrollController scrollController = ScrollController();

  int get activeTab => _activeTab;

  void selectTab(int index) {
    if (_activeTab == index) return;
    _activeTab = index;
    notifyListeners();

    if (scrollController.hasClients) {
      scrollController.jumpTo(0);
    }
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }
}
