# Q4 — AI Prompts Used

## Tool: Claude (Anthropic)

### Prompt 1 — Full App Scaffold

> Generate a complete Flutter Food Delivery app using clean architecture with the following structure:
>
> **Architecture:**
> - Clean architecture: `lib/features/food_delivery/domain|data|presentation`
> - State management: flutter_bloc (Cubit pattern) with equatable
> - Dependency injection: get_it
> - All state is immutable, updated via copyWith
> - Repository methods return `Future` (datasource uses `Future.delayed(300ms)` to simulate I/O)
>
> **Domain Entities:**
> - `Restaurant`: id, name, imageUrl, rating (double), cuisineType (String), deliveryTimeMinutes (int), deliveryFee (double). Extends Equatable.
> - `MenuItem`: id, name, imageUrl, price (double), description, restaurantId. Extends Equatable.
> - `CartItem`: menuItem (MenuItem), quantity (int). Has `double get subtotal => menuItem.price * quantity`. Extends Equatable with copyWith.
> - `OrderStatus` enum: confirmed, preparing, onTheWay, delivered — each with displayName (String) and icon (IconData) getters.
> - `Order`: id, items (List\<CartItem\>), restaurant (Restaurant), subtotal, deliveryFee, estimatedDelivery (DateTime), status (OrderStatus). Has `double get total => subtotal + deliveryFee`. Extends Equatable with copyWith.
>
> **Cubits & States:**
> - `RestaurantListCubit` (factory) — states: initial, loading, loaded(List\<Restaurant\>), error(String). Method: `loadRestaurants()`.
> - `MenuCubit` (factory) — states: initial, loading, loaded(Restaurant, List\<MenuItem\>), error(String). Method: `loadMenu(Restaurant)`.
> - `CartCubit` (**lazySingleton** — persists across navigation, not auto-disposed by BlocProvider) — `CartState` is a single class with: items (List\<CartItem\>), restaurant (Restaurant?). Computed getters: subtotal, deliveryFee, total, itemCount, isEmpty. Methods: `addItem(MenuItem, Restaurant)`, `removeItem(String menuItemId)`, `updateQuantity(String menuItemId, int qty)`, `clearCart()`.
> - `OrderCubit` (factory) — states: initial, placing, tracking(Order), error(String). Method: `placeOrder(List\<CartItem\>, Restaurant)`. Uses Timer.periodic to advance OrderStatus every 5 seconds. Timer stops on delivered. Timer cancelled in `close()` override. Previous timer cancelled before new order.
>
> **Multi-restaurant cart rule:** If cart has items from restaurant A and user adds from restaurant B, show AlertDialog asking to clear cart. If cart is empty, set restaurant on first add.
>
> **Mock Data (local datasource):**
> - 6 restaurants: Pizza Palace (Italian, 4.8★), Dragon Wok (Chinese, 4.6★), Taco Heaven (Mexican, 4.7★), Sushi Master (Japanese, 4.9★), Burger Joint (American, 4.5★), Spice Route (Indian, 4.7★)
> - 5 menu items per restaurant with realistic names, descriptions, prices ($8–$25)
> - Images: `https://picsum.photos/seed/{item-name}/400/300` (seed-based for consistency)
>
> **4 Screens:**
> 1. **RestaurantListScreen** — AppBar with title "Food Delivery" + CartBadge icon. Body: ListView.builder of RestaurantCard widgets. Tap card → navigate to FoodMenuScreen.
> 2. **FoodMenuScreen** — AppBar with restaurant name + back + CartBadge. Header: restaurant image, rating stars, cuisine, delivery time/fee. Body: ListView.builder of MenuItemCard widgets with "Add to Cart" button.
> 3. **CheckoutScreen** — AppBar with "Checkout" + back. Body: restaurant info card, list of CartItemTile widgets with +/- quantity controls (qty 0 removes item), divider, subtotal/delivery fee/total rows. Bottom: "Place Order" button (disabled if cart empty). Empty state when no items.
> 4. **OrderTrackingScreen** — AppBar with "Order Tracking" + close button (pops to root). Body: order ID, restaurant name, OrderStatusStepper (4 vertical stages with icons — completed stages in primary color, current pulsing, upcoming grey), estimated delivery time, order summary list. Closes and clears cart when user dismisses.
>
> **CartBadge widget:** Uses `BlocSelector<CartCubit, CartState, int>` to rebuild only on itemCount change (not full cart state). Shows circular badge with count, hidden when 0. Tapping navigates to CheckoutScreen.
>
> **Theme:**
> - Material 3, dark mode only, `useMaterial3: true`
> - Primary: #FF6B35 (warm orange)
> - Background: #1A1A1A, Surface: #2A2A2A, Border: #3D3D3D
> - Font: Google Fonts Poppins
> - AppBar: transparent, no elevation, centered title
>
> **Dependencies:** flutter_bloc ^9.0.0, equatable ^2.0.7, get_it ^8.0.3, google_fonts ^8.0.2, cached_network_image ^3.4.1, intl ^0.19.0
>
> **Navigation:** Imperative Navigator.push. CartCubit shared via `BlocProvider.value(value: getIt<CartCubit>())`. Factory cubits provided via `BlocProvider(create: (_) => getIt<XCubit>()..loadX())`.
>
> Use const constructors everywhere possible. All lists use ListView.builder. Format currency with intl NumberFormat.currency().

### Prompt 2 — Visual Polish

> Refine the UI of the Food Delivery app:
>
> - **RestaurantCard**: Rounded corners (12px), subtle elevation, restaurant image as background with gradient overlay for text readability. Show rating with star icon, cuisine tag chip, delivery time and fee in row.
> - **MenuItemCard**: Horizontal layout — image (80x80 rounded) on left, name/description/price on right, "Add to Cart" filled button at bottom-right. Show description max 2 lines with ellipsis.
> - **CheckoutScreen**: Card-based sections — restaurant info card at top, scrollable items list in middle, sticky price breakdown card at bottom above Place Order button.
> - **OrderStatusStepper**: Vertical timeline with connecting line. Each stage: circle icon + label + optional subtitle. Completed = primary color + checkmark. Current = primary color + pulsing animation (AnimatedContainer). Upcoming = grey.
> - Consistent 16px horizontal padding, 12px vertical spacing between cards.
> - Loading states: centered CircularProgressIndicator with primary color.
> - Error states: centered icon + message + "Retry" button.
> - Snackbar confirmation when item added to cart: "Added [item name] to cart".
