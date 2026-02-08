part of 'order_tracking_bloc.dart';

abstract class OrderTrackingEvent extends Equatable {
  const OrderTrackingEvent();

  @override
  List<Object?> get props => [];
}

/// Start tracking a specific order
class OrderTrackingStarted extends OrderTrackingEvent {
  final String orderId;

  const OrderTrackingStarted(this.orderId);

  @override
  List<Object?> get props => [orderId];
}

/// Stop tracking the current order
class OrderTrackingStopped extends OrderTrackingEvent {
  const OrderTrackingStopped();
}

/// Order was updated (from stream)
class OrderTrackingUpdated extends OrderTrackingEvent {
  final Order order;

  const OrderTrackingUpdated(this.order);

  @override
  List<Object?> get props => [order];
}

/// Load all active orders for customer
class CustomerOrdersRequested extends OrderTrackingEvent {
  final String customerId;

  const CustomerOrdersRequested(this.customerId);

  @override
  List<Object?> get props => [customerId];
}

/// Refresh orders
class OrdersRefreshRequested extends OrderTrackingEvent {
  const OrdersRefreshRequested();
}
