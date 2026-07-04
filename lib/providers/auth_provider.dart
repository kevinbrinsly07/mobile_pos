import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/app_user.dart';
import '../services/auth_service.dart';
import '../services/local_cache_service.dart';
import '../services/supabase_service.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());
final localCacheServiceProvider = Provider<LocalCacheService>((ref) => LocalCacheService());

class AuthController extends AsyncNotifier<AppUser?> {
  @override
  Future<AppUser?> build() async {
    await SupabaseService.init();
    await ref.read(localCacheServiceProvider).init();
    try {
      final profile = await ref.read(authServiceProvider).currentProfile();
      if (profile != null) {
        await ref.read(localCacheServiceProvider).saveProfile(profile);
      }
      return profile;
    } catch (e) {
      // Offline fallback: check if we have a valid session and cached profile
      try {
        final session = SupabaseService.client.auth.currentSession;
        if (session != null) {
          final cached = ref.read(localCacheServiceProvider).getProfile();
          if (cached != null) {
            return cached;
          }
        }
      } catch (_) {}
      rethrow;
    }
  }

  Future<void> signIn(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(authServiceProvider).signIn(email, password);
      final profile = await ref.read(authServiceProvider).currentProfile();
      if (profile != null) {
        await ref.read(localCacheServiceProvider).saveProfile(profile);
      }
      return profile;
    });
  }

  Future<void> signUp(String email, String password, String fullName) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(authServiceProvider).signUp(email, password, fullName);
      final profile = await ref.read(authServiceProvider).currentProfile();
      if (profile != null) {
        await ref.read(localCacheServiceProvider).saveProfile(profile);
      }
      return profile;
    });
  }

  Future<void> signOut() async {
    await ref.read(authServiceProvider).signOut();
    await ref.read(localCacheServiceProvider).clearProfile();
    state = const AsyncData(null);
  }

  Future<void> pinLogin(String pin, int storeId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(authServiceProvider).pinLogin(pin: pin, storeId: storeId),
    );
  }
}

final authStateProvider = AsyncNotifierProvider<AuthController, AppUser?>(
  AuthController.new,
);
