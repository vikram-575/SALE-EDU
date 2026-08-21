import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/network/supabase_client.dart';

class AuthRepository {
  final SupabaseClient _client = SupabaseService.client;

  User? get currentUser => _client.auth.currentUser;

  Future<dynamic> signInWithEmail(String email, String password) async {
    final cleanEmail = email.trim().toLowerCase();
    final cleanPassword = password.trim();

    if (cleanEmail.isEmpty || cleanPassword.isEmpty) {
      throw const AuthException('Email and password cannot be empty.');
    }

    // 1. Try standard Supabase GoTrue Authentication
    try {
      final response = await _client.auth.signInWithPassword(
        email: cleanEmail,
        password: cleanPassword,
      );
      if (response.session != null && response.user != null) {
        // Fetch matching User profile from database
        final dbUser = await _client
            .from('User')
            .select('id, email, firstName, lastName, roleId')
            .ilike('email', cleanEmail)
            .maybeSingle();

        final profile = {
          'id': dbUser?['id'] ?? response.user!.id,
          'email': response.user!.email ?? cleanEmail,
          'firstName': dbUser?['firstName'] ?? response.user!.userMetadata?['firstName'] ?? 'Sales',
          'lastName': dbUser?['lastName'] ?? response.user!.userMetadata?['lastName'] ?? 'Agent',
          'roleId': dbUser?['roleId'] ?? 'SALES_EXECUTIVE',
        };

        await _saveLocalSession(profile);
        return response;
      }
    } catch (_) {}

    // 2. Real Database User Authentication (Supabase "User" table)
    try {
      final userRecord = await _client
          .from('User')
          .select('id, email, firstName, lastName, roleId, passwordHash')
          .ilike('email', cleanEmail)
          .maybeSingle();

      if (userRecord != null) {
        final storedHash = userRecord['passwordHash']?.toString().trim();
        if (storedHash != null && storedHash == cleanPassword) {
          final profile = {
            'id': userRecord['id'],
            'email': userRecord['email'],
            'firstName': userRecord['firstName'] ?? 'Sales',
            'lastName': userRecord['lastName'] ?? 'Agent',
            'roleId': userRecord['roleId'] ?? 'SALES_EXECUTIVE',
          };
          await _saveLocalSession(profile);
          return profile;
        }
      }
    } catch (_) {}

    throw const AuthException('Invalid login credentials. Please check your registered email and password.');
  }

  Future<void> _saveLocalSession(Map<String, dynamic> userProfile) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('cached_user_profile', jsonEncode(userProfile));
      await prefs.setBool('is_authenticated', true);
    } catch (_) {}
  }

  Future<void> signOut() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('cached_user_profile');
      await prefs.setBool('is_authenticated', false);
      await _client.auth.signOut();
    } catch (_) {}
  }

  Future<Map<String, dynamic>?> getCurrentUserProfile() async {
    // 1. Check local session cache for fast instant boot
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedStr = prefs.getString('cached_user_profile');
      if (cachedStr != null && cachedStr.isNotEmpty) {
        return jsonDecode(cachedStr);
      }
    } catch (_) {}

    // 2. Fetch live from database "User" table
    final user = currentUser;
    if (user != null && user.email != null) {
      try {
        final response = await _client
            .from('User')
            .select('id, email, firstName, lastName, roleId')
            .ilike('email', user.email!)
            .maybeSingle();
        if (response != null) {
          await _saveLocalSession(response);
          return response;
        }
      } catch (_) {}
    }

    return null;
  }
}
