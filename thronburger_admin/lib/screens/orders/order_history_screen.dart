import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../config/theme.dart';
import '../../models/models.dart';
import '../../repositories/repositories.dart';
import '../../services/printing/printing_service.dart';

/// Order History Screen
/// Shows completed and cancelled orders with filtering
class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  List<Order> _orders = [];
  bool _isLoading = true;
  DateTimeRange? _dateRange;

  @override
  void initState() {
    super.initState();
    // Default to last 7 days
    _dateRange = DateTimeRange(
      start: DateTime.now().subtract(const Duration(days: 7)),
      end: DateTime.now(),
    );
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() => _isLoading = true);
    try {
      final orderRepo = context.read<OrderRepository>();
      final orders = await orderRepo.getOrders(
        fromDate: _dateRange?.start,
        toDate: _dateRange?.end,
      );
      setState(() {
        _orders = orders;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load orders: $e'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  Future<void> _selectDateRange() async {
    final result = await showDateRangePicker(
      context: context,
      initialDateRange: _dateRange,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.primary,
              surface: AppTheme.surface,
            ),
          ),
          child: child!,
        );
      },
    );

    if (result != null) {
      setState(() => _dateRange = result);
      _loadOrders();
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormatter = DateFormat('MMM d');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order History'),
        actions: [
          // Date range filter
          TextButton.icon(
            onPressed: _selectDateRange,
            icon: const Icon(Icons.calendar_today, size: 18),
            label: Text(
              _dateRange != null
                  ? '${dateFormatter.format(_dateRange!.start)} - ${dateFormatter.format(_dateRange!.end)}'
                  : 'Select dates',
            ),
          ),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadOrders),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _orders.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _orders.length,
              itemBuilder: (context, index) {
                return _OrderHistoryCard(order: _orders[index]);
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long, size: 64, color: AppTheme.textMuted),
          const SizedBox(height: 16),
          Text(
            'No orders found',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            'Try selecting a different date range',
            style: TextStyle(color: AppTheme.textMuted),
          ),
        ],
      ),
    );
  }
}

class _OrderHistoryCard extends StatelessWidget {
  final Order order;

  const _OrderHistoryCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,###', 'en');
    final dateFormatter = DateFormat('MMM d, h:mm a');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showOrderDetails(context),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Order number
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: _getStatusColor(order.status).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '#${order.orderNumber}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _getStatusColor(order.status),
                      ),
                    ),
                    Icon(
                      _getStatusIcon(order.status),
                      size: 16,
                      color: _getStatusColor(order.status),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Order info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          order.customerName ?? order.orderType.label,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        if (order.isOnlineOrder) ...[
                          const SizedBox(width: 8),
                          Icon(Icons.public, size: 14, color: AppTheme.info),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dateFormatter.format(order.createdAt.toLocal()),
                      style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${order.items.length} items',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              // Total
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${formatter.format(order.totalAmount.toInt())} IQD',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(
                        order.status,
                      ).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      order.status.label,
                      style: TextStyle(
                        color: _getStatusColor(order.status),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right, color: AppTheme.textMuted),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return AppTheme.statusPending;
      case OrderStatus.preparing:
        return AppTheme.statusPreparing;
      case OrderStatus.ready:
        return AppTheme.statusReady;
      case OrderStatus.completed:
        return AppTheme.statusCompleted;
      case OrderStatus.cancelled:
        return AppTheme.statusCancelled;
    }
  }

  IconData _getStatusIcon(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Icons.hourglass_empty;
      case OrderStatus.preparing:
        return Icons.restaurant;
      case OrderStatus.ready:
        return Icons.check_circle_outline;
      case OrderStatus.completed:
        return Icons.done_all;
      case OrderStatus.cancelled:
        return Icons.cancel_outlined;
    }
  }

  void _showOrderDetails(BuildContext context) {
    final formatter = NumberFormat('#,###', 'en');
    final dateFormatter = DateFormat('MMM d, yyyy h:mm a');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(24),
          child: ListView(
            controller: scrollController,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Order #${order.orderNumber}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(order.status),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      order.status.label,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                dateFormatter.format(order.createdAt.toLocal()),
                style: TextStyle(color: AppTheme.textSecondary),
              ),

              // Customer info
              if (order.isOnlineOrder) ...[
                const SizedBox(height: 24),
                const Text(
                  'Customer',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                if (order.customerName != null) Text(order.customerName!),
                if (order.customerPhone != null)
                  Text(
                    order.customerPhone!,
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                if (order.customerAddress != null)
                  Text(
                    order.customerAddress!,
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
              ],

              // Items
              const SizedBox(height: 24),
              const Text(
                'Items',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...order.items.map(
                (item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceLight,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Center(
                          child: Text(
                            '${item.quantity}x',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Text(item.menuItem?.name ?? 'Item')),
                      Text(
                        '${formatter.format(item.lineTotal.toInt())} IQD',
                        style: TextStyle(color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                ),
              ),

              // Notes
              if (order.notes != null && order.notes!.isNotEmpty) ...[
                const SizedBox(height: 24),
                const Text(
                  'Notes',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(order.notes!),
                ),
              ],

              // Total
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  Text(
                    '${formatter.format(order.totalAmount.toInt())} IQD',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: AppTheme.primary,
                    ),
                  ),
                ],
              ),

              // Print buttons
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),
              const Text(
                'Reprint',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _printKitchenTicket(context, order),
                      icon: const Icon(Icons.restaurant, size: 18),
                      label: const Text('Kitchen Ticket'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.orange.shade700,
                        side: BorderSide(color: Colors.orange.shade300),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _printReceipt(context, order),
                      icon: const Icon(Icons.receipt_long, size: 18),
                      label: const Text('Receipt'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.black,
                      ),
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

  Future<void> _printKitchenTicket(BuildContext context, Order order) async {
    try {
      await PrintingService().printKitchenTicket(order);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to print kitchen ticket: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _printReceipt(BuildContext context, Order order) async {
    try {
      await PrintingService().printReceipt(order);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to print receipt: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
