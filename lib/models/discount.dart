enum DiscountType { percent, flat }

class DiscountRule {
  const DiscountRule({
    required this.id,
    required this.name,
    required this.type,
    required this.value,
    required this.minPurchase,
    required this.active,
    this.code,
  });

  final int id;
  final String name;
  final DiscountType type;
  final int value;
  final int minPurchase;
  final bool active;
  final String? code;

  factory DiscountRule.fromMap(Map<String, dynamic> map) {
    return DiscountRule(
      id: map['id'] as int,
      name: map['name'] as String,
      type: (map['type'] as String) == 'flat' ? DiscountType.flat : DiscountType.percent,
      value: map['value'] as int,
      minPurchase: map['min_purchase'] as int? ?? 0,
      active: map['is_active'] as bool? ?? true,
      code: map['promo_code'] as String?,
    );
  }
}
