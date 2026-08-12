import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../../core/network/supabase_client.dart';
import '../models/lead_task_model.dart';

class TaskRepository {
  final SupabaseClient _client = SupabaseService.client;

  String _generateUuid() {
    final now = DateTime.now().microsecondsSinceEpoch.toString();
    final bytes = utf8.encode(now + (1000 + DateTime.now().millisecond).toString());
    final digest = sha256.convert(bytes).toString();
    return '${digest.substring(0, 8)}-${digest.substring(8, 12)}-4${digest.substring(13, 16)}-8${digest.substring(17, 20)}-${digest.substring(20, 32)}';
  }

  // Fetch Tasks
  Future<List<LeadTaskModel>> getTasks({String? leadId, String? status}) async {
    try {
      dynamic query = _client.from('LeadTask').select('*');

      if (leadId != null) {
        query = query.eq('leadId', leadId);
      }
      if (status != null && status != 'ALL') {
        query = query.eq('status', status);
      }

      query = query.order('dueDate', ascending: true);

      final List<dynamic> response = await query;
      return response.map((json) => LeadTaskModel.fromJson(json)).toList();
    } catch (_) {
      return [];
    }
  }

  // Create Task
  Future<LeadTaskModel> createTask(LeadTaskModel task) async {
    final id = task.id.isEmpty ? _generateUuid() : task.id;
    final data = task.toJson();
    data['id'] = id;
    data['createdAt'] = DateTime.now().toIso8601String();

    await _client.from('LeadTask').insert(data);

    if (task.leadId != null) {
      try {
        await _client.from('LeadActivity').insert({
          'id': _generateUuid(),
          'leadId': task.leadId,
          'activityType': 'FOLLOWUP_CREATED',
          'description': 'Task created: "${task.title}" (Due: ${task.dueDate.toIso8601String().split('T')[0]})',
          'createdAt': DateTime.now().toIso8601String(),
        });
      } catch (_) {}
    }

    try {
      final List<dynamic> created = await _client.from('LeadTask').select('*').eq('id', id);
      return LeadTaskModel.fromJson(created.first);
    } catch (_) {
      return task;
    }
  }

  // Update Task Status
  Future<void> updateTaskStatus(String taskId, String newStatus, {String? leadId}) async {
    final now = DateTime.now().toIso8601String();
    try {
      await _client.from('LeadTask').update({
        'status': newStatus,
        if (newStatus == 'COMPLETED') 'completedAt': now,
        'updatedAt': now,
      }).eq('id', taskId);
    } catch (_) {}

    if (leadId != null && newStatus == 'COMPLETED') {
      try {
        await _client.from('LeadActivity').insert({
          'id': _generateUuid(),
          'leadId': leadId,
          'activityType': 'TASK_COMPLETED',
          'description': 'Sales task marked completed',
          'createdAt': now,
        });
      } catch (_) {}
    }
  }
}
