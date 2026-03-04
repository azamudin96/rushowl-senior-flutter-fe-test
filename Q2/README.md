# Ensuring Flutter Performance on Low-End Devices

Most Flutter apps are tested on flagship phones. But globally, the majority of Android devices are budget hardware — 2GB RAM, slow CPUs, and entry-level GPUs. Over the past few years I've shipped Flutter apps targeting devices like the Samsung Galaxy A03 and Redmi 9A. These phones make performance problems impossible to ignore.

## Rendering & UI

Flutter targets 60 FPS, which means each frame has a budget of roughly 16ms (1000ms / 60). If layout, build, or rasterization exceeds that window, the frame is dropped and users perceive it as jank.

The first thing I check is unnecessary rebuilds. I've worked on screens where a single `setState` at the top was forcing the entire page to reconcile — moving to scoped Cubits and adding `const` constructors cut the rebuild count significantly. `RepaintBoundary` helps when the raster thread is spiking.

For lists, `ListView.builder` with `itemExtent` is the standard. Under the hood it uses Flutter's Sliver system, which lazily builds only the visible portion — critical on low-end devices to avoid building hundreds of offscreen widgets.

`Opacity` can trigger a `saveLayer` when compositing is required, creating an offscreen buffer that's expensive on budget GPUs. I swap widgets in and out of the tree or use colour blending instead. Widgets like `IntrinsicHeight` and `IntrinsicWidth` also deserve caution — they force multiple layout passes, which can blow past the 16ms budget. Simpler structures like `SizedBox` with fixed heights often eliminate frame drops entirely.

Flutter now ships with the Impeller rendering engine on many devices, reducing shader compilation jank and improving GPU predictability. But UI thread bottlenecks like layout and rebuilds still remain the main constraints.

## Memory Management

Android's low-memory killer is aggressive on 2GB devices. The biggest culprit is images — a single 4000×3000 photo decoded in RGBA takes around 46MB. I learned this the hard way when an app was crashing on budget Samsungs. Passing `cacheWidth`/`cacheHeight` to decode at display size, combined with `cached_network_image`, cut memory dramatically. I also tune Flutter's image cache for low-end devices:

```dart
PaintingBinding.instance.imageCache.maximumSize = 50;
PaintingBinding.instance.imageCache.maximumSizeBytes = 50 << 20; // 50MB
```

Disposing controllers (`AnimationController`, `ScrollController`, etc.) is equally important. If the DevTools Memory tab shows a heap chart that keeps climbing, something isn't being cleaned up.

## Network & Data

Budget phones often come with unreliable connectivity. I always paginate API calls — cursor-based pagination with 20 items per page prevents the screen from hanging on slower connections.

HTTP `ETag` headers prevent re-downloading unchanged data, and Hive works well for offline storage. I enable gzip compression where possible, reducing payload sizes on slow networks. For images, I serve thumbnails in list views and load full resolution only on detail screens.

Large JSON responses can also block the UI thread. I move heavy parsing to a separate isolate:

```dart
final parsed = await Isolate.run(() => parseLargeJson(data));
```

This keeps the UI thread free during CPU-heavy work.

## Build & Compilation

Debug builds use JIT with assertion checks — significantly slower than release. I always profile with `--profile` on a real device. Release builds compile to native ARM via AOT, which is a completely different performance profile.

`--split-debug-info` and `--obfuscate` reduce APK size, improving download and install time. Dart's tree-shaking removes unreachable code automatically in release mode, but it only works if you avoid reflection and dynamic lookups — keeping imports explicit ensures dead code is actually eliminated. For larger apps, deferred components (`deferred as`) let you split features into separate download units so the initial binary stays small and loads fast on constrained storage.

I also audit `pubspec.yaml` regularly — unused plugins add startup overhead from platform channel initialisation.

## Profiling & Tooling

Profile on real hardware — emulators skip GPU bottlenecks, thermal throttling, and memory pressure. I keep a cheap Redmi in my drawer specifically for this.

In DevTools, I look for timeline spikes above 16ms. The Performance Overlay (`WidgetsApp.showPerformanceOverlay`) gives a quick on-device read — if the raster bar (bottom) is red, the problem is painting or GPU; if the UI bar (top) is red, it's layout or rebuilds. For deeper analysis, DevTools memory snapshots help track allocations and detect leaks. For CI, `integration_test` with `traceAction()` captures frame timings automatically.

First-time shader compilation can also stutter on weak GPUs. Flutter's `--trace-skia` and `--bundle-sksl-path` flags let you capture and pre-compile shaders to prevent runtime jank.

## Final Thoughts

If your app feels smooth on the weakest device your users own, it will feel exceptional everywhere else. Performance work done for low-end hardware rarely goes to waste.

---

*See [diagrams.md](diagrams.md) for supporting diagrams and data.*
