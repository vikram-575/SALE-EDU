class DemoModel {
  final String id;
  final String leadId;
  final DateTime scheduledAt;
  final int durationMinutes;
  final String? salespersonId;
  final String demoType;
  final String status;
  final String? meetingLink;
  final String? notes;
  final String? outcome;
  final String? nextAction;
  final DateTime createdAt;

  DemoModel({
    required this.id,
    required this.leadId,
    required this.scheduledAt,
    this.durationMinutes = 45,
    this.salespersonId,
    this.demoType = 'Online',
    this.status = 'SCHEDULED',
    this.meetingLink,
    this.notes,
    this.outcome,
    this.nextAction,
    required this.createdAt,
  });

  factory DemoModel.fromJson(Map<String, dynamic> json) {
    return DemoModel(
      id: json['id'],
      leadId: json['leadId'],
      scheduledAt: DateTime.parse(json['scheduledAt'] ?? DateTime.now().toIso8601String()),
      durationMinutes: json['durationMinutes'] ?? 45,
      salespersonId: json['salespersonId'],
      demoType: json['demoType'] ?? 'Online',
      status: json['status'] ?? 'SCHEDULED',
      meetingLink: json['meetingLink'],
      notes: json['notes'],
      outcome: json['outcome'],
      nextAction: json['nextAction'],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}
