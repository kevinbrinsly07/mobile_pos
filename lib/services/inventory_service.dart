import 'package:csv/csv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/product.dart';
import 'supabase_service.dart';

class InventoryService {
  SupabaseClient get _client => SupabaseService.client;

  Future<List<Product>> products({required int storeId}) async {
    final rows = await _client
        .from('products')
        .select()
        .eq('store_id', storeId)
        .eq('is_active', true)
        .order('name');

    return rows
        .map((row) => Product.fromMap(Map<String, dynamic>.from(row)))
        .toList();
  }

  Future<void> createProduct(Product product) async {
    await _client.from('products').insert(product.toMap()..remove('id'));
  }

  Future<void> updateStock({
    required int productId,
    required int changeQty,
    required String reason,
  }) async {
    await _client.rpc('adjust_stock', params: {
      'p_product_id': productId,
      'p_change_qty': changeQty,
      'p_reason': reason,
    });
  }

  String exportCsv(List<Product> products) {
    final rows = <List<dynamic>>[
      ['name', 'sku', 'barcode', 'price_cents', 'cost_cents', 'stock_qty'],
      ...products.map(
        (p) => [p.name, p.sku, p.barcode, p.priceCents, p.costCents, p.stockQty],
      ),
    ];
    return const ListToCsvConverter().convert(rows);
  }

  List<Map<String, String>> parseCsv(String csvText) {
    final rows = const CsvToListConverter().convert(csvText);
    if (rows.isEmpty) {
      return <Map<String, String>>[];
    }

    final headers = rows.first.map((h) => h.toString()).toList();
    return rows.skip(1).map((row) {
      final map = <String, String>{};
      for (var i = 0; i < row.length && i < headers.length; i++) {
        map[headers[i]] = row[i].toString();
      }
      return map;
    }).toList();
  }
}
