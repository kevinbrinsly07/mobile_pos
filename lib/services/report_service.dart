import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/report_models.dart';
import 'supabase_service.dart';

class ReportService {
  SupabaseClient get _client => SupabaseService.client;

  Future<SalesSnapshot> summary({required int storeId}) async {
    final row = await _client
        .rpc('sales_summary', params: {'p_store_id': storeId})
        .maybeSingle();

    final map = Map<String, dynamic>.from(row ?? <String, dynamic>{});
    return SalesSnapshot(
      revenueCents: map['revenue_cents'] as int? ?? 0,
      transactions: map['transactions'] as int? ?? 0,
      avgBasketCents: map['avg_basket_cents'] as int? ?? 0,
      cashCents: map['cash_cents'] as int? ?? 0,
      cardCents: map['card_cents'] as int? ?? 0,
      walletCents: map['wallet_cents'] as int? ?? 0,
    );
  }

  Future<List<TopProduct>> topProducts({required int storeId}) async {
    final rows = await _client
        .rpc('top_products', params: {'p_store_id': storeId, 'p_limit': 10});

    return rows
        .map<TopProduct>(
          (row) => TopProduct(
            name: row['product_name'] as String,
            qty: row['qty_sold'] as int,
          ),
        )
        .toList();
  }
}
