import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/food_delivery/domain/entities/order.dart';
import 'package:food_delivery_app/features/food_delivery/presentation/cubit/order_cubit.dart';
import 'package:food_delivery_app/features/food_delivery/presentation/cubit/order_state.dart';

import '../../../../helpers/test_fixtures.dart';

void main() {
  group('OrderCubit', () {
    late OrderCubit cubit;

    setUp(() {
      cubit = OrderCubit();
    });

    tearDown(() => cubit.close());

    test('initial state is OrderInitial', () {
      expect(cubit.state, isA<OrderInitial>());
    });

    test('placeOrder emits OrderPlacing then OrderTracking with confirmed',
        () async {
      final states = <OrderState>[];
      final sub = cubit.stream.listen(states.add);

      cubit.placeOrder([tCartItem], tRestaurant);

      // Allow microtasks to complete
      await Future<void>.delayed(Duration.zero);

      expect(states.length, greaterThanOrEqualTo(2));
      expect(states[0], isA<OrderPlacing>());
      expect(states[1], isA<OrderTracking>());

      final tracking = states[1] as OrderTracking;
      expect(tracking.order.status, OrderStatus.confirmed);
      expect(tracking.order.id, startsWith('ORD-'));
      expect(tracking.order.restaurant, tRestaurant);

      await sub.cancel();
    });

    test('timer advances status every 5 seconds', () {
      fakeAsync((async) {
        cubit.placeOrder([tCartItem], tRestaurant);

        // Initial: confirmed
        expect((cubit.state as OrderTracking).order.status,
            OrderStatus.confirmed);

        // After 5s: preparing
        async.elapse(const Duration(seconds: 5));
        expect((cubit.state as OrderTracking).order.status,
            OrderStatus.preparing);

        // After 10s: onTheWay
        async.elapse(const Duration(seconds: 5));
        expect(
            (cubit.state as OrderTracking).order.status, OrderStatus.onTheWay);

        // After 15s: delivered
        async.elapse(const Duration(seconds: 5));
        expect((cubit.state as OrderTracking).order.status,
            OrderStatus.delivered);
      });
    });

    test('timer stops at delivered', () {
      fakeAsync((async) {
        cubit.placeOrder([tCartItem], tRestaurant);

        // Advance to delivered (3 intervals of 5s)
        async.elapse(const Duration(seconds: 15));
        expect((cubit.state as OrderTracking).order.status,
            OrderStatus.delivered);

        // Advance further — state should remain delivered
        async.elapse(const Duration(seconds: 10));
        expect((cubit.state as OrderTracking).order.status,
            OrderStatus.delivered);
      });
    });

    test('close cancels the timer', () async {
      cubit.placeOrder([tCartItem], tRestaurant);
      await cubit.close();

      // Closing should not throw and the cubit is now done
      expect(cubit.isClosed, true);
    });

    test('re-placeOrder cancels previous timer', () {
      fakeAsync((async) {
        cubit.placeOrder([tCartItem], tRestaurant);
        async.elapse(const Duration(seconds: 5));
        expect((cubit.state as OrderTracking).order.status,
            OrderStatus.preparing);

        // Place a new order — should reset
        cubit.placeOrder([tCartItem2], tRestaurant2);
        expect((cubit.state as OrderTracking).order.status,
            OrderStatus.confirmed);
        expect((cubit.state as OrderTracking).order.restaurant, tRestaurant2);

        // After 5s, the NEW order should advance (not the old one)
        async.elapse(const Duration(seconds: 5));
        expect((cubit.state as OrderTracking).order.status,
            OrderStatus.preparing);
        expect((cubit.state as OrderTracking).order.restaurant, tRestaurant2);
      });
    });
  });
}
