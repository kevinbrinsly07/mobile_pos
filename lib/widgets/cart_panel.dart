import 'package:flutter/material.dart';

import '../models/sale.dart';
import '../utils/currency.dart';

class CartPanel extends StatelessWidget {
  const CartPanel({
    super.key,
    required this.items,
    required this.currencyFormatter,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
    required this.onCheckout,
    required this.totalCents,
  });

  final List<CartItem> items;
  final CurrencyFormatter currencyFormatter;
  final ValueChanged<CartItem> onIncrement;
  final ValueChanged<CartItem> onDecrement;
  final ValueChanged<CartItem> onRemove;
  final VoidCallback onCheckout;
  final int totalCents;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF7FBF9),
        border: Border(left: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return ListTile(
                  title: Text(item.product.name),
                  subtitle: Text(currencyFormatter.cents(item.totalCents)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        padding: const EdgeInsets.all(4),
                        constraints: const BoxConstraints(),
                        onPressed: () => onDecrement(item),
                        icon: const Icon(Icons.remove_circle_outline, size: 20),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${item.quantity}',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        padding: const EdgeInsets.all(4),
                        constraints: const BoxConstraints(),
                        onPressed: () => onIncrement(item),
                        icon: const Icon(Icons.add_circle_outline, size: 20),
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        padding: const EdgeInsets.all(4),
                        constraints: const BoxConstraints(),
                        onPressed: () => onRemove(item),
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Total: ${currencyFormatter.cents(totalCents)}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                FilledButton(
                  onPressed: items.isEmpty ? null : onCheckout,
                  child: const Text('Charge'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
