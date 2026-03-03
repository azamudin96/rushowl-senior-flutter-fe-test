import '../entities/restaurant.dart';
import '../repositories/food_delivery_repository.dart';

class GetRestaurants {
  final FoodDeliveryRepository repository;

  const GetRestaurants(this.repository);

  Future<List<Restaurant>> call() => repository.getRestaurants();
}
