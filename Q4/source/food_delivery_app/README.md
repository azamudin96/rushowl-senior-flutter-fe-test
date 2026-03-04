# RushTrail Eats

A Flutter food delivery app built with clean architecture, flutter_bloc (Cubit), and get_it.

## Getting Started

```bash
flutter pub get
flutter run
```

## Architecture

```
lib/
├── main.dart
├── app.dart
├── core/
│   ├── constants/app_constants.dart
│   └── theme/app_theme.dart
├── di/injection.dart
└── features/food_delivery/
    ├── domain/
    │   ├── entities/
    │   ├── repositories/
    │   └── usecases/
    ├── data/
    │   ├── datasources/
    │   └── repositories/
    └── presentation/
        ├── cubit/
        ├── screens/
        └── widgets/
```

## Screens

1. **Restaurant List** — Browse 6 restaurants with ratings and delivery info
2. **Food Menu** — Hero image, category filters, menu items with "Add to Cart"
3. **Checkout** — Cart items with quantity controls, price breakdown
4. **Order Tracking** — Auto-advancing status stepper

## Generating App Icons

```bash
dart run flutter_launcher_icons
```
