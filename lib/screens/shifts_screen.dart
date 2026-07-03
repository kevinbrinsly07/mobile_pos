import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/shift_provider.dart';
import '../utils/currency.dart';

class ShiftsScreen extends ConsumerWidget {
  const ShiftsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shiftAsync = ref.watch(shiftProvider);
    final shift = shiftAsync.valueOrNull;
    final currency = CurrencyFormatter(currencyCode: 'USD');

    return Scaffold(
      appBar: AppBar(title: const Text('Till / Shift')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: shiftAsync.when(
          data: (_) {
            if (shift == null) {
              return Center(
                child: FilledButton(
                  onPressed: () => _openShiftDialog(context, ref),
                  child: const Text('Open Till'),
                ),
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Open shift #${shift.id}', style: const TextStyle(fontSize: 20)),
                const SizedBox(height: 8),
                Text('Opening float: ${currency.cents(shift.openingFloatCents)}'),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () => _closeShiftDialog(context, ref),
                  child: const Text('Close Till'),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Text('Error: $error'),
        ),
      ),
    );
  }

  Future<void> _openShiftDialog(BuildContext context, WidgetRef ref) async {
    final ctrl = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Open Shift'),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Opening float (cents)'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              await ref.read(shiftProvider.notifier).openShift(int.tryParse(ctrl.text) ?? 0);
              if (context.mounted) {
                Navigator.pop(context);
              }
            },
            child: const Text('Open'),
          ),
        ],
      ),
    );
  }

  Future<void> _closeShiftDialog(BuildContext context, WidgetRef ref) async {
    final ctrl = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Close Shift'),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Counted cash (cents)'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              await ref.read(shiftProvider.notifier).closeShift(int.tryParse(ctrl.text) ?? 0);
              if (context.mounted) {
                Navigator.pop(context);
              }
            },
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
