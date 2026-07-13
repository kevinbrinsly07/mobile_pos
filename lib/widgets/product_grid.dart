import 'package:flutter/material.dart';

import '../models/product.dart';
import '../utils/currency.dart';

class ProductGrid extends StatelessWidget {
  const ProductGrid({
    super.key,
    required this.products,
    required this.currencyFormatter,
    required this.onTap,
  });

  final List<Product> products;
  final CurrencyFormatter currencyFormatter;
  final ValueChanged<Product> onTap;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = screenWidth < 800;

    final int crossAxisCount = isCompact ? 3 : (screenWidth > 1200 ? 5 : 4);
    final double childAspectRatio = isCompact ? 0.85 : 1.1;
    final double spacing = isCompact ? 8.0 : 12.0;

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        final initials = product.name.isNotEmpty
            ? product.name.trim().split(' ').map((e) => e[0]).take(2).join().toUpperCase()
            : 'PR';

        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0c0f0a),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF000000), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => onTap(product),
              borderRadius: BorderRadius.circular(12),
              splashColor: const Color(0xFFf77f00).withOpacity(0.1),
              highlightColor: const Color(0xFFf77f00).withOpacity(0.05),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFf77f00), Color(0xFFf77f00)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            initials,
                            style: const TextStyle(
                              color: Color(0xFF0B0F19),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (product.sku.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1.5),
                            decoration: BoxDecoration(
                              color: const Color(0xFF26324D),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              product.sku,
                              style: const TextStyle(
                                fontSize: 8,
                                color: Colors.white70,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      currencyFormatter.cents(product.priceCents),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFf77f00),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
