class Shift {
  const Shift({
    required this.id,
    required this.storeId,
    required this.cashierId,
    required this.openingFloatCents,
    required this.status,
    required this.openedAt,
    this.closingFloatCents,
    this.closedAt,
  });

  final int id;
  final int storeId;
  final String cashierId;
  final int openingFloatCents;
  final int? closingFloatCents;
  final String status;
  final DateTime openedAt;
  final DateTime? closedAt;

  factory Shift.fromMap(Map<String, dynamic> map) {
    return Shift(
      id: map['id'] as int,
      storeId: map['store_id'] as int,
      cashierId: map['cashier_id'] as String,
      openingFloatCents: map['opening_float'] as int,
      closingFloatCents: map['closing_float'] as int?,
      status: map['status'] as String? ?? 'open',
      openedAt: DateTime.parse(map['opened_at'] as String),
      closedAt: map['closed_at'] != null
          ? DateTime.parse(map['closed_at'] as String)
          : null,
    );
  }
}
