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
    final isCompact = MediaQuery.of(context).size.width < 800;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF000000),
        border: Border(
          left: isCompact
              ? BorderSide.none
              : const BorderSide(color: Color(0xFF212529), width: 1),
          top: const BorderSide(color: Color(0xFF212529), width: 1),
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
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0c0f0a),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF212529), width: 1),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                    title: Text(
                      item.product.name,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Colors.white),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        currencyFormatter.cents(item.totalCents),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFFf77f00)),
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () => onDecrement(item),
                          icon: const Icon(Icons.remove_rounded, color: Colors.white70, size: 18),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Text(
                            '${item.quantity}',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () => onIncrement(item),
                          icon: const Icon(Icons.add_rounded, color: Color(0xFFf77f00), size: 18),
                        ),
                        const SizedBox(width: 6),
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () => onRemove(item),
                          icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 18),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: const BoxDecoration(
              color: Color(0xFF000000),
              border: Border(
                top: BorderSide(color: Color(0xFFf77f00), width: 1),
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
                      style: TextStyle(fontSize: 12, color: Colors.white70),
                    ),
                    Text(
                      currencyFormatter.cents(totalCents),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFf77f00)),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 40,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      padding: EdgeInsets.zero,
                    ),
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
