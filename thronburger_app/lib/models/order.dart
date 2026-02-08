import 'package:equatable/equatable.dart';
import 'order_item.dart';

/// Order Status Enum
enum OrderStatus {
  pending('pending', 'Pending'),
  preparing('preparing', 'Preparing'),
  ready('ready', 'Ready'),
  completed('completed', 'Completed'),
  cancelled('cancelled', 'Cancelled');

  final String value;
  final String label;

  const OrderStatus(this.value, this.label);

  static OrderStatus fromString(String value) {
    return OrderStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => OrderStatus.pending,
    );
  }
}

/// Order Type Enum
enum OrderType {
  dineIn('dine_in', 'Dine In'),
  pickup('pickup', 'Pickup'),
  delivery('delivery', 'Delivery'),
  online('online', 'Online');

  final String value;
  final String label;

  const OrderType(this.value, this.label);

  static OrderType fromString(String value) {
    print('DEBUG: Parsing OrderType: "$value"');
    try {
      return OrderType.values.firstWhere((e) => e.value == value);
    } catch (e) {
      print('DEBUG: OrderType match failed for "$value", defaulting to dineIn');
      return OrderType.dineIn;
    }
  }
}

/// Order Model
class Order extends Equatable {
  final String id;
  final int orderNumber;
  final String? staffId;
  final String? customerId;
  final String? customerName;
  final String? customerPhone;
  final String? customerLocation;
  final String? customerAddress;
  final String? notes;
  final OrderType orderType;
  final OrderStatus status;
  final double totalAmount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<OrderItem> items;

  const Order({
    required this.id,
    required this.orderNumber,
    this.staffId,
    this.customerId,
    this.customerName,
    this.customerPhone,
    this.customerLocation,
    this.customerAddress,
    this.notes,
    required this.orderType,
    required this.status,
    required this.totalAmount,
    required this.createdAt,
    required this.updatedAt,
    this.items = const [],
  });

  /// Parse a date value that could be a String, Firestore Timestamp, or null
  static DateTime _parseDate(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is String) return DateTime.parse(value);
    try {
      return (value as dynamic).toDate();
    } catch (_) {
      return DateTime.now();
    }
  }

  /// Create Order from JSON
  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: (json['id'] as String?) ?? '',
      orderNumber: (json['order_number'] as int?) ?? 0,
      staffId: json['staff_id'] as String?,
      customerId: json['customer_id'] as String?,
      customerName: json['customer_name'] as String?,
      customerPhone: json['customer_phone'] as String?,
      customerLocation: json['customer_location'] as String?,
      customerAddress: json['customer_address'] as String?,
      notes: json['notes'] as String?,
      orderType: OrderType.fromString(
        (json['order_type'] as String?) ?? 'dine_in',
      ),
      status: OrderStatus.fromString((json['status'] as String?) ?? 'pending'),
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
      createdAt: _parseDate(json['created_at']),
      updatedAt: _parseDate(json['updated_at']),
      items:
          ((json['order_items'] ?? json['items']) as List<dynamic>?)
              ?.map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  /// Convert Order to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_number': orderNumber,
      'staff_id': staffId,
      'customer_id': customerId,
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'customer_location': customerLocation,
      'customer_address': customerAddress,
      'notes': notes,
      'order_type': orderType.value,
      'status': status.value,
      'total_amount': totalAmount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Check if order is from online customer
  bool get isOnlineOrder =>
      orderType == OrderType.online ||
      orderType == OrderType.delivery ||
      orderType == OrderType.pickup;

  /// Copy with method
  Order copyWith({
    String? id,
    int? orderNumber,
    String? staffId,
    String? customerId,
    String? customerName,
    String? customerPhone,
    String? customerLocation,
    String? customerAddress,
    String? notes,
    OrderType? orderType,
    OrderStatus? status,
    double? totalAmount,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<OrderItem>? items,
  }) {
    return Order(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      staffId: staffId ?? this.staffId,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      customerLocation: customerLocation ?? this.customerLocation,
      customerAddress: customerAddress ?? this.customerAddress,
      notes: notes ?? this.notes,
      orderType: orderType ?? this.orderType,
      status: status ?? this.status,
      totalAmount: totalAmount ?? this.totalAmount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      items: items ?? this.items,
    );
  }

  @override
  List<Object?> get props => [
    id,
    orderNumber,
    staffId,
    customerId,
    customerName,
    customerPhone,
    customerLocation,
    customerAddress,
    notes,
    orderType,
    status,
    totalAmount,
    createdAt,
    updatedAt,
    items,
  ];
}
