import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/report_provider.dart';
import '../utils/currency.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(salesSummaryProvider);
    final currency = CurrencyFormatter(currencyCode: 'USD');

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: summaryAsync.when(
        data: (summary) {
          return GridView.count(
            padding: const EdgeInsets.all(16),
            crossAxisCount: 2,
            children: [
              _MetricCard(title: 'Revenue', value: currency.cents(summary.revenueCents)),
              _MetricCard(title: 'Transactions', value: '${summary.transactions}'),
              _MetricCard(title: 'Avg Basket', value: currency.cents(summary.avgBasketCents)),
              _MetricCard(title: 'Cash Sales', value: currency.cents(summary.cashCents)),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title),
            const SizedBox(height: 10),
            Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
