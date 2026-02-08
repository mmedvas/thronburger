import 'package:equatable/equatable.dart';
import 'menu_item.dart';

/// Cart Item Model
/// Represents an item in the shopping cart
class CartItem extends Equatable {
  final MenuItem menuItem;
  final int quantity;

  const CartItem({required this.menuItem, this.quantity = 1});

  /// Calculate line total
  double get lineTotal => menuItem.price * quantity;

  /// Copy with method
  CartItem copyWith({MenuItem? menuItem, int? quantity}) {
    return CartItem(
      menuItem: menuItem ?? this.menuItem,
      quantity: quantity ?? this.quantity,
    );
  }

  @override
  List<Object?> get props => [menuItem, quantity];
}
