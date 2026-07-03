import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_provider.dart';

class PinLoginScreen extends ConsumerStatefulWidget {
  const PinLoginScreen({super.key});

  @override
  ConsumerState<PinLoginScreen> createState() => _PinLoginScreenState();
}

class _PinLoginScreenState extends ConsumerState<PinLoginScreen> {
  final _pinCtrl = TextEditingController();
  final _storeCtrl = TextEditingController(text: '1');

  @override
  void dispose() {
    _pinCtrl.dispose();
    _storeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authStateProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Cashier PIN Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _storeCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Store ID'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _pinCtrl,
              keyboardType: TextInputType.number,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'PIN'),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: auth.isLoading
                  ? null
                  : () => ref.read(authStateProvider.notifier).pinLogin(
                        _pinCtrl.text,
                        int.tryParse(_storeCtrl.text) ?? 1,
                      ),
              child: const Text('Unlock Till'),
            ),
            if (auth.hasError)
              Text('${auth.error}', style: const TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }
}
