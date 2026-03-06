import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/food_delivery/domain/entities/cart_item.dart';
import 'package:food_delivery_app/features/food_delivery/presentation/cubit/cart_cubit.dart';
import 'package:food_delivery_app/features/food_delivery/presentation/cubit/cart_state.dart';

import '../../../../helpers/test_fixtures.dart';

void main() {
  group('CartCubit', () {
    late CartCubit cubit;

    setUp(() {
      cubit = CartCubit();
    });

    tearDown(() => cubit.close());

    test('initial state is empty CartState', () {
      expect(cubit.state, const CartState());
      expect(cubit.state.items, isEmpty);
      expect(cubit.state.restaurant, isNull);
    });

    blocTest<CartCubit, CartState>(
      'addItem adds new item with quantity 1',
      build: () => CartCubit(),
      act: (cubit) => cubit.addItem(tMenuItem, tRestaurant),
      expect: () => [
        const CartState(
          items: [CartItem(menuItem: tMenuItem, quantity: 1)],
          restaurant: tRestaurant,
        ),
      ],
    );

    blocTest<CartCubit, CartState>(
      'addItem increments quantity for existing item',
      build: () => CartCubit(),
      act: (cubit) {
        cubit.addItem(tMenuItem, tRestaurant);
        cubit.addItem(tMenuItem, tRestaurant);
      },
      expect: () => [
        const CartState(
          items: [CartItem(menuItem: tMenuItem, quantity: 1)],
          restaurant: tRestaurant,
        ),
        const CartState(
          items: [CartItem(menuItem: tMenuItem, quantity: 2)],
          restaurant: tRestaurant,
        ),
      ],
    );

    blocTest<CartCubit, CartState>(
      'addItem adds different items separately',
      build: () => CartCubit(),
      act: (cubit) {
        cubit.addItem(tMenuItem, tRestaurant);
        cubit.addItem(tMenuItem2, tRestaurant);
      },
      expect: () => [
        const CartState(
          items: [CartItem(menuItem: tMenuItem, quantity: 1)],
          restaurant: tRestaurant,
        ),
        const CartState(
          items: [
            CartItem(menuItem: tMenuItem, quantity: 1),
            CartItem(menuItem: tMenuItem2, quantity: 1),
          ],
          restaurant: tRestaurant,
        ),
      ],
    );

    blocTest<CartCubit, CartState>(
      'removeItem removes item by menuItemId',
      build: () => CartCubit(),
      seed: () => const CartState(
        items: [
          CartItem(menuItem: tMenuItem, quantity: 1),
          CartItem(menuItem: tMenuItem2, quantity: 1),
        ],
        restaurant: tRestaurant,
      ),
      act: (cubit) => cubit.removeItem('m1'),
      expect: () => [
        const CartState(
          items: [CartItem(menuItem: tMenuItem2, quantity: 1)],
          restaurant: tRestaurant,
        ),
      ],
    );

    blocTest<CartCubit, CartState>(
      'removeItem clears restaurant when last item removed',
      build: () => CartCubit(),
      seed: () => const CartState(
        items: [CartItem(menuItem: tMenuItem, quantity: 1)],
        restaurant: tRestaurant,
      ),
      act: (cubit) => cubit.removeItem('m1'),
      expect: () => [const CartState(items: [], restaurant: null)],
    );

    blocTest<CartCubit, CartState>(
      'updateQuantity updates item quantity',
      build: () => CartCubit(),
      seed: () => const CartState(
        items: [CartItem(menuItem: tMenuItem, quantity: 1)],
        restaurant: tRestaurant,
      ),
      act: (cubit) => cubit.updateQuantity('m1', 5),
      expect: () => [
        const CartState(
          items: [CartItem(menuItem: tMenuItem, quantity: 5)],
          restaurant: tRestaurant,
        ),
      ],
    );

    blocTest<CartCubit, CartState>(
      'updateQuantity with 0 removes item',
      build: () => CartCubit(),
      seed: () => const CartState(
        items: [CartItem(menuItem: tMenuItem, quantity: 2)],
        restaurant: tRestaurant,
      ),
      act: (cubit) => cubit.updateQuantity('m1', 0),
      expect: () => [const CartState(items: [], restaurant: null)],
    );

    blocTest<CartCubit, CartState>(
      'clearCart resets to empty state',
      build: () => CartCubit(),
      seed: () => const CartState(
        items: [
          CartItem(menuItem: tMenuItem, quantity: 2),
          CartItem(menuItem: tMenuItem2, quantity: 1),
        ],
        restaurant: tRestaurant,
      ),
      act: (cubit) => cubit.clearCart(),
      expect: () => [const CartState()],
    );

    group('computed getters', () {
      test('subtotal sums all item subtotals', () {
        cubit.addItem(tMenuItem, tRestaurant); // 12.99
        cubit.addItem(tMenuItem, tRestaurant); // qty becomes 2 → 25.98
        cubit.addItem(tMenuItem2, tRestaurant); // 9.99

        expect(cubit.state.subtotal, closeTo(35.97, 0.01));
      });

      test('deliveryFee returns restaurant deliveryFee', () {
        cubit.addItem(tMenuItem, tRestaurant);

        expect(cubit.state.deliveryFee, 3.0);
      });

      test('total returns subtotal + deliveryFee', () {
        cubit.addItem(tMenuItem, tRestaurant); // 12.99 + 3.0

        expect(cubit.state.total, closeTo(15.99, 0.01));
      });

      test('itemCount sums all quantities', () {
        cubit.addItem(tMenuItem, tRestaurant); // qty 1
        cubit.addItem(tMenuItem, tRestaurant); // qty 2
        cubit.addItem(tMenuItem2, tRestaurant); // qty 1

        expect(cubit.state.itemCount, 3);
      });

      test('deliveryFee returns 0 when no restaurant', () {
        expect(cubit.state.deliveryFee, 0);
      });
    });
  });
}
