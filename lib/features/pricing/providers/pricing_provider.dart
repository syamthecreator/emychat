import 'package:emychat/features/pricing/models/pricing_plan_model.dart';
import 'package:flutter/foundation.dart';

import '../repositories/pricing_repository.dart';

class PricingProvider extends ChangeNotifier {
  PricingProvider({
    PricingRepository? pricingRepository,
    dynamic subscriptionApiService,
  }) : _pricingRepository = pricingRepository ?? PricingRepository() {
    _selectedPlan = PricingPlanModel.defaultPlans.firstWhere(
      (p) => p.slug == 'growth',
      orElse: () => PricingPlanModel.defaultPlans[0],
    );
  }

  final PricingRepository _pricingRepository;

  List<PricingPlanModel> _plans = PricingPlanModel.defaultPlans;
  bool _isLoading = false;
  bool _isYearly = true;
  PricingPlanModel? _selectedPlan;
  final Set<String> _expandedFaqs = {};

  List<PricingPlanModel> get plans => _plans;
  bool get isLoading => _isLoading;
  bool get isYearly => _isYearly;
  PricingPlanModel? get selectedPlan => _selectedPlan;

  bool isFaqExpanded(String question) => _expandedFaqs.contains(question);

  void toggleFaq(String question, bool expanded) {
    if (expanded) {
      _expandedFaqs.add(question);
    } else {
      _expandedFaqs.remove(question);
    }
    notifyListeners();
  }

  Future<void> loadPlans() async {
    _isLoading = true;
    notifyListeners();

    try {
      final fetched = await _pricingRepository.getPlans();
      if (fetched.isNotEmpty) {
        _plans = fetched;
        if (_selectedPlan != null) {
          _selectedPlan = _plans.firstWhere(
            (p) => p.slug == _selectedPlan!.slug,
            orElse: () => _plans[0],
          );
        } else {
          _selectedPlan = _plans.firstWhere(
            (p) => p.slug == 'growth',
            orElse: () => _plans[0],
          );
        }
      }
    } catch (_) {
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void toggleBilling(bool yearly) {
    if (_isYearly == yearly) return;
    _isYearly = yearly;
    notifyListeners();
  }

  void selectPlan(PricingPlanModel plan) {
    _selectedPlan = plan;
    notifyListeners();
  }

  void selectPlanBySlug(String slug) {
    final match = _plans.firstWhere(
      (p) => p.slug.toLowerCase() == slug.toLowerCase(),
      orElse: () => _plans[0],
    );
    selectPlan(match);
  }
}

// Backwards compatibility alias
typedef PricingController = PricingProvider;
