import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/food_delivery/domain/entities/order.dart';

import '../../../../helpers/test_fixtures.dart';

void main() {
  final tOrder = Order(
    id: 'ORD-1',
    items: const [tCartItem, tCartItem2],
    restaurant: tRestaurant,
    subtotal: 35.97,
    deliveryFee: 3.0,
    estimatedDelivery: DateTime(2024, 1, 15, 12, 30),
    status: OrderStatus.confirmed,
  );

  group('Order', () {
    test('total returns subtotal + deliveryFee', () {
      expect(tOrder.total, 35.97 + 3.0);
    });

    test('copyWith updates status', () {
      final updated = tOrder.copyWith(status: OrderStatus.delivered);
      expect(updated.status, OrderStatus.delivered);
      expect(updated.id, tOrder.id);
      expect(updated.subtotal, tOrder.subtotal);
    });

    test('equality compares all props', () {
      final a = Order(
        id: 'ORD-1',
        items: const [tCartItem, tCartItem2],
        restaurant: tRestaurant,
        subtotal: 35.97,
        deliveryFee: 3.0,
        estimatedDelivery: DateTime(2024, 1, 15, 12, 30),
        status: OrderStatus.confirmed,
      );
      expect(a, equals(tOrder));
    });
  });

  group('OrderStatus', () {
    test('displayName returns correct strings', () {
      expect(OrderStatus.confirmed.displayName, 'Order Confirmed');
      expect(OrderStatus.preparing.displayName, 'Preparing your meal');
      expect(OrderStatus.onTheWay.displayName, 'On the way');
      expect(OrderStatus.delivered.displayName, 'Delivered');
    });

    test('subtitle returns correct strings', () {
      expect(OrderStatus.confirmed.subtitle, 'Your order has been received');
      expect(OrderStatus.preparing.subtitle, 'Chef is working their magic');
      expect(
        OrderStatus.onTheWay.subtitle,
        'The courier is 1.2km away from you',
      );
      expect(OrderStatus.delivered.subtitle, 'Enjoy your meal!');
    });

    test('icon returns correct IconData', () {
      expect(OrderStatus.confirmed.icon, Icons.check);
      expect(OrderStatus.preparing.icon, Icons.check);
      expect(OrderStatus.onTheWay.icon, Icons.delivery_dining);
      expect(OrderStatus.delivered.icon, Icons.home_rounded);
    });
  });
}
