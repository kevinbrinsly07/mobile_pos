import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';
import '../utils/role_permissions.dart';

class ShellScreen extends ConsumerWidget {
  const ShellScreen({super.key, required this.child});

  final Widget child;

  void _showMoreSheet(BuildContext context, WidgetRef ref) {
    final user = ref.read(authStateProvider).valueOrNull;
    final secondaryTabs = [
      (label: 'Customers', icon: Icons.people, path: '/customers', enabled: true),
      (label: 'Sales History', icon: Icons.receipt_long, path: '/sales-history', enabled: true),
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

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF000000),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Quick Menu',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          user != null ? 'Logged in as: ${user.role}' : '',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white60,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ref.read(authStateProvider.notifier).signOut();
                      },
                      icon: const Icon(Icons.logout, color: Colors.redAccent),
                      tooltip: 'Sign Out',
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(color: Color(0xFF212529)),
                const SizedBox(height: 16),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.1,
                  ),
                  itemCount: secondaryTabs.length,
                  itemBuilder: (context, index) {
                    final tab = secondaryTabs[index];
                    final isEnabled = tab.enabled;
                    return InkWell(
                      onTap: isEnabled
                          ? () {
                              Navigator.pop(context);
                              context.go(tab.path);
                            }
                          : null,
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF212529),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFFf77f00),
                            width: 1,
                          ),
                        ),
                        child: Opacity(
                          opacity: isEnabled ? 1.0 : 0.4,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(tab.icon, size: 28, color: const Color(0xFFf77f00)),
                              const SizedBox(height: 8),
                              Text(
                                tab.label,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).valueOrNull;
    final location = GoRouterState.of(context).matchedLocation;
    final isCompact = MediaQuery.of(context).size.width < 600;

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

    final currentPath = location;
    final bottomIndex = currentPath == '/pos'
        ? 0
        : currentPath == '/dashboard'
            ? 1
            : currentPath == '/inventory'
                ? 2
                : 3;

    return Scaffold(
      body: Row(
        children: [
          if (!isCompact)
            Container(
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF000000),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFF000000),
                  width: 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: NavigationRail(
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
                  trailing: Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: IconButton(
                          onPressed: () => ref.read(authStateProvider.notifier).signOut(),
                          icon: const Icon(Icons.logout, color: Colors.redAccent),
                          tooltip: 'Sign Out',
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          Expanded(child: child),
        ],
      ),
      bottomNavigationBar: isCompact
          ? Padding(
              padding: const EdgeInsets.only(left: 12, right: 12, bottom: 8, top: 12),
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black,
                      blurRadius: 36,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: NavigationBar(
                    selectedIndex: bottomIndex,
                    onDestinationSelected: (index) {
                      if (index == 3) {
                        _showMoreSheet(context, ref);
                      } else {
                        final path = index == 0
                            ? '/pos'
                            : index == 1
                                ? '/dashboard'
                                : '/inventory';
                        context.go(path);
                      }
                    },
                    destinations: const [
                      NavigationDestination(
                        icon: Icon(Icons.point_of_sale_outlined),
                        selectedIcon: Icon(Icons.point_of_sale),
                        label: 'POS',
                      ),
                      NavigationDestination(
                        icon: Icon(Icons.dashboard_outlined),
                        selectedIcon: Icon(Icons.dashboard),
                        label: 'Dashboard',
                      ),
                      NavigationDestination(
                        icon: Icon(Icons.inventory_2_outlined),
                        selectedIcon: Icon(Icons.inventory_2),
                        label: 'Inventory',
                      ),
                      NavigationDestination(
                        icon: Icon(Icons.more_horiz),
                        label: 'More',
                      ),
                    ],
                  ),
                ),
              ),
            )
          : null,
    );
  }
}
