# Expected Profiling Data

Approximate measurements when running both projects on a mid-range device (e.g. Pixel 4a, `flutter run --profile`). Values will vary by hardware but the relative difference is consistent.

## 1. Frame Timing (DevTools Timeline)

```
Naive — fast scroll through 1,000 images
─────────────────────────────────────────────────
  16ms budget ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─
  ██                 ██ ██       ██ ██ ██
  ██  ██          ██ ██ ██    ██ ██ ██ ██ ██
  ██  ██  ██   ██ ██ ██ ██ ██ ██ ██ ██ ██ ██
  ██  ██  ██ █ ██ ██ ██ ██ ██ ██ ██ ██ ██ ██
  ───────────────────────────────────────────────
  Frequent spikes above 16ms. Many dropped frames.

Optimised — fast scroll through 1,000 images
─────────────────────────────────────────────────
  16ms budget ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─
  ▄  ▄  ▄  ▄  ▄  ▄  ▄  ▄  ▄  ▄  ▄  ▄  ▄  ▄  ▄
  ───────────────────────────────────────────────
  Consistently below 16ms. Smooth 60 fps.
```

## 2. Frame Build Times

| Metric | Naive | Optimised |
|---|---|---|
| First frame build | ~800–1200 ms | ~5–10 ms |
| Avg frame during scroll | ~25–40 ms | ~4–8 ms |
| Worst frame during scroll | ~80+ ms | ~12–15 ms |
| Dropped frames (30s scroll) | 40–60% | < 2% |

**Why the naive first frame is so slow:** `SingleChildScrollView` + `Column` forces Flutter to call `build()` on all 1,000 `Image.network` widgets, lay out the full column height (200,000 px), and begin decoding visible images — all in a single frame.

## 3. Memory Usage

```
Naive — heap over time (30s scroll session)
─────────────────────────────────────────────────
  400MB ┤                               ╭─────╮
        │                         ╭─────╯     │ GC
  300MB ┤                   ╭─────╯           ╰──╮
        │             ╭─────╯                    │
  200MB ┤       ╭─────╯                          ╰──
        │ ╭─────╯  ← each image: ~0.9 MB (full res)
  100MB ┤─╯
        │
    0MB ┤
        └────────────────────────────────────────────
         0s     5s     10s    15s    20s    25s    30s

Optimised — heap over time (30s scroll session)
─────────────────────────────────────────────────
  400MB ┤
        │
  300MB ┤
        │
  200MB ┤
        │
  100MB ┤
   60MB ┤──────────────────────────────────────────
        │  ← plateau: ~5-7 tiles × 0.1 MB + cache
    0MB ┤
        └────────────────────────────────────────────
         0s     5s     10s    15s    20s    25s    30s
```

| Metric | Naive | Optimised |
|---|---|---|
| Peak heap | 300–400 MB | ~60 MB |
| Image memory per tile | ~0.9 MB (600×400 full) | ~0.1 MB (display-sized) |
| GC frequency | Every 2–3 seconds | Rare after warm-up |
| Steady-state memory | Keeps climbing | Flat plateau |

## 4. Raster Thread

| Metric | Naive | Optimised |
|---|---|---|
| Raster frame avg | ~18–30 ms | ~3–6 ms |
| saveLayer calls | None, but full-list repaints | Isolated per-tile (RepaintBoundary) |
| Compositing cost | High — repaints entire Column | Low — only dirty tiles repaint |

**Key insight:** Without `RepaintBoundary`, a single image fade-in animation causes the entire `Column` of 1,000 widgets to repaint. With per-tile boundaries, only the animating tile repaints.

## 5. Performance Overlay Reading

```
Naive (--profile mode)                Optimised (--profile mode)
┌─────────────────────────┐           ┌─────────────────────────┐
│ UI:  ██████████████ RED  │           │ UI:  ███ GREEN          │
│ Rast:██████████ RED      │           │ Rast:██ GREEN           │
└─────────────────────────┘           └─────────────────────────┘
Both bars red = both threads           Both bars green = both
struggling during scroll.              threads within budget.
```

## How to Reproduce

```bash
# Run in profile mode for accurate measurements
cd naive && flutter run --profile
cd optimised && flutter run --profile

# In the terminal, press 'P' to toggle Performance Overlay
# Press 'd' to open DevTools for timeline and memory analysis
```
