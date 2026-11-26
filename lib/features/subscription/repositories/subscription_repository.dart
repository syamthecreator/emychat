import 'package:emychat/features/subscription/models/subscription_model.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/auth_token_manager.dart';
import '../services/subscription_service.dart';

class SubscriptionRepository {
  SubscriptionRepository({
    SubscriptionService? subscriptionService,
    ApiClient? apiClient,
  }) : _subscriptionService =
           subscriptionService ??
           SubscriptionService(
             apiClient:
                 apiClient ?? ApiClient(tokenManager: AuthTokenManager()),
           );

  final SubscriptionService _subscriptionService;

  Future<SubscriptionModel?> getCurrentSubscription(String workspaceId) =>
      _subscriptionService.getCurrentSubscription(workspaceId);

  Future<CheckoutSessionModel> createCheckoutSession({
    required String workspaceId,
    required String planSlug,
    required String billingFrequency,
  }) => _subscriptionService.createCheckoutSession(
    workspaceId: workspaceId,
    planSlug: planSlug,
    billingFrequency: billingFrequency,
  );

  Future<SubscriptionModel> verifyPaymentAndActivate({
    required String workspaceId,
    required String planSlug,
    required String billingFrequency,
    String? transactionId,
    String paymentMethod = 'CARD',
  }) => _subscriptionService.verifyPaymentAndActivate(
    workspaceId: workspaceId,
    planSlug: planSlug,
    billingFrequency: billingFrequency,
    transactionId: transactionId,
    paymentMethod: paymentMethod,
  );
}
