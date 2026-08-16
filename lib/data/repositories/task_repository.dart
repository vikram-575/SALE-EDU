import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/network/supabase_client.dart';
import '../models/lead_task_model.dart';

class TaskRepository {
  final SupabaseClient _client = SupabaseService.client;

  String _generateId() {
    return 'task_${DateTime.now().millisecondsSinceEpoch}';
  }

  // Fetch Tasks
  Future<List<LeadTaskModel>> getTasks({String? leadId, String? status}) async {
    List<LeadTaskModel> tasks = [];

    // 1. Try LeadTask table
    try {
      dynamic query = _client.from('LeadTask').select('*');
      if (leadId != null && leadId.isNotEmpty) {
        query = query.eq('leadId', leadId);
      }
      if (status != null && status != 'ALL') {
        query = query.eq('status', status);
      }
      query = query.order('dueDate', ascending: true);

      final List<dynamic> response = await query;
      final tList = response.map((json) => LeadTaskModel.fromJson(json)).toList();
      tasks.addAll(tList);
    } catch (_) {}

    // 2. Fallback to LeadNote / SalesNote tasks if LeadTask empty
    if (tasks.isEmpty && leadId != null) {
      try {
        final List<dynamic> notes = await _client
            .from('LeadNote')
            .select('*')
            .eq('leadId', leadId)
            .ilike('content', '%[TASK]%')
            .order('createdAt', ascending: false);

        for (var n in notes) {
          final content = n['content'] as String? ?? '';
          final cleanTitle = content.replaceAll('[TASK]', '').trim();
          tasks.add(LeadTaskModel(
            id: n['id'] ?? '',
            leadId: leadId,
            title: cleanTitle.isEmpty ? 'Follow-up Task' : cleanTitle,
            description: 'Task logged in Lead Profile',
            dueDate: DateTime.tryParse(n['createdAt'] ?? '')?.add(const Duration(days: 1)) ?? DateTime.now(),
            priority: 'HIGH',
            status: content.contains('[DONE]') ? 'COMPLETED' : 'PENDING',
            createdAt: DateTime.tryParse(n['createdAt'] ?? '') ?? DateTime.now(),
          ));
        }
      } catch (_) {}
    }

    return tasks;
  }

  // Create Task
  Future<LeadTaskModel> createTask(LeadTaskModel task) async {
    final id = task.id.isEmpty ? _generateId() : task.id;
    final now = DateTime.now().toIso8601String();

    final taskData = {
      'id': id,
      'leadId': task.leadId,
      'title': task.title,
      'description': task.description,
      'priority': task.priority,
      'status': task.status,
      'dueDate': task.dueDate.toIso8601String(),
      'createdAt': now,
    };

    // 1. Try LeadTask table insert
    try {
      await _client.from('LeadTask').insert(taskData);
    } catch (_) {
      // 2. Fallback to LeadNote & SalesNote
      if (task.leadId != null) {
        try {
          await _client.from('LeadNote').insert({
            'id': 'lnote_${DateTime.now().millisecondsSinceEpoch}',
            'leadId': task.leadId,
            'content': '[TASK] [${task.priority}] ${task.title} (Due: ${task.dueDate.toIso8601String().split('T')[0]})',
            'authorId': 'agent_vikram_01',
            'createdAt': now,
          });
        } catch (_) {}
      }
    }

    return task.copyWith(id: id);
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
    } catch (_) {
      if (leadId != null) {
        try {
          await _client.from('LeadNote').insert({
            'id': 'lnote_${DateTime.now().millisecondsSinceEpoch}',
            'leadId': leadId,
            'content': '[TASK] [DONE] Task marked completed ($newStatus)',
            'authorId': 'agent_vikram_01',
            'createdAt': now,
          });
        } catch (_) {}
      }
    }
  }
}
