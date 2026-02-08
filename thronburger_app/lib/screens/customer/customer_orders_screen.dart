import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart' hide TextDirection;
import '../../config/theme.dart';
import '../../models/models.dart';
import '../../repositories/repositories.dart';

/// Customer Orders Screen
/// Order history and tracking
class CustomerOrdersScreen extends StatefulWidget {
  const CustomerOrdersScreen({super.key});

  @override
  State<CustomerOrdersScreen> createState() => _CustomerOrdersScreenState();
}

class _CustomerOrdersScreenState extends State<CustomerOrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final customerRepo = context.read<CustomerRepository>();
    final orderRepo = context.read<OrderRepository>();
    final user = customerRepo.currentUser;

    if (user == null) {
      return const Center(child: Text('Please sign in to view orders'));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
        backgroundColor: AppTheme.background,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primary,
          labelColor: AppTheme.primary,
          unselectedLabelColor: AppTheme.textSecondary,
          tabs: const [
            Tab(text: 'Active'),
            Tab(text: 'Past'),
          ],
        ),
      ),
      body: StreamBuilder<List<Order>>(
        stream: orderRepo.subscribeToCustomerOrders(user.uid),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            print(
              '🔔 [CustomerOrdersScreen] StreamBuilder received ${snapshot.data!.length} orders',
            );
          } else if (snapshot.hasError) {
            print(
              '🔔 [CustomerOrdersScreen] StreamBuilder error: ${snapshot.error}',
            );
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final orders = snapshot.data!;
          final activeOrders = orders
              .where(
                (o) =>
                    o.status == OrderStatus.pending ||
                    o.status == OrderStatus.preparing ||
                    o.status == OrderStatus.ready,
              )
              .toList();

          final pastOrders = orders
              .where(
                (o) =>
                    o.status == OrderStatus.completed ||
                    o.status == OrderStatus.cancelled,
              )
              .toList();

          return TabBarView(
            controller: _tabController,
            children: [
              // Active Orders
              activeOrders.isEmpty
                  ? _emptyState('No active orders')
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: activeOrders.length,
                      itemBuilder: (context, index) {
                        return _OrderCard(
                          order: activeOrders[index],
                          onTap: () => _showOrderDetail(activeOrders[index]),
                        );
                      },
                    ),
              // Past Orders
              pastOrders.isEmpty
                  ? _emptyState('No past orders')
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: pastOrders.length,
                      itemBuilder: (context, index) {
                        return _OrderCard(
                          order: pastOrders[index],
                          onTap: () => _showOrderDetail(pastOrders[index]),
                        );
                      },
                    ),
            ],
          );
        },
      ),
    );
  }

  Widget _emptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 64,
            color: AppTheme.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(message, style: TextStyle(color: AppTheme.textSecondary)),
        ],
      ),
    );
  }

  void _showOrderDetail(Order order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _OrderDetailSheet(order: order),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback onTap;

  const _OrderCard({required this.order, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Order #${order.orderNumber}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  _StatusChip(status: order.status),
                ],
              ),
              const SizedBox(height: 12),

              // Items preview
              Text(
                order.items
                    .map((i) => '${i.quantity}x ${i.menuItem?.name ?? 'Item'}')
                    .join(', '),
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),

              // Footer
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat('MMM d, h:mm a').format(order.createdAt),
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    '${order.totalAmount.toStringAsFixed(0)} IQD',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final OrderStatus status;

  const _StatusChip({required this.status});

  Color get _color {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.preparing:
        return Colors.blue;
      case OrderStatus.ready:
        return AppTheme.success;
      case OrderStatus.completed:
        return AppTheme.textSecondary;
      case OrderStatus.cancelled:
        return AppTheme.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: _color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _OrderDetailSheet extends StatelessWidget {
  final Order order;

  const _OrderDetailSheet({required this.order});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.textSecondary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order #${order.orderNumber}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat(
                          'MMMM d, yyyy • h:mm a',
                        ).format(order.createdAt),
                        style: TextStyle(color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                  _StatusChip(status: order.status),
                ],
              ),
              const SizedBox(height: 24),

              // Status Timeline
              if (order.status != OrderStatus.cancelled) ...[
                _OrderTimeline(status: order.status),
                const SizedBox(height: 24),
              ],

              // Order Type
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  order.orderType == OrderType.online
                      ? Icons.delivery_dining
                      : Icons.store,
                  color: AppTheme.primary,
                ),
                title: Text(
                  order.orderType == OrderType.online ? 'Delivery' : 'Pickup',
                ),
                subtitle: order.customerAddress != null
                    ? Text(order.customerAddress!)
                    : null,
              ),
              const Divider(),

              // Items
              const Text(
                'Items',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 12),
              ...order.items.map(
                (item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${item.quantity}x ${item.menuItem?.name ?? 'Item'}',
                      ),
                      Text(
                        '${(item.unitPrice * item.quantity).toStringAsFixed(0)} IQD',
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(height: 32),

              // Total
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  Text(
                    '${order.totalAmount.toStringAsFixed(0)} IQD',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: AppTheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Notes
              if (order.notes != null && order.notes!.isNotEmpty) ...[
                const Text(
                  'Notes',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  order.notes!,
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _OrderTimeline extends StatelessWidget {
  final OrderStatus status;

  const _OrderTimeline({required this.status});

  @override
  Widget build(BuildContext context) {
    final steps = [
      ('Received', OrderStatus.pending),
      ('Preparing', OrderStatus.preparing),
      ('Ready', OrderStatus.ready),
      ('Completed', OrderStatus.completed),
    ];

    final currentIndex = steps.indexWhere((s) => s.$2 == status);

    return Row(
      children: List.generate(steps.length * 2 - 1, (index) {
        if (index.isOdd) {
          // Connector line
          final stepIndex = index ~/ 2;
          final isCompleted = stepIndex < currentIndex;
          return Expanded(
            child: Container(
              height: 3,
              color: isCompleted ? AppTheme.primary : AppTheme.border,
            ),
          );
        }

        // Step dot
        final stepIndex = index ~/ 2;
        final step = steps[stepIndex];
        final isCompleted = stepIndex <= currentIndex;
        final isCurrent = stepIndex == currentIndex;

        return Column(
          children: [
            Container(
              width: isCurrent ? 24 : 16,
              height: isCurrent ? 24 : 16,
              decoration: BoxDecoration(
                color: isCompleted ? AppTheme.primary : AppTheme.surface,
                border: Border.all(
                  color: isCompleted ? AppTheme.primary : AppTheme.border,
                  width: 2,
                ),
                shape: BoxShape.circle,
              ),
              child: isCompleted
                  ? const Icon(Icons.check, size: 12, color: Colors.black)
                  : null,
            ),
            const SizedBox(height: 4),
            Text(
              step.$1,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                color: isCompleted
                    ? AppTheme.textPrimary
                    : AppTheme.textSecondary,
              ),
            ),
          ],
        );
      }),
    );
  }
}
