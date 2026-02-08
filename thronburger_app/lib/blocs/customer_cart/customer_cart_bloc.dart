import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/models.dart';

part 'customer_cart_event.dart';
part 'customer_cart_state.dart';

/// Customer Cart BLoC
/// Manages shopping cart state for customer ordering
class CustomerCartBloc extends Bloc<CustomerCartEvent, CustomerCartState> {
  static const String _cartKey = 'customer_cart';

  CustomerCartBloc() : super(const CustomerCartState()) {
    on<CustomerCartLoaded>(_onLoaded);
    on<CustomerCartItemAdded>(_onItemAdded);
    on<CustomerCartItemRemoved>(_onItemRemoved);
    on<CustomerCartQuantityUpdated>(_onQuantityUpdated);
    on<CustomerCartNotesUpdated>(_onNotesUpdated);
    on<CustomerCartCleared>(_onCleared);
  }

  /// Load cart from shared preferences
  Future<void> _onLoaded(
    CustomerCartLoaded event,
    Emitter<CustomerCartState> emit,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartJson = prefs.getString(_cartKey);

      if (cartJson != null) {
        final List<dynamic> decoded = jsonDecode(cartJson);
        final items = decoded
            .map(
              (item) => CustomerCartItem.fromJson(item as Map<String, dynamic>),
            )
            .toList();
        emit(state.copyWith(items: items));
      }
    } catch (e) {
      // If loading fails, start with empty cart
      emit(const CustomerCartState());
    }
  }

  /// Add item to cart
  Future<void> _onItemAdded(
    CustomerCartItemAdded event,
    Emitter<CustomerCartState> emit,
  ) async {
    final existingIndex = state.items.indexWhere(
      (item) => item.menuItem.id == event.menuItem.id,
    );

    List<CustomerCartItem> updatedItems;

    if (existingIndex >= 0) {
      // Update existing item quantity
      updatedItems = List.from(state.items);
      final existing = updatedItems[existingIndex];
      updatedItems[existingIndex] = existing.copyWith(
        quantity: existing.quantity + event.quantity,
        notes: event.notes ?? existing.notes,
      );
    } else {
      // Add new item
      updatedItems = [
        ...state.items,
        CustomerCartItem(
          menuItem: event.menuItem,
          quantity: event.quantity,
          notes: event.notes,
        ),
      ];
    }

    emit(state.copyWith(items: updatedItems));
    await _saveCart(updatedItems);
  }

  /// Remove item from cart
  Future<void> _onItemRemoved(
    CustomerCartItemRemoved event,
    Emitter<CustomerCartState> emit,
  ) async {
    final updatedItems = state.items
        .where((item) => item.menuItem.id != event.menuItemId)
        .toList();

    emit(state.copyWith(items: updatedItems));
    await _saveCart(updatedItems);
  }

  /// Update item quantity
  Future<void> _onQuantityUpdated(
    CustomerCartQuantityUpdated event,
    Emitter<CustomerCartState> emit,
  ) async {
    if (event.quantity <= 0) {
      add(CustomerCartItemRemoved(event.menuItemId));
      return;
    }

    final updatedItems = state.items.map((item) {
      if (item.menuItem.id == event.menuItemId) {
        return item.copyWith(quantity: event.quantity);
      }
      return item;
    }).toList();

    emit(state.copyWith(items: updatedItems));
    await _saveCart(updatedItems);
  }

  /// Update item notes
  Future<void> _onNotesUpdated(
    CustomerCartNotesUpdated event,
    Emitter<CustomerCartState> emit,
  ) async {
    final updatedItems = state.items.map((item) {
      if (item.menuItem.id == event.menuItemId) {
        return item.copyWith(notes: event.notes);
      }
      return item;
    }).toList();

    emit(state.copyWith(items: updatedItems));
    await _saveCart(updatedItems);
  }

  /// Clear cart
  Future<void> _onCleared(
    CustomerCartCleared event,
    Emitter<CustomerCartState> emit,
  ) async {
    emit(const CustomerCartState());
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cartKey);
  }

  /// Save cart to shared preferences
  Future<void> _saveCart(List<CustomerCartItem> items) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartJson = jsonEncode(items.map((item) => item.toJson()).toList());
      await prefs.setString(_cartKey, cartJson);
    } catch (e) {
      // Silently fail save
    }
  }
}
