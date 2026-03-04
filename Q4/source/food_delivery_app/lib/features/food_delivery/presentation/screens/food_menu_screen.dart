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
      child: _FoodMenuView(restaurantName: restaurant.name),
    );
  }
}

class _FoodMenuView extends StatefulWidget {
  final String restaurantName;

  const _FoodMenuView({required this.restaurantName});

  @override
  State<_FoodMenuView> createState() => _FoodMenuViewState();
}

class _FoodMenuViewState extends State<_FoodMenuView> {
  bool _isSearching = false;
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        _searchQuery = '';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                onChanged: (q) => setState(() => _searchQuery = q),
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search menu...',
                  hintStyle: const TextStyle(color: Colors.white38),
                  border: InputBorder.none,
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close, color: Colors.white54),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                ),
              )
            : Text(
                widget.restaurantName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
        actions: [
          IconButton(
            onPressed: _toggleSearch,
            icon: Icon(
              _isSearching ? Icons.close : Icons.search,
              color: Colors.white,
            ),
          ),
          const CartBadge(),
        ],
      ),
      body: BlocBuilder<MenuCubit, MenuState>(
        builder: (context, state) {
          return switch (state) {
            MenuInitial() || MenuLoading() =>
              const Center(child: CircularProgressIndicator()),
            MenuLoaded(:final restaurant, :final items) =>
              _MenuContent(
                restaurant: restaurant,
                items: items,
                searchQuery: _searchQuery,
              ),
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
    );
  }
}

class _MenuContent extends StatefulWidget {
  final Restaurant restaurant;
  final List<MenuItem> items;
  final String searchQuery;

  const _MenuContent({
    required this.restaurant,
    required this.items,
    this.searchQuery = '',
  });

  @override
  State<_MenuContent> createState() => _MenuContentState();
}

class _MenuContentState extends State<_MenuContent> {
  String _selectedCategory = 'All Items';
  final _scrollController = ScrollController();

  @override
  void didUpdateWidget(covariant _MenuContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchQuery != widget.searchQuery) {
      _scrollToResults();
    }
  }

  void _scrollToResults() {
    if (!_scrollController.hasClients) return;
    // Scroll to just below the hero + chips (~340px)
    const targetOffset = 340.0;
    final maxScroll = _scrollController.position.maxScrollExtent;
    _scrollController.animateTo(
      targetOffset.clamp(0.0, maxScroll),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filteredItems = _filteredItems;

    return CustomScrollView(
      controller: _scrollController,
      cacheExtent: 500,
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

        // Menu items or empty state
        if (filteredItems.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: AnimatedOpacity(
              opacity: 1.0,
              duration: const Duration(milliseconds: 300),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.search_off, size: 48, color: Colors.white38),
                    const SizedBox(height: 16),
                    Text(
                      'No items found',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: Colors.white54,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        else ...[
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final item = filteredItems[index];
                return _AnimatedMenuItemEntry(
                  key: ValueKey(item.id),
                  index: index,
                  child: MenuItemCard(
                    item: item,
                    onAddToCart: () => _handleAddToCart(context, item),
                  ),
                );
              },
              childCount: filteredItems.length,
            ),
          ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 16)),
        ],
      ],
    );
  }

  List<String> get _categories => [
        'All Items',
        ...{for (final item in widget.items) item.category},
      ];

  List<MenuItem> get _filteredItems {
    var items = widget.items;
    if (_selectedCategory != 'All Items') {
      items = items
          .where((item) => item.category == _selectedCategory)
          .toList();
    }
    if (widget.searchQuery.isNotEmpty) {
      final query = widget.searchQuery.toLowerCase();
      items = items
          .where((item) => item.name.toLowerCase().contains(query))
          .toList();
    }
    return items;
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
                memCacheWidth: 600,
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

class _AnimatedMenuItemEntry extends StatefulWidget {
  final int index;
  final Widget child;

  const _AnimatedMenuItemEntry({
    super.key,
    required this.index,
    required this.child,
  });

  @override
  State<_AnimatedMenuItemEntry> createState() => _AnimatedMenuItemEntryState();
}

class _AnimatedMenuItemEntryState extends State<_AnimatedMenuItemEntry>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    final delay = (widget.index * 0.06).clamp(0.0, 0.4);
    final curved = CurvedAnimation(
      parent: _controller,
      curve: Interval(delay, 1.0, curve: Curves.easeOut),
    );
    _opacity = Tween<double>(begin: 0, end: 1).animate(curved);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(curved);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slide,
      child: FadeTransition(
        opacity: _opacity,
        child: widget.child,
      ),
    );
  }
}
