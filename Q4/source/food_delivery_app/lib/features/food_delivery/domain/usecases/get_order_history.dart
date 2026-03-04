import '../entities/order_history_item.dart';
import '../repositories/food_delivery_repository.dart';

class GetOrderHistory {
  final FoodDeliveryRepository repository;

  const GetOrderHistory(this.repository);

  Future<List<OrderHistoryItem>> call() => repository.getOrderHistory();
}
