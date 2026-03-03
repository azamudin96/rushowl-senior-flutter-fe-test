import 'package:equatable/equatable.dart';

import '../../domain/entities/restaurant.dart';

sealed class RestaurantListState extends Equatable {
  const RestaurantListState();

  @override
  List<Object?> get props => [];
}

class RestaurantListInitial extends RestaurantListState {
  const RestaurantListInitial();
}

class RestaurantListLoading extends RestaurantListState {
  const RestaurantListLoading();
}

class RestaurantListLoaded extends RestaurantListState {
  final List<Restaurant> restaurants;

  const RestaurantListLoaded(this.restaurants);

  @override
  List<Object?> get props => [restaurants];
}

class RestaurantListError extends RestaurantListState {
  final String message;

  const RestaurantListError(this.message);

  @override
  List<Object?> get props => [message];
}
