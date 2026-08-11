class LeadTaskModel {
  final String id;
  final String? leadId;
  final String? customerId;
  final String title;
  final String? description;
  final String taskType;
  final String priority;
  final String status;
  final DateTime dueDate;
  final String? dueTime;
  final String? assignedToId;
  final String? createdById;
  final DateTime? completedAt;
  final DateTime createdAt;

  LeadTaskModel({
    required this.id,
    this.leadId,
    this.customerId,
    required this.title,
    this.description,
    this.taskType = 'Follow-up',
    this.priority = 'MEDIUM',
    this.status = 'TODO',
    required this.dueDate,
    this.dueTime,
    this.assignedToId,
    this.createdById,
    this.completedAt,
    required this.createdAt,
  });

  factory LeadTaskModel.fromJson(Map<String, dynamic> json) {
    return LeadTaskModel(
      id: json['id'],
      leadId: json['leadId'],
      customerId: json['customerId'],
      title: json['title'] ?? '',
      description: json['description'],
      taskType: json['taskType'] ?? 'Follow-up',
      priority: json['priority'] ?? 'MEDIUM',
      status: json['status'] ?? 'TODO',
      dueDate: DateTime.parse(json['dueDate'] ?? DateTime.now().toIso8601String()),
      dueTime: json['dueTime'],
      assignedToId: json['assignedToId'],
      createdById: json['createdById'],
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'leadId': leadId,
      'customerId': customerId,
      'title': title,
      'description': description,
      'taskType': taskType,
      'priority': priority,
      'status': status,
      'dueDate': dueDate.toIso8601String(),
      'dueTime': dueTime,
      'assignedToId': assignedToId,
      'createdById': createdById,
      'completedAt': completedAt?.toIso8601String(),
    };
  }
}
