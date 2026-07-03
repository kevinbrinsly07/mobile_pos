import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/report_provider.dart';
import '../utils/currency.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(salesSummaryProvider);
    final productsAsync = ref.watch(topProductsProvider);
    final currency = CurrencyFormatter(currencyCode: 'USD');

    return Scaffold(
      appBar: AppBar(title: const Text('Reports')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          summaryAsync.when(
            data: (summary) {
              final values = [
                summary.cashCents.toDouble(),
                summary.cardCents.toDouble(),
                summary.walletCents.toDouble(),
              ];
              return SizedBox(
                height: 250,
                child: BarChart(
                  BarChartData(
                    barGroups: values
                        .asMap()
                        .entries
                        .map(
                          (e) => BarChartGroupData(
                            x: e.key,
                            barRods: [BarChartRodData(toY: e.value)],
                          ),
                        )
                        .toList(),
                  ),
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Text('Error: $error'),
          ),
          const SizedBox(height: 16),
          productsAsync.when(
            data: (products) => Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Top Products', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    for (final product in products)
                      ListTile(
                        dense: true,
                        title: Text(product.name),
                        trailing: Text('Qty ${product.qty}'),
                      ),
                  ],
                ),
              ),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Text('Error: $error'),
          ),
          const SizedBox(height: 8),
          summaryAsync.when(
            data: (summary) => Text(
              'Revenue: ${currency.cents(summary.revenueCents)} • Avg basket: ${currency.cents(summary.avgBasketCents)}',
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
