import '../../domain/entities/menu_item.dart';
import '../../domain/entities/order_history_item.dart';
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

  @override
  Future<List<Restaurant>> searchRestaurants(String query) =>
      datasource.searchRestaurants(query);

  @override
  Future<List<MenuItem>> searchAllMenuItems(String query) =>
      datasource.searchAllMenuItems(query);

  @override
  Future<List<OrderHistoryItem>> getOrderHistory() =>
      datasource.getOrderHistory();
}
