import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/network/supabase_client.dart';
import '../models/lead_model.dart';
import '../models/lead_activity_model.dart';

class LeadRepository {
  final SupabaseClient _client = SupabaseService.client;

  String _generateId() {
    return 'lead_${DateTime.now().millisecondsSinceEpoch}';
  }

  // Fetch all live leads with Geo-filtering (City, District, Pincode)
  Future<List<LeadModel>> getLeads({
    String? stage,
    String? source,
    String? priority,
    String? stateFilter,
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

      if (stateFilter != null && stateFilter.isNotEmpty && stateFilter != 'ALL') {
        final sf = stateFilter.toLowerCase();
        leads = leads.where((l) => (l.state ?? 'Rajasthan').toLowerCase().contains(sf)).toList();
      }

      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        final q = searchQuery.toLowerCase().trim();
        leads = leads.where((l) =>
          l.schoolName.toLowerCase().contains(q) ||
          l.contactPerson.toLowerCase().contains(q) ||
          (l.phone != null && l.phone!.contains(q)) ||
          (l.email != null && l.email!.toLowerCase().contains(q)) ||
          (l.city != null && l.city!.toLowerCase().contains(q)) ||
          (l.district != null && l.district!.toLowerCase().contains(q)) ||
          (l.state != null && l.state!.toLowerCase().contains(q)) ||
          (l.pincode != null && l.pincode!.contains(q)) ||
          l.id.contains(q)
        ).toList();
      }

      return leads;
    } catch (e) {
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
    final id = lead.id.isEmpty ? _generateId() : lead.id;
    final now = DateTime.now().toIso8601String();
    
    final sanitizedLead = lead.copyWith(
      id: id,
      createdAt: lead.createdAt,
      updatedAt: DateTime.now(),
    );

    final payload = sanitizedLead.toSupabaseMap();
    payload['id'] = id;
    payload['createdAt'] = now;
    payload['updatedAt'] = now;

    await _client.from('Lead').insert(payload);

    // Also record an initial lead note / timeline entry
    try {
      await _client.from('LeadNote').insert({
        'id': 'lnote_${DateTime.now().millisecondsSinceEpoch}',
        'leadId': id,
        'content': 'Lead created for ${lead.schoolName} (${lead.contactPerson})',
        'authorId': 'agent_vikram_01',
        'createdAt': now,
      });
    } catch (_) {}

    try {
      await _client.from('SalesNote').insert({
        'id': 'snote_${DateTime.now().millisecondsSinceEpoch}',
        'leadId': id,
        'schoolName': lead.schoolName,
        'authorName': 'Vikram',
        'content': 'New field lead registered: ${lead.schoolName}',
        'tags': ['#NewLead', '#${lead.stage}'],
        'createdAt': now,
      });
    } catch (_) {}

    final created = await getLeadById(id);
    return created ?? sanitizedLead;
  }

  // Update Lead
  Future<void> updateLead(LeadModel lead) async {
    final payload = lead.toSupabaseMap();
    payload['updatedAt'] = DateTime.now().toIso8601String();

    await _client.from('Lead').update(payload).eq('id', lead.id);
  }

  // Change Lead Stage with Timeline & Activity logging
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
    }).eq('id', leadId);

    try {
      await _client.from('LeadNote').insert({
        'id': 'lnote_${DateTime.now().millisecondsSinceEpoch}',
        'leadId': leadId,
        'content': 'Pipeline stage updated from ${previousStage ?? 'Previous'} to $newStage${reason != null ? ' ($reason)' : ''}',
        'authorId': actorId ?? 'agent_vikram_01',
        'createdAt': now,
      });
    } catch (_) {}

    try {
      await _client.from('SalesNote').insert({
        'id': 'snote_${DateTime.now().millisecondsSinceEpoch}',
        'leadId': leadId,
        'authorName': 'Vikram',
        'content': 'Stage changed to $newStage: ${reason ?? 'Sales progression'}',
        'tags': ['#StageChange', '#$newStage'],
        'createdAt': now,
      });
    } catch (_) {}
  }

  // Get Activities / Timeline for a Lead
  Future<List<LeadActivityModel>> getLeadActivities(String leadId) async {
    List<LeadActivityModel> activities = [];

    // 1. Try LeadNote
    try {
      final List<dynamic> notes = await _client
          .from('LeadNote')
          .select('*')
          .eq('leadId', leadId)
          .order('createdAt', ascending: false);

      for (var n in notes) {
        activities.add(LeadActivityModel(
          id: n['id'] ?? '',
          leadId: leadId,
          activityType: 'NOTE_ADDED',
          description: n['content'] ?? 'Note recorded',
          actorId: n['authorId'],
          createdAt: DateTime.tryParse(n['createdAt'] ?? '') ?? DateTime.now(),
        ));
      }
    } catch (_) {}

    // 2. Try SalesNote
    try {
      final List<dynamic> salesNotes = await _client
          .from('SalesNote')
          .select('*')
          .eq('leadId', leadId)
          .order('createdAt', ascending: false);

      for (var sn in salesNotes) {
        if (!activities.any((a) => a.id == sn['id'])) {
          activities.add(LeadActivityModel(
            id: sn['id'] ?? '',
            leadId: leadId,
            activityType: 'SALES_NOTE',
            description: '${sn['authorName'] ?? 'Agent'}: ${sn['content'] ?? ''}',
            createdAt: DateTime.tryParse(sn['createdAt'] ?? '') ?? DateTime.now(),
          ));
        }
      }
    } catch (_) {}

    activities.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return activities;
  }

  // Add Note to Lead
  Future<void> addNote({
    required String leadId,
    required String content,
    String? schoolName,
    String? authorId,
  }) async {
    final now = DateTime.now().toIso8601String();
    final noteId = 'lnote_${DateTime.now().millisecondsSinceEpoch}';

    try {
      await _client.from('LeadNote').insert({
        'id': noteId,
        'leadId': leadId,
        'content': content,
        'authorId': authorId ?? 'agent_vikram_01',
        'createdAt': now,
      });
    } catch (_) {}

    try {
      await _client.from('SalesNote').insert({
        'id': 'snote_${DateTime.now().millisecondsSinceEpoch}',
        'leadId': leadId,
        'schoolName': schoolName,
        'authorName': 'Vikram',
        'content': content,
        'tags': ['#FieldNote'],
        'createdAt': now,
      });
    } catch (_) {}
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
      try {
        final List<dynamic> response2 = await _client
            .from('SalesNote')
            .select('*')
            .eq('leadId', leadId)
            .order('createdAt', ascending: false);
        return List<Map<String, dynamic>>.from(response2);
      } catch (_) {
        return [];
      }
    }
  }

  // Update Note
  Future<bool> updateNote(String noteId, String newContent) async {
    try {
      await _client.from('LeadNote').update({'content': newContent}).eq('id', noteId);
      try {
        await _client.from('SalesNote').update({'content': newContent}).eq('id', noteId);
      } catch (_) {}
      return true;
    } catch (_) {
      return false;
    }
  }

  // Delete Note
  Future<bool> deleteNote(String noteId) async {
    try {
      await _client.from('LeadNote').delete().eq('id', noteId);
      try {
        await _client.from('SalesNote').delete().eq('id', noteId);
      } catch (_) {}
      return true;
    } catch (_) {
      return false;
    }
  }
}
