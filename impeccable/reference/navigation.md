# Navigation

This doc covers SwiftUI navigation structure: when to use `NavigationStack` vs. `NavigationSplitView`, how to place toolbar items semantically, how to handle titles and safe areas, and how to wire type-safe deep links with `NavigationPath`. It does not cover tab structure (that's root-level IA, not navigation) or modal presentation rules (that's interaction-design).

## Stack For Drill-Down, Split For List-Detail

**`NavigationStack` is for hierarchies you descend into. `NavigationSplitView` is for list-detail relationships you traverse laterally.** The choice is structural, not cosmetic. A `NavigationStack` says "there is a parent, and this is a child of it." A `NavigationSplitView` says "there are two coequal panes — a list of things and the thing currently selected." These are different information architectures. Picking the wrong one cripples the iPad and Mac builds of the same app.

```swift
// Right for Mail, Notes, Files — anywhere list+detail is the metaphor
NavigationSplitView {
    SidebarView(selection: $selectedFolder)
} content: {
    MessageListView(folder: selectedFolder, selection: $selectedMessage)
} detail: {
    MessageDetailView(message: selectedMessage)
}

// Right for Settings, linear drill-downs, wizards
NavigationStack(path: $path) {
    RootView()
        .navigationDestination(for: Route.self) { route in
            view(for: route)
        }
}
```

**Rule:** Reach for `NavigationSplitView` first on anything that will ship to iPad or Mac. Only use `NavigationStack` when the content is genuinely linear.

**Anti-pattern — "The iPhone-shape iPad app."** An app built with `NavigationStack` as the root container. On iPhone it looks fine. On iPad it renders as a narrow column floating in a sea of gray, wasting 600pt of horizontal real estate. On Mac it's worse — the window looks like a blown-up phone. `NavigationSplitView` would have given iPhone a collapsed stack, iPad a two-column layout, and Mac a three-column layout, from the same code.

## Toolbar Items Use Semantic Placement

**Stop hardcoding "top-right" or "leading." Use `ToolbarItem(placement:)` with semantic slots.** `.primaryAction`, `.secondaryAction`, `.navigation`, `.bottomBar`, `.confirmationAction`, `.cancellationAction`, `.topBarTrailing` — each resolves to the correct place for the current platform, size class, and accessibility state. The system knows where a primary action belongs on iPhone vs. iPad vs. Mac. You do not.

```swift
.toolbar {
    ToolbarItem(placement: .primaryAction) {
        Button("Save", action: save)
    }
    ToolbarItem(placement: .navigation) {
        Button("Back", systemImage: "chevron.left") { dismiss() }
    }
    ToolbarItem(placement: .bottomBar) {
        Button("Delete", systemImage: "trash", role: .destructive) { delete() }
    }
}
```

**Rule:** Always use semantic placements. `.primaryAction` for the dominant affirmative verb. `.cancellationAction` and `.confirmationAction` inside sheets. `.navigation` for back/close. `.bottomBar` for iPhone-scale action clusters.

**Anti-pattern — "The toolbar free-for-all."** Every `ToolbarItem` uses `.topBarTrailing` because that's where the designer saw it in the mock. On iPhone it works. On iPad the primary action lands in a cramped corner next to unrelated chrome. On Mac it breaks the window's title bar convention entirely. Ship semantic placements — the platform will sort them.

## Titles And Display Mode Are Deliberate

**Set `.navigationTitle(_:)` and pair it with a deliberate `.navigationBarTitleDisplayMode(_:)`.** Large titles (`.large`) belong on top-level destinations where the title doubles as a header. Inline titles (`.inline`) belong on drilled-in views where the title is a label, not a statement. Defaulting silently means the system picks — and it picks large for the root, inline for pushed views, which is usually right but sometimes wrong (a drill-in that's still "top level" in the user's mind should often stay large).

```swift
RootView()
    .navigationTitle("Library")
    .navigationBarTitleDisplayMode(.large)

DetailView()
    .navigationTitle(document.name)
    .navigationBarTitleDisplayMode(.inline)
```

**Rule:** Every navigable view declares both the title and the display mode. No implicit defaults.

## Safe-Area Handling Goes Through The System

**Never hardcode `.padding(.top, 44)` or `.padding(.bottom, 34)` to dodge the status bar or home indicator.** Those values are wrong on every device you didn't test on. Use `.safeAreaInset(edge:)` to attach chrome that respects the safe area, or let the layout system handle insets automatically via `NavigationStack` / `NavigationSplitView`.

```swift
ContentView()
    .safeAreaInset(edge: .bottom) {
        FloatingActionBar()
            .padding(.horizontal, 16)
            .padding(.bottom, 8)
    }
```

**Anti-pattern — "The hardcoded safe area."** `.padding(.top, 44)` because "the status bar is 44pt." It isn't, on iPhone X and later. It isn't during a phone call. It isn't on iPad. It isn't with Dynamic Island. The number will betray you on every device you didn't check. `.safeAreaInset` is the only right answer.

## Deep Linking Goes Through `NavigationPath`

**Type-safe routes, not string matching.** Drive the stack with a `NavigationPath` bound to state, and register destinations with `navigationDestination(for:)`. Deep links, state restoration, and back-stack behavior all fall out for free.

```swift
enum Route: Hashable {
    case document(Document.ID)
    case settings
}

@State private var path = NavigationPath()

NavigationStack(path: $path) {
    RootView()
        .navigationDestination(for: Route.self) { route in
            switch route {
            case .document(let id): DocumentView(id: id)
            case .settings:         SettingsView()
            }
        }
}
```

**Rule:** Every destination is an enum case with `Hashable` conformance. No stringly-typed routes.

## iPadOS: Popovers Over Sheets

**On iPadOS, contextual menus belong in popovers, not sheets.** A sheet darkens the whole screen and demands full attention; a popover anchors to the trigger and preserves context. Reserve sheets for discrete tasks (compose, checkout, onboarding) — everything else is a popover. `.popover` anchors correctly on iPad and Mac and falls back to a sheet on iPhone automatically.

## Modal Depth: One Layer at a Time

**Declare: never present a sheet from inside a sheet. If a task needs sub-navigation inside a modal, push onto a `NavigationStack` inside the sheet — don't add another `.sheet`.**

**Why:** A user inside a second-level sheet has no reliable gesture to dismiss both. Swipe-to-dismiss removes only the top sheet, stranding them inside the first. There is no system back gesture that cascades through modal layers. The user is trapped with no obvious exit.

The HIG rule: one active modal at a time. Two is the outer limit, and only for clearly separated contexts (e.g., a share sheet triggered from inside a compose view). If you find yourself writing `.sheet` inside a `.sheet` body, that's the signal to use `NavigationStack` instead.

```swift
// WRONG — sheet presenting sheet
ProfileView()
    .sheet(isPresented: $showEditAvatar) {
        AvatarEditor()  // Second modal layer — user now has no exit
    }

// CORRECT — sub-navigation inside a sheet stays on a stack
.sheet(isPresented: $showProfile) {
    NavigationStack {
        ProfileView()
            .navigationDestination(for: ProfileRoute.self) { route in
                view(for: route)  // Push, don't modal
            }
    }
}
```

## Sheet vs. fullScreenCover

**Declare: use `.sheet` for self-contained tasks where the user should retain context awareness. Use `.fullScreenCover` only for immersive experiences that require total visual focus.**

**Why:** `.sheet` partially covers the presenting view — the user can see (and be reminded of) where they came from. `.fullScreenCover` completely hides the presenting context and has no swipe-to-dismiss by default, so it requires an explicit dismiss mechanism. Reaching for `.fullScreenCover` to avoid thinking about sheet sizing is the wrong reason.

Use `.sheet` for: settings panels, quick compose, filter pickers, onboarding flows.
Use `.fullScreenCover` for: camera, media playback, full-screen onboarding with video, any experience where showing the background would break immersion.

```swift
// Sheet — user retains context awareness
.sheet(isPresented: $showCompose) {
    ComposeView()
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
}

// fullScreenCover — camera needs total visual focus
.fullScreenCover(isPresented: $showCamera) {
    CameraView()
}
```

**Anti-pattern — "The fullScreenCover Escape Hatch":**

```swift
// WRONG — fullScreenCover for a settings form
.fullScreenCover(isPresented: $showSettings) {
    SettingsView()
    // No reason to cover the full screen — use .sheet with .large detent
}
```

## Sheet Sizing with presentationDetents

**Declare: use `presentationDetents([.medium, .large])` when the sheet's content fits in half the screen without scrolling. Default to `.large` for content-heavy sheets.**

**Why:** `.medium` puts the sheet at approximately half-screen height. If the primary content requires scrolling inside a `.medium` sheet, the sheet is the wrong size for the content — use `.large` or offer both and let the user resize. Forcing scroll inside a half-height sheet is a friction error.

```swift
.sheet(isPresented: $showFilter) {
    FilterPanel()
        .presentationDetents([.medium, .large])  // User can drag between sizes
        .presentationDragIndicator(.visible)       // Show the drag indicator explicitly
}

// Content-heavy sheet — start at large, let user pull down to medium
.sheet(isPresented: $showCompose) {
    ComposeView()
        .presentationDetents([.large, .medium])    // Large is default (first in array)
}
```

---

**Avoid:** `NavigationStack` as the root on apps that ship to iPad. Hardcoded toolbar placements. Implicit title display modes. Manual safe-area padding. String-based navigation routes. Sheets where popovers belong on iPad. `.sheet` inside `.sheet`. `.fullScreenCover` for non-immersive content. `.medium` detent when content requires scrolling.
