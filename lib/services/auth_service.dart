import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/app_user.dart';
import 'supabase_service.dart';

class AuthService {
  SupabaseClient get _client => SupabaseService.client;

  Future<void> signIn(String email, String password) async {
    await _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signUp(String email, String password, String fullName) async {
    await _client.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': fullName},
    );
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  Future<AppUser?> currentProfile() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return null;
    }
    final row = await _client
        .from('profiles')
        .select('id, full_name, role, organization_id, store_id')
        .eq('id', user.id)
        .maybeSingle();

    if (row == null) {
      return null;
    }

    final map = Map<String, dynamic>.from(row);
    map['email'] = user.email;
    return AppUser.fromMap(map);
  }

  Future<AppUser?> pinLogin({required String pin, required int storeId}) async {
    final digest = sha256.convert(utf8.encode(pin)).toString();
    final row = await _client
        .from('profiles')
        .select('id, full_name, role, organization_id, store_id, email')
        .eq('store_id', storeId)
        .eq('pin_code_hash', digest)
        .eq('is_active', true)
        .maybeSingle();

    if (row == null) {
      return null;
    }
    return AppUser.fromMap(Map<String, dynamic>.from(row));
  }
}
