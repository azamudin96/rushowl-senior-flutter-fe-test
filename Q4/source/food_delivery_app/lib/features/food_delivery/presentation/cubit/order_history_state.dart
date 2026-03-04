import 'package:equatable/equatable.dart';

import '../../domain/entities/order_history_item.dart';

sealed class OrderHistoryState extends Equatable {
  const OrderHistoryState();

  @override
  List<Object?> get props => [];
}

class OrderHistoryInitial extends OrderHistoryState {
  const OrderHistoryInitial();
}

class OrderHistoryLoading extends OrderHistoryState {
  const OrderHistoryLoading();
}

class OrderHistoryLoaded extends OrderHistoryState {
  final List<OrderHistoryItem> activeOrders;
  final List<OrderHistoryItem> pastOrders;

  const OrderHistoryLoaded({
    required this.activeOrders,
    required this.pastOrders,
  });

  @override
  List<Object?> get props => [activeOrders, pastOrders];
}

class OrderHistoryError extends OrderHistoryState {
  final String message;

  const OrderHistoryError(this.message);

  @override
  List<Object?> get props => [message];
}
