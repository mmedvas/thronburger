part of 'cart_bloc.dart';

/// Cart Events
sealed class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object?> get props => [];
}

/// Add item to cart
class CartItemAdded extends CartEvent {
  final MenuItem menuItem;

  const CartItemAdded(this.menuItem);

  @override
  List<Object?> get props => [menuItem];
}

/// Remove item from cart
class CartItemRemoved extends CartEvent {
  final String menuItemId;

  const CartItemRemoved(this.menuItemId);

  @override
  List<Object?> get props => [menuItemId];
}

/// Update item quantity
class CartItemQuantityUpdated extends CartEvent {
  final String menuItemId;
  final int quantity;

  const CartItemQuantityUpdated({
    required this.menuItemId,
    required this.quantity,
  });

  @override
  List<Object?> get props => [menuItemId, quantity];
}

/// Clear cart
class CartCleared extends CartEvent {
  const CartCleared();
}
