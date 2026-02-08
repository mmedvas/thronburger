import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import '../models/models.dart'
    show Order, OrderStatus, OrderType, CartItem, OrderItem;

/// Order Repository
/// Handles order CRUD operations and real-time subscriptions
class OrderRepository {
  final FirebaseFirestore _firestore;

  OrderRepository(this._firestore);

  /// Get all orders with optional filters
  Future<List<Order>> getOrders({
    DateTime? fromDate,
    DateTime? toDate,
    OrderStatus? status,
    int? limit,
  }) async {
    // Simple query - get all orders
    final snapshot = await _firestore
        .collection('orders')
        .limit(limit ?? 100)
        .get();

    // Process all orders
    final orders = <Order>[];
    for (final doc in snapshot.docs) {
      final order = await _getOrderWithItems(doc);
      if (order != null) {
        // Filter by date in memory
        if (fromDate != null && order.createdAt.isBefore(fromDate)) continue;
        if (toDate != null &&
            order.createdAt.isAfter(toDate.add(const Duration(days: 1))))
          continue;
        // Filter by status in memory
        if (status != null && order.status != status) continue;

        orders.add(order);
      }
    }

    // Sort by createdAt descending
    orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return orders;
  }

  /// Get active orders (pending, preparing, ready)
  Future<List<Order>> getActiveOrders() async {
    final snapshot = await _firestore
        .collection('orders')
        .where('status', whereIn: ['pending', 'preparing', 'ready'])
        .orderBy('created_at', descending: false)
        .get();

    final orders = <Order>[];
    for (final doc in snapshot.docs) {
      final order = await _getOrderWithItems(doc);
      if (order != null) orders.add(order);
    }

    return orders;
  }

  /// Get customer's orders
  Future<List<Order>> getCustomerOrders(String customerId) async {
    final snapshot = await _firestore
        .collection('orders')
        .where('customer_id', isEqualTo: customerId)
        .orderBy('created_at', descending: true)
        .get();

    final orders = <Order>[];
    for (final doc in snapshot.docs) {
      final order = await _getOrderWithItems(doc);
      if (order != null) orders.add(order);
    }

    return orders;
  }

  /// Get single order by ID
  Future<Order?> getOrder(String id) async {
    final doc = await _firestore.collection('orders').doc(id).get();
    if (!doc.exists) return null;
    return await _getOrderWithItems(doc);
  }

  /// Helper method to get order with items subcollection
  Future<Order?> _getOrderWithItems(DocumentSnapshot doc) async {
    try {
      final data = doc.data() as Map<String, dynamic>?;
      if (data == null) return null;

      // Convert Firestore Timestamps to ISO strings
      final createdAt = data['created_at'];
      final updatedAt = data['updated_at'];

      final processedData = {
        ...data,
        'created_at': createdAt is Timestamp
            ? createdAt.toDate().toIso8601String()
            : createdAt?.toString() ?? DateTime.now().toIso8601String(),
        'updated_at': updatedAt is Timestamp
            ? updatedAt.toDate().toIso8601String()
            : updatedAt?.toString() ?? DateTime.now().toIso8601String(),
      };

      // Fetch order items subcollection
      final itemsSnapshot = await _firestore
          .collection('orders')
          .doc(doc.id)
          .collection('items')
          .get();

      final items = <Map<String, dynamic>>[];
      for (final itemDoc in itemsSnapshot.docs) {
        final itemData = itemDoc.data();

        // Use stored menu_item_name instead of fetching from menu_items collection
        // This is much faster and the name is already stored when order is created
        items.add({
          ...itemData,
          'id': itemDoc.id,
          'order_id': doc.id,
          'created_at': (processedData['created_at'] as String),
          'menu_items': {
            'id': itemData['menu_item_id'] ?? '',
            'name': itemData['menu_item_name'] ?? 'Item',
            'price': itemData['unit_price'] ?? 0,
            'category': 'unknown',
            'created_at': processedData['created_at'],
            'updated_at': processedData['updated_at'],
          },
        });
      }

      return Order.fromJson({
        ...processedData,
        'id': doc.id,
        'order_items': items,
      });
    } catch (e) {
      print('Error parsing order ${doc.id}: $e');
      return null;
    }
  }

  /// Create in-store order (POS)
  Future<Order> createOrder({
    required String staffId,
    required List<CartItem> items,
    OrderType orderType = OrderType.dineIn,
    String? notes,
  }) async {
    // Calculate total
    final totalAmount = items.fold<double>(
      0,
      (sum, item) => sum + item.lineTotal,
    );

    // Generate order number
    final orderNumber = await _generateOrderNumber();

    // Use Timestamp.now() so we can read the order back immediately
    final now = Timestamp.now();

    // Create order document
    final orderRef = await _firestore.collection('orders').add({
      'order_number': orderNumber,
      'staff_id': staffId,
      'order_type': orderType.value,
      'status': 'completed', // POS orders are completed immediately
      'total_amount': totalAmount,
      'notes': notes,
      'created_at': now,
      'updated_at': now,
    });

    // Create order items as subcollection
    final orderItems = <OrderItem>[];
    for (final item in items) {
      final itemRef = await orderRef.collection('items').add({
        'menu_item_id': item.menuItem.id,
        'menu_item_name': item.menuItem.name,
        'quantity': item.quantity,
        'unit_price': item.menuItem.price,
      });

      orderItems.add(
        OrderItem(
          id: itemRef.id,
          orderId: orderRef.id,
          menuItemId: item.menuItem.id,
          quantity: item.quantity,
          unitPrice: item.menuItem.price,
          createdAt: now.toDate(),
          menuItem: item.menuItem,
        ),
      );
    }

    // Return order directly (no need to fetch)
    return Order(
      id: orderRef.id,
      orderNumber: orderNumber,
      staffId: staffId,
      orderType: orderType,
      status: OrderStatus.completed,
      totalAmount: totalAmount,
      notes: notes,
      createdAt: now.toDate(),
      updatedAt: now.toDate(),
      items: orderItems,
    );
  }

  /// Create customer order (Online/Pickup from customer portal)
  Future<Order> createCustomerOrder({
    required String customerId,
    required List<Map<String, dynamic>>
    items, // [{menuItemId, quantity, unitPrice}]
    required OrderType orderType,
    String? customerName,
    String? customerPhone,
    String? customerAddress,
    String? notes,
  }) async {
    // Calculate total
    final totalAmount = items.fold<double>(
      0,
      (sum, item) =>
          sum + ((item['quantity'] as int) * (item['unitPrice'] as double)),
    );

    // Generate order number
    final orderNumber = await _generateOrderNumber();

    // Use Timestamp.now() so we can read the order back immediately
    final now = Timestamp.now();

    // Create order document
    final orderRef = await _firestore.collection('orders').add({
      'order_number': orderNumber,
      'customer_id': customerId,
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'customer_address': customerAddress,
      'order_type': orderType.value,
      'status': 'pending',
      'total_amount': totalAmount,
      'notes': notes,
      'created_at': now,
      'updated_at': now,
    });

    // Create order items as subcollection
    final orderItems = <OrderItem>[];
    for (final item in items) {
      // Fetch menu item name
      final menuItemDoc = await _firestore
          .collection('menu_items')
          .doc(item['menuItemId'] as String)
          .get();

      final itemRef = await orderRef.collection('items').add({
        'menu_item_id': item['menuItemId'],
        'menu_item_name': menuItemDoc.data()?['name'] ?? 'Unknown',
        'quantity': item['quantity'],
        'unit_price': item['unitPrice'],
      });

      orderItems.add(
        OrderItem(
          id: itemRef.id,
          orderId: orderRef.id,
          menuItemId: item['menuItemId'] as String,
          quantity: item['quantity'] as int,
          unitPrice: (item['unitPrice'] as num).toDouble(),
          createdAt: now.toDate(),
        ),
      );
    }

    // Return order directly
    return Order(
      id: orderRef.id,
      orderNumber: orderNumber,
      customerId: customerId,
      customerName: customerName,
      customerPhone: customerPhone,
      customerAddress: customerAddress,
      orderType: orderType,
      status: OrderStatus.pending,
      totalAmount: totalAmount,
      notes: notes,
      createdAt: now.toDate(),
      updatedAt: now.toDate(),
      items: orderItems,
    );
  }

  /// Update order status
  Future<Order> updateOrderStatus(String orderId, OrderStatus status) async {
    await _firestore.collection('orders').doc(orderId).update({
      'status': status.value,
      'updated_at': Timestamp.now(),
    });

    return (await getOrder(orderId))!;
  }

  /// Subscribe to active orders (real-time)
  Stream<List<Order>> subscribeToActiveOrders() {
    return _firestore
        .collection('orders')
        .where('status', whereIn: ['pending', 'preparing', 'ready'])
        .orderBy('created_at', descending: false)
        .snapshots()
        .asyncMap((snapshot) async {
          final orders = <Order>[];
          for (final doc in snapshot.docs) {
            final order = await _getOrderWithItems(doc);
            if (order != null) orders.add(order);
          }
          return orders;
        });
  }

  /// Subscribe to customer orders (real-time)
  Stream<List<Order>> subscribeToCustomerOrders(String customerId) {
    return _firestore
        .collection('orders')
        .where('customer_id', isEqualTo: customerId)
        .orderBy('created_at', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
          final orders = <Order>[];
          for (final doc in snapshot.docs) {
            final order = await _getOrderWithItems(doc);
            if (order != null) orders.add(order);
          }
          return orders;
        });
  }

  /// Stream of new orders (for notifications)
  Stream<Order> get onNewOrder {
    return _firestore
        .collection('orders')
        .where(
          'created_at',
          isGreaterThan: Timestamp.now(),
        ) // Only future orders
        .snapshots()
        .expand((snapshot) => snapshot.docChanges)
        .where((change) => change.type == DocumentChangeType.added)
        .asyncMap((change) async {
          return await _getOrderWithItems(change.doc);
        })
        .where((order) => order != null)
        .cast<Order>();
  }

  /// Generate order number (returns int)
  Future<int> _generateOrderNumber() async {
    final counterRef = _firestore.collection('counters').doc('orders');

    return _firestore.runTransaction<int>((transaction) async {
      final snapshot = await transaction.get(counterRef);

      if (!snapshot.exists) {
        // Initialize counter if it doesn't exist
        // Start at 1000 so the first order is 1001
        transaction.set(counterRef, {'current': 1000});
        return 1001;
      }

      final current = snapshot.data()?['current'] as int? ?? 1000;
      final next = current + 1;

      transaction.update(counterRef, {'current': next});

      return next;
    });
  }

  /// Get sales report data
  Future<Map<String, dynamic>> getSalesReport({
    required DateTime fromDate,
    required DateTime toDate,
  }) async {
    final snapshot = await _firestore
        .collection('orders')
        .where('status', isEqualTo: 'completed')
        .where(
          'created_at',
          isGreaterThanOrEqualTo: Timestamp.fromDate(fromDate),
        )
        .where('created_at', isLessThanOrEqualTo: Timestamp.fromDate(toDate))
        .get();

    double totalSales = 0;
    int totalOrders = snapshot.docs.length;
    int totalItems = 0;
    Map<String, int> itemCounts = {};
    Map<String, double> itemRevenue = {};

    for (final orderDoc in snapshot.docs) {
      final orderData = orderDoc.data();
      totalSales += (orderData['total_amount'] as num?)?.toDouble() ?? 0;

      // Get items subcollection
      final itemsSnapshot = await orderDoc.reference.collection('items').get();
      for (final itemDoc in itemsSnapshot.docs) {
        final itemData = itemDoc.data();
        final quantity = itemData['quantity'] as int? ?? 0;
        final name = itemData['menu_item_name'] as String? ?? 'Unknown';
        final unitPrice = (itemData['unit_price'] as num?)?.toDouble() ?? 0;

        totalItems += quantity;
        itemCounts[name] = (itemCounts[name] ?? 0) + quantity;
        itemRevenue[name] = (itemRevenue[name] ?? 0) + (quantity * unitPrice);
      }
    }

    // Sort items by quantity
    final sortedItems = itemCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return {
      'totalSales': totalSales,
      'totalOrders': totalOrders,
      'totalItems': totalItems,
      'averageOrderValue': totalOrders > 0 ? totalSales / totalOrders : 0,
      'topItems': sortedItems
          .take(5)
          .map(
            (e) => {
              'name': e.key,
              'quantity': e.value,
              'revenue': itemRevenue[e.key] ?? 0,
            },
          )
          .toList(),
    };
  }

  /// Get daily sales for chart
  Future<List<Map<String, dynamic>>> getDailySales({
    required DateTime fromDate,
    required DateTime toDate,
  }) async {
    final snapshot = await _firestore
        .collection('orders')
        .where('status', isEqualTo: 'completed')
        .where(
          'created_at',
          isGreaterThanOrEqualTo: Timestamp.fromDate(fromDate),
        )
        .where('created_at', isLessThanOrEqualTo: Timestamp.fromDate(toDate))
        .get();

    // Group by date
    Map<String, double> dailyTotals = {};

    for (final orderDoc in snapshot.docs) {
      final data = orderDoc.data();
      final timestamp = data['created_at'] as Timestamp?;
      if (timestamp != null) {
        final date = timestamp.toDate();
        final dateKey =
            '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
        final amount = (data['total_amount'] as num?)?.toDouble() ?? 0.0;
        dailyTotals[dateKey] = (dailyTotals[dateKey] ?? 0) + amount;
      }
    }

    // Generate date range
    final result = <Map<String, dynamic>>[];
    var current = fromDate;
    while (current.isBefore(toDate) || current.isAtSameMomentAs(toDate)) {
      final dateKey =
          '${current.year}-${current.month.toString().padLeft(2, '0')}-${current.day.toString().padLeft(2, '0')}';
      result.add({'date': dateKey, 'sales': dailyTotals[dateKey] ?? 0});
      current = current.add(const Duration(days: 1));
    }

    return result;
  }
}
