import '../models/billing_invoice_model.dart';
import '../services/billing_service.dart';

class BillingRepository {
  BillingRepository({BillingService? service})
      : _service = service ?? const BillingService();

  final BillingService _service;

  Future<List<BillingInvoiceModel>> getInvoices() => _service.fetchInvoices();
  Future<List<ResourceUsageModel>> getResourceUsage() => _service.fetchResourceUsage();
}
