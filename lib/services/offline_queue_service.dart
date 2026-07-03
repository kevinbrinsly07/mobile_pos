import 'package:hive_flutter/hive_flutter.dart';

class OfflineQueueService {
  static const _boxName = 'offline_queue';
  static Box<dynamic>? _box;

  Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox<dynamic>(_boxName);
  }

  Future<void> enqueue(Map<String, dynamic> payload) async {
    await _box?.add(payload);
  }

  List<Map<String, dynamic>> pending() {
    return _box?.values
            .map((entry) => Map<String, dynamic>.from(entry as Map))
            .toList() ??
        <Map<String, dynamic>>[];
  }

  Future<void> clear() async {
    await _box?.clear();
  }
}
