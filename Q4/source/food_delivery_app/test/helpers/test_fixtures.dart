import 'package:food_delivery_app/features/food_delivery/domain/entities/cart_item.dart';
import 'package:food_delivery_app/features/food_delivery/domain/entities/menu_item.dart';
import 'package:food_delivery_app/features/food_delivery/domain/entities/order_history_item.dart';
import 'package:food_delivery_app/features/food_delivery/domain/entities/restaurant.dart';

const tRestaurant = Restaurant(
  id: 'r1',
  name: 'Test Restaurant',
  imageUrl: 'https://example.com/img.png',
  rating: 4.5,
  cuisineType: 'Italian',
  deliveryTimeMinutes: 30,
  deliveryFee: 3.0,
);

const tRestaurant2 = Restaurant(
  id: 'r2',
  name: 'Another Restaurant',
  imageUrl: 'https://example.com/img2.png',
  rating: 4.0,
  cuisineType: 'Japanese',
  deliveryTimeMinutes: 25,
  deliveryFee: 2.5,
);

const tMenuItem = MenuItem(
  id: 'm1',
  name: 'Pizza',
  imageUrl: 'https://example.com/pizza.png',
  price: 12.99,
  description: 'Delicious pizza',
  restaurantId: 'r1',
  category: 'Main',
);

const tMenuItem2 = MenuItem(
  id: 'm2',
  name: 'Pasta',
  imageUrl: 'https://example.com/pasta.png',
  price: 9.99,
  description: 'Fresh pasta',
  restaurantId: 'r1',
  category: 'Main',
);

const tCartItem = CartItem(menuItem: tMenuItem, quantity: 2);

const tCartItem2 = CartItem(menuItem: tMenuItem2, quantity: 1);

final tOrderHistoryItem = OrderHistoryItem(
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

final tActiveOrderHistoryItem = OrderHistoryItem(
  id: 'oh2',
  restaurantName: 'Another Restaurant',
  restaurantImageUrl: 'https://example.com/img2.png',
  date: DateTime(2024, 1, 20),
  status: OrderHistoryStatus.inProgress,
  itemsSummary: '1x Pasta',
  total: 9.99,
  cartItems: const [tCartItem2],
  restaurant: tRestaurant2,
);
