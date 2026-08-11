class OnboardingRecordModel {
  final String id;
  final String customerId;
  final String schoolId;
  final String? ownerId;
  final String status;
  final Map<String, bool> checklistProgress;
  final DateTime? targetGoLiveDate;
  final DateTime? completedAt;
  final DateTime createdAt;

  OnboardingRecordModel({
    required this.id,
    required this.customerId,
    required this.schoolId,
    this.ownerId,
    this.status = 'IN_PROGRESS',
    required this.checklistProgress,
    this.targetGoLiveDate,
    this.completedAt,
    required this.createdAt,
  });

  factory OnboardingRecordModel.fromJson(Map<String, dynamic> json) {
    Map<String, bool> progress = {};
    if (json['checklistProgress'] != null) {
      final rawMap = Map<String, dynamic>.from(json['checklistProgress']);
      rawMap.forEach((key, value) {
        progress[key] = value == true;
      });
    }

    return OnboardingRecordModel(
      id: json['id'],
      customerId: json['customerId'],
      schoolId: json['schoolId'],
      ownerId: json['ownerId'],
      status: json['status'] ?? 'IN_PROGRESS',
      checklistProgress: progress,
      targetGoLiveDate: json['targetGoLiveDate'] != null ? DateTime.parse(json['targetGoLiveDate']) : null,
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  int get completedItemCount => checklistProgress.values.where((v) => v).length;
  int get totalItemCount => checklistProgress.isNotEmpty ? checklistProgress.length : 15;
  double get percentage => (completedItemCount / totalItemCount) * 100;
}
