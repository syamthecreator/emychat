import 'package:emychat/core/network/api_client.dart';
import 'package:emychat/core/network/api_constants.dart';
import 'package:emychat/features/pricing/models/pricing_plan_model.dart';

class PricingService {
  PricingService({this.apiClient});

  final ApiClient? apiClient;

  Future<List<PricingPlanModel>> fetchPlans() async {
    final client = apiClient;
    if (client == null) return PricingPlanModel.defaultPlans;
    try {
      final response = await client.get(
        ApiConstants.plans,
        requiresAuth: false,
      );

      if (response['success'] == true && response['data'] is List) {
        final list = (response['data'] as List)
            .map(
              (item) => PricingPlanModel.fromJson(
                Map<String, dynamic>.from(item as Map),
              ),
            )
            .toList();
        if (list.isNotEmpty) return list;
      }
    } catch (_) {}
    return PricingPlanModel.defaultPlans;
  }
}
