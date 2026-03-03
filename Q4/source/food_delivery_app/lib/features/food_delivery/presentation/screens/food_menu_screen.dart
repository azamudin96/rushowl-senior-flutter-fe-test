import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../di/injection.dart';
import '../../domain/entities/menu_item.dart';
import '../../domain/entities/restaurant.dart';
import '../cubit/cart_cubit.dart';
import '../cubit/menu_cubit.dart';
import '../cubit/menu_state.dart';
import '../widgets/cart_badge.dart';
import '../widgets/menu_item_card.dart';

class FoodMenuScreen extends StatelessWidget {
  final Restaurant restaurant;

  const FoodMenuScreen({super.key, required this.restaurant});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<MenuCubit>()..loadMenu(restaurant),
      child: const _FoodMenuView(),
    );
  }
}

class _FoodMenuView extends StatelessWidget {
  const _FoodMenuView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: const [
          IconButton(
            onPressed: null,
            icon: Icon(Icons.search, color: Colors.white),
          ),
          CartBadge(),
        ],
      ),
      body: BlocBuilder<MenuCubit, MenuState>(
        builder: (context, state) {
          return switch (state) {
            MenuInitial() || MenuLoading() =>
              const Center(child: CircularProgressIndicator()),
            MenuLoaded(:final restaurant, :final items) =>
              _MenuContent(restaurant: restaurant, items: items),
            MenuError(:final message) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 48),
                    const SizedBox(height: 16),
                    Text(message),
                  ],
                ),
              ),
          };
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (_) {},
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
}

class _MenuContent extends StatefulWidget {
  final Restaurant restaurant;
  final List<MenuItem> items;

  const _MenuContent({required this.restaurant, required this.items});

  @override
  State<_MenuContent> createState() => _MenuContentState();
}

class _MenuContentState extends State<_MenuContent> {
  String _selectedCategory = 'All Items';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filteredItems = _filteredItems;

    return CustomScrollView(
      slivers: [
        // Hero image + info card combined in one sliver
        SliverToBoxAdapter(
          child: _HeroWithInfoCard(
            restaurant: widget.restaurant,
            theme: theme,
          ),
        ),

        // Category filter chips
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 12),
            child: _CategoryChips(
              categories: _categories,
              selected: _selectedCategory,
              onSelected: (cat) => setState(() => _selectedCategory = cat),
            ),
          ),
        ),

        // Menu items
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final item = filteredItems[index];
              return MenuItemCard(
                item: item,
                onAddToCart: () => _handleAddToCart(context, item),
              );
            },
            childCount: filteredItems.length,
          ),
        ),
        const SliverPadding(padding: EdgeInsets.only(bottom: 16)),
      ],
    );
  }

  List<String> get _categories => [
        'All Items',
        ...{for (final item in widget.items) item.category},
      ];

  List<MenuItem> get _filteredItems {
    if (_selectedCategory == 'All Items') return widget.items;
    return widget.items
        .where((item) => item.category == _selectedCategory)
        .toList();
  }

  void _handleAddToCart(BuildContext context, MenuItem item) {
    final cartCubit = context.read<CartCubit>();
    final cartState = cartCubit.state;

    if (cartState.restaurant != null &&
        cartState.restaurant!.id != widget.restaurant.id) {
      _showSwitchRestaurantDialog(context, cartCubit, item);
    } else {
      cartCubit.addItem(item, widget.restaurant);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text('Added ${item.name} to cart')),
        );
    }
  }

  void _showSwitchRestaurantDialog(
    BuildContext context,
    CartCubit cartCubit,
    MenuItem item,
  ) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Switch restaurant?'),
        content: Text(
          'Your cart has items from ${cartCubit.state.restaurant!.name}. '
          'Clear cart and switch to ${widget.restaurant.name}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              cartCubit.clearCart();
              cartCubit.addItem(item, widget.restaurant);
              Navigator.of(dialogContext).pop();
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(content: Text('Added ${item.name} to cart')),
                );
            },
            child: const Text('Clear & Add'),
          ),
        ],
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final ThemeData theme;

  const _InfoBox({
    required this.icon,
    required this.label,
    required this.value,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFF3D3D3D)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: theme.colorScheme.primary),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: Colors.white54,
                letterSpacing: 0.8,
                fontSize: 9,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroWithInfoCard extends StatelessWidget {
  final Restaurant restaurant;
  final ThemeData theme;

  const _HeroWithInfoCard({
    required this.restaurant,
    required this.theme,
  });

  static const _imageHeight = 220.0;
  static const _cardOverlap = 40.0;

  @override
  Widget build(BuildContext context) {
    // Stack: image is Positioned (behind), card is the sizing child.
    // Card has top padding = imageHeight - overlap so it sits below the
    // image with an overlap region. Because the card is the normal
    // (non-positioned) child it drives the Stack's total height.
    return Stack(
      children: [
        // 1) Image behind — positioned, does NOT affect Stack size
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: _imageHeight,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CachedNetworkImage(
                imageUrl: restaurant.imageUrl,
                fit: BoxFit.cover,
                placeholder: (_, __) => const ColoredBox(
                  color: Color(0xFF2A2A2A),
                  child: Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (_, __, ___) => const ColoredBox(
                  color: Color(0xFF2A2A2A),
                  child: Icon(Icons.restaurant, size: 48),
                ),
              ),
              // Gradient fade at bottom
              const Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: 100,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Color(0xFF0D0D0D),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // 2) Card — normal child, determines Stack height
        Padding(
          padding: const EdgeInsets.only(
            top: _imageHeight - _cardOverlap,
            left: 16,
            right: 16,
            bottom: 16,
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF2A2A2A)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        restaurant.name,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: theme.colorScheme.primary.withAlpha(100),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.star,
                            size: 14,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            restaurant.rating.toStringAsFixed(1),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  restaurant.cuisineType,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white54,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _InfoBox(
                      icon: Icons.schedule,
                      label: 'DELIVERY',
                      value: '${restaurant.deliveryTimeMinutes} min',
                      theme: theme,
                    ),
                    const SizedBox(width: 10),
                    _InfoBox(
                      icon: Icons.location_on_outlined,
                      label: 'DISTANCE',
                      value: '1.2 km',
                      theme: theme,
                    ),
                    const SizedBox(width: 10),
                    _InfoBox(
                      icon: Icons.receipt_long_outlined,
                      label: 'MINIMUM',
                      value:
                          '\$${restaurant.deliveryFee.toStringAsFixed(2)}',
                      theme: theme,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CategoryChips extends StatelessWidget {
  final List<String> categories;
  final String selected;
  final ValueChanged<String> onSelected;

  const _CategoryChips({
    required this.categories,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = cat == selected;
          return GestureDetector(
            onTap: () => onSelected(cat),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
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
              alignment: Alignment.center,
              child: Text(
                cat,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isSelected ? Colors.black : Colors.white70,
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
