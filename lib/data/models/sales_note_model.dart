class SalesNoteModel {
  final String id;
  final String? leadId;
  final String? schoolName;
  final String? authorName;
  final String content;
  final List<String> tags;
  final bool isPinned;
  final DateTime createdAt;

  SalesNoteModel({
    required this.id,
    this.leadId,
    this.schoolName,
    this.authorName,
    required this.content,
    this.tags = const [],
    this.isPinned = false,
    required this.createdAt,
  });

  factory SalesNoteModel.fromJson(Map<String, dynamic> json) {
    return SalesNoteModel(
      id: json['id'],
      leadId: json['leadId'],
      schoolName: json['schoolName'],
      authorName: json['authorName'] ?? 'Sales Agent',
      content: json['content'] ?? '',
      tags: json['tags'] != null ? List<String>.from(json['tags']) : [],
      isPinned: json['isPinned'] ?? false,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'leadId': leadId,
      'schoolName': schoolName,
      'authorName': authorName,
      'content': content,
      'tags': tags,
      'isPinned': isPinned,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
