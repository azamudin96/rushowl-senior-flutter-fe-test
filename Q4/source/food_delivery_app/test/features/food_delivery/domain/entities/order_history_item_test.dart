import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/features/food_delivery/domain/entities/order_history_item.dart';

import '../../../../helpers/test_fixtures.dart';

void main() {
  group('OrderHistoryItem', () {
    test('equality compares all props', () {
      final a = OrderHistoryItem(
        id: 'oh1',
        restaurantName: 'Test Restaurant',
        restaurantImageUrl: 'https://example.com/img.png',
        date: DateTime(2024, 1, 15),
        status: OrderHistoryStatus.delivered,
        itemsSummary: '2x Pizza, 1x Pasta',
        total: 35.97,
        cartItems: const [tCartItem, tCartItem2],
        restaurant: tRestaurant,
      );
      expect(a, equals(tOrderHistoryItem));
    });
  });
}
