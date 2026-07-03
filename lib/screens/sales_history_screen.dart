import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/supabase_service.dart';

class SalesHistoryScreen extends StatefulWidget {
  const SalesHistoryScreen({super.key});

  @override
  State<SalesHistoryScreen> createState() => _SalesHistoryScreenState();
}

class _SalesHistoryScreenState extends State<SalesHistoryScreen> {
  late final SupabaseClient _client;
  List<Map<String, dynamic>> _sales = <Map<String, dynamic>>[];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _client = SupabaseService.client;
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final rows = await _client
        .from('sales')
        .select('id, receipt_number, total, status, created_at, payment_method')
        .order('created_at', ascending: false)
        .limit(200);

    setState(() {
      _sales = rows.map((e) => Map<String, dynamic>.from(e)).toList();
      _loading = false;
    });
  }

  Future<void> _refund(int saleId) async {
    await _client.rpc('refund_sale', params: {
      'p_sale_id': saleId,
      'p_reason': 'Manual refund from mobile POS',
    });
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sales History')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _sales.length,
              itemBuilder: (context, index) {
                final sale = _sales[index];
                return ListTile(
                  title: Text('Receipt #${sale['receipt_number']}'),
                  subtitle: Text(
                    '${sale['status']} • ${sale['payment_method']} • ${sale['created_at']}',
                  ),
                  trailing: Text((sale['total'] ?? 0).toString()),
                  onTap: () => _showSaleActions(context, sale),
                );
              },
            ),
    );
  }

  Future<void> _showSaleActions(BuildContext context, Map<String, dynamic> sale) async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.receipt),
              title: const Text('Reprint receipt'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.reply),
              title: const Text('Refund sale'),
              onTap: () async {
                Navigator.pop(context);
                await _refund(sale['id'] as int);
              },
            ),
          ],
        ),
      ),
    );
  }
}
