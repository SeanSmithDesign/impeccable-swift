# Optimize

Identify and fix performance issues to create faster, smoother SwiftUI experiences. On Apple platforms, performance has three axes: how fast the app loads, how efficiently SwiftUI re-renders, and whether animations stay on the GPU. Address them in that order.

**CRITICAL**: Measure before optimizing. Instruments tells you where time actually goes. Profiling hunches without data is a week of refactoring the wrong thing.

## Assess Performance Issues

Understand current performance before writing any code.

**What's slow?**

- Initial launch?
- Scrolling a long list?
- Presenting a sheet or pushing a view?
- Animations stuttering at 60 fps?
- Async image loading visible to users?

**How bad is it?**

- Perceptible (users notice but tolerate)?
- Annoying (users complain)?
- Blocking (app is unusable)?

**Who's affected?**

- All devices or only A12-class and below?
- Only on first launch (cold start) or also warm?
- Only when data set is large?

## Loading Performance

### App Launch

The `@main` entry point and `WindowGroup` body run on the main thread before the first frame renders. Keep them empty.

```swift
@main
struct MyApp: App {
    // ✅ No heavy init here: just declare the scene
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    @State private var store: AppStore?

    var body: some View {
        Group {
            if let store {
                MainView(store: store)
            } else {
                LaunchPlaceholderView()
            }
        }
        .task {
            // ✅ Heavy init deferred to first view appearance
            store = await AppStore.load()
        }
    }
}
```

**Pre-warm launch:** `LaunchScreen.storyboard` (or `UILaunchScreen` in `Info.plist` on iOS 14+) lets the system display a static launch experience while your app initializes. Use it. An app that jumps from blank-black to content reads as slow regardless of actual time.

For iOS 26+ multi-scene apps, `UILaunchScreens` in `Info.plist` provides per-scene launch configuration.

**Never** do database migrations, network prefetches, or heavy JSON parsing before the first view renders.

### Async Image Loading

`AsyncImage` is the correct primitive for remote images in SwiftUI.

```swift
// ✅ Correct: placeholder + scaled rendering
AsyncImage(url: imageURL, scale: 2.0) { phase in
    switch phase {
    case .empty:
        // Show placeholder: same frame as the loaded image
        RoundedRectangle(cornerRadius: 8)
            .fill(.quaternary)
            .frame(width: 80, height: 80)

    case .success(let image):
        image
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: 80, height: 80)
            .clipShape(RoundedRectangle(cornerRadius: 8))

    case .failure:
        Image(systemName: "photo.badge.exclamationmark")
            .frame(width: 80, height: 80)

    @unknown default:
        EmptyView()
    }
}
```

**`scale:`** Pass `2.0` for @2x targets, `3.0` for @3x. Without it, SwiftUI assumes @1x and overallocates GPU memory for the decoded bitmap.

**Placeholder frame:** Give the placeholder exactly the same `.frame()` as the loaded image. If the frame changes on load, every row in a list reflows, causing visible layout shift and poor perceived performance.

### Task Cancellation

Use `.task { }` for view-bound async work. SwiftUI automatically cancels the task when the view disappears.

```swift
struct ProfileView: View {
    let userID: String
    @State private var user: User?

    var body: some View {
        UserCard(user: user)
            .task(id: userID) {
                // ✅ Re-runs if userID changes; cancelled on disappear
                user = try? await UserService.fetch(id: userID)
            }
    }
}
```

`task(id:)` re-triggers when the identity value changes, cancelling the prior task first. This is the correct pattern for detail views driven by selection state.

For URLSession outside of SwiftUI's task graph, cancel explicitly:

```swift
// Store the task reference; cancel in onDisappear or deinit
private var fetchTask: URLSessionDataTask?

fetchTask = URLSession.shared.dataTask(with: request) { data, _, error in
    // handle
}
fetchTask?.resume()
// ...
fetchTask?.cancel()
```

### Binary and Module Size

Smaller binaries launch faster on first install because the OS has less to link and page in.

- **Extract feature modules into Swift Packages.** Xcode only links modules that are actually imported. Loose files in the same target are always linked. Separate large, conditionally-used features (e.g., a video editor, an AR experience) into their own package targets.
- **Strip unused symbols.** In Xcode's Build Settings: `Dead Code Stripping = YES` (on by default for Release). `Symbols Hidden by Default = YES` for framework targets.
- **Asset catalog optimization.** Use the `Compress PNG Files` and `Remove PNG Text Chunks` Build Settings. Export artwork at 1x/2x/3x only; avoid redundant scales for assets only displayed at one density. Use vector PDFs for icons that scale cleanly; Xcode generates rasterizations at build time.
- **Audit third-party dependencies.** Each framework adds to both binary size and launch time (dynamic linking is paid per-framework at launch). Prefer Swift Package Manager over frameworks that ship pre-built binaries.

## Rendering Performance

### LazyVStack, LazyHStack, LazyVGrid

Plain `VStack` inside a `ScrollView` renders every child immediately, even those off-screen. For any `ForEach` of more than roughly 50 items, use a lazy container.

```swift
// ❌ Renders all 500 rows on first scroll appear
ScrollView {
    VStack {
        ForEach(items) { item in
            ItemRow(item: item)
        }
    }
}

// ✅ Renders only visible rows + a buffer
ScrollView {
    LazyVStack(spacing: 0) {
        ForEach(items) { item in
            ItemRow(item: item)
        }
    }
}
```

`LazyVGrid` and `LazyHStack` follow the same rule.

**Threshold:** 100+ rows in a plain `VStack` will cause visible frame drops on older devices. 50+ is enough to warrant `LazyVStack` as a precaution. There is no downside to lazy containers for large lists; the minor overhead of view lifecycle callbacks is irrelevant compared to the rendering cost of 500 simultaneous views.

### @State vs @Binding vs @ObservedObject Re-render Cost

SwiftUI re-renders a view whenever its observed state changes. The scope of that re-render depends on where state lives.

| Property wrapper     | Re-renders                                         | Best for                                      |
| -------------------- | -------------------------------------------------- | --------------------------------------------- |
| `@State`             | Only the view that owns it                         | Local, ephemeral UI state                     |
| `@Binding`           | The view that owns the `@State` + the child        | Shared leaf state                             |
| `@ObservedObject`    | The entire view subtree on any `@Published` change | Screen-level view models                      |
| `@StateObject`       | Same as `@ObservedObject`, but view owns lifecycle | Screen-level view models with stable identity |
| `@EnvironmentObject` | Any view in the tree that reads it                 | Global session state                          |

**Critical rule:** Do not put `@ObservedObject` in list rows.

```swift
// ❌ Every @Published change on any row's viewModel re-renders the row
// AND causes the parent list to diff all rows
struct ItemRow: View {
    @ObservedObject var viewModel: ItemViewModel
    // ...
}

// ✅ Pass value types into rows; keep @ObservedObject at the screen level
struct ItemRow: View {
    let item: Item
    // ...
}
```

When a row observes its own `ObservableObject`, a single property change on any model in the list triggers a re-render of every row that is visible. For a list of 50 visible rows, that is 50 view body calls per update. Use `@Observable` (Swift 5.9 / iOS 17+, macOS 14+) to get property-level observation granularity instead of whole-object diffs.

### View Update Gating

**`.equatable()`** Wraps a view in an `EquatableView` that skips body evaluation if the new value equals the old one. The view's type must conform to `Equatable`.

```swift
struct PriceTag: View, Equatable {
    let price: Decimal
    let currencyCode: String

    var body: some View { /* ... */ }
}

// Parent view
PriceTag(price: item.price, currencyCode: settings.currency)
    .equatable()
```

**`.id()`** Forces SwiftUI to destroy and recreate a view when the identity changes. Use it to reset a view's state completely (e.g., clearing a text field when the user navigates to a different item).

```swift
// Re-initializes DetailView with fresh @State when selectedID changes
DetailView(item: selectedItem)
    .id(selectedItem.id)
```

Do not use `.id()` to force updates: that is a re-render sledgehammer. Use `@Observable` or `@State` dependencies instead.

### Diagnosing Re-renders

During development, add this line at the top of a view's `body` property to print which state changed and caused the re-render:

```swift
var body: some View {
    let _ = Self._printChanges()
    // rest of body
}
```

This calls a SwiftUI-internal debugging hook. Remove it before shipping. It works in Xcode Previews and on-device. The output names the exact property that changed.

## Animation Performance

### GPU-Friendly vs. Layout-Changing Properties

SwiftUI animations that change only compositing properties run entirely on the GPU and do not require the CPU to recompute layout. Animations that change layout properties require the CPU to re-measure the view tree every frame: this is expensive.

**GPU-friendly (fast):**

- Opacity: `.opacity()`
- Scale: `.scaleEffect()`
- Offset: `.offset()`, `.position()`
- Rotation: `.rotationEffect()`, `.rotation3DEffect()`
- Blur: `.blur()`
- Color interpolation: `.foregroundStyle()` with animatable colors

**Layout-changing (expensive, avoid animating):**

- Frame: `.frame(width:height:)`
- Padding: `.padding()`
- Font size changes
- Any modifier that affects how the view's parent measures it

```swift
// ❌ Animates frame size: forces layout recalculation every frame
.frame(width: isExpanded ? 300 : 100)
.animation(.spring(), value: isExpanded)

// ✅ Animate scale instead: GPU only
.scaleEffect(isExpanded ? 3.0 : 1.0)
.animation(.spring(), value: isExpanded)
```

For the full layout-vs-paint model and the motion system, see [`motion-design.md`](motion-design.md). This doc does not restate those rules.

## Profiling with Instruments

Instruments is the performance source of truth. Run it on a real device; the Simulator does not represent GPU or memory behavior accurately.

### Instrument Templates

Open Xcode, then Product > Profile (Cmd+I) to launch Instruments against the current scheme.

| Instrument              | Use when                                                             |
| ----------------------- | -------------------------------------------------------------------- |
| **Time Profiler**       | CPU is pegged; find which functions consume the most wall-clock time |
| **Allocations**         | Memory grows over time; find what's being allocated and not freed    |
| **Core Animation**      | Animations are dropping frames; find paint/layout passes             |
| **Metal System Trace**  | GPU work is slow or hitching; find GPU-side bottlenecks              |
| **SwiftUI** (Xcode 15+) | View body calls are excessive; view update waterfall                 |
| **App Launch**          | Cold launch is slow; find what runs before first frame               |

The SwiftUI instrument is the most actionable for the problems in this document. It shows a waterfall of which views updated, when, and how long their `body` evaluation took.

### os_signpost for Custom Regions

Mark your own performance-sensitive regions so they appear as named intervals in Instruments' timeline.

```swift
import os

private let perfLog = OSLog(subsystem: "com.yourapp", category: .pointsOfInterest)

func loadFeed() async {
    let id = OSSignpostID(log: perfLog)
    os_signpost(.begin, log: perfLog, name: "Feed Load", signpostID: id)
    defer { os_signpost(.end, log: perfLog, name: "Feed Load", signpostID: id) }

    items = try? await FeedService.fetch()
}
```

`os_signpost` has near-zero overhead when Instruments is not attached. The `.pointsOfInterest` category surfaces intervals in the Time Profiler timeline automatically.

### Hangs

A hang is when the main thread is blocked for more than 250ms and the app stops responding to input.

**During development:** Enable the Thread Performance Checker in the scheme diagnostics (Product > Scheme > Edit Scheme > Run > Diagnostics). It flags main-thread violations at runtime.

**In production:** `MetricKit` delivers `MXHangDiagnostic` payloads to your `MXMetricManagerSubscriber`. These include call stacks from real user sessions.

```swift
import MetricKit

class MetricsHandler: NSObject, MXMetricManagerSubscriber {
    func didReceive(_ payloads: [MXMetricPayload]) {
        // Process standard metrics (launch time, memory, hang rate)
    }

    func didReceive(_ payloads: [MXDiagnosticPayload]) {
        for payload in payloads {
            if let hangs = payload.hangDiagnostics {
                // Log or upload hang call stacks
            }
        }
    }
}
```

Register the subscriber early in the app lifecycle:

```swift
MXMetricManager.shared.add(MetricsHandler())
```

**Xcode Organizer** (Window > Organizer > Hangs) shows aggregated hang rates from App Store users, ranked by frequency. Use this to prioritize which hangs to fix first.

## Detector Wiring

No automated detector currently checks for lazy-stack violations. The `tools/impeccable-lint/` CLI could add a `non-lazy-stack-with-foreach` SwiftSyntax rule that flags `VStack { ForEach(...) }` inside a `ScrollView` when the `ForEach` data collection type is a known large-cardinality type. Tracked for a future `impeccable-lint` release.

## NEVER

- Profile on the Simulator. GPU behavior, memory pressure, and launch timing are not representative of real hardware.
- Optimize without measuring first. Pick one Instruments trace, find the top bottleneck, fix it, re-measure.
- Put `@ObservedObject` in list rows.
- Animate layout-changing properties (frame, padding, font size). Animate compositing properties instead.
- Block the main thread with synchronous I/O, JSON decoding of large payloads, or database reads. Use `async`/`await` and move heavy work to a background actor.
- Lazy-load images without a same-frame placeholder. Layout shift in a list is a perceived-performance failure even if the data loads fast.
- Ship `Self._printChanges()` calls in production builds.

## Verify Improvements

After each optimization:

- **Re-run Instruments** on the same device with the same workload. The before/after delta is the only proof the fix worked.
- **Check for regressions:** A change that improves render time but breaks `@State` propagation is not an improvement.
- **Test on the oldest supported device.** A12 performance on a large list is the constraint, not M4 iPad.
- **Measure perceived performance.** Does it _feel_ faster to a first-time user, not just to you after optimizing it for two days?

Performance is a component of polish. A fast app that responds to input immediately, scrolls without stutter, and loads content before the user notices it was absent reads as more capable and more trustworthy than a feature-rich app that hesitates.
