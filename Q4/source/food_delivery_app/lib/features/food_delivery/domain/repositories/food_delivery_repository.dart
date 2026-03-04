import '../entities/menu_item.dart';
import '../entities/order_history_item.dart';
import '../entities/restaurant.dart';

abstract class FoodDeliveryRepository {
  Future<List<Restaurant>> getRestaurants();
  Future<List<MenuItem>> getMenuItems(String restaurantId);
  Future<List<Restaurant>> searchRestaurants(String query);
  Future<List<MenuItem>> searchAllMenuItems(String query);
  Future<List<OrderHistoryItem>> getOrderHistory();
}
