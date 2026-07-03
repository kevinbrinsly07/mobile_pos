import 'package:supabase_flutter/supabase_flutter.dart';

import '../utils/app_config.dart';

class SupabaseService {
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized || !AppConfig.isConfigured) {
      return;
    }
    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      publishableKey: AppConfig.supabaseAnonKey,
    );
    _initialized = true;
  }

  static SupabaseClient get client => Supabase.instance.client;
}
