import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _darkMode = false;
  bool _english = true;
  final _storeName = TextEditingController(text: 'Demo Store');
  final _address = TextEditingController();
  final _footer = TextEditingController(text: 'Thanks for your purchase');
  final _tax = TextEditingController(text: '800');

  @override
  void dispose() {
    _storeName.dispose();
    _address.dispose();
    _footer.dispose();
    _tax.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings & Admin')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(controller: _storeName, decoration: const InputDecoration(labelText: 'Store name')),
          const SizedBox(height: 8),
          TextField(controller: _address, decoration: const InputDecoration(labelText: 'Address')),
          const SizedBox(height: 8),
          TextField(controller: _footer, decoration: const InputDecoration(labelText: 'Receipt footer')),
          const SizedBox(height: 8),
          TextField(
            controller: _tax,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Default tax rate (basis points)'),
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Dark theme'),
            value: _darkMode,
            onChanged: (value) => setState(() => _darkMode = value),
          ),
          SwitchListTile(
            title: const Text('English language'),
            value: _english,
            onChanged: (value) => setState(() => _english = value),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings saved locally.')),
              );
            },
            child: const Text('Save Settings'),
          ),
        ],
      ),
    );
  }
}
