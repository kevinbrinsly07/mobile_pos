import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/sale.dart';
import 'offline_queue_service.dart';
import 'supabase_service.dart';

class PosService {
  PosService(this._offlineQueueService);

  final OfflineQueueService _offlineQueueService;
  SupabaseClient get _client => SupabaseService.client;

  Future<void> submitSale(SaleDraft draft) async {
    final online = await _isOnline();
    if (!online) {
      await _offlineQueueService.enqueue({'type': 'sale', 'payload': _serializeDraft(draft)});
      return;
    }
    await _submitOnline(draft);
  }

  Future<void> syncPending() async {
    final online = await _isOnline();
    if (!online) {
      return;
    }

    final pending = _offlineQueueService.pending();
    for (final entry in pending) {
      if (entry['type'] != 'sale') {
        continue;
      }
      final payload = Map<String, dynamic>.from(entry['payload'] as Map);
      await _client.rpc('create_sale_with_items', params: payload);
    }
    await _offlineQueueService.clear();
  }

  Future<bool> _isOnline() async {
    final status = await Connectivity().checkConnectivity();
    return !status.contains(ConnectivityResult.none);
  }

  Future<void> _submitOnline(SaleDraft draft) async {
    await _client.rpc('create_sale_with_items', params: _serializeDraft(draft));
  }

  Map<String, dynamic> _serializeDraft(SaleDraft draft) {
    return {
      'p_store_id': draft.storeId,
      'p_shift_id': draft.shiftId,
      'p_cashier_id': draft.cashierId,
      'p_customer_id': draft.customerId,
      'p_subtotal': draft.subtotalCents,
      'p_discount_total': draft.lineDiscountCents + draft.cartDiscountCents,
      'p_tax_total': draft.taxCents,
      'p_total': draft.totalCents,
      'p_amount_tendered': draft.amountTenderedCents,
      'p_change_due': draft.changeDueCents,
      'p_items': draft.items
          .map((item) => {
                'product_id': item.product.id,
                'variant_id': item.variantId,
                'product_name': item.product.name,
                'unit_price': item.unitPriceCents,
                'quantity': item.quantity,
                'modifiers_snapshot': item.modifiers,
                'discount_applied': item.discountCents,
                'line_total': item.totalCents,
              })
          .toList(),
      'p_payments': draft.payments.map((p) => p.toMap()).toList(),
    };
  }
}
