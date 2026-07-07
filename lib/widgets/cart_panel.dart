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
      decoration: const BoxDecoration(
        color: Color(0xFF101524),
        border: Border(
          left: BorderSide(color: Color(0xFF26324D), width: 1),
          top: BorderSide(color: Color(0xFF26324D), width: 1),
        ),
      ),
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 12),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1C2538),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF26324D), width: 1),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    title: Text(
                      item.product.name,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.white),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        currencyFormatter.cents(item.totalCents),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF00E676)),
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () => onDecrement(item),
                          icon: const Icon(Icons.remove_rounded, color: Colors.white70, size: 20),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            '${item.quantity}',
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () => onIncrement(item),
                          icon: const Icon(Icons.add_rounded, color: Color(0xFF00E676), size: 20),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () => onRemove(item),
                          icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFF161C2A),
              border: Border(
                top: BorderSide(color: Color(0xFF26324D), width: 1),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Amount',
                      style: TextStyle(fontSize: 14, color: Colors.white70),
                    ),
                    Text(
                      currencyFormatter.cents(totalCents),
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF00E676)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 52,
                  child: FilledButton(
                    onPressed: items.isEmpty ? null : onCheckout,
                    child: const Text('Charge'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
