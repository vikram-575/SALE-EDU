import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/network/supabase_client.dart';

class AuthRepository {
  final SupabaseClient _client = SupabaseService.client;

  User? get currentUser => _client.auth.currentUser;

  Future<AuthResponse> signInWithEmail(String email, String password) async {
    return await _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  Future<Map<String, dynamic>?> getCurrentUserProfile() async {
    final user = currentUser;
    if (user == null) {
      // Fetch default active sales/super_admin user from User table if session not logged in
      final response = await _client.from('User').select('id, email, firstName, lastName, roleId').limit(1).maybeSingle();
      return response;
    }
    final response = await _client.from('User').select('id, email, firstName, lastName, roleId').eq('id', user.id).maybeSingle();
    return response;
  }
}
