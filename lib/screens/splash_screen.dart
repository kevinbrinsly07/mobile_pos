import 'package:flutter/material.dart';

import '../services/supabase_service.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 12),
            Text(
              SupabaseService.isInitialized
                  ? 'Connecting to Supabase...'
                  : 'Set SUPABASE_URL and SUPABASE_ANON_KEY using --dart-define.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
