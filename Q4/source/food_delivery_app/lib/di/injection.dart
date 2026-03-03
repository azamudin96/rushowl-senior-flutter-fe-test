import 'package:get_it/get_it.dart';

import '../features/food_delivery/data/datasources/food_delivery_local_datasource.dart';
import '../features/food_delivery/data/repositories/food_delivery_repository_impl.dart';
import '../features/food_delivery/domain/repositories/food_delivery_repository.dart';
import '../features/food_delivery/domain/usecases/get_menu_items.dart';
import '../features/food_delivery/domain/usecases/get_restaurants.dart';
import '../features/food_delivery/presentation/cubit/cart_cubit.dart';
import '../features/food_delivery/presentation/cubit/menu_cubit.dart';
import '../features/food_delivery/presentation/cubit/order_cubit.dart';
import '../features/food_delivery/presentation/cubit/restaurant_list_cubit.dart';

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

  // Cubits
  getIt.registerFactory(() => RestaurantListCubit(getIt<GetRestaurants>()));
  getIt.registerFactory(() => MenuCubit(getIt<GetMenuItems>()));
  getIt.registerLazySingleton(() => CartCubit());
  getIt.registerFactory(() => OrderCubit());
}
