import 'package:get_it/get_it.dart';

import '../features/food_delivery/data/datasources/food_delivery_local_datasource.dart';
import '../features/food_delivery/data/repositories/food_delivery_repository_impl.dart';
import '../features/food_delivery/domain/repositories/food_delivery_repository.dart';
import '../features/food_delivery/domain/usecases/get_menu_items.dart';
import '../features/food_delivery/domain/usecases/get_order_history.dart';
import '../features/food_delivery/domain/usecases/get_restaurants.dart';
import '../features/food_delivery/domain/usecases/search_food.dart';
import '../features/food_delivery/presentation/cubit/cart_cubit.dart';
import '../features/food_delivery/presentation/cubit/menu_cubit.dart';
import '../features/food_delivery/presentation/cubit/order_cubit.dart';
import '../features/food_delivery/presentation/cubit/order_history_cubit.dart';
import '../features/food_delivery/presentation/cubit/restaurant_list_cubit.dart';
import '../features/food_delivery/presentation/cubit/search_cubit.dart';

final getIt = GetIt.instance;

void setupDependencies() {
  // Datasources
  getIt.registerSingleton<FoodDeliveryLocalDatasource>(
    FoodDeliveryLocalDatasource(),
  );

  // Repositories
  getIt.registerSingleton<FoodDeliveryRepository>(
    FoodDeliveryRepositoryImpl(getIt<FoodDeliveryLocalDatasource>()),
  );

  // Use cases
  getIt.registerFactory(() => GetRestaurants(getIt<FoodDeliveryRepository>()));
  getIt.registerFactory(() => GetMenuItems(getIt<FoodDeliveryRepository>()));
  getIt.registerFactory(() => SearchFood(getIt<FoodDeliveryRepository>()));
  getIt
      .registerFactory(() => GetOrderHistory(getIt<FoodDeliveryRepository>()));

  // Cubits
  getIt.registerFactory(() => RestaurantListCubit(getIt<GetRestaurants>()));
  getIt.registerFactory(() => MenuCubit(getIt<GetMenuItems>()));
  getIt.registerLazySingleton(
    () => SearchCubit(getIt<SearchFood>(), getIt<GetRestaurants>()),
  );
  getIt.registerLazySingleton(() => CartCubit());
  getIt.registerFactory(() => OrderCubit());
  getIt.registerLazySingleton(
      () => OrderHistoryCubit(getIt<GetOrderHistory>()));
}
