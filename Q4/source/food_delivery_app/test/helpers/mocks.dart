import 'package:food_delivery_app/features/food_delivery/domain/repositories/food_delivery_repository.dart';
import 'package:food_delivery_app/features/food_delivery/domain/usecases/get_menu_items.dart';
import 'package:food_delivery_app/features/food_delivery/domain/usecases/get_order_history.dart';
import 'package:food_delivery_app/features/food_delivery/domain/usecases/get_restaurants.dart';
import 'package:food_delivery_app/features/food_delivery/domain/usecases/search_food.dart';
import 'package:mocktail/mocktail.dart';

class MockFoodDeliveryRepository extends Mock
    implements FoodDeliveryRepository {}

class MockGetRestaurants extends Mock implements GetRestaurants {}

class MockGetMenuItems extends Mock implements GetMenuItems {}

class MockSearchFood extends Mock implements SearchFood {}

class MockGetOrderHistory extends Mock implements GetOrderHistory {}
