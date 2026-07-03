import '../utils/role_permissions.dart';

class AppUser {
  const AppUser({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    required this.organizationId,
    required this.storeId,
  });

  final String id;
  final String email;
  final String fullName;
  final UserRole role;
  final int organizationId;
  final int storeId;

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: map['id'] as String,
      email: map['email'] as String? ?? '',
      fullName: map['full_name'] as String? ?? '',
      role: UserRole.values.firstWhere(
        (r) => r.name == (map['role'] as String? ?? 'cashier'),
        orElse: () => UserRole.cashier,
      ),
      organizationId: map['organization_id'] as int? ?? 0,
      storeId: map['store_id'] as int? ?? 0,
    );
  }
}
