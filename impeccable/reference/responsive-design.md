# Responsive Design

Responsive on Apple platforms is not about pixel breakpoints — it's about size classes, Dynamic Type, safe areas, and multitasking. A SwiftUI layout that adapts correctly to these four axes works on every device Apple has ever shipped.

## Size Classes, Not Breakpoints

**Declare: branch layout on `horizontalSizeClass` and `verticalSizeClass`, never on device model or screen dimensions.** A size class describes the space the view actually has — not what hardware is rendering it.

**Why:** iPad in Slide Over reports `.compact` horizontally. Stage Manager resizes your window to an arbitrary rectangle. iPhone Pro Max in landscape is sometimes `.regular`. A device-model check will be wrong in every one of those cases and will silently regress when Apple ships new form factors.

```swift
struct Dashboard: View {
    @Environment(\.horizontalSizeClass) private var hSize

    var body: some View {
        if hSize == .regular {
            HStack { sidebar; detail }
        } else {
            VStack { summary; list }
        }
    }
}
```

**Rule:** two size classes × two orientations = four cases. Design for `.compact` first (the constrained case), then let `.regular` unlock additional density.

**Anti-pattern — "The Device-Width Trap":** reading `UIScreen.main.bounds.width`, branching on `UIDevice.current.userInterfaceIdiom`, or hardcoding `if isIPad`. All three break the moment the window isn't full-screen. Size classes are the only correct signal.

## `NavigationSplitView` Adapts So You Don't Have To

**Declare: use `NavigationSplitView` for any app with a hierarchical navigation model.** It collapses to `NavigationStack` automatically in `.compact` and expands to two or three columns in `.regular`.

**Why:** Hand-rolling an iPad-vs-iPhone nav switch means maintaining two trees that drift out of sync. `NavigationSplitView` is one declaration that covers iPhone portrait, iPhone landscape, iPad all multitasking modes, and macOS — with free keyboard shortcuts and pointer behavior on each.

```swift
struct RootView: View {
    @State private var selectedFolder: Folder?
    @State private var selectedItem: Item?

    var body: some View {
        NavigationSplitView {
            FolderList(selection: $selectedFolder)
        } content: {
            ItemList(folder: selectedFolder, selection: $selectedItem)
        } detail: {
            if let selectedItem { ItemDetail(item: selectedItem) }
            else { ContentUnavailableView("Select an item", systemImage: "doc") }
        }
    }
}
```

## `ViewThatFits` Replaces Media Queries

**Declare: use `ViewThatFits` when the same content has two or three legitimate layouts and the right one depends on available space.** It evaluates each candidate in order and renders the first that fits.

**Why:** You cannot and should not measure the container manually. `ViewThatFits` removes a whole class of `GeometryReader` plus `if width > X` code and evaluates at layout time, including after text scaling or window resizing.

```swift
struct StatsRow: View {
    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: 24) {
                Stat(label: "Today", value: "4 hrs 12 min")
                Stat(label: "This week", value: "23 hrs")
                Stat(label: "Streak", value: "12 days")
            }
            VStack(alignment: .leading, spacing: 12) {
                Stat(label: "Today", value: "4 hrs 12 min")
                Stat(label: "This week", value: "23 hrs")
                Stat(label: "Streak", value: "12 days")
            }
        }
    }
}
```

**Rule:** order candidates most-expansive first. `ViewThatFits` picks the first that fits, so the biggest layout must come first or it will never appear.

## Dynamic Type Is the Other Axis of "Responsive"

**Declare: every font on every view uses a semantic style (`.body`, `.headline`, `.largeTitle`) — never a fixed point size.** Fixed sizes do not scale and they lock out the largest accessibility sizes.

**Why:** Users can triple text size via Settings. "Responsive" on the web means width; on Apple platforms it equally means Dynamic Type. A layout that looks immaculate at default size and truncates at `.accessibilityLarge` is not responsive — it's fragile.

```swift
Text("Weekly Summary")
    .font(.title2)                 // Semantic — scales automatically

@ScaledMetric private var iconSize: CGFloat = 24
@ScaledMetric private var cardPadding: CGFloat = 16

// Use @ScaledMetric for any dimension that should grow with text.
Image(systemName: "chart.bar.fill")
    .font(.system(size: iconSize))
    .padding(cardPadding)
```

**Rule:** combine `@ScaledMetric` with `ViewThatFits` to reflow horizontal content into vertical stacks at larger sizes. Clamp with `.dynamicTypeSize(...DynamicTypeSize.accessibility3)` _only_ when the design genuinely cannot accommodate larger sizes — and then document the decision.

**Anti-pattern — "The Dynamic Type Regression":** fixed-height rows (`.frame(height: 44)`), single-line labels without `.minimumScaleFactor`, or `.lineLimit(1)` without `.truncationMode(.tail)`. These appear fine at default size and collapse at `.accessibilityLarge`, where every single label truncates to ellipsis.

## Safe Areas: Trust the System

**Declare: place content inside SwiftUI's default safe area and use `.safeAreaInset(edge:)` for pinned toolbars or action bars.** Never hardcode padding to clear the notch, Dynamic Island, or home indicator.

**Why:** Hardcoded insets drift out of date every time Apple ships a new device class. The safe-area environment is automatically correct on every iPhone, iPad orientation, and window size — past, present, and future.

```swift
struct ReaderView: View {
    var body: some View {
        ScrollView { articleBody }
            .safeAreaInset(edge: .bottom) {
                HStack { Button("Previous"){} ; Spacer() ; Button("Next"){} }
                    .padding()
                    .background(.regularMaterial)
            }
    }
}
```

**Rule:** content that should bleed edge-to-edge (hero images, maps, full-bleed video) uses `.ignoresSafeArea()` — but only that content. Text and controls stay inside the safe area, always.

## Multitasking on iPad Is Non-Negotiable

**Declare: your app works in Split View, Slide Over, and Stage Manager without layout collapse.** Every size from 320pt wide up to full iPad Pro landscape is a legitimate runtime state.

**Why:** App Review rejects apps that break in multitasking. More importantly, users live in Split View — notes beside Safari, Mail beside Calendar. An app that assumes "iPad = big screen" is broken the moment the user drags another app alongside it.

**Rule:** test every screen at four widths: 320pt (Slide Over), 375pt (iPhone-equivalent), 700pt (half iPad), and full-width. If a layout breaks at any of these, refactor with `ViewThatFits` or a size-class branch before shipping.

## The Grid Scales by Size Class, Not by Count

**Declare: use `LazyVGrid` with `GridItem(.adaptive(minimum:))` to let the grid decide column count from available width.** Don't hardcode "2 columns on iPhone, 4 on iPad."

**Why:** Adaptive grids fill whatever space you give them. A hardcoded column count is wrong in Split View, wrong on a resized Mac window, and wrong at accessibility text sizes where each cell needs more room.

```swift
struct PhotoGrid: View {
    let photos: [Photo]
    @ScaledMetric private var minCell: CGFloat = 140

    var body: some View {
        ScrollView {
            LazyVGrid(
                columns: [GridItem(.adaptive(minimum: minCell), spacing: 8)],
                spacing: 8
            ) {
                ForEach(photos) { PhotoCell(photo: $0) }
            }
            .padding()
        }
    }
}
```

## presentationCompactAdaptation — Control Popover Fallback Explicitly

**Declare: when a `.popover` must behave differently in compact environments than the default sheet fallback, use `presentationCompactAdaptation` to state that explicitly. Never use `.none` on content-heavy popovers.**

**Why:** `.popover` automatically adapts to a `.sheet` on iPhone (horizontally compact). This default is usually correct — popovers require space to anchor to their source without covering the screen, and iPhone doesn't have that space. But there are cases where the default is wrong: a small color picker that genuinely fits on iPhone without a full sheet, or a detented sheet that needs to stay detented even in landscape compact.

The four `PresentationAdaptation` values:

- `.automatic` — platform default (popover → sheet on compact). Usually correct; prefer this.
- `.none` — keep the popover as a popover in compact. Only valid for genuinely small, self-contained panels (color pickers, emoji selectors). Never use on content requiring scroll.
- `.sheet` — explicitly adapt to a sheet. Use when you need `presentationDetents` on the compact version.
- `.fullScreenCover` — adapt to full-screen cover. Rare.

```swift
// Small self-contained panel — stays as popover on iPhone
Button("Color") { showPicker = true }
    .popover(isPresented: $showPicker) {
        ColorPickerContent()
            .frame(width: 280, height: 320)
            .presentationCompactAdaptation(.none)
    }

// Popover that explicitly becomes a detented sheet on iPhone
Button("Filter") { showFilter = true }
    .popover(isPresented: $showFilter) {
        FilterPanel()
            .presentationDetents([.medium, .large])
            .presentationCompactAdaptation(.sheet)
    }

// Prevent a detented sheet from expanding to full-screen cover in landscape iPhone
.sheet(isPresented: $showFilter) {
    FilterPanel()
        .presentationDetents([.medium, .large])
        .presentationCompactAdaptation(.none)  // Stay detented, don't full-screen in landscape
}

// Different adaptations per dimension
.presentationCompactAdaptation(horizontal: .sheet, vertical: .none)
```

**Anti-pattern — "The Suppressed Adaptation":**

```swift
// WRONG — suppressing adaptation on a content-heavy popover
.popover(isPresented: $showMenu) {
    FullMenuView()              // Long scrollable content
        .presentationCompactAdaptation(.none)
    // On iPhone: partially covers content, no clear dismiss gesture, content clips
}
```

## Orientation Is a Weak Signal

**Declare: design to size classes, not to `UIDevice.orientation`.** An iPhone in landscape might be `.compact` height and `.regular` width; an iPad in portrait is usually `.regular` × `.regular`. Orientation alone tells you nothing useful.

**Why:** "Landscape" means different layouts on an iPhone Mini versus an iPad Pro. Branching on orientation produces code that is right for one device and wrong for every other. Size classes encode the actual layout intent.

## External Keyboard and Pointer Are First-Class

**Declare: every primary action has a keyboard shortcut; every list supports arrow-key navigation via `@FocusState`.** A keyboard-attached iPad is a laptop — treat it like one.

**Why:** iPad users attach Magic Keyboards. Mac users expect keyboard shortcuts on everything. Building these affordances is a couple of modifiers; skipping them makes your app feel like a phone app stretched onto a bigger screen.

```swift
Button("New Note", systemImage: "plus", action: newNote)
    .keyboardShortcut("n", modifiers: [.command])
```

---

**Avoid:** reading `UIScreen.main.bounds` or `UIDevice.current.userInterfaceIdiom` to branch layout. Hardcoded column counts. Fixed-height rows that trap Dynamic Type. Ignoring Split View widths below 400pt. Porting `@media (max-width:)` thinking as a size-class ladder with device-specific values — size classes are not breakpoints and should not be used as such.
