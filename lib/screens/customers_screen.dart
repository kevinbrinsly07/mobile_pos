import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/supabase_service.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  late final SupabaseClient _client;
  final _searchCtrl = TextEditingController();
  List<Map<String, dynamic>> _rows = <Map<String, dynamic>>[];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _client = SupabaseService.client;
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final rows = await (_searchCtrl.text.isEmpty
      ? _client.from('customers').select().order('name')
      : _client
        .from('customers')
        .select()
        .ilike('name', '%${_searchCtrl.text}%')
        .order('name'));

    setState(() {
      _rows = rows.map((e) => Map<String, dynamic>.from(e)).toList();
      _loading = false;
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Customers')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Search customers',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _load,
                ),
                border: const OutlineInputBorder(),
              ),
              onSubmitted: (_) => _load(),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _rows.length,
                    itemBuilder: (context, index) {
                      final customer = _rows[index];
                      return ListTile(
                        title: Text(customer['name']?.toString() ?? ''),
                        subtitle: Text(
                          'Phone: ${customer['phone'] ?? '-'} • Points: ${customer['loyalty_points'] ?? 0}',
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
