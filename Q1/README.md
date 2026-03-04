# Q1 — Flutter List Rendering Optimisation

Two Flutter projects comparing a **naive** vs **optimised** approach to rendering a scrollable list of 1,000 network images. Both use identical tile dimensions (200px, BoxFit.cover) for fair comparison.

## Problems with the Naive Approach

The naive implementation (`naive/`) uses `SingleChildScrollView` with a `Column` containing all 1,000 image widgets. Flutter builds, lays out, and retains every widget on the first frame — even though only ~5 are visible. This causes a multi-second initial build and rapidly climbing memory that triggers frequent GC pauses.

Raw `Image.network()` provides no caching; scrolling back re-downloads and re-decodes from scratch. Each decoded image stays at full source resolution (600×400 RGBA ≈ 0.9 MB), so even a fraction of the list consumes hundreds of megabytes. In DevTools, expect both UI and raster threads to regularly exceed the 16ms budget — resulting in visible frame drops.

No placeholders means blank pop-in. No `const` constructors means every rebuild creates fresh instances the framework cannot short-circuit.

## Techniques Applied in the Optimised Version

The optimised implementation (`optimised/`) applies several targeted fixes:

- **`ListView.builder` with `itemExtent: 200`** — Builds only visible widgets (~5–7). Fixed `itemExtent` makes scroll calculations O(1).
- **`addAutomaticKeepAlives: false`** — Prevents retaining off-screen widget state; the image cache handles re-display.
- **`addRepaintBoundaries: false`** — Each `ImageTile` wraps itself in a `RepaintBoundary`, so the list default is disabled to avoid double-wrapping.
- **`cacheExtent: 1200`** — Prefetches ~6 extra tiles beyond the viewport, giving images a head start.
- **`cached_network_image`** — Memory and disk caching; scrolling back is instant.
- **`memCacheWidth` / `memCacheHeight` from `MediaQuery`** — Decodes at display pixel size, not source resolution. Drops memory from ~0.9 MB to ~0.1 MB per image.
- **`RepaintBoundary`** — Per-tile isolation so fade-in transitions repaint only their own tile, not the entire list.
- **Static `ColoredBox` placeholder** — Avoids per-tile animated spinners that cause continuous repaints across ~5–7 loading tiles.
- **`const` constructors** — Lets Flutter's reconciliation short-circuit rebuilds for unchanged widgets.

## Expected Behaviour

| Metric | Naive | Optimised |
|---|---|---|
| Initial build | ~1,000 widgets, slow | ~5 widgets, instant |
| Memory | Climbs rapidly, frequent GC | Stable plateau, cache-bounded |
| Scroll performance | Jank, frame drops | Smooth 60 fps |
| Image memory per tile | ~0.9 MB (full resolution) | ~0.1 MB (display resolution) |
| Re-visit images | Re-downloads from network | Served from cache |

## What to Measure in DevTools

- **Frame chart** — Naive shows frequent spikes above 16ms on both UI and raster threads; optimised stays below.
- **Memory tab** — Naive shows a climbing sawtooth (allocate → GC → allocate); optimised shows a flat plateau once warm.
- **Performance Overlay** — Real-time UI (top) and raster (bottom) frame bars directly on-device.

## Running

```bash
# Naive
cd naive && flutter run

# Optimised
cd optimised && flutter run
```

Open DevTools to compare profiles side by side.

---

*See [profiling.md](profiling.md) for expected frame timing, memory, and raster thread data.*
