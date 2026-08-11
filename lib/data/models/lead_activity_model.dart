class LeadActivityModel {
  final String id;
  final String leadId;
  final String activityType;
  final String description;
  final String? actorId;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;

  LeadActivityModel({
    required this.id,
    required this.leadId,
    required this.activityType,
    required this.description,
    this.actorId,
    this.metadata,
    required this.createdAt,
  });

  factory LeadActivityModel.fromJson(Map<String, dynamic> json) {
    return LeadActivityModel(
      id: json['id'],
      leadId: json['leadId'],
      activityType: json['activityType'] ?? 'ACTIVITY',
      description: json['description'] ?? '',
      actorId: json['actorId'],
      metadata: json['metadata'] != null ? Map<String, dynamic>.from(json['metadata']) : null,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}
