# Q1 — Flutter List Rendering Optimisation

Two Flutter projects demonstrating the performance difference between a **naive** and an **optimised** approach to rendering a vertically scrollable list of 1,000 network images.

Both load images from `https://picsum.photos/seed/{index}/600/400` with identical tile dimensions (height: 200, BoxFit.cover) for a fair comparison.

## Problems with the Naive Approach

The naive implementation (`naive/`) uses `SingleChildScrollView` with a `Column` containing all 1,000 image widgets. Flutter builds, lays out, and retains every widget on the first frame — even though only ~5 are visible. This causes a massive initial build time and rapidly climbing memory.

Raw `Image.network()` provides no caching; scrolling back re-downloads and re-decodes images from scratch. There are no placeholders, so users see blank space that suddenly pops in. No `const` constructors are used, so every rebuild creates fresh widget instances the framework cannot short-circuit.

## Techniques Applied in the Optimised Version

The optimised implementation (`optimised/`) applies several targeted fixes:

- **`ListView.builder` with `itemExtent: 200`** — Builds only visible widgets (~5–7). Fixed `itemExtent` makes scroll calculations O(1).
- **`addAutomaticKeepAlives: false`** — Prevents retaining off-screen widget state; the image cache handles re-display.
- **`addRepaintBoundaries: false`** — Each `ImageTile` already wraps itself in a `RepaintBoundary`, so the list's default is disabled to avoid double-wrapping.
- **`cacheExtent: 1200`** — Prefetches ~6 extra tiles beyond the viewport, giving images a head start before entering view.
- **`cached_network_image`** — Memory and disk caching. Scrolling back is instant — no re-download.
- **`memCacheWidth` / `memCacheHeight` from `MediaQuery`** — Decodes at display pixel size (`logicalWidth × devicePixelRatio`), avoiding wasted memory on downscaled pixels.
- **`RepaintBoundary`** — Per-tile isolation so fade-in transitions repaint only their own tile.
- **Static `ColoredBox` placeholder** — Avoids per-tile `CircularProgressIndicator` animations that cause continuous repaints across ~5–7 loading tiles.
- **`const` constructors** — Allows Flutter's reconciliation to short-circuit rebuilds.

## Expected Behaviour

| Metric | Naive | Optimised |
|---|---|---|
| Initial build | Builds 1,000 widgets | Builds ~5 visible widgets |
| Memory | Climbs rapidly, frequent GC | Stable, bounded by cache |
| Scroll performance | Jank, frame drops | Smooth 60 fps |
| Re-visit images | Re-downloads from network | Served from memory cache |
| Loading UX | Blank pop-in | Placeholder, smooth fade-in |

## What to Measure in DevTools

- **Frame chart** — Naive shows frequent spikes above the 16ms budget; optimised stays below.
- **Raster thread** — High spike frequency in naive, rare in optimised.
- **Memory tab** — Naive shows a climbing sawtooth (allocate → GC → allocate); optimised shows a flat plateau once the cache is warm.

## Running

```bash
# Naive
cd naive && flutter run

# Optimised
cd optimised && flutter run
```

Open DevTools (press `d` in the terminal) to compare performance profiles.
