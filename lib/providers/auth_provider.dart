import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/app_user.dart';
import '../services/auth_service.dart';
import '../services/supabase_service.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

class AuthController extends AsyncNotifier<AppUser?> {
  @override
  Future<AppUser?> build() async {
    await SupabaseService.init();
    return ref.read(authServiceProvider).currentProfile();
  }

  Future<void> signIn(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(authServiceProvider).signIn(email, password);
      return ref.read(authServiceProvider).currentProfile();
    });
  }

  Future<void> signUp(String email, String password, String fullName) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(authServiceProvider).signUp(email, password, fullName);
      return ref.read(authServiceProvider).currentProfile();
    });
  }

  Future<void> signOut() async {
    await ref.read(authServiceProvider).signOut();
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
