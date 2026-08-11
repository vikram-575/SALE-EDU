class TrialModel {
  final String id;
  final String leadId;
  final String? schoolId;
  final DateTime startDate;
  final DateTime endDate;
  final String status;
  final String? adminUserId;
  final int maxStudents;
  final int maxTeachers;
  final Map<String, dynamic> usageMetrics;
  final int engagementScore;
  final DateTime? lastActiveAt;
  final DateTime createdAt;

  TrialModel({
    required this.id,
    required this.leadId,
    this.schoolId,
    required this.startDate,
    required this.endDate,
    this.status = 'ACTIVE',
    this.adminUserId,
    this.maxStudents = 100,
    this.maxTeachers = 10,
    this.usageMetrics = const {},
    this.engagementScore = 50,
    this.lastActiveAt,
    required this.createdAt,
  });

  factory TrialModel.fromJson(Map<String, dynamic> json) {
    return TrialModel(
      id: json['id'],
      leadId: json['leadId'],
      schoolId: json['schoolId'],
      startDate: DateTime.parse(json['startDate'] ?? DateTime.now().toIso8601String()),
      endDate: DateTime.parse(json['endDate'] ?? DateTime.now().add(const Duration(days: 14)).toIso8601String()),
      status: json['status'] ?? 'ACTIVE',
      adminUserId: json['adminUserId'],
      maxStudents: json['maxStudents'] ?? 100,
      maxTeachers: json['maxTeachers'] ?? 10,
      usageMetrics: json['usageMetrics'] != null ? Map<String, dynamic>.from(json['usageMetrics']) : {},
      engagementScore: json['engagementScore'] ?? 50,
      lastActiveAt: json['lastActiveAt'] != null ? DateTime.parse(json['lastActiveAt']) : null,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  int get daysRemaining {
    final now = DateTime.now();
    if (endDate.isBefore(now)) return 0;
    return endDate.difference(now).inDays;
  }
}
