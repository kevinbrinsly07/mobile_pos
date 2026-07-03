import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/shift.dart';
import '../services/supabase_service.dart';
import 'auth_provider.dart';

class ShiftController extends AsyncNotifier<Shift?> {
  SupabaseClient get _client => SupabaseService.client;

  @override
  Future<Shift?> build() async {
    final user = ref.watch(authStateProvider).valueOrNull;
    if (user == null) {
      return null;
    }

    final row = await _client
        .from('shifts')
        .select()
        .eq('cashier_id', user.id)
        .eq('status', 'open')
        .order('opened_at', ascending: false)
        .maybeSingle();

    if (row == null) {
      return null;
    }
    return Shift.fromMap(Map<String, dynamic>.from(row));
  }

  Future<void> openShift(int openingFloatCents) async {
    final user = ref.read(authStateProvider).valueOrNull;
    if (user == null) {
      return;
    }

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final row = await _client
          .from('shifts')
          .insert({
            'cashier_id': user.id,
            'store_id': user.storeId,
            'opening_float': openingFloatCents,
            'status': 'open',
          })
          .select()
          .single();
      return Shift.fromMap(Map<String, dynamic>.from(row));
    });
  }

  Future<void> closeShift(int closingFloatCents) async {
    final current = state.valueOrNull;
    if (current == null) {
      return;
    }

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final row = await _client
          .from('shifts')
          .update({
            'closing_float': closingFloatCents,
            'closed_at': DateTime.now().toIso8601String(),
            'status': 'closed',
          })
          .eq('id', current.id)
          .select()
          .single();
      return Shift.fromMap(Map<String, dynamic>.from(row));
    });
  }
}

final shiftProvider = AsyncNotifierProvider<ShiftController, Shift?>(
  ShiftController.new,
);
