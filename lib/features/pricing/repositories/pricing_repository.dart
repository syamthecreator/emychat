import 'package:emychat/features/pricing/models/pricing_plan_model.dart';

import '../services/pricing_service.dart';

class PricingRepository {
  PricingRepository({PricingService? pricingService})
    : _pricingService = pricingService ?? PricingService();

  final PricingService _pricingService;

  Future<List<PricingPlanModel>> getPlans() => _pricingService.fetchPlans();
}
