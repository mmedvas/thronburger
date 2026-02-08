import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/models.dart';
import '../../repositories/order_repository.dart';

part 'order_tracking_event.dart';
part 'order_tracking_state.dart';

class OrderTrackingBloc extends Bloc<OrderTrackingEvent, OrderTrackingState> {
  final OrderRepository _orderRepository;
  StreamSubscription<List<Order>>? _orderSubscription;
  String? _customerId;

  OrderTrackingBloc({
    required OrderRepository orderRepository,
  })  : _orderRepository = orderRepository,
        super(const OrderTrackingState()) {
    on<OrderTrackingStarted>(_onTrackingStarted);
    on<OrderTrackingStopped>(_onTrackingStopped);
    on<OrderTrackingUpdated>(_onTrackingUpdated);
    on<CustomerOrdersRequested>(_onCustomerOrdersRequested);
    on<OrdersRefreshRequested>(_onOrdersRefreshRequested);
  }

  Future<void> _onTrackingStarted(
    OrderTrackingStarted event,
    Emitter<OrderTrackingState> emit,
  ) async {
    emit(state.copyWith(status: OrderTrackingStatus.loading));

    try {
      // Get initial order state
      final order = await _orderRepository.getOrder(event.orderId);

      if (order != null) {
        emit(state.copyWith(
          status: OrderTrackingStatus.tracking,
          trackedOrder: order,
        ));

        // Subscribe to updates (via active orders stream)
        _orderSubscription?.cancel();
        _orderSubscription = _orderRepository.subscribeToActiveOrders().listen(
          (orders) {
            final updatedOrder = orders.firstWhere(
              (o) => o.id == event.orderId,
              orElse: () => order,
            );
            add(OrderTrackingUpdated(updatedOrder));
          },
        );
      } else {
        emit(state.copyWith(
          status: OrderTrackingStatus.error,
          errorMessage: 'Order not found',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: OrderTrackingStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onTrackingStopped(
    OrderTrackingStopped event,
    Emitter<OrderTrackingState> emit,
  ) async {
    _orderSubscription?.cancel();
    _orderSubscription = null;
    emit(state.copyWith(status: OrderTrackingStatus.initial));
  }

  Future<void> _onTrackingUpdated(
    OrderTrackingUpdated event,
    Emitter<OrderTrackingState> emit,
  ) async {
    emit(state.copyWith(trackedOrder: event.order));
  }

  Future<void> _onCustomerOrdersRequested(
    CustomerOrdersRequested event,
    Emitter<OrderTrackingState> emit,
  ) async {
    _customerId = event.customerId;
    emit(state.copyWith(status: OrderTrackingStatus.loading));

    try {
      final orders = await _orderRepository.getOrders();
      final customerOrders =
          orders.where((o) => o.customerId == event.customerId).toList();

      final activeOrders = customerOrders
          .where(
            (o) =>
                o.status == OrderStatus.pending ||
                o.status == OrderStatus.preparing ||
                o.status == OrderStatus.ready,
          )
          .toList();

      final pastOrders = customerOrders
          .where(
            (o) =>
                o.status == OrderStatus.completed ||
                o.status == OrderStatus.cancelled,
          )
          .toList();

      emit(state.copyWith(
        status: OrderTrackingStatus.loaded,
        activeOrders: activeOrders,
        pastOrders: pastOrders,
      ));

      // Subscribe to real-time updates for active orders
      _orderSubscription?.cancel();
      _orderSubscription = _orderRepository.subscribeToActiveOrders().listen(
        (orders) {
          final customerActiveOrders = orders
              .where((o) => o.customerId == _customerId)
              .toList();

          // Update active orders if changed
          if (customerActiveOrders.length != state.activeOrders.length ||
              customerActiveOrders.any((o) =>
                !state.activeOrders.any((a) =>
                  a.id == o.id && a.status == o.status
                )
              )) {
            add(const OrdersRefreshRequested());
          }
        },
      );
    } catch (e) {
      emit(state.copyWith(
        status: OrderTrackingStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onOrdersRefreshRequested(
    OrdersRefreshRequested event,
    Emitter<OrderTrackingState> emit,
  ) async {
    if (_customerId == null) return;

    try {
      final orders = await _orderRepository.getOrders();
      final customerOrders =
          orders.where((o) => o.customerId == _customerId).toList();

      final activeOrders = customerOrders
          .where(
            (o) =>
                o.status == OrderStatus.pending ||
                o.status == OrderStatus.preparing ||
                o.status == OrderStatus.ready,
          )
          .toList();

      final pastOrders = customerOrders
          .where(
            (o) =>
                o.status == OrderStatus.completed ||
                o.status == OrderStatus.cancelled,
          )
          .toList();

      emit(state.copyWith(
        activeOrders: activeOrders,
        pastOrders: pastOrders,
      ));
    } catch (e) {
      // Silently fail on refresh
    }
  }

  @override
  Future<void> close() {
    _orderSubscription?.cancel();
    return super.close();
  }
}
