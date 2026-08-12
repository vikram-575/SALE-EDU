import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../../core/network/supabase_client.dart';
import '../models/lead_model.dart';
import '../models/lead_activity_model.dart';

class LeadRepository {
  final SupabaseClient _client = SupabaseService.client;

  String _generateUuid() {
    final now = DateTime.now().microsecondsSinceEpoch.toString();
    final bytes = utf8.encode(now + (1000 + DateTime.now().millisecond).toString());
    final digest = sha256.convert(bytes).toString();
    return '${digest.substring(0, 8)}-${digest.substring(8, 12)}-4${digest.substring(13, 16)}-8${digest.substring(17, 20)}-${digest.substring(20, 32)}';
  }

  // Fetch all live leads with Geo-filtering (City, District, Pincode)
  Future<List<LeadModel>> getLeads({
    String? stage,
    String? source,
    String? priority,
    String? cityFilter,
    String? districtFilter,
    String? pincodeFilter,
    String? searchQuery,
  }) async {
    try {
      dynamic query = _client.from('Lead').select('*').eq('isArchived', false);

      if (stage != null && stage != 'ALL') {
        query = query.eq('stage', stage);
      }
      if (source != null && source != 'ALL') {
        query = query.eq('source', source);
      }
      if (priority != null && priority != 'ALL') {
        query = query.eq('priority', priority);
      }
      if (cityFilter != null && cityFilter.isNotEmpty && cityFilter != 'ALL') {
        query = query.ilike('city', '%$cityFilter%');
      }
      if (districtFilter != null && districtFilter.isNotEmpty && districtFilter != 'ALL') {
        query = query.ilike('district', '%$districtFilter%');
      }
      if (pincodeFilter != null && pincodeFilter.isNotEmpty && pincodeFilter != 'ALL') {
        query = query.eq('pincode', pincodeFilter.trim());
      }

      query = query.order('createdAt', ascending: false);

      final List<dynamic> response = await query;
      List<LeadModel> leads = response.map((json) => LeadModel.fromJson(json)).toList();

      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        final q = searchQuery.toLowerCase().trim();
        leads = leads.where((l) =>
          l.schoolName.toLowerCase().contains(q) ||
          l.contactPerson.toLowerCase().contains(q) ||
          (l.phone != null && l.phone!.contains(q)) ||
          (l.email != null && l.email!.toLowerCase().contains(q)) ||
          (l.city != null && l.city!.toLowerCase().contains(q)) ||
          (l.district != null && l.district!.toLowerCase().contains(q)) ||
          (l.pincode != null && l.pincode!.contains(q)) ||
          l.id.contains(q)
        ).toList();
      }

      return leads;
    } catch (_) {
      return [];
    }
  }

  // Fetch Lead by ID
  Future<LeadModel?> getLeadById(String leadId) async {
    try {
      final response = await _client.from('Lead').select('*').eq('id', leadId).maybeSingle();
      if (response == null) return null;
      return LeadModel.fromJson(response);
    } catch (_) {
      return null;
    }
  }

  // Create new Lead
  Future<LeadModel> createLead(LeadModel lead) async {
    final id = lead.id.isEmpty ? _generateUuid() : lead.id;
    final leadData = lead.toJson();
    leadData['id'] = id;
    leadData['createdAt'] = DateTime.now().toIso8601String();
    leadData['updatedAt'] = DateTime.now().toIso8601String();

    await _client.from('Lead').insert(leadData);

    // Log Activity
    try {
      await _client.from('LeadActivity').insert({
        'id': _generateUuid(),
        'leadId': id,
        'activityType': 'LEAD_CREATED',
        'description': 'Lead created for ${lead.schoolName}',
        'createdAt': DateTime.now().toIso8601String(),
      });
    } catch (_) {}

    final created = await getLeadById(id);
    return created ?? lead;
  }

  // Update Lead
  Future<void> updateLead(LeadModel lead) async {
    final leadData = lead.toJson();
    leadData['updatedAt'] = DateTime.now().toIso8601String();

    await _client.from('Lead').update(leadData).eq('id', lead.id);
  }

  // Change Lead Stage with History & Activity logging
  Future<void> changeLeadStage({
    required String leadId,
    required String newStage,
    String? previousStage,
    String? actorId,
    String? reason,
  }) async {
    final now = DateTime.now().toIso8601String();

    await _client.from('Lead').update({
      'stage': newStage,
      'updatedAt': now,
      if (newStage == 'LOST') 'lostReason': reason,
    }).eq('id', leadId);

    try {
      await _client.from('LeadStageHistory').insert({
        'id': _generateUuid(),
        'leadId': leadId,
        'previousStage': previousStage ?? 'UNKNOWN',
        'newStage': newStage,
        'changedById': actorId,
        'changeReason': reason ?? 'Stage updated in CRM Pipeline',
        'createdAt': now,
      });

      await _client.from('LeadActivity').insert({
        'id': _generateUuid(),
        'leadId': leadId,
        'activityType': 'STAGE_CHANGED',
        'description': 'Stage changed from ${previousStage ?? 'Previous'} to $newStage',
        'actorId': actorId,
        'createdAt': now,
      });
    } catch (_) {}
  }

  // Get Activities for a Lead
  Future<List<LeadActivityModel>> getLeadActivities(String leadId) async {
    try {
      final List<dynamic> response = await _client
          .from('LeadActivity')
          .select('*')
          .eq('leadId', leadId)
          .order('createdAt', ascending: false);

      return response.map((json) => LeadActivityModel.fromJson(json)).toList();
    } catch (_) {
      return [];
    }
  }

  // Add Note to Lead
  Future<void> addNote({
    required String leadId,
    required String content,
    String? authorId,
  }) async {
    final now = DateTime.now().toIso8601String();

    try {
      await _client.from('LeadNote').insert({
        'id': _generateUuid(),
        'leadId': leadId,
        'content': content,
        'authorId': authorId,
        'createdAt': now,
        'updatedAt': now,
      });
    } catch (_) {
      await _client.from('SalesNote').insert({
        'id': _generateUuid(),
        'leadId': leadId,
        'authorName': 'Sales Agent',
        'content': content,
        'createdAt': now,
      });
    }
  }

  // Fetch Lead Notes
  Future<List<Map<String, dynamic>>> getLeadNotes(String leadId) async {
    try {
      final List<dynamic> response = await _client
          .from('LeadNote')
          .select('*')
          .eq('leadId', leadId)
          .order('createdAt', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (_) {
      return [];
    }
  }
}
