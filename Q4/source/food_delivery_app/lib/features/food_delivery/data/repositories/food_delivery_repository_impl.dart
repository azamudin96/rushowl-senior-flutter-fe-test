import '../../domain/entities/menu_item.dart';
import '../../domain/entities/restaurant.dart';
import '../../domain/repositories/food_delivery_repository.dart';
import '../datasources/food_delivery_local_datasource.dart';

class FoodDeliveryRepositoryImpl implements FoodDeliveryRepository {
  final FoodDeliveryLocalDatasource datasource;

  const FoodDeliveryRepositoryImpl(this.datasource);

  @override
  Future<List<Restaurant>> getRestaurants() => datasource.getRestaurants();

  @override
  Future<List<MenuItem>> getMenuItems(String restaurantId) =>
      datasource.getMenuItems(restaurantId);
}
