import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../models/sale.dart';
import '../providers/inventory_provider.dart';
import '../providers/pos_provider.dart';
import '../providers/shift_provider.dart';
import '../utils/currency.dart';
import '../widgets/cart_panel.dart';
import '../widgets/loading_state.dart';
import '../widgets/payment_sheet.dart';
import '../widgets/product_grid.dart';
import '../widgets/status_banner.dart';

class PosScreen extends ConsumerWidget {
  const PosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productsProvider);
    final pos = ref.watch(posProvider);
    final shift = ref.watch(shiftProvider).valueOrNull;
    final currency = CurrencyFormatter(currencyCode: 'LKR');
    final draft = SaleDraft(
      storeId: 0,
      shiftId: shift?.id ?? 0,
      cashierId: '',
      items: pos.items,
      cartDiscountCents: pos.cartDiscountCents,
      payments: pos.payments,
      amountTenderedCents: pos.amountTenderedCents,
    );

    final isCompact = MediaQuery.of(context).size.width < 800;

    final productGridWidget = productsAsync.when(
      data: (products) => Padding(
        padding: const EdgeInsets.all(12),
        child: ProductGrid(
          products: products,
          currencyFormatter: currency,
          onTap: (product) => ref
              .read(posProvider.notifier)
              .addItem(CartItem(product: product)),
        ),
      ),
      loading: () => const LoadingState(),
      error: (error, _) => Center(child: Text('Error: $error')),
    );

    final cartPanelWidget = CartPanel(
      items: pos.items,
      currencyFormatter: currency,
      onIncrement: (item) => ref
          .read(posProvider.notifier)
          .updateQuantity(item, item.quantity + 1),
      onDecrement: (item) => ref
          .read(posProvider.notifier)
          .updateQuantity(item, item.quantity - 1),
      onRemove: (item) => ref.read(posProvider.notifier).removeItem(item),
      totalCents: draft.totalCents,
      onCheckout: shift == null
          ? () {}
          : () async {
              final payment = await showModalBottomSheet<SplitPayment>(
                context: context,
                isScrollControlled: true,
                builder: (_) => PaymentSheet(totalCents: draft.totalCents),
              );
              if (payment != null) {
                ref.read(posProvider.notifier).addPayment(payment);
                ref
                    .read(posProvider.notifier)
                    .setAmountTendered(
                      payment.method == PaymentMethod.cash
                          ? payment.amountCents
                          : draft.totalCents,
                    );
                await ref
                    .read(posProvider.notifier)
                    .checkout(shiftId: shift.id);
              }
            },
    );

    final appBar = AppBar(
      title: const Text('Checkout'),
      bottom: isCompact
          ? TabBar(
              indicatorColor: const Color(0xFFf77f00),
              labelColor: const Color(0xFFf77f00),
              unselectedLabelColor: Colors.white60,
              tabs: [
                const Tab(
                  icon: Icon(Icons.grid_view),
                  text: 'Products',
                ),
                Tab(
                  icon: Badge.count(
                    count: pos.items.fold(0, (sum, item) => sum + item.quantity),
                    isLabelVisible: pos.items.isNotEmpty,
                    child: const Icon(Icons.shopping_cart),
                  ),
                  text: 'Cart',
                ),
              ],
            )
          : null,
      actions: [
        IconButton(
          tooltip: 'Scan barcode',
          icon: const Icon(Icons.qr_code_scanner),
          onPressed: () {
            showModalBottomSheet<void>(
              context: context,
              builder: (_) => SizedBox(
                height: 360,
                child: MobileScanner(
                  onDetect: (capture) {
                    final barcode = capture.barcodes.first.rawValue;
                    if (barcode == null) {
                      return;
                    }
                    final products = productsAsync.valueOrNull ?? [];
                    final match = products.where((p) => p.barcode == barcode).firstOrNull;
                    if (match != null) {
                      ref.read(posProvider.notifier).addItem(CartItem(product: match));
                      Navigator.of(context).pop();
                    }
                  },
                ),
              ),
            );
          },
        ),
      ],
    );

    final body = Column(
      children: [
        if (shift == null)
          const StatusBanner(
            text: 'No open shift. Go to Shifts and open till first.',
          ),
        Expanded(
          child: isCompact
              ? TabBarView(
                  children: [
                    productGridWidget,
                    cartPanelWidget,
                  ],
                )
              : Row(
                  children: [
                    Expanded(flex: 3, child: productGridWidget),
                    SizedBox(
                      width: 400,
                      child: cartPanelWidget,
                    ),
                  ],
                ),
        ),
      ],
    );

    final scaffold = Scaffold(
      appBar: appBar,
      body: body,
    );

    if (isCompact) {
      return DefaultTabController(
        length: 2,
        child: scaffold,
      );
    } else {
      return scaffold;
    }
  }
}
