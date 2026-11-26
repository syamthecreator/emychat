import '../models/billing_invoice_model.dart';

class BillingService {
  const BillingService();

  Future<List<BillingInvoiceModel>> fetchInvoices() async {
    return const [
      BillingInvoiceModel(
        id: 'INV-2026-1102',
        date: 'Nov 15, 2026',
        amount: '\$79.00',
        status: 'Paid',
      ),
      BillingInvoiceModel(
        id: 'INV-2026-1014',
        date: 'Oct 15, 2026',
        amount: '\$79.00',
        status: 'Paid',
      ),
    ];
  }

  Future<List<ResourceUsageModel>> fetchResourceUsage() async {
    return const [
      ResourceUsageModel(
        label: 'Connected Channels',
        used: 2,
        max: 5,
        unit: 'channels',
      ),
      ResourceUsageModel(
        label: 'AI Automation Tokens',
        used: 124000,
        max: 300000,
        unit: 'tokens',
      ),
      ResourceUsageModel(
        label: 'Monthly Conversations',
        used: 840,
        max: 2500,
        unit: 'conversations',
      ),
    ];
  }
}
