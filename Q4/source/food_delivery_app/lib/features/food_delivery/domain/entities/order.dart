import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import 'cart_item.dart';
import 'restaurant.dart';

enum OrderStatus {
  confirmed,
  preparing,
  onTheWay,
  delivered;

  String get displayName {
    switch (this) {
      case OrderStatus.confirmed:
        return 'Order Confirmed';
      case OrderStatus.preparing:
        return 'Preparing your meal';
      case OrderStatus.onTheWay:
        return 'On the way';
      case OrderStatus.delivered:
        return 'Delivered';
    }
  }

  String get subtitle {
    switch (this) {
      case OrderStatus.confirmed:
        return 'Your order has been received';
      case OrderStatus.preparing:
        return 'Chef is working their magic';
      case OrderStatus.onTheWay:
        return 'The courier is 1.2km away from you';
      case OrderStatus.delivered:
        return 'Enjoy your meal!';
    }
  }

  IconData get icon {
    switch (this) {
      case OrderStatus.confirmed:
        return Icons.check;
      case OrderStatus.preparing:
        return Icons.check;
      case OrderStatus.onTheWay:
        return Icons.delivery_dining;
      case OrderStatus.delivered:
        return Icons.home_rounded;
    }
  }
}

class Order extends Equatable {
  final String id;
  final List<CartItem> items;
  final Restaurant restaurant;
  final double subtotal;
  final double deliveryFee;
  final DateTime estimatedDelivery;
  final OrderStatus status;

  const Order({
    required this.id,
    required this.items,
    required this.restaurant,
    required this.subtotal,
    required this.deliveryFee,
    required this.estimatedDelivery,
    required this.status,
  });

  double get total => subtotal + deliveryFee;

  Order copyWith({
    String? id,
    List<CartItem>? items,
    Restaurant? restaurant,
    double? subtotal,
    double? deliveryFee,
    DateTime? estimatedDelivery,
    OrderStatus? status,
  }) {
    return Order(
      id: id ?? this.id,
      items: items ?? this.items,
      restaurant: restaurant ?? this.restaurant,
      subtotal: subtotal ?? this.subtotal,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      estimatedDelivery: estimatedDelivery ?? this.estimatedDelivery,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [
        id,
        items,
        restaurant,
        subtotal,
        deliveryFee,
        estimatedDelivery,
        status,
      ];
}
