import 'package:supabase_flutter/supabase_flutter.dart';

import '../utils/app_config.dart';

class SupabaseService {
  static bool _initialized = false;

  static bool get isInitialized => _initialized;

  static Future<void> init({String? url, String? anonKey}) async {
    if (_initialized) {
      return;
    }
    final targetUrl = AppConfig.isConfigured ? AppConfig.supabaseUrl : url;
    final targetKey = AppConfig.isConfigured ? AppConfig.supabaseAnonKey : anonKey;

    if (targetUrl == null || targetUrl.isEmpty || targetKey == null || targetKey.isEmpty) {
      return;
    }
    await Supabase.initialize(
      url: targetUrl,
      publishableKey: targetKey,
    );
    _initialized = true;
  }

  static SupabaseClient get client => Supabase.instance.client;
}
