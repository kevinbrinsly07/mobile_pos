import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/product.dart';
import '../services/inventory_service.dart';
import 'auth_provider.dart';

final inventoryServiceProvider = Provider<InventoryService>(
  (ref) => InventoryService(),
);

final productsProvider = FutureProvider<List<Product>>((ref) async {
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user == null) {
    return <Product>[];
  }
  return ref.read(inventoryServiceProvider).products(storeId: user.storeId);
});
