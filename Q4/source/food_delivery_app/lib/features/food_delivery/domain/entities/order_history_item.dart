import 'package:equatable/equatable.dart';

import 'cart_item.dart';
import 'restaurant.dart';

enum OrderHistoryStatus { inProgress, delivered, cancelled }

class OrderHistoryItem extends Equatable {
  final String id;
  final String restaurantName;
  final String restaurantImageUrl;
  final DateTime date;
  final OrderHistoryStatus status;
  final String itemsSummary;
  final double total;
  final List<CartItem> cartItems;
  final Restaurant restaurant;

  const OrderHistoryItem({
    required this.id,
    required this.restaurantName,
    required this.restaurantImageUrl,
    required this.date,
    required this.status,
    required this.itemsSummary,
    required this.total,
    required this.cartItems,
    required this.restaurant,
  });

  @override
  List<Object?> get props => [
        id,
        restaurantName,
        restaurantImageUrl,
        date,
        status,
        itemsSummary,
        total,
        cartItems,
        restaurant,
      ];
}
