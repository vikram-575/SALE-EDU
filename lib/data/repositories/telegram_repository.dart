import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/network/supabase_client.dart';
import '../../core/network/api_service.dart';
import '../models/telegram_message_model.dart';

class TelegramRepository {
  final SupabaseClient _client = SupabaseService.client;

  // Fetch Telegram Conversations
  Future<List<TelegramConversationModel>> getConversations({String filter = 'ALL'}) async {
    dynamic query = _client.from('TelegramConversation').select('*');

    if (filter == 'UNMATCHED') {
      query = query.eq('isMatched', false);
    } else if (filter == 'HOT_LEADS') {
      query = query.eq('isMatched', true);
    } else if (filter == 'UNREAD') {
      query = query.gt('unreadCount', 0);
    }

    query = query.order('lastMessageAt', ascending: false);

    final List<dynamic> response = await query;
    return response.map((json) => TelegramConversationModel.fromJson(json)).toList();
  }

  // Fetch Messages for a Conversation
  Future<List<TelegramMessageModel>> getMessages(String conversationId) async {
    final List<dynamic> response = await _client
        .from('TelegramMessage')
        .select('*')
        .eq('conversationId', conversationId)
        .order('sentAt', ascending: true);

    return response.map((json) => TelegramMessageModel.fromJson(json)).toList();
  }

  // Send Telegram message over backend API (Zero secret exposure in APK)
  Future<bool> sendMessage({
    required String conversationId,
    required String content,
    String? leadId,
    String? agentId,
  }) async {
    final result = await ApiService.sendTelegramMessage(
      conversationId: conversationId,
      leadId: leadId,
      content: content,
      agentId: agentId,
    );
    return result['success'] == true;
  }

  // Fetch Message Templates
  Future<List<Map<String, dynamic>>> getTemplates() async {
    final List<dynamic> response = await _client
        .from('MessageTemplate')
        .select('*')
        .order('category', ascending: true);
    return List<Map<String, dynamic>>.from(response);
  }

  // Link Conversation to Lead
  Future<void> linkConversationToLead(String conversationId, String leadId) async {
    await _client.from('TelegramConversation').update({
      'leadId': leadId,
      'isMatched': true,
      'status': 'OPEN',
      'updatedAt': DateTime.now().toIso8601String(),
    }).eq('id', conversationId);
  }
}
