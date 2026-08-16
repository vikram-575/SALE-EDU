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

  LeadTaskModel copyWith({
    String? id,
    String? leadId,
    String? customerId,
    String? title,
    String? description,
    String? taskType,
    String? priority,
    String? status,
    DateTime? dueDate,
    String? dueTime,
    String? assignedToId,
    String? createdById,
    DateTime? completedAt,
    DateTime? createdAt,
  }) {
    return LeadTaskModel(
      id: id ?? this.id,
      leadId: leadId ?? this.leadId,
      customerId: customerId ?? this.customerId,
      title: title ?? this.title,
      description: description ?? this.description,
      taskType: taskType ?? this.taskType,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      dueDate: dueDate ?? this.dueDate,
      dueTime: dueTime ?? this.dueTime,
      assignedToId: assignedToId ?? this.assignedToId,
      createdById: createdById ?? this.createdById,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory LeadTaskModel.fromJson(Map<String, dynamic> json) {
    return LeadTaskModel(
      id: json['id'] ?? '',
      leadId: json['leadId'],
      customerId: json['customerId'],
      title: json['title'] ?? '',
      description: json['description'],
      taskType: json['taskType'] ?? 'Follow-up',
      priority: json['priority'] ?? 'MEDIUM',
      status: json['status'] ?? 'PENDING',
      dueDate: json['dueDate'] != null ? DateTime.tryParse(json['dueDate']) ?? DateTime.now() : DateTime.now(),
      dueTime: json['dueTime'],
      assignedToId: json['assignedToId'],
      createdById: json['createdById'],
      completedAt: json['completedAt'] != null ? DateTime.tryParse(json['completedAt']) : null,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) ?? DateTime.now() : DateTime.now(),
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
