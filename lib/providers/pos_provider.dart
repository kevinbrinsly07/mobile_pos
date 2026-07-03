import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/sale.dart';
import '../services/offline_queue_service.dart';
import '../services/pos_service.dart';
import 'auth_provider.dart';

final offlineQueueServiceProvider = Provider<OfflineQueueService>(
  (ref) => OfflineQueueService(),
);

final posServiceProvider = Provider<PosService>((ref) {
  return PosService(ref.read(offlineQueueServiceProvider));
});

class PosState {
  const PosState({
    this.items = const <CartItem>[],
    this.cartDiscountCents = 0,
    this.payments = const <SplitPayment>[],
    this.customerId,
    this.amountTenderedCents = 0,
  });

  final List<CartItem> items;
  final int cartDiscountCents;
  final List<SplitPayment> payments;
  final int? customerId;
  final int amountTenderedCents;

  PosState copyWith({
    List<CartItem>? items,
    int? cartDiscountCents,
    List<SplitPayment>? payments,
    int? customerId,
    int? amountTenderedCents,
  }) {
    return PosState(
      items: items ?? this.items,
      cartDiscountCents: cartDiscountCents ?? this.cartDiscountCents,
      payments: payments ?? this.payments,
      customerId: customerId ?? this.customerId,
      amountTenderedCents: amountTenderedCents ?? this.amountTenderedCents,
    );
  }
}

class PosController extends Notifier<PosState> {
  @override
  PosState build() {
    ref.read(offlineQueueServiceProvider).init();
    return const PosState();
  }

  void addItem(CartItem item) {
    final existingIndex = state.items.indexWhere(
      (i) => i.product.id == item.product.id && i.variantId == item.variantId,
    );
    if (existingIndex == -1) {
      state = state.copyWith(items: [...state.items, item]);
      return;
    }

    final updated = [...state.items];
    final old = updated[existingIndex];
    updated[existingIndex] = old.copyWith(quantity: old.quantity + 1);
    state = state.copyWith(items: updated);
  }

  void removeItem(CartItem item) {
    state = state.copyWith(items: state.items.where((i) => i != item).toList());
  }

  void updateQuantity(CartItem item, int qty) {
    final updated = state.items
        .map((i) => i == item ? i.copyWith(quantity: qty < 1 ? 1 : qty) : i)
        .toList();
    state = state.copyWith(items: updated);
  }

  void setCartDiscount(int cents) {
    state = state.copyWith(cartDiscountCents: cents);
  }

  void setAmountTendered(int cents) {
    state = state.copyWith(amountTenderedCents: cents);
  }

  void addPayment(SplitPayment payment) {
    state = state.copyWith(payments: [...state.payments, payment]);
  }

  Future<void> checkout({required int shiftId}) async {
    final user = ref.read(authStateProvider).valueOrNull;
    if (user == null || state.items.isEmpty) {
      return;
    }

    final draft = SaleDraft(
      storeId: user.storeId,
      shiftId: shiftId,
      cashierId: user.id,
      customerId: state.customerId,
      items: state.items,
      cartDiscountCents: state.cartDiscountCents,
      payments: state.payments,
      amountTenderedCents: state.amountTenderedCents,
    );

    await ref.read(posServiceProvider).submitSale(draft);
    state = const PosState();
  }
}

final posProvider = NotifierProvider<PosController, PosState>(PosController.new);
