import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/models.dart';

part 'cart_event.dart';
part 'cart_state.dart';

/// Cart BLoC
/// Manages shopping cart state for POS
class CartBloc extends Bloc<CartEvent, CartState> {
  CartBloc() : super(const CartState()) {
    on<CartItemAdded>(_onItemAdded);
    on<CartItemRemoved>(_onItemRemoved);
    on<CartItemQuantityUpdated>(_onQuantityUpdated);
    on<CartCleared>(_onCleared);
  }

  void _onItemAdded(CartItemAdded event, Emitter<CartState> emit) {
    final existingIndex = state.items.indexWhere(
      (item) => item.menuItem.id == event.menuItem.id,
    );

    if (existingIndex >= 0) {
      // Increment quantity
      final updatedItems = List<CartItem>.from(state.items);
      final existing = updatedItems[existingIndex];
      updatedItems[existingIndex] = existing.copyWith(
        quantity: existing.quantity + 1,
      );
      emit(state.copyWith(items: updatedItems));
    } else {
      // Add new item
      emit(
        state.copyWith(
          items: [
            ...state.items,
            CartItem(menuItem: event.menuItem),
          ],
        ),
      );
    }
  }

  void _onItemRemoved(CartItemRemoved event, Emitter<CartState> emit) {
    final updatedItems = state.items
        .where((item) => item.menuItem.id != event.menuItemId)
        .toList();
    emit(state.copyWith(items: updatedItems));
  }

  void _onQuantityUpdated(
    CartItemQuantityUpdated event,
    Emitter<CartState> emit,
  ) {
    if (event.quantity <= 0) {
      // Remove item if quantity is 0 or less
      add(CartItemRemoved(event.menuItemId));
      return;
    }

    final existingIndex = state.items.indexWhere(
      (item) => item.menuItem.id == event.menuItemId,
    );

    if (existingIndex >= 0) {
      final updatedItems = List<CartItem>.from(state.items);
      updatedItems[existingIndex] = updatedItems[existingIndex].copyWith(
        quantity: event.quantity,
      );
      emit(state.copyWith(items: updatedItems));
    }
  }

  void _onCleared(CartCleared event, Emitter<CartState> emit) {
    emit(const CartState());
  }
}
