import '../entities/menu_item.dart';
import '../entities/restaurant.dart';

abstract class FoodDeliveryRepository {
  Future<List<Restaurant>> getRestaurants();
  Future<List<MenuItem>> getMenuItems(String restaurantId);
}
