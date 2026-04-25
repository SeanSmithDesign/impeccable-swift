# Adapt

Adapt SwiftUI interfaces to work effectively across Apple's device family: from a 320pt Slide Over column to a resizable macOS Stage Manager window to a visionOS ornament. Adaptation on Apple platforms is not about viewport widths; it is about traits, containers, and platform idioms.

> **Additional context needed**: target platforms and deployment idiom (iPhone-only, universal, Mac native, etc.).

---

## Assess the Adaptation Challenge

Before touching layout code, establish the shape of the problem:

1. **What idiom was the UI designed for?**
   - iPhone-only, iPhone + iPad universal, iPad-first, Mac native, Mac Catalyst, Designed for iPad on Mac, watchOS, visionOS.
   - See [`ios-vs-macos.md`](ios-vs-macos.md) for the full platform resolution matrix.

2. **What size-class conditions does it need to survive?**
   - `.compact` horizontal (iPhone portrait, Slide Over, Split View 1/3 column).
   - `.regular` horizontal (iPad landscape full-screen, Split View 2/3, Stage Manager).
   - `.compact` vertical (iPhone landscape).
   - `.regular` vertical (iPad, Mac, visionOS).

3. **What input models must it support?**
   - Touch (iPhone, iPad, visionOS indirect): 44pt minimum tap area.
   - Pointer / trackpad / keyboard (Mac, iPad with keyboard/trackpad): 28pt cursor target is acceptable; hover states and right-click context menus are expected.
   - Digital Crown, tap gesture only (watchOS).

4. **What adaptation challenges exist?**
   - Layouts that assume a fixed column count.
   - Touch targets sized for mouse pointers (too small) or vice versa.
   - Navigation containers that don't collapse gracefully.
   - Text that truncates instead of reflows at larger Dynamic Type sizes.

**CRITICAL**: Adaptation is not scaling. It is rethinking the experience for the space and input model it actually has.

---

## Adaptive Layout Strategy

### Size Classes Are the Signal

Branch layout on `horizontalSizeClass` and `verticalSizeClass`. Never branch on device model, screen dimensions, or `UIDevice.current.userInterfaceIdiom`.

```swift
struct ContentView: View {
    @Environment(\.horizontalSizeClass) private var hSize
    @Environment(\.verticalSizeClass) private var vSize

    var body: some View {
        if hSize == .regular {
            // Two-pane or multi-column layout
            TwoColumnLayout()
        } else {
            // Single-column layout
            SingleColumnLayout()
        }
    }
}
```

**Why size classes matter:** iPad in Slide Over reports `.compact` horizontally. Stage Manager gives an arbitrary rectangle. iPhone Pro Max in landscape is `.regular`. Any hardcoded dimension check silently regresses when the window changes. Full treatment in [`responsive-design.md`](responsive-design.md).

**Rule:** Design `.compact` first. Let `.regular` unlock additional density, never subtract from it.

### `ViewThatFits` for Content-Driven Selection

When you have multiple layout candidates and want the system to pick the first one that fits the available space without measurement code:

```swift
ViewThatFits(in: .horizontal) {
    // Preferred: side-by-side when width allows
    HStack(spacing: 16) {
        ThumbnailView(item: item)
        MetadataView(item: item)
    }
    // Fallback: stacked when width is too narrow
    VStack(alignment: .leading, spacing: 8) {
        ThumbnailView(item: item)
        MetadataView(item: item)
    }
}
```

`ViewThatFits` is content-driven. It does not require you to know the container width at call time. Use it for single components that have two or three sensible arrangements.

**When to use it vs. size-class branching:**

- Size-class branching: whole-page structural decisions (nav, sidebars, tab vs. split).
- `ViewThatFits`: individual component layout variants within a page.

### `NavigationSplitView` Adapts Automatically

`NavigationSplitView` is the primary adapter for list-detail apps. It collapses to a push stack on compact width (iPhone, Slide Over), expands to two or three columns on regular width (iPad, Mac). This behavior is built in. Do not override it.

```swift
NavigationSplitView(columnVisibility: $visibility) {
    SidebarView(selection: $selection)
        .navigationSplitViewColumnWidth(min: 180, ideal: 220)
} detail: {
    DetailView(item: selection)
}
.navigationSplitViewStyle(.balanced)
```

Full structural guidance in [`navigation.md`](navigation.md) and platform-specific column behavior in [`ios-vs-macos.md`](ios-vs-macos.md).

### `TabView` to Sidebar Transitions

In iOS 18+ / iPadOS 18+, `TabView` with `.tabViewStyle(.sidebarAdaptable)` automatically renders as a bottom tab bar on compact width and as a sidebar on regular width:

```swift
TabView(selection: $selectedTab) {
    Tab("Home", systemImage: "house", value: Tab.home) {
        HomeView()
    }
    Tab("Library", systemImage: "books.vertical", value: Tab.library) {
        LibraryView()
    }
}
.tabViewStyle(.sidebarAdaptable)
```

**Rule:** Prefer `.sidebarAdaptable` over manually managing sidebar visibility when the content model maps naturally to tabs. The framework handles the compact/regular transition.

---

## Platform Idioms

Platform idioms are distinct from size classes. An iPad in Split View has compact horizontal size class but is still the iPad idiom. A Mac is always regular but has its own behavioral expectations. See [`ios-vs-macos.md`](ios-vs-macos.md) for the full matrix; this section covers the adaptation decisions that `ios-vs-macos.md` does not:

### iPhone-Only

- Design entirely in `.compact` horizontal. No split view, no sidebar.
- Single-column `NavigationStack` or `TabView` is the correct root.
- Safe areas are the layout constraint : never hardcode top/bottom insets.

### iPhone + iPad Universal

- This is the default for any new SwiftUI target.
- Design `.compact` first. Regular layout layers on top.
- `NavigationSplitView` at the root gives iPad two columns and iPhone a collapsed stack from the same code.

### iPad Multitasking Dimensions

iPad can be placed in three distinct multitasking configurations simultaneously. Size classes capture the effect:

| Configuration                 | Horizontal size class | Approximate width |
| ----------------------------- | --------------------- | ----------------- |
| Full screen (portrait)        | regular               | 768pt+            |
| Split View 50/50              | compact               | ~390pt            |
| Split View 70/30 (large side) | regular               | ~540pt            |
| Split View 70/30 (small side) | compact               | ~320pt            |
| Slide Over                    | compact               | 320pt             |
| Stage Manager (resizable)     | compact or regular    | variable          |

**Rule:** Design for 320pt as the minimum viable width on iPad. Slide Over is always 320pt and it is a legitimate use case, not an edge case.

**Stage Manager note:** On iPadOS 16+ and macOS Sonoma+, windows can be any arbitrary size within the display. Size classes remain the correct signal. If a layout must impose constraints, use `frame(minWidth:minHeight:)` on the root view : do not assume full-screen.

### Mac Native (SwiftUI native target)

- Windows are resizable. Enforce a minimum window size via `WindowGroup` scene modifiers:

```swift
WindowGroup {
    ContentView()
}
.defaultSize(width: 900, height: 600)
.windowResizability(.contentMinSize)
```

- NSWindow restoration (reopening the window at its previous size and position) is automatic for document-based apps and `WindowGroup` with a persistent identifier.
- Hover states are expected. Use `.hoverEffect()` and `.onHover` where the pointer should change behavior.
- Cursor target minimum is 28pt. Controls do not need 44pt tap area on Mac.
- Right-click context menus must work. Use `.contextMenu` on interactive elements.

### Mac Catalyst

Catalyst is a compatibility path. Prefer a native SwiftUI Mac target when the app's interaction model is pointer-based. If Catalyst is the deployment choice, use `UIRequiresFullScreen` only when the layout cannot tolerate resizing, and test Stage Manager explicitly.

### Designed for iPad (on Mac)

iPhone and iPad apps running on Apple Silicon Mac via the "Designed for iPad" path run in a fixed window. They receive iPad size classes. They do not receive hover events or right-click by default. This is an acceptable compatibility target, not a first-class Mac experience. Label it accordingly in your release strategy.

### watchOS

Single-column only. Digital Crown scrolling replaces scroll gestures. Complications drive re-entry; do not assume full navigation state is available on launch. Composing with `TimelineView` for live updates is the primary pattern.

### visionOS

Volumes and ornaments replace fixed windows. `NavigationSplitView` is the standard structure for app content. Ornaments host secondary controls floating beside the main window : use `.ornament(attachmentAnchor:)`. Hover is replaced by eye tracking gaze; interactive elements must be large enough to target with gaze (44pt remains the floor).

---

## Touch Targets and Pointer Targets

| Context                       | Minimum tap / click area           |
| ----------------------------- | ---------------------------------- |
| iPhone, iPad (touch)          | 44 x 44 pt                         |
| iPad with trackpad / keyboard | 44 x 44 pt (touch may still occur) |
| Mac (cursor only)             | 28 x 28 pt                         |
| visionOS (gaze)               | 44 x 44 pt                         |
| watchOS (finger tap)          | 44 x 44 pt                         |

Apply minimum tap area with `.contentShape` when the visible element is smaller:

```swift
Button(action: dismiss) {
    Image(systemName: "xmark")
        .font(.system(size: 14, weight: .medium))
}
.frame(width: 44, height: 44)
.contentShape(Rectangle())
```

**Rule:** If the visual affordance is smaller than the tap area, pad with transparent content shape : never shrink the tap area to match the visual.

---

## Dynamic Type Adaptation

Layouts must reflow as the user scales text. Truncation is not acceptable on body or label text. Fixed-height containers that clip at large Dynamic Type sizes fail both accessibility requirements and practical usability.

```swift
// Fragile: fixed height clips at AX5
HStack {
    Image(systemName: icon)
    Text(label)
}
.frame(height: 44) // Clips if Dynamic Type scales label to 28pt

// Correct: minimum height, allows growth
HStack(alignment: .firstTextBaseline) {
    Image(systemName: icon)
        .imageScale(.medium)
    Text(label)
        .fixedSize(horizontal: false, vertical: true)
}
.frame(minHeight: 44)
```

For label-icon pairs at large Dynamic Type sizes, consider switching to a vertical stack:

```swift
struct AdaptiveCell: View {
    @ScaledMetric private var iconSize: CGFloat = 24
    @Environment(\.dynamicTypeSize) private var typeSize

    var body: some View {
        if typeSize >= .accessibility2 {
            VStack(alignment: .leading, spacing: 8) {
                Image(systemName: "star.fill")
                    .frame(width: iconSize, height: iconSize)
                Text("Favorites")
                    .fixedSize(horizontal: false, vertical: true)
            }
        } else {
            HStack(spacing: 12) {
                Image(systemName: "star.fill")
                    .frame(width: iconSize, height: iconSize)
                Text("Favorites")
            }
        }
    }
}
```

Use `@ScaledMetric` for any spacing or icon dimension that should scale with text.

**Rule:** Test AX5 (the largest accessibility size) during layout design, not after. Layouts that only work at default type size are not production-ready.

---

## Detector Wiring

There is no automated `impeccable-lint` rule for adaptive layout. Adaptation correctness is inherently contextual and requires visual inspection across device configurations.

**Review process:**

- Use Xcode's device preview matrix (the device picker in the Preview canvas) to cycle through iPhone SE, iPhone Pro, iPad mini, iPad Pro, and Mac.
- Use `#Preview` traits to pin previews to specific size classes:

```swift
#Preview("Compact", traits: .sizeThatFitsLayout) {
    ContentView()
        .environment(\.horizontalSizeClass, .compact)
}

#Preview("Regular", traits: .sizeThatFitsLayout) {
    ContentView()
        .environment(\.horizontalSizeClass, .regular)
}
```

- Test Slide Over manually on iPad: Spotlight > type your app name > drag to edge. The 320pt column is the stress test.
- Test Stage Manager on an M-series iPad or macOS: resize the window to its minimum and confirm the layout degrades gracefully.
- Test Dynamic Type via Settings > Accessibility > Display & Text Size > Larger Text.

---

## Anti-Patterns

**Never**:

- Branch on `UIDevice.current.userInterfaceIdiom` or `UIScreen.main.bounds` for layout decisions. Both break in multitasking and Stage Manager.
- Hardcode a column count that assumes full-screen. Slide Over is always 320pt.
- Use fixed-height containers on text-bearing rows. They clip at large Dynamic Type.
- Assume iPad means regular width. Split View and Slide Over deliver compact.
- Disable multitasking (`UIRequiresFullScreen`) without documenting why and verifying it is truly incompatible.
- Ship a Mac build with 44pt tap targets and sheet-as-default presentation. See [`ios-vs-macos.md`](ios-vs-macos.md) for what Mac users expect instead.
- Hide core functionality conditionally on size class. If a feature matters, adapt it : don't remove it.
- Assume landscape is edge-case. iPhone landscape is `.compact` vertical and `.regular` horizontal : a common configuration that many users prefer for media and reading.
