class TelegramConversationModel {
  final String id;
  final String? leadId;
  final String? customerId;
  final String telegramChatId;
  final String? telegramUsername;
  final String? contactName;
  final String? phone;
  final String status;
  final int unreadCount;
  final DateTime lastMessageAt;
  final String? assignedAgentId;
  final bool isMatched;
  final String? priority;
  final String? intentCategory;
  final bool doNotContact;
  final String? aiSummary;

  TelegramConversationModel({
    required this.id,
    this.leadId,
    this.customerId,
    required this.telegramChatId,
    this.telegramUsername,
    this.contactName,
    this.phone,
    this.status = 'OPEN',
    this.unreadCount = 0,
    required this.lastMessageAt,
    this.assignedAgentId,
    this.isMatched = false,
    this.priority,
    this.intentCategory,
    this.doNotContact = false,
    this.aiSummary,
  });

  String get displayContactName => contactName ?? (telegramUsername != null ? '@$telegramUsername' : 'Telegram Contact');

  factory TelegramConversationModel.fromJson(Map<String, dynamic> json) {
    return TelegramConversationModel(
      id: json['id'],
      leadId: json['leadId'],
      customerId: json['customerId'],
      telegramChatId: json['telegramChatId'] ?? '',
      telegramUsername: json['telegramUsername'],
      contactName: json['contactName'],
      phone: json['phone'],
      status: json['status'] ?? 'OPEN',
      unreadCount: json['unreadCount'] ?? 0,
      lastMessageAt: DateTime.parse(json['lastMessageAt'] ?? DateTime.now().toIso8601String()),
      assignedAgentId: json['assignedAgentId'],
      isMatched: json['isMatched'] ?? false,
      priority: json['priority'] ?? 'NORMAL',
      intentCategory: json['intentCategory'] ?? 'UNKNOWN',
      doNotContact: json['doNotContact'] ?? false,
      aiSummary: json['aiSummary'],
    );
  }
}

class TelegramMessageModel {
  final String id;
  final String conversationId;
  final String? telegramMessageId;
  final String senderType; // PROSPECT, AGENT, BOT, SYSTEM
  final String content;
  final String? attachmentUrl;
  final String? mediaType;
  final String status;
  final String? deliveryStatus;
  final DateTime sentAt;

  TelegramMessageModel({
    required this.id,
    required this.conversationId,
    this.telegramMessageId,
    required this.senderType,
    required this.content,
    this.attachmentUrl,
    this.mediaType,
    this.status = 'SENT',
    this.deliveryStatus,
    required this.sentAt,
  });

  factory TelegramMessageModel.fromJson(Map<String, dynamic> json) {
    return TelegramMessageModel(
      id: json['id'],
      conversationId: json['conversationId'],
      telegramMessageId: json['telegramMessageId'],
      senderType: json['senderType'] ?? 'PROSPECT',
      content: json['content'] ?? '',
      attachmentUrl: json['attachmentUrl'],
      mediaType: json['mediaType'],
      status: json['status'] ?? 'SENT',
      deliveryStatus: json['deliveryStatus'],
      sentAt: DateTime.parse(json['sentAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}
