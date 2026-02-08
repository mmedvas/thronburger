import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../config/theme.dart';
import '../../models/models.dart';
import '../../repositories/repositories.dart';

/// Live Order Queue Screen
/// Kanban-style order board with real-time updates
class LiveQueueScreen extends StatefulWidget {
  const LiveQueueScreen({super.key});

  @override
  State<LiveQueueScreen> createState() => _LiveQueueScreenState();
}

class _LiveQueueScreenState extends State<LiveQueueScreen> {
  List<Order> _orders = [];
  bool _isLoading = true;
  bool _soundEnabled = true;
  StreamSubscription? _subscription;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _loadOrders();
    _subscribeToOrders();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _loadOrders() async {
    setState(() => _isLoading = true);
    try {
      final orderRepo = context.read<OrderRepository>();
      final orders = await orderRepo.getActiveOrders();
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

  void _subscribeToOrders() {
    final orderRepo = context.read<OrderRepository>();

    // Subscribe to new online orders for sound notifications
    // TODO: Re-implement new order notifications with Firebase Cloud Messaging
    // orderRepo.subscribeToNewOrders((order) {
    //   if (_soundEnabled && order.isOnlineOrder) {
    //     _playNotificationSound();
    //   }
    //   _loadOrders(); // Refresh the list
    // });

    // Subscribe to order changes
    _subscription = orderRepo.subscribeToActiveOrders().listen((orders) {
      if (mounted) {
        setState(() => _orders = orders);
      }
    });
  }

  Future<void> _playNotificationSound() async {
    try {
      // Use a simple beep sound
      await _audioPlayer.play(AssetSource('sounds/notification.mp3'));
    } catch (_) {
      // Fallback: try to use platform sounds
      debugPrint('Could not play notification sound');
    }
  }

  List<Order> _getOrdersByStatus(OrderStatus status) {
    return _orders.where((o) => o.status == status).toList();
  }

  Future<void> _updateStatus(Order order, OrderStatus newStatus) async {
    try {
      final orderRepo = context.read<OrderRepository>();
      await orderRepo.updateOrderStatus(order.id, newStatus);
      _loadOrders();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update order: $e'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWideScreen = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Order Queue'),
        actions: [
          // Sound toggle
          IconButton(
            icon: Icon(_soundEnabled ? Icons.volume_up : Icons.volume_off),
            onPressed: () {
              setState(() => _soundEnabled = !_soundEnabled);
            },
            tooltip: _soundEnabled
                ? 'Mute notifications'
                : 'Enable notifications',
          ),
          // Test sound
          if (_soundEnabled)
            IconButton(
              icon: const Icon(Icons.music_note),
              onPressed: _playNotificationSound,
              tooltip: 'Test sound',
            ),
          // Refresh
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadOrders),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : isWideScreen
          ? _buildWideLayout()
          : _buildTabLayout(),
    );
  }

  Widget _buildWideLayout() {
    return Row(
      children: [
        Expanded(
          child: _OrderColumn(
            title: 'Pending',
            icon: Icons.hourglass_empty,
            color: AppTheme.statusPending,
            orders: _getOrdersByStatus(OrderStatus.pending),
            onStatusChange: _updateStatus,
            primaryAction: OrderStatus.preparing,
            primaryActionLabel: 'Accept',
          ),
        ),
        const VerticalDivider(width: 1),
        Expanded(
          child: _OrderColumn(
            title: 'Preparing',
            icon: Icons.restaurant,
            color: AppTheme.statusPreparing,
            orders: _getOrdersByStatus(OrderStatus.preparing),
            onStatusChange: _updateStatus,
            primaryAction: OrderStatus.ready,
            primaryActionLabel: 'Mark Ready',
          ),
        ),
        const VerticalDivider(width: 1),
        Expanded(
          child: _OrderColumn(
            title: 'Ready',
            icon: Icons.check_circle_outline,
            color: AppTheme.statusReady,
            orders: _getOrdersByStatus(OrderStatus.ready),
            onStatusChange: _updateStatus,
            primaryAction: OrderStatus.completed,
            primaryActionLabel: 'Complete',
          ),
        ),
      ],
    );
  }

  Widget _buildTabLayout() {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          TabBar(
            labelColor: AppTheme.primary,
            unselectedLabelColor: AppTheme.textSecondary,
            indicatorColor: AppTheme.primary,
            tabs: [
              Tab(
                child: _buildTabLabel(
                  'Pending',
                  _getOrdersByStatus(OrderStatus.pending).length,
                  AppTheme.statusPending,
                ),
              ),
              Tab(
                child: _buildTabLabel(
                  'Preparing',
                  _getOrdersByStatus(OrderStatus.preparing).length,
                  AppTheme.statusPreparing,
                ),
              ),
              Tab(
                child: _buildTabLabel(
                  'Ready',
                  _getOrdersByStatus(OrderStatus.ready).length,
                  AppTheme.statusReady,
                ),
              ),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _OrderColumn(
                  title: 'Pending',
                  icon: Icons.hourglass_empty,
                  color: AppTheme.statusPending,
                  orders: _getOrdersByStatus(OrderStatus.pending),
                  onStatusChange: _updateStatus,
                  primaryAction: OrderStatus.preparing,
                  primaryActionLabel: 'Accept',
                  showHeader: false,
                ),
                _OrderColumn(
                  title: 'Preparing',
                  icon: Icons.restaurant,
                  color: AppTheme.statusPreparing,
                  orders: _getOrdersByStatus(OrderStatus.preparing),
                  onStatusChange: _updateStatus,
                  primaryAction: OrderStatus.ready,
                  primaryActionLabel: 'Mark Ready',
                  showHeader: false,
                ),
                _OrderColumn(
                  title: 'Ready',
                  icon: Icons.check_circle_outline,
                  color: AppTheme.statusReady,
                  orders: _getOrdersByStatus(OrderStatus.ready),
                  onStatusChange: _updateStatus,
                  primaryAction: OrderStatus.completed,
                  primaryActionLabel: 'Complete',
                  showHeader: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabLabel(String title, int count, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(title),
        if (count > 0) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _OrderColumn extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final List<Order> orders;
  final void Function(Order, OrderStatus) onStatusChange;
  final OrderStatus primaryAction;
  final String primaryActionLabel;
  final bool showHeader;

  const _OrderColumn({
    required this.title,
    required this.icon,
    required this.color,
    required this.orders,
    required this.onStatusChange,
    required this.primaryAction,
    required this.primaryActionLabel,
    this.showHeader = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (showHeader)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              border: Border(
                bottom: BorderSide(color: color.withValues(alpha: 0.3)),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '${orders.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        Expanded(
          child: orders.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon, size: 48, color: AppTheme.textMuted),
                      const SizedBox(height: 8),
                      Text(
                        'No $title orders',
                        style: TextStyle(color: AppTheme.textMuted),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    return _OrderCard(
                      order: orders[index],
                      primaryAction: primaryAction,
                      primaryActionLabel: primaryActionLabel,
                      actionColor: color,
                      onStatusChange: onStatusChange,
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Order order;
  final OrderStatus primaryAction;
  final String primaryActionLabel;
  final Color actionColor;
  final void Function(Order, OrderStatus) onStatusChange;

  const _OrderCard({
    required this.order,
    required this.primaryAction,
    required this.primaryActionLabel,
    required this.actionColor,
    required this.onStatusChange,
  });

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,###', 'en');
    final timeFormatter = DateFormat('h:mm a');

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '#${order.orderNumber}',
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (order.isOnlineOrder) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.info,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.public, size: 14, color: Colors.white),
                        SizedBox(width: 4),
                        Text(
                          'Online',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const Spacer(),
                Text(
                  timeFormatter.format(order.createdAt.toLocal()),
                  style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                ),
              ],
            ),

            // Customer info for online orders
            if (order.isOnlineOrder && order.customerName != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(
                    Icons.person,
                    size: 16,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      order.customerName!,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
              if (order.customerPhone != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.phone,
                      size: 16,
                      color: AppTheme.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      order.customerPhone!,
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
              if (order.customerAddress != null) ...[
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.location_on,
                      size: 16,
                      color: AppTheme.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        order.customerAddress!,
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],

            // Items
            const SizedBox(height: 12),
            ...order.items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceLight,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Center(
                        child: Text(
                          '${item.quantity}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item.menuItem?.name ?? 'Item',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Notes
            if (order.notes != null && order.notes!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppTheme.warning.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.notes, size: 16, color: AppTheme.warning),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        order.notes!,
                        style: TextStyle(color: AppTheme.warning, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Footer
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  '${formatter.format(order.totalAmount.toInt())} IQD',
                  style: TextStyle(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                // Cancel button
                if (order.status == OrderStatus.pending)
                  TextButton(
                    onPressed: () =>
                        onStatusChange(order, OrderStatus.cancelled),
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.error,
                    ),
                    child: const Text('Cancel'),
                  ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => onStatusChange(order, primaryAction),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: actionColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  child: Text(primaryActionLabel),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
