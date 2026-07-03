import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../models/product.dart';
import '../providers/inventory_provider.dart';
import '../utils/currency.dart';

class InventoryScreen extends ConsumerWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productsProvider);
    final currency = CurrencyFormatter(currencyCode: 'USD');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory'),
        actions: [
          IconButton(
            onPressed: () async {
              final products = productsAsync.valueOrNull ?? <Product>[];
              final csv = ref.read(inventoryServiceProvider).exportCsv(products);
              await SharePlus.instance.share(ShareParams(text: csv));
            },
            icon: const Icon(Icons.file_upload),
            tooltip: 'Export CSV',
          ),
        ],
      ),
      body: productsAsync.when(
        data: (products) => ListView.builder(
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return ListTile(
              title: Text(product.name),
              subtitle: Text('SKU: ${product.sku} • Stock: ${product.stockQty}'),
              trailing: Text(currency.cents(product.priceCents)),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateProductDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('New Product'),
      ),
    );
  }

  Future<void> _showCreateProductDialog(BuildContext context, WidgetRef ref) async {
    final nameCtrl = TextEditingController();
    final skuCtrl = TextEditingController();
    final barcodeCtrl = TextEditingController();
    final priceCtrl = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Create Product'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name')),
                TextField(controller: skuCtrl, decoration: const InputDecoration(labelText: 'SKU')),
                TextField(controller: barcodeCtrl, decoration: const InputDecoration(labelText: 'Barcode')),
                TextField(controller: priceCtrl, decoration: const InputDecoration(labelText: 'Price cents')),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            FilledButton(
              onPressed: () async {
                final product = Product(
                  id: 0,
                  storeId: 1,
                  name: nameCtrl.text,
                  priceCents: int.tryParse(priceCtrl.text) ?? 0,
                  costCents: 0,
                  taxRateBasisPoints: 0,
                  stockQty: 0,
                  sku: skuCtrl.text,
                  barcode: barcodeCtrl.text,
                );
                await ref.read(inventoryServiceProvider).createProduct(product);
                ref.invalidate(productsProvider);
                if (context.mounted) {
                  Navigator.pop(context);
                }
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }
}
