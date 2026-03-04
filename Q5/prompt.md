# Q5 — Prompts Used

**Tool:** Claude (Anthropic) via Claude Code CLI

---

## Prompt 1 — Initial Scaffold

> Generate a Flutter app (targeting web, iOS, and Android) for a voucher selection and QR code payment flow. Use clean architecture with domain, data, and presentation layers. Use `flutter_bloc` (Cubit) for state management and `get_it` for dependency injection.
>
> Requirements:
> - No authentication — the app opens directly to the voucher list screen.
> - Display the following vouchers in a 2-column grid:
>   - $2 voucher — quantity 2
>   - $5 voucher — quantity 2
>   - $10 voucher — quantity 2
> - Each voucher instance is individually selectable (tap to toggle).
> - Show a sticky "Pay Now" button at the bottom. It should display the total amount and the count of selected vouchers. Disable it when nothing is selected.
> - On tapping Pay, navigate to a QR code screen that shows:
>   - A QR code whose data is a plain-text comma-separated string of the selected voucher amounts, sorted ascending. Example: selecting 2x $2 and 1x $10 → QR content is `2,2,10`.
>   - The total amount displayed as text (e.g. `$14.00`).
> - Use a dark theme with a yellow accent colour.
> - Use `qr_flutter` for QR code rendering and `equatable` for entity equality.

---

## Prompt 2 — Visual Refinement

> Improve the QR code screen:
> - Add a glowing box-shadow behind the QR code container.
> - Show an "AWAITING TRANSACTION" status badge below the QR code.
> - Add a Payment Summary card that lists each selected voucher with its name, display number, and individual amount, plus a total row.
> - Add a 5-minute countdown timer that auto-dismisses the screen when it expires. Show the timer text in red when under 60 seconds.
> - Add a "Cancel Payment" button at the bottom.

---

## Prompt 3 — Voucher Card Polish

> Refine the voucher card widget:
> - Use different Material icons per denomination ($2 → confirmation_number, $5 → local_activity, $10 → redeem).
> - Show a primary-coloured (yellow) checkmark circle overlay when selected.
> - Animate the border colour and background on selection with a 200 ms duration.
> - Display the voucher display number (e.g. "Voucher 8812") below the amount.

---

## Prompt 4 — Performance Optimisation (Q1/Q2 learnings applied)

> Apply the performance patterns I developed in Q1 (list rendering) and Q2 (low-end device essay) to this app:
>
> **From Q1 — List Rendering Optimisation:**
> - Wrap each `VoucherCard` in `RepaintBoundary` so that selection animation on one card does not repaint the entire grid.
>
> **From Q2 — Low-End Device Performance:**
> - The QR code screen uses a `BlocBuilder` that rebuilds the entire widget tree (QR code, payment summary, header) every second when the countdown timer ticks. Extract the countdown text into a separate `_CountdownText` widget using `BlocSelector` that selects only `remainingSeconds`. Add `buildWhen` to the main `BlocBuilder` to skip timer-only state changes. This way the heavy QR code and payment summary widgets are not rebuilt every second.
