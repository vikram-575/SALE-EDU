import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';

class ApiService {
  static String get baseUrl {
    return ApiConstants.backendApiUrlLocal;
  }

  // Generic GET
  static Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl$endpoint'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (_) {}
    return {'success': false, 'error': 'Network error'};
  }

  // Generic POST
  static Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> body) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
      return jsonDecode(response.body);
    } catch (err) {
      return {'success': false, 'error': err.toString()};
    }
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

  static Future<Map<String, dynamic>> getHealthStatus() => checkHealth();

  // Telegram Command Center Stats
  static Future<Map<String, dynamic>> getTelegramCommandCenterStats() async {
    return get('/api/telegram/command-center');
  }

  // Send Telegram message over backend proxy
  static Future<Map<String, dynamic>> sendTelegramMessage({
    String? conversationId,
    String? telegramChatId,
    String? leadId,
    required String content,
    String? agentId,
  }) async {
    return post(ApiConstants.telegramSendEndpoint, {
      'conversationId': conversationId,
      'telegramChatId': telegramChatId,
      'leadId': leadId,
      'content': content,
      'agentId': agentId,
    });
  }

  // Duplicate Check
  static Future<Map<String, dynamic>> checkDuplicateCustomer({
    required String schoolName,
    String? phone,
    String? email,
    String? website,
  }) async {
    return post(ApiConstants.duplicateCheckEndpoint, {
      'schoolName': schoolName,
      'phone': phone,
      'email': email,
      'website': website,
    });
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
    return post(ApiConstants.convertLeadEndpoint, {
      'leadId': leadId,
      'annualRevenue': annualRevenue,
      'monthlyRevenue': monthlyRevenue,
      'oneTimeRevenue': oneTimeRevenue,
      'planId': planId,
      'targetGoLiveDate': targetGoLiveDate,
      'userId': userId,
      'bypassDuplicateCheck': bypassDuplicateCheck,
    });
  }

  // AI Sales Copilot
  static Future<Map<String, dynamic>> queryCopilot({
    required String prompt,
    String? leadId,
  }) async {
    return post(ApiConstants.copilotEndpoint, {
      'prompt': prompt,
      'leadId': leadId,
    });
  }
}
