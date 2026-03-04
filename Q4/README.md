# Q4 — AI-Generated Food Delivery App

## Approach

This app was generated using Claude (Anthropic) with five iterative prompts. The first prompt established the complete app scaffold with clean architecture, all entities, state management, screens, and mock data. The second prompt refined visual polish and UI interactions. The third applied performance optimisations from Q1/Q2. The fourth rebranded the app to "RushTrail Eats" with a custom app icon. The fifth replaced placeholder images with food-matched Unsplash photos.

### Architecture

- **Clean Architecture**: `domain/` → `data/` → `presentation/` separation within a `features/food_delivery/` feature module
- **State Management**: flutter_bloc (Cubit pattern) with sealed class states for exhaustive pattern matching
- **Dependency Injection**: get_it — singletons for datasources/repositories, factory for screen-scoped cubits, lazySingleton for CartCubit (persists across navigation)
- **Immutable State**: All states use Equatable; mutations via copyWith only

### Key Design Decisions

1. **CartCubit as lazySingleton** — Cart state must survive navigation pushes/pops. Registered as lazySingleton in GetIt and provided via `BlocProvider.value` (not auto-disposed).

2. **Multi-restaurant cart guard** — When adding an item from a different restaurant, an AlertDialog confirms clearing the existing cart before switching.

3. **OrderCubit Timer lifecycle** — `Timer.periodic` advances order status every 5 seconds. Timer is cancelled both on delivery completion and in the cubit's `close()` override to prevent memory leaks.

4. **Sealed class states** — Using Dart 3 sealed classes enables exhaustive `switch` in BlocBuilder, ensuring every state (initial, loading, loaded, error) is handled.

5. **BlocSelector for CartBadge** — Rebuilds only when `itemCount` changes, not on every cart state mutation (e.g., quantity changes don't cause unnecessary AppBar rebuilds).

### Branding

- **App name:** RushTrail Eats (shared RushTrail brand identity with Q5)
- **App icon:** Custom RushTrail owl logo (black background, gold owl + text), generated via `flutter_launcher_icons` for both Android (adaptive) and iOS
- **Theme:** Black + gold (#FFB800) dark theme with Poppins font

### Food Images

All menu item images are real food photos sourced from:
- **Foodish API** — burgers, pizza, pasta, biryani, dessert
- **TheMealDB** — specific dishes (Pad Thai, Kung Pao Chicken, etc.)
- **Unsplash** — 29 remaining items matched by dish name (garlic bread, bruschetta, miso soup, matcha latte, etc.)

### Screens

| Screen | Description |
|---|---|
| Restaurant List | Browse 6 restaurants with image cards, ratings, delivery info |
| Food Menu | Hero image with overlapping info card, category filter chips, scrollable menu items with "Add to Cart" |
| Checkout | Cart items with +/- quantity, price breakdown, "Place Order" |
| Order Tracking | Auto-advancing status stepper (confirmed → preparing → on the way → delivered) |

### Dependencies

| Package | Purpose |
|---|---|
| flutter_bloc ^9.0.0 | State management (Cubit pattern) |
| equatable ^2.0.7 | Value equality for entities and states |
| get_it ^8.0.3 | Service locator / dependency injection |
| google_fonts ^8.0.2 | Poppins font family |
| cached_network_image ^3.4.1 | Image loading with caching and placeholders |
| intl ^0.19.0 | Currency formatting |
| flutter_launcher_icons ^0.14.3 | App icon generation (dev dependency) |

### Running

```bash
cd Q4/source/food_delivery_app
flutter pub get
flutter run
```

### Performance Optimisations (from Q1 & Q2)

These patterns were developed during Q1 (list rendering optimisation) and Q2 (low-end device essay), then applied here:

| Technique | Source | Where Applied |
|---|---|---|
| `RepaintBoundary` on list tiles | Q1 | `RestaurantCard`, `MenuItemCard`, `CartItemTile` |
| `cacheExtent: 500` on scroll views | Q1 | `RestaurantListScreen` ListView, `FoodMenuScreen` CustomScrollView |
| `memCacheWidth`/`memCacheHeight` on images | Q1 + Q2 | All `CachedNetworkImage` widgets (400×180, 90×90, 70×70, hero: width-only 600) |
| Global image cache cap (50 entries / 50 MB) | Q2 | `main.dart` |
| Replace `IntrinsicHeight` with fixed `SizedBox` | Q2 | `OrderStatusStepper` (avoids expensive multi-pass layout) |

### What I Would Improve

- Add unit tests for cubits (especially CartCubit's multi-restaurant logic and OrderCubit's timer)
- Add integration tests for the full checkout flow
- Replace mock `Future.delayed` with a proper repository pattern backed by a local database
- Add pull-to-refresh on restaurant list
- Add search/filter functionality
- Animated transitions between screens
