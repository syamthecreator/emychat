import 'package:flutter/foundation.dart';
import '../models/billing_invoice_model.dart';
import '../repositories/billing_repository.dart';

class BillingProvider extends ChangeNotifier {
  BillingProvider({BillingRepository? repository})
      : _repository = repository ?? BillingRepository() {
    _loadInitialData();
  }

  final BillingRepository _repository;

  List<BillingInvoiceModel> _invoices = const [];
  List<ResourceUsageModel> _resourceUsage = const [];
  bool _isLoading = false;

  List<BillingInvoiceModel> get invoices => _invoices;
  List<ResourceUsageModel> get resourceUsage => _resourceUsage;
  bool get isLoading => _isLoading;

  Future<void> _loadInitialData() async {
    _isLoading = true;
    notifyListeners();
    try {
      _invoices = await _repository.getInvoices();
      _resourceUsage = await _repository.getResourceUsage();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() => _loadInitialData();
}
