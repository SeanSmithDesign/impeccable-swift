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

---

**Avoid:** `NavigationStack` as the root on apps that ship to iPad. Hardcoded toolbar placements. Implicit title display modes. Manual safe-area padding. String-based navigation routes. Sheets where popovers belong on iPad.
