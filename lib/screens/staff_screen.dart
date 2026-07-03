import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/supabase_service.dart';

class StaffScreen extends StatefulWidget {
  const StaffScreen({super.key});

  @override
  State<StaffScreen> createState() => _StaffScreenState();
}

class _StaffScreenState extends State<StaffScreen> {
  late final SupabaseClient _client;
  List<Map<String, dynamic>> _staff = <Map<String, dynamic>>[];

  @override
  void initState() {
    super.initState();
    _client = SupabaseService.client;
    _load();
  }

  Future<void> _load() async {
    final rows = await _client
        .from('profiles')
        .select('id, full_name, role, is_active, store_id')
        .order('full_name');

    setState(() {
      _staff = rows.map((e) => Map<String, dynamic>.from(e)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Staff Management')),
      body: ListView.builder(
        itemCount: _staff.length,
        itemBuilder: (context, index) {
          final member = _staff[index];
          return SwitchListTile(
            title: Text(member['full_name']?.toString() ?? 'Unknown'),
            subtitle: Text('Role: ${member['role']} • Store: ${member['store_id']}'),
            value: member['is_active'] as bool? ?? true,
            onChanged: (active) async {
              await _client
                  .from('profiles')
                  .update({'is_active': active})
                  .eq('id', member['id'] as String);
              await _load();
            },
          );
        },
      ),
    );
  }
}
