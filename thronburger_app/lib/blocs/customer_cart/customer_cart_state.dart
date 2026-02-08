part of 'customer_cart_bloc.dart';

/// Customer Cart Item (with notes support)
class CustomerCartItem extends Equatable {
  final MenuItem menuItem;
  final int quantity;
  final String? notes;

  const CustomerCartItem({
    required this.menuItem,
    this.quantity = 1,
    this.notes,
  });

  double get lineTotal => menuItem.price * quantity;

  CustomerCartItem copyWith({
    MenuItem? menuItem,
    int? quantity,
    String? notes,
  }) {
    return CustomerCartItem(
      menuItem: menuItem ?? this.menuItem,
      quantity: quantity ?? this.quantity,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() => {
    'menu_item': menuItem.toJson(),
    'quantity': quantity,
    'notes': notes,
  };

  factory CustomerCartItem.fromJson(Map<String, dynamic> json) {
    return CustomerCartItem(
      menuItem: MenuItem.fromJson(json['menu_item'] as Map<String, dynamic>),
      quantity: json['quantity'] as int? ?? 1,
      notes: json['notes'] as String?,
    );
  }

  @override
  List<Object?> get props => [menuItem, quantity, notes];
}

/// Customer Cart State
class CustomerCartState extends Equatable {
  final List<CustomerCartItem> items;
  final String? orderNotes;

  const CustomerCartState({this.items = const [], this.orderNotes});

  /// Total item count
  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  /// Unique items count
  int get uniqueItemCount => items.length;

  /// Total price
  double get totalPrice => items.fold(0.0, (sum, item) => sum + item.lineTotal);

  /// Is cart empty
  bool get isEmpty => items.isEmpty;

  /// Is cart not empty
  bool get isNotEmpty => items.isNotEmpty;

  /// Get item by menu item ID
  CustomerCartItem? getItem(String menuItemId) {
    try {
      return items.firstWhere((item) => item.menuItem.id == menuItemId);
    } catch (_) {
      return null;
    }
  }

  /// Check if item exists in cart
  bool hasItem(String menuItemId) => getItem(menuItemId) != null;

  CustomerCartState copyWith({
    List<CustomerCartItem>? items,
    String? orderNotes,
  }) {
    return CustomerCartState(
      items: items ?? this.items,
      orderNotes: orderNotes ?? this.orderNotes,
    );
  }

  @override
  List<Object?> get props => [items, orderNotes];
}
