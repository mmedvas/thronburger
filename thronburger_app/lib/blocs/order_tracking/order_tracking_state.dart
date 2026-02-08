part of 'order_tracking_bloc.dart';

enum OrderTrackingStatus {
  initial,
  loading,
  tracking,
  loaded,
  error,
}

class OrderTrackingState extends Equatable {
  final OrderTrackingStatus status;
  final Order? trackedOrder;
  final List<Order> activeOrders;
  final List<Order> pastOrders;
  final String? errorMessage;

  const OrderTrackingState({
    this.status = OrderTrackingStatus.initial,
    this.trackedOrder,
    this.activeOrders = const [],
    this.pastOrders = const [],
    this.errorMessage,
  });

  bool get isLoading => status == OrderTrackingStatus.loading;
  bool get isTracking => status == OrderTrackingStatus.tracking;
  bool get hasActiveOrders => activeOrders.isNotEmpty;

  @override
  List<Object?> get props => [
        status,
        trackedOrder,
        activeOrders,
        pastOrders,
        errorMessage,
      ];

  OrderTrackingState copyWith({
    OrderTrackingStatus? status,
    Order? trackedOrder,
    List<Order>? activeOrders,
    List<Order>? pastOrders,
    String? errorMessage,
  }) {
    return OrderTrackingState(
      status: status ?? this.status,
      trackedOrder: trackedOrder ?? this.trackedOrder,
      activeOrders: activeOrders ?? this.activeOrders,
      pastOrders: pastOrders ?? this.pastOrders,
      errorMessage: errorMessage,
    );
  }
}
