import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../di/injection.dart';
import '../../domain/entities/menu_item.dart';
import '../../domain/entities/restaurant.dart';
import '../cubit/cart_cubit.dart';
import '../cubit/search_cubit.dart';
import '../cubit/search_state.dart';
import '../widgets/menu_item_card.dart';
import '../widgets/restaurant_card.dart';
import 'food_menu_screen.dart';
import 'order_history_screen.dart';
import 'profile_screen.dart';

const _categoryIcons = <String, IconData>{
  'Italian': Icons.restaurant,
  'Chinese': Icons.ramen_dining,
  'Mexican': Icons.tapas,
  'Japanese': Icons.set_meal,
  'American': Icons.lunch_dining,
  'Indian': Icons.rice_bowl,
};

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: getIt<SearchCubit>()..loadSuggestions(),
      child: const _SearchView(),
    );
  }
}

class _SearchView extends StatefulWidget {
  const _SearchView();

  @override
  State<_SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<_SearchView> {
  final _controller = TextEditingController();

  void _handleBack() {
    final state = context.read<SearchCubit>().state;
    if (state is! SearchInitial) {
      _controller.clear();
      context.read<SearchCubit>().clearSearch();
      setState(() {});
    } else {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _handleBack();
      },
      child: Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Search',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          // Search input
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _controller,
              onChanged: (q) => context.read<SearchCubit>().search(q),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search restaurants or dishes...',
                hintStyle: const TextStyle(color: Colors.white38),
                prefixIcon:
                    const Icon(Icons.search, color: Colors.white54),
                suffixIcon: _controller.text.isNotEmpty
                    ? IconButton(
                        icon:
                            const Icon(Icons.close, color: Colors.white54),
                        onPressed: () {
                          _controller.clear();
                          context.read<SearchCubit>().clearSearch();
                          setState(() {});
                        },
                      )
                    : const Icon(Icons.mic, color: Colors.white54),
                filled: true,
                fillColor: const Color(0xFF1A1A1A),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: Color(0xFF3D3D3D)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: Color(0xFF3D3D3D)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: theme.colorScheme.primary),
                ),
              ),
            ),
          ),
          // Body
          Expanded(
            child: BlocBuilder<SearchCubit, SearchState>(
              builder: (context, state) {
                return switch (state) {
                  SearchInitial(
                    :final suggestions,
                    :final recentSearches,
                  ) =>
                    _InitialContent(
                      suggestions: suggestions,
                      recentSearches: recentSearches,
                      onCategoryTap: (cat) {
                        _controller.text = cat;
                        context.read<SearchCubit>().search(cat);
                        setState(() {});
                      },
                      onRecentTap: (q) {
                        _controller.text = q;
                        context.read<SearchCubit>().search(q);
                        setState(() {});
                      },
                    ),
                  SearchLoading() =>
                    const Center(child: CircularProgressIndicator()),
                  SearchLoaded(
                    :final restaurants,
                    :final menuItems,
                    :final query,
                    :final allRestaurants,
                  ) =>
                    _SearchResults(
                      restaurants: restaurants,
                      menuItems: menuItems,
                      query: query,
                      allRestaurants: allRestaurants,
                    ),
                  SearchError(:final message) =>
                    Center(child: Text(message)),
                };
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        onTap: (i) {
          if (i == 0) {
            Navigator.of(context).popUntil((route) => route.isFirst);
          } else if (i == 2) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute<void>(
                builder: (_) => const OrderHistoryScreen(),
              ),
            );
          } else if (i == 3) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute<void>(
                builder: (_) => const ProfileScreen(),
              ),
            );
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
    ),
    );
  }
}

// ─── Initial content (before search) ───

class _InitialContent extends StatelessWidget {
  final List<Restaurant> suggestions;
  final List<String> recentSearches;
  final ValueChanged<String> onCategoryTap;
  final ValueChanged<String> onRecentTap;

  const _InitialContent({
    required this.suggestions,
    required this.recentSearches,
    required this.onCategoryTap,
    required this.onRecentTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cubit = context.read<SearchCubit>();

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        // Recent searches
        if (recentSearches.isNotEmpty) ...[
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                'Recent Searches',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => cubit.clearRecentSearches(),
                child: Text(
                  'Clear All',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...List.generate(recentSearches.length, (i) {
            final term = recentSearches[i];
            return ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.history, color: Colors.white38, size: 20),
              title: Text(
                term,
                style: const TextStyle(color: Colors.white70),
              ),
              trailing: GestureDetector(
                onTap: () => cubit.removeRecentSearch(i),
                child: const Icon(Icons.close, color: Colors.white38, size: 18),
              ),
              onTap: () => onRecentTap(term),
            );
          }),
        ],

        // Popular categories
        const SizedBox(height: 24),
        Text(
          'Popular Categories',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _categoryIcons.entries.map((e) {
            return GestureDetector(
              onTap: () => onCategoryTap(e.key),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF3D3D3D)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(e.value, size: 18, color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      e.key,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),

        // You might like
        if (suggestions.isNotEmpty) ...[
          const SizedBox(height: 24),
          Text(
            'You might like',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 220,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: suggestions.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final r = suggestions[index];
                return SizedBox(
                  width: 260,
                  child: _SuggestionCard(
                    restaurant: r,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => FoodMenuScreen(restaurant: r),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],

        const SizedBox(height: 16),
      ],
    );
  }
}

// ─── Search results ───

class _SearchResults extends StatelessWidget {
  final List<Restaurant> restaurants;
  final List<MenuItem> menuItems;
  final String query;
  final List<Restaurant> allRestaurants;

  const _SearchResults({
    required this.restaurants,
    required this.menuItems,
    required this.query,
    required this.allRestaurants,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (restaurants.isEmpty && menuItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_off, size: 48, color: Colors.white38),
            const SizedBox(height: 16),
            Text(
              'No results for "$query"',
              style: theme.textTheme.bodyLarge?.copyWith(color: Colors.white54),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: 16),
      children: [
        if (restaurants.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text(
              'Restaurants',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          ...restaurants.map(
            (r) => RestaurantCard(
              restaurant: r,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => FoodMenuScreen(restaurant: r),
                  ),
                );
              },
            ),
          ),
        ],
        if (menuItems.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Text(
              'Menu Items',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          ...menuItems.map(
            (item) {
              final restaurant = allRestaurants.firstWhere(
                (r) => r.id == item.restaurantId,
              );
              return MenuItemCard(
                item: item,
                onAddToCart: () {
                  context.read<CartCubit>().addItem(item, restaurant);
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      SnackBar(content: Text('Added ${item.name} to cart')),
                    );
                },
              );
            },
          ),
        ],
      ],
    );
  }
}

class _SuggestionCard extends StatelessWidget {
  final Restaurant restaurant;
  final VoidCallback onTap;

  const _SuggestionCard({required this.restaurant, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SizedBox(
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                      imageUrl: restaurant.imageUrl,
                      fit: BoxFit.cover,
                      memCacheWidth: 260,
                      placeholder: (_, __) => const ColoredBox(
                        color: Color(0xFF2A2A2A),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (_, __, ___) => const ColoredBox(
                        color: Color(0xFF2A2A2A),
                        child: Icon(Icons.restaurant, size: 32),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withAlpha(180),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.star, size: 12,
                                color: theme.colorScheme.primary),
                            const SizedBox(width: 3),
                            Text(
                              restaurant.rating.toStringAsFixed(1),
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    restaurant.name,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${restaurant.cuisineType}  •  ${restaurant.deliveryTimeMinutes} min',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white54,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
