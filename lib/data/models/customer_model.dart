class CustomerModel {
  final String id;
  final String schoolId;
  final String? leadId;
  final String? primaryContactId;
  final String? accountManagerId;
  final String status;
  final double annualRevenue;
  final double monthlyRevenue;
  final double oneTimeRevenue;
  final DateTime? contractStartDate;
  final DateTime? contractEndDate;
  final DateTime convertedAt;
  final DateTime createdAt;

  CustomerModel({
    required this.id,
    required this.schoolId,
    this.leadId,
    this.primaryContactId,
    this.accountManagerId,
    this.status = 'ACTIVE',
    this.annualRevenue = 0.0,
    this.monthlyRevenue = 0.0,
    this.oneTimeRevenue = 0.0,
    this.contractStartDate,
    this.contractEndDate,
    required this.convertedAt,
    required this.createdAt,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id'],
      schoolId: json['schoolId'],
      leadId: json['leadId'],
      primaryContactId: json['primaryContactId'],
      accountManagerId: json['accountManagerId'],
      status: json['status'] ?? 'ACTIVE',
      annualRevenue: (json['annualRevenue'] as num?)?.toDouble() ?? 0.0,
      monthlyRevenue: (json['monthlyRevenue'] as num?)?.toDouble() ?? 0.0,
      oneTimeRevenue: (json['oneTimeRevenue'] as num?)?.toDouble() ?? 0.0,
      contractStartDate: json['contractStartDate'] != null ? DateTime.parse(json['contractStartDate']) : null,
      contractEndDate: json['contractEndDate'] != null ? DateTime.parse(json['contractEndDate']) : null,
      convertedAt: DateTime.parse(json['convertedAt'] ?? DateTime.now().toIso8601String()),
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}
