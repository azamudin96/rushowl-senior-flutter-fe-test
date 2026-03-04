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
