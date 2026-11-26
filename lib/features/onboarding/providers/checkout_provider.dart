import 'package:emychat/features/pricing/models/pricing_plan_model.dart';
import 'package:emychat/features/pricing/providers/pricing_provider.dart';
import 'package:emychat/features/subscription/providers/subscription_provider.dart';
import 'package:emychat/features/workspace/providers/workspace_provider.dart';
import 'package:flutter/material.dart';

class CheckoutProvider extends ChangeNotifier {
  CheckoutProvider();

  final TextEditingController cardNumberCtrl = TextEditingController(
    text: '•••• •••• •••• 4242',
  );
  final TextEditingController expiryCtrl = TextEditingController(text: '12/28');
  final TextEditingController cvcCtrl = TextEditingController(text: '•••');
  final TextEditingController cardholderCtrl = TextEditingController(
    text: 'Jane Doe',
  );

  bool _isSimulatingPayment = false;
  String? _checkoutError;

  bool get isSimulatingPayment => _isSimulatingPayment;
  String? get checkoutError => _checkoutError;

  Future<bool> processPaymentAndVerify({
    required WorkspaceController wsController,
    required PricingController pricingController,
    required SubscriptionController subController,
  }) async {
    final currentWs =
        wsController.activeWorkspace ??
        (wsController.userWorkspaces.isNotEmpty
            ? wsController.userWorkspaces.first
            : null);

    if (currentWs == null) {
      _checkoutError =
          'Workspace not found. Please create or select a workspace first.';
      notifyListeners();
      return false;
    }

    final plan =
        pricingController.selectedPlan ?? PricingPlanModel.defaultPlans[1];
    final frequency = pricingController.isYearly ? 'YEARLY' : 'MONTHLY';

    _isSimulatingPayment = true;
    _checkoutError = null;
    notifyListeners();

    try {
      await subController.initiateCheckout(
        workspaceId: currentWs.id,
        planSlug: plan.slug,
        billingFrequency: frequency,
      );

      await Future.delayed(const Duration(milliseconds: 1200));

      final generatedTxnId = 'ac_pay_${DateTime.now().millisecondsSinceEpoch}';
      final verified = await subController.verifyAndActivateSubscription(
        workspaceId: currentWs.id,
        planSlug: plan.slug,
        billingFrequency: frequency,
        transactionId: generatedTxnId,
        paymentMethod: 'CARD',
      );

      if (!verified) {
        _checkoutError = subController.errorMessage ?? 'Payment verification failed. Please check your card details and try again.';
      }
      return verified;
    } catch (e) {
      _checkoutError = 'An unexpected payment error occurred: $e';
      return false;
    } finally {
      _isSimulatingPayment = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    cardNumberCtrl.dispose();
    expiryCtrl.dispose();
    cvcCtrl.dispose();
    cardholderCtrl.dispose();
    super.dispose();
  }
}
