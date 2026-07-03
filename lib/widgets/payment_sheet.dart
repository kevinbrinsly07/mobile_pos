import 'package:flutter/material.dart';

import '../models/sale.dart';

class PaymentSheet extends StatefulWidget {
  const PaymentSheet({super.key, required this.totalCents});

  final int totalCents;

  @override
  State<PaymentSheet> createState() => _PaymentSheetState();
}

class _PaymentSheetState extends State<PaymentSheet> {
  PaymentMethod _method = PaymentMethod.cash;
  final _amountController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SegmentedButton<PaymentMethod>(
            segments: const [
              ButtonSegment(value: PaymentMethod.cash, label: Text('Cash')),
              ButtonSegment(value: PaymentMethod.card, label: Text('Card')),
              ButtonSegment(value: PaymentMethod.mobileWallet, label: Text('Wallet')),
            ],
            selected: {_method},
            onSelectionChanged: (value) => setState(() => _method = value.first),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Amount (cents)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () {
              final amount = int.tryParse(_amountController.text) ?? widget.totalCents;
              Navigator.of(context).pop(
                SplitPayment(method: _method, amountCents: amount),
              );
            },
            child: const Text('Add Payment'),
          ),
        ],
      ),
    );
  }
}
