import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../di/injection.dart';
import '../../domain/entities/restaurant.dart';
import '../cubit/restaurant_list_cubit.dart';
import '../cubit/restaurant_list_state.dart';
import '../widgets/cart_badge.dart';
import '../widgets/restaurant_card.dart';
import 'food_menu_screen.dart';
import 'order_history_screen.dart';
import 'profile_screen.dart';
import 'search_screen.dart';

class RestaurantListScreen extends StatelessWidget {
  const RestaurantListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<RestaurantListCubit>()..loadRestaurants(),
      child: const _RestaurantListView(),
    );
  }
}

class _RestaurantListView extends StatefulWidget {
  const _RestaurantListView();

  @override
  State<_RestaurantListView> createState() => _RestaurantListViewState();
}

class _RestaurantListViewState extends State<_RestaurantListView> {
  int _navIndex = 0;
  String _selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'RushTrail Eats',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: const [CartBadge()],
      ),
      body: BlocBuilder<RestaurantListCubit, RestaurantListState>(
        builder: (context, state) {
          return switch (state) {
            RestaurantListInitial() ||
            RestaurantListLoading() =>
              const Center(child: CircularProgressIndicator()),
            RestaurantListLoaded(:final restaurants) => Column(
                children: [
                  _CategoryFilter(
                    restaurants: restaurants,
                    selected: _selectedCategory,
                    onSelected: (cat) =>
                        setState(() => _selectedCategory = cat),
                  ),
                  Expanded(
                    child: _RestaurantList(
                      restaurants: _filterRestaurants(restaurants),
                    ),
                  ),
                ],
              ),
            RestaurantListError(:final message) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 48),
                    const SizedBox(height: 16),
                    Text(message),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context
                          .read<RestaurantListCubit>()
                          .loadRestaurants(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
          };
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _navIndex,
        onTap: (i) {
          if (i == 1) {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const SearchScreen(),
              ),
            );
          } else if (i == 2) {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const OrderHistoryScreen(),
              ),
            );
          } else if (i == 3) {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const ProfileScreen(),
              ),
            );
          } else {
            setState(() => _navIndex = i);
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  List<Restaurant> _filterRestaurants(List<Restaurant> restaurants) {
    if (_selectedCategory == 'All') return restaurants;
    return restaurants
        .where((r) => r.cuisineType == _selectedCategory)
        .toList();
  }
}

const _categoryIcons = <String, IconData>{
  'All': Icons.grid_view_rounded,
  'Italian': Icons.restaurant,
  'Chinese': Icons.ramen_dining,
  'Mexican': Icons.tapas,
  'Japanese': Icons.set_meal,
  'American': Icons.lunch_dining,
  'Indian': Icons.rice_bowl,
};

class _CategoryFilter extends StatelessWidget {
  final List<Restaurant> restaurants;
  final String selected;
  final ValueChanged<String> onSelected;

  const _CategoryFilter({
    required this.restaurants,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categories = [
      'All',
      ...{for (final r in restaurants) r.cuisineType},
    ];

    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = cat == selected;
          return GestureDetector(
            onTap: () => onSelected(cat),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.colorScheme.primary
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : const Color(0xFF3D3D3D),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _categoryIcons[cat] ?? Icons.restaurant,
                    size: 16,
                    color: isSelected ? Colors.black : Colors.white54,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    cat,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isSelected ? Colors.black : Colors.white70,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _RestaurantList extends StatelessWidget {
  final List<Restaurant> restaurants;

  const _RestaurantList({required this.restaurants});

  @override
  Widget build(BuildContext context) {
    if (restaurants.isEmpty) {
      return const Center(
        child: Text(
          'No restaurants found',
          style: TextStyle(color: Colors.white54),
        ),
      );
    }

    return ListView.builder(
      cacheExtent: 500,
      padding: const EdgeInsets.only(top: 8, bottom: 16),
      itemCount: restaurants.length,
      itemBuilder: (context, index) {
        final restaurant = restaurants[index];
        return RestaurantCard(
          restaurant: restaurant,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => FoodMenuScreen(restaurant: restaurant),
              ),
            );
          },
        );
      },
    );
  }
}
