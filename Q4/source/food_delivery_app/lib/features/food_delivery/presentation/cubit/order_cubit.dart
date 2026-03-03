import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/restaurant.dart';
import 'order_state.dart';

class OrderCubit extends Cubit<OrderState> {
  Timer? _timer;

  OrderCubit() : super(const OrderInitial());

  void placeOrder(List<CartItem> items, Restaurant restaurant) {
    _timer?.cancel();

    emit(const OrderPlacing());

    final subtotal = items.fold<double>(0, (sum, item) => sum + item.subtotal);
    final order = Order(
      id: 'ORD-${DateTime.now().millisecondsSinceEpoch}',
      items: items,
      restaurant: restaurant,
      subtotal: subtotal,
      deliveryFee: restaurant.deliveryFee,
      estimatedDelivery: DateTime.now().add(AppConstants.simulatedDeliveryTime),
      status: OrderStatus.confirmed,
    );

    emit(OrderTracking(order));

    _timer = Timer.periodic(AppConstants.orderStatusInterval, (_) {
      final currentState = state;
      if (currentState is! OrderTracking) return;

      final currentIndex = OrderStatus.values.indexOf(
        currentState.order.status,
      );
      if (currentIndex >= OrderStatus.values.length - 1) {
        _timer?.cancel();
        return;
      }

      final nextStatus = OrderStatus.values[currentIndex + 1];
      emit(OrderTracking(currentState.order.copyWith(status: nextStatus)));

      if (nextStatus == OrderStatus.delivered) {
        _timer?.cancel();
      }
    });
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
