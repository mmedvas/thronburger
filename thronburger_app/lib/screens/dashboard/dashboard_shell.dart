import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../config/theme.dart';

/// Dashboard Shell
/// Bottom navigation wrapper for dashboard screens
class DashboardShell extends StatelessWidget {
  final Widget child;

  const DashboardShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final isAdmin = authState.isAdmin;

        return Scaffold(
          body: child,
          bottomNavigationBar: _buildBottomNav(context, isAdmin),
          drawer: _buildDrawer(context, authState),
        );
      },
    );
  }

  Widget _buildBottomNav(BuildContext context, bool isAdmin) {
    final location = GoRouterState.of(context).matchedLocation;

    // Base destinations for all users
    final destinations = <NavigationDestination>[
      const NavigationDestination(
        icon: Icon(Icons.point_of_sale_outlined),
        selectedIcon: Icon(Icons.point_of_sale),
        label: 'POS',
      ),
      const NavigationDestination(
        icon: Icon(Icons.queue_outlined),
        selectedIcon: Icon(Icons.queue),
        label: 'Queue',
      ),
      const NavigationDestination(
        icon: Icon(Icons.receipt_long_outlined),
        selectedIcon: Icon(Icons.receipt_long),
        label: 'History',
      ),
    ];

    // Add admin destinations
    if (isAdmin) {
      destinations.addAll([
        const NavigationDestination(
          icon: Icon(Icons.restaurant_menu_outlined),
          selectedIcon: Icon(Icons.restaurant_menu),
          label: 'Menu',
        ),
        const NavigationDestination(
          icon: Icon(Icons.analytics_outlined),
          selectedIcon: Icon(Icons.analytics),
          label: 'Reports',
        ),
      ]);
    }

    final routes = ['/dashboard/pos', '/dashboard/queue', '/dashboard/history'];
    if (isAdmin) {
      routes.addAll(['/dashboard/menu', '/dashboard/reports']);
    }

    int selectedIndex = routes.indexOf(location);
    if (selectedIndex < 0) selectedIndex = 0;

    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: (index) {
        context.go(routes[index]);
      },
      destinations: destinations,
    );
  }

  Widget _buildDrawer(BuildContext context, AuthState authState) {
    final profile = authState.profile;

    return Drawer(
      child: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 24,
              bottom: 24,
              left: 24,
              right: 24,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.primary, AppTheme.primaryDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        'assets/icons/logo.png',
                        width: 48,
                        height: 48,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'THRONBURGER',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // User info
                if (profile != null) ...[
                  Text(
                    profile.fullName ?? 'Staff User',
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      profile.role.label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Navigation items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _DrawerItem(
                  icon: Icons.point_of_sale,
                  label: 'Point of Sale',
                  onTap: () {
                    Navigator.pop(context);
                    context.go('/dashboard/pos');
                  },
                ),
                _DrawerItem(
                  icon: Icons.queue,
                  label: 'Live Queue',
                  onTap: () {
                    Navigator.pop(context);
                    context.go('/dashboard/queue');
                  },
                ),
                _DrawerItem(
                  icon: Icons.receipt_long,
                  label: 'Order History',
                  onTap: () {
                    Navigator.pop(context);
                    context.go('/dashboard/history');
                  },
                ),
                if (authState.isAdmin) ...[
                  const Divider(height: 32),
                  const Padding(
                    padding: EdgeInsets.only(left: 16, bottom: 8),
                    child: Text(
                      'ADMIN',
                      style: TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  _DrawerItem(
                    icon: Icons.restaurant_menu,
                    label: 'Menu Management',
                    onTap: () {
                      Navigator.pop(context);
                      context.go('/dashboard/menu');
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.analytics,
                    label: 'Sales Reports',
                    onTap: () {
                      Navigator.pop(context);
                      context.go('/dashboard/reports');
                    },
                  ),
                ],
              ],
            ),
          ),

          // Logout button
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.logout, color: AppTheme.error),
            title: const Text(
              'Logout',
              style: TextStyle(color: AppTheme.error),
            ),
            onTap: () {
              Navigator.pop(context);
              context.read<AuthBloc>().add(const AuthLogoutRequested());
            },
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
        ],
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(leading: Icon(icon), title: Text(label), onTap: onTap);
  }
}
