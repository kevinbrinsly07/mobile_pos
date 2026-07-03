import 'product.dart';

class CartItem {
  CartItem({
    required this.product,
    this.variantId,
    this.variantName,
    this.quantity = 1,
    this.discountCents = 0,
    this.modifiers = const <String>[],
  });

  final Product product;
  final int? variantId;
  final String? variantName;
  final int quantity;
  final int discountCents;
  final List<String> modifiers;

  int get unitPriceCents => product.priceCents;
  int get subtotalCents => unitPriceCents * quantity;
  int get lineTaxCents => ((subtotalCents - discountCents) * product.taxRateBasisPoints) ~/ 10000;
  int get totalCents => subtotalCents - discountCents + lineTaxCents;

  CartItem copyWith({
    int? quantity,
    int? discountCents,
    List<String>? modifiers,
  }) {
    return CartItem(
      product: product,
      variantId: variantId,
      variantName: variantName,
      quantity: quantity ?? this.quantity,
      discountCents: discountCents ?? this.discountCents,
      modifiers: modifiers ?? this.modifiers,
    );
  }
}

enum PaymentMethod { cash, card, mobileWallet }

class SplitPayment {
  const SplitPayment({required this.method, required this.amountCents});

  final PaymentMethod method;
  final int amountCents;

  Map<String, dynamic> toMap() {
    return {'method': method.name, 'amount': amountCents};
  }
}

class SaleDraft {
  SaleDraft({
    required this.storeId,
    required this.shiftId,
    required this.cashierId,
    this.customerId,
    this.items = const <CartItem>[],
    this.cartDiscountCents = 0,
    this.payments = const <SplitPayment>[],
    this.amountTenderedCents = 0,
  });

  final int storeId;
  final int shiftId;
  final String cashierId;
  final int? customerId;
  final List<CartItem> items;
  final int cartDiscountCents;
  final List<SplitPayment> payments;
  final int amountTenderedCents;

  int get subtotalCents =>
      items.fold<int>(0, (sum, item) => sum + item.subtotalCents);

  int get lineDiscountCents =>
      items.fold<int>(0, (sum, item) => sum + item.discountCents);

  int get taxCents => items.fold<int>(0, (sum, item) => sum + item.lineTaxCents);

  int get totalCents => subtotalCents - lineDiscountCents - cartDiscountCents + taxCents;

  int get paidCents =>
      payments.fold<int>(0, (sum, payment) => sum + payment.amountCents);

  int get changeDueCents => amountTenderedCents > totalCents
      ? amountTenderedCents - totalCents
      : 0;

  bool get isFullyPaid => paidCents >= totalCents;
}
