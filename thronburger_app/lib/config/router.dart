import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
// Customer screens
import '../screens/customer/customer_shell.dart';
import '../screens/customer/customer_home_screen.dart';
import '../screens/customer/menu_browse_screen.dart';
import '../screens/customer/cart_screen.dart';
import '../screens/customer/checkout_screen.dart';
import '../screens/customer/customer_orders_screen.dart';
import '../screens/customer/customer_profile_screen.dart';
// Customer auth screens
import '../screens/customer/auth/phone_input_screen.dart';
import '../screens/customer/auth/otp_verification_screen.dart';
import '../screens/customer/auth/name_entry_screen.dart';

/// App Router configuration using go_router
/// Customer-only app - Staff panel is separate
class AppRouter {
  AppRouter();

  late final GoRouter router = GoRouter(
    initialLocation: '/customer',
    redirect: (context, state) {
      final isLoggedIn = FirebaseAuth.instance.currentUser != null;
      final location = state.matchedLocation;
      final isOnAuthPage = location.startsWith('/customer/auth');
      final isOnMainAuthPage = location == '/customer/auth';

      // Not logged in and not on auth page → go to sign in
      if (!isLoggedIn && !isOnAuthPage) {
        return '/customer/auth';
      }

      // Logged in and on the main auth page (phone input) → go to home
      // Don't redirect from /verify or /name — user may still be completing auth
      if (isLoggedIn && isOnMainAuthPage) {
        return '/customer';
      }

      // No redirect needed
      return null;
    },
    routes: [
      // Redirect root to customer home
      GoRoute(path: '/', redirect: (context, state) => '/customer'),

      // Customer Auth Routes
      GoRoute(
        path: '/customer/auth',
        name: 'customer-auth',
        builder: (context, state) => const PhoneInputScreen(),
      ),
      GoRoute(
        path: '/customer/auth/verify',
        name: 'customer-auth-verify',
        builder: (context, state) {
          final phone = state.extra as String? ?? '';
          return OtpVerificationScreen(phone: phone);
        },
      ),
      GoRoute(
        path: '/customer/auth/name',
        name: 'customer-auth-name',
        builder: (context, state) => const NameEntryScreen(),
      ),

      // Customer Shell with nested routes
      ShellRoute(
        builder: (context, state, child) => CustomerShell(child: child),
        routes: [
          GoRoute(
            path: '/customer',
            name: 'customer-home',
            builder: (context, state) => const CustomerHomeScreen(),
          ),
          GoRoute(
            path: '/customer/menu',
            name: 'customer-menu',
            builder: (context, state) {
              final category = state.uri.queryParameters['category'];
              return MenuBrowseScreen(initialCategory: category);
            },
          ),
          GoRoute(
            path: '/customer/cart',
            name: 'customer-cart',
            builder: (context, state) => const CartScreen(),
          ),
          GoRoute(
            path: '/customer/orders',
            name: 'customer-orders',
            builder: (context, state) => const CustomerOrdersScreen(),
          ),
          GoRoute(
            path: '/customer/profile',
            name: 'customer-profile',
            builder: (context, state) => const CustomerProfileScreen(),
          ),
        ],
      ),

      // Customer Checkout (outside shell for full screen)
      GoRoute(
        path: '/customer/checkout',
        name: 'customer-checkout',
        builder: (context, state) => const CheckoutScreen(),
      ),
    ],
    errorBuilder: (context, state) => const _ErrorPage(),
  );
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
              onPressed: () => context.go('/customer'),
              child: const Text('Go to Home'),
            ),
          ],
        ),
      ),
    );
  }
}
