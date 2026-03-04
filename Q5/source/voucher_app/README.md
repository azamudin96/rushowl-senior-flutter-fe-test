# RushTrail Voucher

A Flutter voucher selection and QR code payment app built with clean architecture, flutter_bloc (Cubit), and get_it.

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
└── features/voucher/
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

1. **Voucher List** — Select from $2, $5, and $10 vouchers in a 2-column grid
2. **QR Code** — Displays payment QR code with 5-minute countdown timer and payment summary
