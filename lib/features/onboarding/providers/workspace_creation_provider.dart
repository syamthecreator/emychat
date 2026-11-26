import 'package:emychat/features/workspace/models/workspace_model.dart';
import 'package:emychat/features/workspace/providers/workspace_provider.dart';
import 'package:flutter/material.dart';

import '../models/onboarding_model.dart';
import '../repositories/onboarding_repository.dart';

class WorkspaceCreationProvider extends ChangeNotifier {
  WorkspaceCreationProvider({required this.onboardingRepository}) {
    _config = onboardingRepository.getConfig();
    wsNameCtrl.addListener(_autoGenerateSlug);
  }

  final OnboardingRepository onboardingRepository;
  late final OnboardingConfigModel _config;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController wsNameCtrl = TextEditingController();
  final TextEditingController businessNameCtrl = TextEditingController();
  final TextEditingController slugCtrl = TextEditingController();

  String _selectedCategory = 'E-Commerce & Retail';
  String _selectedTimezone = 'UTC (Universal Coordinated Time)';
  String _selectedCountry = 'United States';
  bool _isCreating = false;

  String get selectedCategory => _selectedCategory;
  String get selectedTimezone => _selectedTimezone;
  String get selectedCountry => _selectedCountry;
  bool get isCreating => _isCreating;

  List<String> get categories => _config.categories;
  List<String> get timezones => _config.timezones;
  List<String> get countries => _config.countries;

  void setCategory(String category) {
    if (_selectedCategory == category) return;
    _selectedCategory = category;
    notifyListeners();
  }

  void setTimezone(String timezone) {
    if (_selectedTimezone == timezone) return;
    _selectedTimezone = timezone;
    notifyListeners();
  }

  void setCountry(String country) {
    if (_selectedCountry == country) return;
    _selectedCountry = country;
    notifyListeners();
  }

  void _autoGenerateSlug() {
    final raw = wsNameCtrl.text.toLowerCase().trim();
    final slug = raw
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-|-$'), '');
    if (slugCtrl.text != slug && slug.isNotEmpty) {
      slugCtrl.text = slug;
    }
  }

  Future<WorkspaceModel?> submitWorkspace(
    WorkspaceController wsController, {
    String? userId,
  }) async {
    if (!formKey.currentState!.validate()) return null;

    _isCreating = true;
    notifyListeners();

    try {
      final workspace = await wsController.createWorkspace(
        name: wsNameCtrl.text.trim(),
        businessName: businessNameCtrl.text.trim(),
        businessCategory: _selectedCategory,
        slug: slugCtrl.text.trim(),
        timezone: _selectedTimezone,
        country: _selectedCountry,
        userId: userId,
      );
      return workspace;
    } finally {
      _isCreating = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    wsNameCtrl.removeListener(_autoGenerateSlug);
    wsNameCtrl.dispose();
    businessNameCtrl.dispose();
    slugCtrl.dispose();
    super.dispose();
  }
}
