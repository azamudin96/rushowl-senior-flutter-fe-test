import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_restaurants.dart';
import '../../domain/usecases/search_food.dart';
import 'search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  final SearchFood _searchFood;
  final GetRestaurants _getRestaurants;

  final List<String> recentSearches = [];

  Timer? _debounce;

  SearchCubit(this._searchFood, this._getRestaurants)
      : super(const SearchInitial());

  Future<void> loadSuggestions() async {
    try {
      final restaurants = await _getRestaurants();
      final sorted = [...restaurants]
        ..sort((a, b) => b.rating.compareTo(a.rating));
      emit(SearchInitial(
        suggestions: sorted.take(2).toList(),
        recentSearches: List.unmodifiable(recentSearches),
      ));
    } catch (e) {
      emit(SearchError(e.toString()));
    }
  }

  void search(String query) {
    _debounce?.cancel();
    if (query.trim().isEmpty) {
      loadSuggestions();
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _performSearch(query.trim());
    });
  }

  Future<void> _performSearch(String query) async {
    emit(const SearchLoading());
    try {
      if (!recentSearches.contains(query)) {
        recentSearches.insert(0, query);
        if (recentSearches.length > 10) recentSearches.removeLast();
      }
      final allRestaurants = await _getRestaurants();
      final (restaurants, menuItems) = await _searchFood(query);
      emit(SearchLoaded(
        restaurants: restaurants,
        menuItems: menuItems,
        query: query,
        allRestaurants: allRestaurants,
      ));
    } catch (e) {
      emit(SearchError(e.toString()));
    }
  }

  void clearSearch() {
    _debounce?.cancel();
    loadSuggestions();
  }

  void removeRecentSearch(int index) {
    if (index >= 0 && index < recentSearches.length) {
      recentSearches.removeAt(index);
      loadSuggestions();
    }
  }

  void clearRecentSearches() {
    recentSearches.clear();
    loadSuggestions();
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}
