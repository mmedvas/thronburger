import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/auth/auth_bloc.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/dashboard/dashboard_shell.dart';
import '../screens/dashboard/dashboard_home_screen.dart';
import '../screens/pos/pos_screen.dart';
import '../screens/live_queue/live_queue_screen.dart';
import '../screens/orders/order_history_screen.dart';
import '../screens/menu_admin/menu_admin_screen.dart';
import '../screens/reports/reports_screen.dart';

/// Admin Panel Router configuration
class AppRouter {
  final AuthBloc authBloc;

  AppRouter({required this.authBloc});

  late final GoRouter router = GoRouter(
    initialLocation: '/login',
    refreshListenable: GoRouterRefreshStream(authBloc.stream),
    redirect: (context, state) {
      final authState = authBloc.state;
      final isAuthenticated = authState.status == AuthStatus.authenticated;
      final location = state.matchedLocation;

      final isOnAuthPage = location == '/login' || location == '/signup';

      // Redirect to login if not authenticated
      if (!isAuthenticated && !isOnAuthPage) {
        return '/login';
      }

      // Redirect to dashboard if authenticated and on auth page
      if (isAuthenticated && isOnAuthPage) {
        return '/dashboard/home';
      }

      return null;
    },
    routes: [
      // Auth routes
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        name: 'signup',
        builder: (context, state) => const SignupScreen(),
      ),

      // Dashboard shell with nested routes
      ShellRoute(
        builder: (context, state, child) => DashboardShell(child: child),
        routes: [
          GoRoute(
            path: '/dashboard/home',
            name: 'home',
            builder: (context, state) => const DashboardHomeScreen(),
          ),
          GoRoute(
            path: '/dashboard/pos',
            name: 'pos',
            builder: (context, state) => const PosScreen(),
          ),
          GoRoute(
            path: '/dashboard/queue',
            name: 'queue',
            builder: (context, state) => const LiveQueueScreen(),
          ),
          GoRoute(
            path: '/dashboard/history',
            name: 'history',
            builder: (context, state) => const OrderHistoryScreen(),
          ),
          GoRoute(
            path: '/dashboard/menu',
            name: 'menu',
            builder: (context, state) => const MenuAdminScreen(),
          ),
          GoRoute(
            path: '/dashboard/reports',
            name: 'reports',
            builder: (context, state) {
              final authBloc = context.read<AuthBloc>();
              if (!authBloc.state.isAdmin) {
                return const _UnauthorizedPage();
              }
              return const ReportsScreen();
            },
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => const _ErrorPage(),
  );
}

/// Unauthorized access page
class _UnauthorizedPage extends StatelessWidget {
  const _UnauthorizedPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Access Denied')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text('Admin access required', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/dashboard/pos'),
              child: const Text('Go to POS'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Error page for unknown routes
class _ErrorPage extends StatelessWidget {
  const _ErrorPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Page Not Found')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.orange),
            const SizedBox(height: 16),
            const Text('Page not found', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/dashboard/pos'),
              child: const Text('Go to Dashboard'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Stream listener for GoRouter refresh
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    stream.listen((_) {
      notifyListeners();
    });
  }
}
