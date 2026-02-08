part of 'customer_cart_bloc.dart';

/// Customer Cart Events
abstract class CustomerCartEvent extends Equatable {
  const CustomerCartEvent();

  @override
  List<Object?> get props => [];
}

/// Add item to cart
class CustomerCartItemAdded extends CustomerCartEvent {
  final MenuItem menuItem;
  final int quantity;
  final String? notes;

  const CustomerCartItemAdded({
    required this.menuItem,
    this.quantity = 1,
    this.notes,
  });

  @override
  List<Object?> get props => [menuItem, quantity, notes];
}

/// Remove item from cart
class CustomerCartItemRemoved extends CustomerCartEvent {
  final String menuItemId;

  const CustomerCartItemRemoved(this.menuItemId);

  @override
  List<Object?> get props => [menuItemId];
}

/// Update item quantity
class CustomerCartQuantityUpdated extends CustomerCartEvent {
  final String menuItemId;
  final int quantity;

  const CustomerCartQuantityUpdated({
    required this.menuItemId,
    required this.quantity,
  });

  @override
  List<Object?> get props => [menuItemId, quantity];
}

/// Update item notes
class CustomerCartNotesUpdated extends CustomerCartEvent {
  final String menuItemId;
  final String notes;

  const CustomerCartNotesUpdated({
    required this.menuItemId,
    required this.notes,
  });

  @override
  List<Object?> get props => [menuItemId, notes];
}

/// Clear cart
class CustomerCartCleared extends CustomerCartEvent {
  const CustomerCartCleared();
}

/// Load cart from storage
class CustomerCartLoaded extends CustomerCartEvent {
  const CustomerCartLoaded();
}
