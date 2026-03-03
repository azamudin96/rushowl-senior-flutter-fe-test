# Q5 — AI-Generated Voucher App

## Approach

I used **Claude** (Anthropic's AI assistant via Claude Code CLI) to scaffold and iteratively refine a Flutter voucher-selection and QR-code payment app.

### Process

1. **Single comprehensive prompt** — I described the full functional spec (voucher denominations, quantities, selection behaviour, pay flow, QR content format, and total display) in one detailed prompt.
2. **Architecture decision** — I asked for clean architecture (domain / data / presentation layers) with `flutter_bloc` for state management and `get_it` for dependency injection, reflecting production-level patterns.
3. **Iterative refinement** — After reviewing the initial output I iterated on:
   - Visual polish (dark theme, animated selection states, QR glow effect)
   - A 5-minute countdown timer on the QR screen for realism
   - Payment summary card showing individual voucher line items
4. **Manual verification** — Ran `flutter analyze` (zero issues) and manually tested voucher selection combinations to confirm QR content correctness.

### Architecture Overview

```
lib/
├── main.dart                          # Entry point
├── app.dart                           # MaterialApp configuration
├── core/
│   ├── constants/app_constants.dart    # App-wide constants
│   └── theme/app_theme.dart           # Dark theme + colour palette
├── di/injection.dart                  # GetIt service locator setup
└── features/voucher/
    ├── domain/
    │   ├── entities/voucher_instance.dart
    │   ├── repositories/voucher_repository.dart
    │   └── usecases/
    │       ├── get_vouchers.dart
    │       └── generate_qr_content.dart
    ├── data/
    │   ├── datasources/voucher_local_datasource.dart
    │   └── repositories/voucher_repository_impl.dart
    └── presentation/
        ├── cubit/
        │   ├── voucher_cubit.dart
        │   └── voucher_state.dart
        ├── screens/
        │   ├── voucher_list_screen.dart
        │   └── qr_code_screen.dart
        └── widgets/
            ├── voucher_card.dart
            └── pay_button.dart
```

### Key Libraries

| Package | Purpose |
|---------|---------|
| `flutter_bloc` | State management via Cubit |
| `qr_flutter` | QR code rendering |
| `equatable` | Value equality for state/entities |
| `get_it` | Dependency injection |
| `google_fonts` | Poppins font family |

### How to Run

```bash
cd Q5/source/voucher_app
flutter pub get
flutter run            # or: flutter run -d chrome
```

### QR Code Content Format

When vouchers are selected, the QR code encodes a **comma-separated list of the selected voucher amounts**, sorted ascending. For example, selecting 2x $2 and 1x $10 produces the QR string `2,2,10`, and the screen displays a total of `$14.00`.
