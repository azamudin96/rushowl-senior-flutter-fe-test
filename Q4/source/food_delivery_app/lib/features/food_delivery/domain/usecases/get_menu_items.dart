import '../entities/menu_item.dart';
import '../repositories/food_delivery_repository.dart';

class GetMenuItems {
  final FoodDeliveryRepository repository;

  const GetMenuItems(this.repository);

  Future<List<MenuItem>> call(String restaurantId) =>
      repository.getMenuItems(restaurantId);
}
