import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/food_delivery/domain/entities/cart_item.dart';

import '../../../../helpers/test_fixtures.dart';

void main() {
  group('CartItem', () {
    test('subtotal returns price * quantity', () {
      // tCartItem: price 12.99, quantity 2
      expect(tCartItem.subtotal, 12.99 * 2);
    });

    test('subtotal returns price * 1 for single quantity', () {
      // tCartItem2: price 9.99, quantity 1
      expect(tCartItem2.subtotal, 9.99);
    });

    test('copyWith updates quantity', () {
      final updated = tCartItem.copyWith(quantity: 5);
      expect(updated.quantity, 5);
      expect(updated.menuItem, tCartItem.menuItem);
    });

    test('equality compares by menuItem and quantity', () {
      const a = CartItem(menuItem: tMenuItem, quantity: 2);
      const b = CartItem(menuItem: tMenuItem, quantity: 2);
      const c = CartItem(menuItem: tMenuItem, quantity: 3);

      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });
  });
}
