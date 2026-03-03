# Q1 — Flutter List Rendering Optimisation

This directory contains two Flutter projects demonstrating the performance difference between a **naive** and an **optimised** approach to rendering a vertically scrollable list of 1,000 network images.

Both projects load images from `https://picsum.photos/seed/{index}/600/400` with identical tile dimensions (height: 200, BoxFit.cover) for a fair comparison.

## Problems with the Naive Approach

The naive implementation (`naive/`) uses `SingleChildScrollView` with a `Column` containing all 1,000 image widgets. This forces Flutter to build, lay out, and keep in memory every single widget on the very first frame — even though only ~5 are visible at a time. The result is a massive initial build time and a large memory footprint that climbs as images decode.

Raw `Image.network()` provides no caching. When a user scrolls down and then back up, previously loaded images are re-downloaded and re-decoded from scratch, wasting bandwidth and CPU. There are no placeholders or error widgets, so users see blank space that suddenly pops in — a poor loading experience. No `const` constructors are used anywhere, so every rebuild creates fresh widget instances that the framework cannot short-circuit — compounding the cost of already building 1,000 widgets eagerly.

Note: the naive version deliberately keeps the same fixed tile height (200) and `BoxFit.cover` as the optimised version for a fair apples-to-apples comparison. In a truly unconstrained naive implementation, removing fixed dimensions would add layout thrash on top of everything else.

## Techniques Applied in the Optimised Version

The optimised implementation (`optimised/`) applies several targeted fixes:

- **`ListView.builder` with `itemExtent: 200`** — Only builds widgets currently in or near the viewport (~5–7 at a time). The fixed `itemExtent` lets the framework skip per-item layout measurement entirely, making scrolling calculations O(1).
- **`addAutomaticKeepAlives: false`** — Prevents the list from retaining off-screen widget state. In this scenario (1,000 images with `cached_network_image` handling caching), we don't need the framework to keep disposed tiles alive — the image cache already handles re-display efficiently. This reduces memory retention during long scrolls.
- **`addRepaintBoundaries: false`** — Disabled because each `ImageTile` already wraps itself in a `RepaintBoundary`. Keeping the list's default would double-wrap every tile, adding unnecessary layer overhead. Choose one or the other — not both.
- **`cacheExtent: 1200`** — Prefetches ~6 extra tiles (at 200px each) beyond the visible viewport. This reduces blank tiles during fast scrolling by giving images a head start on loading before they enter view.
- **`cached_network_image` package** — Caches decoded images in memory (and on disk where the platform supports it). Scrolling back to a previously viewed image is instant — no re-download or re-decode.
- **`memCacheWidth` / `memCacheHeight` computed from `MediaQuery`** — Decodes images at the actual display pixel size (`logicalWidth × devicePixelRatio`), not the source resolution. This avoids wasting memory on pixels that will be downscaled by the GPU anyway. Hardcoding source dimensions (e.g. 600×400) misses this optimisation entirely.
- **`RepaintBoundary`** — Wraps each tile so that fade-in transitions only repaint their own tile, not the entire list.
- **Static `ColoredBox` placeholder** — Avoids the cost of per-tile `CircularProgressIndicator` animations. With ~5–7 tiles loading simultaneously, animated spinners cause continuous repaints on every frame. A static grey box is virtually free.
- **`const` constructors** — Used wherever possible to allow Flutter's widget reconciliation to short-circuit rebuilds.

## Expected Behaviour Comparison

| Metric | Naive | Optimised |
|---|---|---|
| Initial build | Slow — builds 1,000 widgets | Fast — builds ~5 visible widgets |
| Memory | Climbs rapidly, frequent GC | Stable, bounded by cache limits |
| Scroll performance | Jank, frame drops | Smooth 60 fps |
| Re-visit images | Re-downloads from network | Served from memory cache |
| Loading UX | Blank space, sudden pop-in | Static placeholder, smooth fade-in |

## What to Measure in DevTools

- **Frame chart** — Look for UI and GPU jank spikes. The naive version will show frequent spikes above the 16 ms budget; the optimised version should stay consistently below it.
- **Raster thread** — Monitor spike frequency during fast scrolling. High frequency in naive, rare in optimised.
- **Memory tab** — Compare heap growth patterns. Naive shows a steadily climbing sawtooth (allocate → GC → allocate); optimised shows a flat plateau once the visible cache is warm.

## Running

```bash
# Naive
cd naive && flutter run

# Optimised
cd optimised && flutter run
```

Open DevTools (press `d` in the terminal) to compare performance profiles side by side.
