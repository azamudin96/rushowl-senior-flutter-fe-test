# Ensuring Flutter Performance on Low-End Devices

Most Flutter apps are tested on flagship phones. But globally, the majority of Android devices are budget hardware — 2 GB RAM, slow CPUs, and entry-level GPUs. Over the past few years I've shipped Flutter apps targeting devices like the Samsung Galaxy A03 and Redmi 9A. These phones make performance problems impossible to ignore.

## Rendering & UI

Flutter targets 60 FPS, which means each frame has a budget of roughly 16 ms. If layout, build, or rasterisation exceeds that window, the frame is dropped and users perceive jank.

The first thing I check is unnecessary rebuilds. I've worked on screens where a single `setState` at the root was forcing the entire page to reconcile — moving to scoped Cubits and adding `const` constructors cut the rebuild count significantly. `RepaintBoundary` helps when the raster thread is spiking, isolating repaints to the subtree that actually changed.

For lists, `ListView.builder` with `itemExtent` lazily builds only the visible portion — critical on low-end devices to avoid inflating hundreds of offscreen widgets. `Opacity` can trigger a `saveLayer`, creating an offscreen buffer expensive on budget GPUs; I swap widgets in and out of the tree instead. Widgets like `IntrinsicHeight` force multiple layout passes that blow past the 16 ms budget — simpler structures like `SizedBox` with fixed heights eliminate those frame drops.

Flutter now ships with the Impeller rendering engine, reducing shader compilation jank. But UI-thread bottlenecks like layout and rebuilds still remain the main constraints on low-end hardware.

## Memory Management

Android's low-memory killer is aggressive on 2 GB devices. The biggest culprit is images — a single 4000×3000 photo decoded in RGBA takes around 46 MB. Passing `cacheWidth`/`cacheHeight` to decode at display size, combined with `cached_network_image`, cuts memory dramatically. I also tune Flutter's image cache:

```dart
PaintingBinding.instance.imageCache.maximumSize = 50;
PaintingBinding.instance.imageCache.maximumSizeBytes = 50 << 20; // 50 MB
```

Lazy loading complements this — only fetching and decoding resources when they're about to enter the viewport. Disposing controllers (`AnimationController`, `ScrollController`, etc.) is equally important; if the DevTools Memory tab shows a heap chart that keeps climbing, something isn't being cleaned up.

## Network & Data

Budget phones often come with unreliable connectivity. I always paginate API calls — cursor-based pagination with 20 items per page prevents the screen from hanging on slower connections.

HTTP `ETag` headers prevent re-downloading unchanged data, and Hive works well for offline caching. I enable gzip compression where possible, reducing payload sizes on slow networks. For images, I serve thumbnails in list views and load full resolution only on detail screens.

Large JSON responses can block the UI thread. I move heavy parsing to a separate isolate:

```dart
final parsed = await Isolate.run(() => parseLargeJson(data));
```

This keeps the UI thread free during CPU-heavy work.

## Build & Compilation

Debug builds use JIT with assertion checks — significantly slower than release. I always profile with `--profile` on a real device. Release builds compile to native ARM via AOT, which is a completely different performance profile.

Dart's tree-shaking automatically strips unreachable code in release mode, but it only works when you avoid reflection and dynamic lookups — keeping imports explicit ensures dead code is actually eliminated. For larger apps, deferred components (`deferred as`) split features into separate download units so the initial binary stays small and loads fast on constrained storage. `--split-debug-info` and `--obfuscate` further reduce APK size.

I also audit `pubspec.yaml` regularly — unused plugins add startup overhead from platform channel initialisation.

## Profiling & Tooling

Profile on real hardware — emulators skip GPU bottlenecks, thermal throttling, and memory pressure. I keep a cheap Redmi in my drawer specifically for this.

The Performance Overlay (`WidgetsApp.showPerformanceOverlay`) gives a quick on-device read: if the raster bar (bottom) is red, the problem is painting or GPU work; if the UI bar (top) is red, it's layout or rebuilds. In DevTools, I look for timeline spikes above 16 ms and use memory snapshots to track allocations and detect leaks. For CI, `integration_test` with `traceAction()` captures frame timings automatically.

First-time shader compilation can stutter on weak GPUs. Shader warm-up via `--trace-skia` and `--bundle-sksl-path` captures SkSL shaders during a test run and bundles them into the release binary, so they're pre-compiled at launch rather than stuttering on first use.

## Final Thoughts

If your app feels smooth on the weakest device your users own, it will feel exceptional everywhere else. Performance work done for low-end hardware rarely goes to waste.

---

*See [diagrams.md](diagrams.md) for supporting diagrams and data.*
