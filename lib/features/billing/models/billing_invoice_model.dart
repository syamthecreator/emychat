class BillingInvoiceModel {
  const BillingInvoiceModel({
    required this.id,
    required this.date,
    required this.amount,
    required this.status,
    this.downloadUrl,
  });

  final String id;
  final String date;
  final String amount;
  final String status;
  final String? downloadUrl;

  factory BillingInvoiceModel.fromJson(Map<String, dynamic> json) {
    return BillingInvoiceModel(
      id: json['id'] as String? ?? '',
      date: json['date'] as String? ?? '',
      amount: json['amount'] as String? ?? '',
      status: json['status'] as String? ?? 'Paid',
      downloadUrl: json['downloadUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date,
    'amount': amount,
    'status': status,
    'downloadUrl': downloadUrl,
  };

  BillingInvoiceModel copyWith({
    String? id,
    String? date,
    String? amount,
    String? status,
    String? downloadUrl,
  }) {
    return BillingInvoiceModel(
      id: id ?? this.id,
      date: date ?? this.date,
      amount: amount ?? this.amount,
      status: status ?? this.status,
      downloadUrl: downloadUrl ?? this.downloadUrl,
    );
  }
}

class ResourceUsageModel {
  const ResourceUsageModel({
    required this.label,
    required this.used,
    required this.max,
    required this.unit,
  });

  final String label;
  final int used;
  final int max;
  final String unit;

  double get percentage => (max > 0 ? used / max : 0.0).clamp(0.0, 1.0);
}
