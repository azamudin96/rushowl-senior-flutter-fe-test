import 'package:equatable/equatable.dart';

import '../../domain/entities/order.dart';

sealed class OrderState extends Equatable {
  const OrderState();

  @override
  List<Object?> get props => [];
}

class OrderInitial extends OrderState {
  const OrderInitial();
}

class OrderPlacing extends OrderState {
  const OrderPlacing();
}

class OrderTracking extends OrderState {
  final Order order;

  const OrderTracking(this.order);

  @override
  List<Object?> get props => [order];
}

class OrderError extends OrderState {
  final String message;

  const OrderError(this.message);

  @override
  List<Object?> get props => [message];
}
