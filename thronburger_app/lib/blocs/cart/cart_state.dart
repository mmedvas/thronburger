part of 'cart_bloc.dart';

/// Cart State
class CartState extends Equatable {
  final List<CartItem> items;

  const CartState({this.items = const []});

  /// Total number of items
  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  /// Total price
  double get totalPrice => items.fold(0, (sum, item) => sum + item.lineTotal);

  /// Check if cart is empty
  bool get isEmpty => items.isEmpty;

  /// Check if cart has items
  bool get isNotEmpty => items.isNotEmpty;

  /// Get item by menu item ID
  CartItem? getItem(String menuItemId) {
    try {
      return items.firstWhere((item) => item.menuItem.id == menuItemId);
    } catch (_) {
      return null;
    }
  }

  /// Copy with method
  CartState copyWith({List<CartItem>? items}) {
    return CartState(items: items ?? this.items);
  }

  @override
  List<Object?> get props => [items];
}
