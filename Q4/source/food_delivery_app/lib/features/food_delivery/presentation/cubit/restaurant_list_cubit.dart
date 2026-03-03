import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_restaurants.dart';
import 'restaurant_list_state.dart';

class RestaurantListCubit extends Cubit<RestaurantListState> {
  final GetRestaurants _getRestaurants;

  RestaurantListCubit(this._getRestaurants)
      : super(const RestaurantListInitial());

  Future<void> loadRestaurants() async {
    emit(const RestaurantListLoading());
    try {
      final restaurants = await _getRestaurants();
      emit(RestaurantListLoaded(restaurants));
    } catch (e) {
      emit(RestaurantListError(e.toString()));
    }
  }
}
