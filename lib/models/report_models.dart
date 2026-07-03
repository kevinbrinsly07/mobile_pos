class SalesSnapshot {
  const SalesSnapshot({
    required this.revenueCents,
    required this.transactions,
    required this.avgBasketCents,
    required this.cashCents,
    required this.cardCents,
    required this.walletCents,
  });

  final int revenueCents;
  final int transactions;
  final int avgBasketCents;
  final int cashCents;
  final int cardCents;
  final int walletCents;
}

class TopProduct {
  const TopProduct({required this.name, required this.qty});

  final String name;
  final int qty;
}
