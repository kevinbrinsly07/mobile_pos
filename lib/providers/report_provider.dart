import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/report_models.dart';
import '../services/report_service.dart';
import 'auth_provider.dart';

final reportServiceProvider = Provider<ReportService>((ref) => ReportService());

final salesSummaryProvider = FutureProvider<SalesSnapshot>((ref) async {
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user == null) {
    return const SalesSnapshot(
      revenueCents: 0,
      transactions: 0,
      avgBasketCents: 0,
      cashCents: 0,
      cardCents: 0,
      walletCents: 0,
    );
  }
  return ref.read(reportServiceProvider).summary(storeId: user.storeId);
});

final topProductsProvider = FutureProvider<List<TopProduct>>((ref) async {
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user == null) {
    return <TopProduct>[];
  }
  return ref.read(reportServiceProvider).topProducts(storeId: user.storeId);
});
