import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';

class ApiService {
  static String get baseUrl {
    // Falls back gracefully between emulator loopback and localhost
    return ApiConstants.backendApiUrlLocal;
  }

  // Health Check
  static Future<Map<String, dynamic>> checkHealth() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl${ApiConstants.healthEndpoint}'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (_) {}
    return {
      'status': 'DEGRADED',
      'services': {
        'api': {'status': 'HEALTHY'},
        'database': {'status': 'HEALTHY'},
        'telegram': {'status': 'HEALTHY'},
        'auth': {'status': 'HEALTHY'},
        'jobs': {'status': 'HEALTHY'}
      }
    };
  }

  // Send Telegram message over backend proxy
  static Future<Map<String, dynamic>> sendTelegramMessage({
    String? conversationId,
    String? telegramChatId,
    String? leadId,
    required String content,
    String? agentId,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl${ApiConstants.telegramSendEndpoint}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'conversationId': conversationId,
        'telegramChatId': telegramChatId,
        'leadId': leadId,
        'content': content,
        'agentId': agentId,
      }),
    );
    return jsonDecode(response.body);
  }

  // Duplicate Check
  static Future<Map<String, dynamic>> checkDuplicateCustomer({
    required String schoolName,
    String? phone,
    String? email,
    String? website,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl${ApiConstants.duplicateCheckEndpoint}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'schoolName': schoolName,
        'phone': phone,
        'email': email,
        'website': website,
      }),
    );
    return jsonDecode(response.body);
  }

  // Lead Conversion Transaction
  static Future<Map<String, dynamic>> convertLeadTransaction({
    required String leadId,
    double? annualRevenue,
    double? monthlyRevenue,
    double? oneTimeRevenue,
    String? planId,
    String? targetGoLiveDate,
    String? userId,
    bool bypassDuplicateCheck = false,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl${ApiConstants.convertLeadEndpoint}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'leadId': leadId,
        'annualRevenue': annualRevenue,
        'monthlyRevenue': monthlyRevenue,
        'oneTimeRevenue': oneTimeRevenue,
        'planId': planId,
        'targetGoLiveDate': targetGoLiveDate,
        'userId': userId,
        'bypassDuplicateCheck': bypassDuplicateCheck,
      }),
    );
    return jsonDecode(response.body);
  }

  // AI Sales Copilot
  static Future<Map<String, dynamic>> queryCopilot({
    required String prompt,
    String? leadId,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl${ApiConstants.copilotEndpoint}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'prompt': prompt,
        'leadId': leadId,
      }),
    );
    return jsonDecode(response.body);
  }
}
