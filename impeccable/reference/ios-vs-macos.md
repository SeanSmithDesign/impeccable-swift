# iOS vs. macOS

This doc covers the places where the same SwiftUI code must resolve differently on iPhone, iPad, and Mac — sidebar behavior, toolbar placement, pointer effects, window chrome, context menus, and popover-vs-sheet defaults. It does not cover Catalyst specifics or AppKit interop; if you're reaching for either of those, this skill is the wrong level.

## Write Once, Resolve Per Platform

**Never ship a macOS build that looks like a scaled-up iPhone.** The iPhone idiom — single-column navigation, sheet-as-default, touch-sized controls, no hover — is actively wrong on Mac. macOS users expect pointer affordances, context menus on right-click, content-size windows, and a menu bar that participates in the app. Shipping iPhone defaults unchanged is not "Mac support"; it's neglect with a target membership checkbox.

**Rule:** Any SwiftUI target that ships to Mac (native or Designed for iPad) needs explicit Mac treatments for the surfaces below. `#if os(macOS)` is allowed and expected where the platform idiom genuinely differs.

**Anti-pattern — "The transplanted iPhone app."** A Mac window with iPhone-sized tap targets, no hover states, sheets where popovers belong, and a toolbar that crowds everything into the top-right. Reads as "made with Mac Catalyst, never polished." Users smell it instantly.

## Sidebars Persist On Mac, Collapse On iPhone

**`NavigationSplitView` adapts automatically — stop overriding it.** On Mac it's a three-column window. On iPad landscape it's two or three columns. On iPad portrait it's two columns with a toggleable sidebar. On iPhone it collapses to a stack. That's the contract. If you've written `#if os(iOS)` branches to hand-collapse the sidebar, you've fought the framework and lost.

```swift
NavigationSplitView(columnVisibility: $visibility) {
    SidebarView()
        .navigationSplitViewColumnWidth(min: 180, ideal: 220)
} detail: {
    DetailView()
}
.navigationSplitViewStyle(.balanced)
```

**Rule:** Use `NavigationSplitView` with `.navigationSplitViewColumnWidth` and `.navigationSplitViewStyle`. Let the framework handle collapse. Override only when there's a documented reason.

## Toolbar Placement Resolves Differently

**The same `.primaryAction` lands top-right on iPhone and top-right on Mac — but the Mac version sits in the window title bar with different padding, and the iPad version may split between primary and secondary slots.** Semantic placement is the mechanism that makes one codebase render correctly across all three. Hardcoded placements break the contract.

**Rule:** Every toolbar item uses semantic placement (`.primaryAction`, `.navigation`, `.confirmationAction`, `.cancellationAction`). See `navigation.md` for the full set.

## Pointer Contexts Require Hover Treatments

**On Mac and iPad-with-trackpad, every interactive control needs a hover treatment.** `.hoverEffect(.lift)`, `.hoverEffect(.highlight)`, or a custom `onHover` handler. Without hover, the user can't tell what's clickable — the whole point of the pointer is that it disambiguates targets, and a static UI throws that away.

```swift
Button("Edit", systemImage: "pencil") { edit() }
    .hoverEffect(.highlight)
    .help("Edit the selected item")             // tooltip on Mac + iPad pointer

ImageTile(image: image)
    .onContinuousHover { phase in
        switch phase {
        case .active(let loc): tooltipPosition = loc
        case .ended: tooltipPosition = nil
        }
    }
```

**Rule:** Every button, link, row, and tappable area on a pointer-capable surface has `.hoverEffect(_:)` and a `.help(_:)` tooltip where the label isn't self-evident.

**Anti-pattern — "The invisible hover."** A Mac window full of buttons with no hover treatment. The cursor slides across and nothing responds. The user has to click blindly to discover what's clickable. Every interactive control needs visible hover feedback on pointer platforms.

## Window Chrome Is Mac-Only And Mandatory

**Mac apps declare window behavior explicitly.** `.windowStyle(.hiddenTitleBar)` removes the default title bar for custom chrome. `.containerBackground(.regularMaterial, for: .window)` gives the window a material base. `.windowResizability(.contentSize)` says the window should size to its content rather than float at an arbitrary default. None of these have iOS equivalents — omitting them means shipping a Mac app with default AppKit chrome glued onto SwiftUI content.

```swift
WindowGroup {
    RootView()
        .containerBackground(.regularMaterial, for: .window)
}
.windowStyle(.hiddenTitleBar)
.windowResizability(.contentSize)
```

**Rule:** Every `WindowGroup` declares style, background, and resizability. Defaults are wrong for most apps.

**Anti-pattern — "The status-bar cover."** A Mac window that ignores the menu bar, fights window chrome, or hides the traffic-light buttons without compensating. Mac users expect the window to live _with_ the system chrome, not on top of it.

## Context Menus Are Default On Mac, Rare On iPhone

**On Mac, every selectable row gets `.contextMenu`. On iPhone, use it sparingly.** Right-click is a discoverable, expected Mac gesture — a row without a context menu on Mac feels broken. Long-press on iPhone is neither discoverable nor expected by default, so reach for it only when there's clear discovery (a visible chevron, a hint in onboarding) and never as the only path to an action.

```swift
RowView(item: item)
    .contextMenu {
        Button("Rename", systemImage: "pencil") { rename(item) }
        Button("Duplicate", systemImage: "plus.square.on.square") { duplicate(item) }
        Divider()
        Button("Delete", systemImage: "trash", role: .destructive) { delete(item) }
    }
```

## `MenuBarExtra` Is Mac-Only

**For menu-bar-resident apps, use `MenuBarExtra`.** There is no iOS equivalent. State that plainly in the brief if the app is menu-bar-primary on Mac — the iOS build will need a different primary surface (widget, shortcut, control center extension), not a transplant of the menu bar UI.

```swift
@main
struct TimerApp: App {
    var body: some Scene {
        MenuBarExtra("Timer", systemImage: "timer") {
            TimerMenu()
        }
        .menuBarExtraStyle(.window)
    }
}
```

## Popovers On Mac And iPad, Sheets On iPhone

**`.popover` on pointer surfaces, `.sheet` on iPhone.** A popover anchors to the trigger and preserves surrounding context — the right idiom when there's room. A sheet darkens the screen and demands full attention — the right idiom when there isn't. `.popover` on iPhone falls back to a sheet automatically when the screen is too small, so writing popover-first usually gives you both for free.

**Rule:** Start with `.popover(isPresented: attachmentAnchor: arrowEdge:)`. Fall back to `.sheet` only when the surface genuinely needs full attention (compose, checkout, onboarding).

---

**Avoid:** Shipping a Mac build without hover treatments. Hand-collapsing `NavigationSplitView` for iPhone. Hardcoded toolbar placements. Default window chrome on Mac. Missing `.contextMenu` on Mac rows. Sheets where popovers belong.
