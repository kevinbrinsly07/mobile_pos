import 'package:hive_flutter/hive_flutter.dart';
import '../models/app_user.dart';
import '../models/product.dart';

class LocalCacheService {
  static const _boxName = 'local_cache';
  static Box<dynamic>? _box;

  Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox<dynamic>(_boxName);
  }

  Future<void> saveProfile(AppUser user) async {
    await _box?.put('profile', user.toMap());
  }

  AppUser? getProfile() {
    final data = _box?.get('profile');
    if (data == null) return null;
    return AppUser.fromMap(Map<String, dynamic>.from(data as Map));
  }

  Future<void> clearProfile() async {
    await _box?.delete('profile');
  }

  Future<void> saveProducts(int storeId, List<Product> products) async {
    final list = products.map((p) => p.toMap()).toList();
    await _box?.put('products_$storeId', list);
  }

  List<Product> getProducts(int storeId) {
    final list = _box?.get('products_$storeId');
    if (list == null) return <Product>[];
    return (list as List)
        .map((entry) => Product.fromMap(Map<String, dynamic>.from(entry as Map)))
        .toList();
  }
}
