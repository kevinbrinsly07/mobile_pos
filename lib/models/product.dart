class Product {
  const Product({
    required this.id,
    required this.storeId,
    required this.name,
    required this.priceCents,
    required this.costCents,
    required this.taxRateBasisPoints,
    required this.stockQty,
    required this.sku,
    required this.barcode,
    this.categoryId,
    this.imageUrl,
    this.isActive = true,
  });

  final int id;
  final int storeId;
  final String name;
  final int priceCents;
  final int costCents;
  final int taxRateBasisPoints;
  final int stockQty;
  final String sku;
  final String barcode;
  final int? categoryId;
  final String? imageUrl;
  final bool isActive;

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] as int,
      storeId: map['store_id'] as int,
      name: map['name'] as String,
      priceCents: map['price'] as int,
      costCents: map['cost'] as int? ?? 0,
      taxRateBasisPoints: map['tax_rate'] as int? ?? 0,
      stockQty: map['stock_qty'] as int? ?? 0,
      sku: map['sku'] as String? ?? '',
      barcode: map['barcode'] as String? ?? '',
      categoryId: map['category_id'] as int?,
      imageUrl: map['image_url'] as String?,
      isActive: map['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'store_id': storeId,
      'name': name,
      'price': priceCents,
      'cost': costCents,
      'tax_rate': taxRateBasisPoints,
      'stock_qty': stockQty,
      'sku': sku,
      'barcode': barcode,
      'category_id': categoryId,
      'image_url': imageUrl,
      'is_active': isActive,
    };
  }
}
