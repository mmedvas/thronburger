import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import '../../l10n/app_localizations.dart';
import '../../config/theme.dart';
import '../../blocs/customer_cart/customer_cart_bloc.dart';
import '../../repositories/repositories.dart';
import '../../models/models.dart';
import '../../services/notification_service.dart';

/// Customer Shell
/// Bottom navigation shell for customer app
class CustomerShell extends StatefulWidget {
  final Widget child;

  const CustomerShell({super.key, required this.child});

  @override
  State<CustomerShell> createState() => _CustomerShellState();
}

class _CustomerShellState extends State<CustomerShell> {
  StreamSubscription<List<Order>>? _orderSubscription;
  Map<String, OrderStatus> _previousStatuses = {};

  @override
  void initState() {
    super.initState();
    _setupOrderListener();
  }

  void _setupOrderListener() {
    final user = context.read<CustomerRepository>().currentUser;
    if (user != null) {
      _orderSubscription = context
          .read<OrderRepository>()
          .subscribeToCustomerOrders(user.uid)
          .listen(
            (orders) {
              print(
                '🔔 [CustomerShell] Received ${orders.length} orders update',
              );
              for (final order in orders) {
                // If we have seen this order before, check if status changed
                if (_previousStatuses.containsKey(order.id)) {
                  final previousStatus = _previousStatuses[order.id];
                  print(
                    '🔔 [CustomerShell] Order ${order.orderNumber}: $previousStatus -> ${order.status}',
                  );
                  if (previousStatus != order.status) {
                    // Status changed! Show notification
                    print(
                      '🔔 [CustomerShell] Showing notification for Order ${order.orderNumber}',
                    );
                    NotificationService().showOrderStatusNotification(order);
                  }
                }
                // Update status tracker
                _previousStatuses[order.id] = order.status;
              }
            },
            onError: (e) {
              print('🔔 [CustomerShell] Error in order stream: $e');
            },
          );
    }
  }

  @override
  void dispose() {
    _orderSubscription?.cancel();
    super.dispose();
  }

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/customer/menu')) return 1;
    if (location.startsWith('/customer/cart')) return 2;
    if (location.startsWith('/customer/orders')) return 3;
    if (location.startsWith('/customer/profile')) return 4;
    return 0; // Home
  }

  void _onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/customer');
        break;
      case 1:
        context.go('/customer/menu');
        break;
      case 2:
        context.go('/customer/cart');
        break;
      case 3:
        context.go('/customer/orders');
        break;
      case 4:
        context.go('/customer/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: BlocBuilder<CustomerCartBloc, CustomerCartState>(
        builder: (context, cartState) {
          return NavigationBar(
            selectedIndex: _calculateSelectedIndex(context),
            onDestinationSelected: (index) => _onItemTapped(context, index),
            backgroundColor: AppTheme.surface,
            indicatorColor: AppTheme.primary.withValues(alpha: 0.2),
            destinations: [
              NavigationDestination(
                icon: const Icon(Icons.home_outlined),
                selectedIcon: const Icon(Icons.home, color: AppTheme.primary),
                label: l10n.home,
              ),
              NavigationDestination(
                icon: const Icon(Icons.restaurant_menu_outlined),
                selectedIcon: const Icon(
                  Icons.restaurant_menu,
                  color: AppTheme.primary,
                ),
                label: l10n.menu,
              ),
              NavigationDestination(
                icon: Badge(
                  isLabelVisible: cartState.itemCount > 0,
                  label: Text('${cartState.itemCount}'),
                  child: const Icon(Icons.shopping_cart_outlined),
                ),
                selectedIcon: Badge(
                  isLabelVisible: cartState.itemCount > 0,
                  label: Text('${cartState.itemCount}'),
                  child: const Icon(
                    Icons.shopping_cart,
                    color: AppTheme.primary,
                  ),
                ),
                label: l10n.cart,
              ),
              NavigationDestination(
                icon: const Icon(Icons.receipt_long_outlined),
                selectedIcon: const Icon(
                  Icons.receipt_long,
                  color: AppTheme.primary,
                ),
                label: l10n.orders,
              ),
              NavigationDestination(
                icon: const Icon(Icons.person_outline),
                selectedIcon: const Icon(Icons.person, color: AppTheme.primary),
                label: l10n.profile,
              ),
            ],
          );
        },
      ),
    );
  }
}
