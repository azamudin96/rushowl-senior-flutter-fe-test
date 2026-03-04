import 'package:equatable/equatable.dart';

import '../../domain/entities/menu_item.dart';
import '../../domain/entities/restaurant.dart';

sealed class SearchState extends Equatable {
  const SearchState();

  @override
  List<Object?> get props => [];
}

class SearchInitial extends SearchState {
  final List<Restaurant> suggestions;
  final List<String> recentSearches;

  const SearchInitial({
    this.suggestions = const [],
    this.recentSearches = const [],
  });

  @override
  List<Object?> get props => [suggestions, recentSearches];
}

class SearchLoading extends SearchState {
  const SearchLoading();
}

class SearchLoaded extends SearchState {
  final List<Restaurant> restaurants;
  final List<MenuItem> menuItems;
  final String query;
  final List<Restaurant> allRestaurants;

  const SearchLoaded({
    required this.restaurants,
    required this.menuItems,
    required this.query,
    required this.allRestaurants,
  });

  @override
  List<Object?> get props => [restaurants, menuItems, query, allRestaurants];
}

class SearchError extends SearchState {
  final String message;

  const SearchError(this.message);

  @override
  List<Object?> get props => [message];
}
