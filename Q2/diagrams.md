# Supporting Diagrams & Data

## 1. Widget Rebuild Scope

How scoped state management reduces unnecessary rebuilds:

```
setState at root (BAD)              Scoped Cubit (GOOD)
─────────────────────               ─────────────────────
  Scaffold  [REBUILD]                 Scaffold
  ├─ AppBar [REBUILD]                 ├─ AppBar
  ├─ Body   [REBUILD]                 ├─ Body
  │  ├─ Header [REBUILD]              │  ├─ Header
  │  ├─ List   [REBUILD]              │  ├─ BlocBuilder ← only this rebuilds
  │  │  ├─ Item [REBUILD]             │  │  ├─ Item [REBUILD]
  │  │  ├─ Item [REBUILD]             │  │  ├─ Item [REBUILD]
  │  │  └─ Item [REBUILD]             │  │  └─ Item [REBUILD]
  │  └─ Footer [REBUILD]              │  └─ Footer
  └─ BottomNav [REBUILD]              └─ BottomNav

  12 widgets rebuilt                   4 widgets rebuilt
```

## 2. Image Memory by Decode Resolution

Memory consumed by a single RGBA image at different decode sizes:

| Source Resolution | Decoded At | Memory (RGBA) | Savings |
|---|---|---|---|
| 4000 x 3000 | Full (no cacheWidth) | **45.8 MB** | — |
| 4000 x 3000 | 800 x 600 | **1.8 MB** | 96% |
| 4000 x 3000 | 400 x 300 | **0.46 MB** | 99% |
| 4000 x 3000 | 200 x 150 | **0.11 MB** | 99.7% |

Formula: `width x height x 4 bytes (RGBA)`

On a 2GB device with ~400MB available to your app, a single full-resolution decode eats 11% of your memory budget. Ten images and you're in low-memory killer territory.

```dart
// Fix: decode at display size
Image.network(
  url,
  cacheWidth: 400,   // match display width in logical pixels
  cacheHeight: 300,
);
```

## 3. Frame Budget Breakdown (60 FPS)

Each frame must complete within 16.67ms to avoid jank:

```
0ms          4ms          8ms         12ms        16.67ms
├────────────┼────────────┼────────────┼────────────┤
│   Build    │   Layout   │   Paint    │  Composite │
│  (widget   │  (RenderObj│ (raster    │  (GPU      │
│   tree)    │   sizing)  │  commands) │   upload)  │
├────────────┴────────────┴────────────┴────────────┤
│              SMOOTH FRAME (< 16.67ms)             │
└───────────────────────────────────────────────────┘

├──────────────────────────────────────────────┼─────┤ JANK!
│              Frame exceeds budget            │LATE │
│  (user sees stutter / dropped frame)         │     │
└──────────────────────────────────────────────┴─────┘
```

**Common causes by phase:**

| Phase | Bottleneck | Fix |
|---|---|---|
| Build | Unnecessary rebuilds, deep widget trees | const constructors, scoped state |
| Layout | IntrinsicHeight, multiple passes | Fixed dimensions, simpler structures |
| Paint | Large images, Opacity/saveLayer | cacheWidth, widget swap instead of Opacity |
| Composite | Shader compilation (first run) | SkSL warmup, Impeller |

## 4. Performance Overlay Interpretation

The Performance Overlay shows two real-time graphs directly on-device:

```
┌───────────────────────────────┐
│  UI thread  ▁▂▁▃▁▁▂▁  (top)  │  ← Build + Layout
│  Raster     ▁▁▂▁▁▁▁▁  (bot)  │  ← Paint + Composite (GPU)
└───────────────────────────────┘
        GREEN = within 16ms budget
        RED   = exceeding budget (jank)
```

| Bar | Red Means | Likely Cause | Fix |
|---|---|---|---|
| UI (top) | Build or layout too slow | Deep widget trees, unnecessary rebuilds | Scoped state, const constructors |
| Raster (bottom) | Paint or GPU too slow | Large images, saveLayer, shader compile | cacheWidth, RepaintBoundary, SkSL warmup |
| Both | Frame completely blown | Multiple issues compounding | Profile each phase in DevTools |

Enable via `WidgetsApp.showPerformanceOverlay: true` or press `P` in the terminal during `flutter run --profile`.

## 5. Tree-Shaking & Deferred Loading

How Dart's tree-shaking and deferred components reduce binary size:

```
Full app bundle (no optimization)
┌──────────────────────────────────────────┐
│  Core   │  Feature A  │  Feature B  │ Dead│  12 MB
└──────────────────────────────────────────┘

After tree-shaking (release mode)
┌────────────────────────────────────┐
│  Core   │  Feature A  │  Feature B │         10 MB (-17%)
└────────────────────────────────────┘
  Dead code removed automatically

After deferred components
┌────────────────────┐  ┌───────────┐
│  Core  │ Feature A │  │ Feature B │          7 MB initial + 3 MB on demand
└────────────────────┘  └───────────┘
  Initial download        Loaded when needed
```

```dart
// Deferred loading example
import 'package:app/features/reports.dart' deferred as reports;

Future<void> openReports() async {
  await reports.loadLibrary();
  reports.showReportScreen();
}
```

**Impact on low-end devices:** Smaller initial binary means faster install, less storage used, and quicker cold start — critical on devices with 16–32 GB storage shared with the OS.

## 6. SkSL Shader Warm-Up Pipeline

How pre-compiled shaders eliminate first-run jank:

```
WITHOUT warm-up:
  App launch → first animation → shader compile (stutter!) → smooth after

WITH warm-up:
  Test run → capture SkSL → bundle into APK → App launch → smooth from start
```

Steps:

```bash
# 1. Run app and exercise all animations
flutter run --profile --cache-sksl --purge-persistent-cache

# 2. Press 'M' to export SkSL shaders to a file
#    → outputs flutter_01.sksl.json

# 3. Build release with bundled shaders
flutter build apk --bundle-sksl-path flutter_01.sksl.json
```

This is especially impactful on budget GPUs where shader compilation can add 50–200 ms per unique shader — enough to cause visible stutter on first scroll or first animation.
