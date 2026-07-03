enum UserRole { owner, admin, manager, cashier }

class RolePermissions {
  static bool canRefund(UserRole role) =>
      role == UserRole.owner || role == UserRole.admin || role == UserRole.manager;

  static bool canOverridePrice(UserRole role) =>
      role == UserRole.owner || role == UserRole.admin || role == UserRole.manager;

  static bool canManageStaff(UserRole role) =>
      role == UserRole.owner || role == UserRole.admin;

  static bool canViewCrossStore(UserRole role) =>
      role == UserRole.owner || role == UserRole.admin;
}
