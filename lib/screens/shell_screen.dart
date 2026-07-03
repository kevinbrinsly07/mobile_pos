import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';
import '../utils/role_permissions.dart';

class ShellScreen extends ConsumerWidget {
  const ShellScreen({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).valueOrNull;
    final location = GoRouterState.of(context).matchedLocation;

    final tabs = <({String label, IconData icon, String path, bool enabled})>[
      (label: 'POS', icon: Icons.point_of_sale, path: '/pos', enabled: true),
      (label: 'Dashboard', icon: Icons.dashboard, path: '/dashboard', enabled: true),
      (label: 'Inventory', icon: Icons.inventory_2, path: '/inventory', enabled: true),
      (label: 'Customers', icon: Icons.people, path: '/customers', enabled: true),
      (label: 'Sales', icon: Icons.receipt_long, path: '/sales-history', enabled: true),
      (label: 'Reports', icon: Icons.bar_chart, path: '/reports', enabled: true),
      (label: 'Shifts', icon: Icons.access_time, path: '/shifts', enabled: true),
      (
        label: 'Staff',
        icon: Icons.manage_accounts,
        path: '/staff',
        enabled: user != null && RolePermissions.canManageStaff(user.role),
      ),
      (label: 'Settings', icon: Icons.settings, path: '/settings', enabled: true),
    ];

    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: tabs.indexWhere((item) => location == item.path),
            destinations: tabs
                .map(
                  (item) => NavigationRailDestination(
                    icon: Icon(item.icon),
                    label: Text(item.label),
                  ),
                )
                .toList(),
            onDestinationSelected: (index) {
              final selected = tabs[index];
              if (selected.enabled) {
                context.go(selected.path);
              }
            },
            trailing: Padding(
              padding: const EdgeInsets.only(top: 16),
              child: IconButton(
                onPressed: () => ref.read(authStateProvider.notifier).signOut(),
                icon: const Icon(Icons.logout),
              ),
            ),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}
