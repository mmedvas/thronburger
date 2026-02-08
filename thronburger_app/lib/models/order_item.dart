import 'package:equatable/equatable.dart';
import 'menu_item.dart';

/// Order Item Model
/// Represents an individual item within an order
class OrderItem extends Equatable {
  final String id;
  final String orderId;
  final String menuItemId;
  final int quantity;
  final double unitPrice;
  final DateTime createdAt;
  final MenuItem? menuItem;

  const OrderItem({
    required this.id,
    required this.orderId,
    required this.menuItemId,
    required this.quantity,
    required this.unitPrice,
    required this.createdAt,
    this.menuItem,
  });

  /// Calculate line total
  double get lineTotal => quantity * unitPrice;

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

  /// Create OrderItem from JSON
  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: (json['id'] as String?) ?? '',
      orderId: (json['order_id'] as String?) ?? '',
      menuItemId: (json['menu_item_id'] as String?) ?? '',
      quantity: (json['quantity'] as int?) ?? 0,
      unitPrice: (json['unit_price'] as num?)?.toDouble() ?? 0.0,
      createdAt: _parseDate(json['created_at']),
      menuItem: json['menu_items'] != null
          ? MenuItem.fromJson(json['menu_items'] as Map<String, dynamic>)
          : null,
    );
  }

  /// Convert OrderItem to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'menu_item_id': menuItemId,
      'quantity': quantity,
      'unit_price': unitPrice,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Create OrderItem for insert
  Map<String, dynamic> toInsertJson() {
    return {
      'order_id': orderId,
      'menu_item_id': menuItemId,
      'quantity': quantity,
      'unit_price': unitPrice,
    };
  }

  /// Copy with method
  OrderItem copyWith({
    String? id,
    String? orderId,
    String? menuItemId,
    int? quantity,
    double? unitPrice,
    DateTime? createdAt,
    MenuItem? menuItem,
  }) {
    return OrderItem(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      menuItemId: menuItemId ?? this.menuItemId,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      createdAt: createdAt ?? this.createdAt,
      menuItem: menuItem ?? this.menuItem,
    );
  }

  @override
  List<Object?> get props => [
    id,
    orderId,
    menuItemId,
    quantity,
    unitPrice,
    createdAt,
    menuItem,
  ];
}
