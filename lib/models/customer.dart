class Customer {
  const Customer({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.loyaltyPoints,
    required this.totalSpentCents,
  });

  final int id;
  final String name;
  final String? phone;
  final String? email;
  final int loyaltyPoints;
  final int totalSpentCents;

  factory Customer.fromMap(Map<String, dynamic> map) {
    return Customer(
      id: map['id'] as int,
      name: map['name'] as String,
      phone: map['phone'] as String?,
      email: map['email'] as String?,
      loyaltyPoints: map['loyalty_points'] as int? ?? 0,
      totalSpentCents: map['total_spent'] as int? ?? 0,
    );
  }
}
