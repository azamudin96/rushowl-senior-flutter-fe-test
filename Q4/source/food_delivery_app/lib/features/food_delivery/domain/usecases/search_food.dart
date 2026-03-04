import '../../domain/entities/menu_item.dart';
import '../../domain/entities/restaurant.dart';
import '../../domain/repositories/food_delivery_repository.dart';

class SearchFood {
  final FoodDeliveryRepository repository;

  const SearchFood(this.repository);

  Future<(List<Restaurant>, List<MenuItem>)> call(String query) async {
    final results = await Future.wait([
      repository.searchRestaurants(query),
      repository.searchAllMenuItems(query),
    ]);
    return (results[0] as List<Restaurant>, results[1] as List<MenuItem>);
  }
}
