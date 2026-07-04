import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'services/supabase_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseService.init(
    url: 'https://vlzanpvqxxwyxenbrubt.supabase.co',
    anonKey: 'sb_publishable_TnQh_isoM5OTd7XTEfO-CQ_LUHZivYn',
  );
  runApp(
    const ProviderScope(
      child: PosApp(),
    ),
  );
}
