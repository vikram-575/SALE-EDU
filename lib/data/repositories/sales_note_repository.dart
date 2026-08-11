import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/network/supabase_client.dart';
import '../models/sales_note_model.dart';

class SalesNoteRepository {
  final SupabaseClient _supabase = SupabaseService.client;

  Future<List<SalesNoteModel>> getNotes({String? leadId, String? tagFilter}) async {
    try {
      var query = _supabase.from('SalesNote').select('*');
      if (leadId != null && leadId.isNotEmpty) {
        query = query.eq('leadId', leadId);
      }
      final data = await query.order('isPinned', ascending: false).order('createdAt', ascending: false);
      final notes = (data as List).map((json) => SalesNoteModel.fromJson(json)).toList();

      if (tagFilter != null && tagFilter.isNotEmpty && tagFilter != 'ALL') {
        return notes.where((n) => n.tags.contains(tagFilter)).toList();
      }
      return notes;
    } catch (e) {
      print('Error fetching sales notes: $e');
      return [];
    }
  }

  Future<bool> createNote({
    String? leadId,
    String? schoolName,
    required String content,
    List<String> tags = const [],
    bool isPinned = false,
  }) async {
    try {
      final id = 'note_${DateTime.now().millisecondsSinceEpoch}';
      await _supabase.from('SalesNote').insert({
        'id': id,
        'leadId': leadId,
        'schoolName': schoolName,
        'authorName': 'Vikram',
        'content': content,
        'tags': tags,
        'isPinned': isPinned,
        'createdAt': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      print('Error creating sales note: $e');
      return false;
    }
  }

  Future<bool> togglePinNote(String noteId, bool currentPinState) async {
    try {
      await _supabase.from('SalesNote').update({
        'isPinned': !currentPinState,
      }).eq('id', noteId);
      return true;
    } catch (e) {
      print('Error toggling pin state: $e');
      return false;
    }
  }
}
