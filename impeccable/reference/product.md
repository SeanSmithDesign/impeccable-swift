# Product register

When design SERVES the product: app UI, settings sheets, dashboards, content lists, forms, navigation stacks, tool panes, admin surfaces, authenticated screens, anything where the user is in a task.

On Apple platforms this is the default register. Most SwiftUI you ship lives here: a settings screen, a `NavigationStack` of content, a `Form`, a content list, a utility tool. Brand register is the exception: marketing shells, portfolios, campaign surfaces.

## The product slop test

Not "would someone say AI made this." Familiarity is often a feature here. The test is: would a user fluent in the platform's best apps (Things, Reeder, Mail, Music, Tot, NetNewsWire, OmniFocus, Linear's Mac client come to mind) sit down and trust this interface, or pause at every subtly-off control?

Product UI's failure mode in SwiftUI isn't flatness, it's strangeness without purpose: hand-built `Toggle` replacements, a custom segmented control where `Picker(.segmented)` is right there, gratuitous spring animations on every state change, display weights where labels should be, invented affordances for standard tasks. The bar is earned familiarity. The tool should disappear into the task.

Apple already standardised most of these affordances. Reaching past them needs a reason.

## Typography

- **SF Pro is the right answer most of the time.** It ships with the platform, supports every Dynamic Type tier, has built-in numeric styles, and matches user expectations for native apps. Use `Font.system(...)` and SF Pro's text styles before reaching for `Font.custom(...)`.
- **One family is usually right.** Product UIs don't need display/body pairing. SF Pro carries headings, buttons, labels, body, and data well.
- **Dynamic Type is non-negotiable.** Use the semantic text styles (`.largeTitle`, `.title`, `.title2`, `.title3`, `.headline`, `.body`, `.callout`, `.subheadline`, `.footnote`, `.caption`, `.caption2`). They scale across all 12 user tiers automatically. Fixed point sizes for body copy fail accessibility immediately.
- **Tighter scale ratio.** SF Pro's text styles already encode a sensible 1.125–1.2 ratio between adjacent steps. Don't fight them; pick from the ladder, don't invent your own.
- **Numeric styles matter in product UI.** Use `.monospacedDigit()` on counts, timers, prices, anything where digits jitter on update. Use `Text(value, format: ...)` not string interpolation.
- **Line length still applies for prose** (65–75 characters). Set the container width with `.frame(maxWidth:)` rather than relying on the device width. Data and compact UI can run denser: a wide `Table` on macOS at 800pt+ is fine.

See [reference/typography.md](typography.md) for the full Swift typography reference.

## Color

Product defaults to Restrained. A single surface can earn Committed: a dashboard where one category color carries a report, an onboarding sheet with a drenched welcome screen: but Restrained is the floor.

- **Lean on system semantic colors first.** `.primary`, `.secondary`, `Color(.systemBackground)`, `Color(.secondarySystemBackground)`, `Color(.tertiarySystemBackground)`, `Color(.label)`, `Color(.systemFill)` already adapt to Dark Mode, Increase Contrast, and elevated surfaces. Tint only where you've earned the deviation.
- **Accent color is for primary actions, current selection, and state indicators only.** Apply via `.tint(_:)` on the relevant container or root view, or via the asset catalog's AccentColor entry. Not decoration.
- **State-rich semantic vocabulary.** Standardize Color Set entries for hover (macOS), focus, pressed, disabled, selected, loading, error, warning, success, info. Define them as Color Sets in the asset catalog with Any/Dark variants: never hex literals scattered through views.
- **A second neutral layer for sidebars, toolbars, and panels.** macOS sidebars, navigation panes, and inspectors want to read as a different surface. `Color(.windowBackgroundColor)` vs `Color(.controlBackgroundColor)` on macOS, or `.background(.regularMaterial)` for floating panels on iOS.

See [reference/color-and-contrast.md](color-and-contrast.md) for OKLCH reasoning, asset catalog Color Set structure, and Dark Mode coverage.

## Layout

- **Predictable structure.** Consistency IS an affordance: users navigate faster when the structure is expected. A `NavigationStack` with a title and a trailing toolbar item is invisible because it's right.
- **Familiar patterns are features.** `NavigationStack` (push/pop), `NavigationSplitView` (sidebar + content + detail on iPad and Mac), `TabView` (peer destinations), `Form` (settings), `List` (content collections), `.searchable`, `.refreshable`. These have established user expectations. Don't reinvent for flavor.
- **Responsive behavior is structural.** Collapse the sidebar at compact width, switch a `LazyVGrid` column count via size class, swap layouts with `ViewThatFits`. Not fluid typography: Dynamic Type already scales the type.
- **Spacing in points, not pixels.** Use the 4 / 8 / 16 / 24 scale across the surface. Vary it for rhythm: same padding everywhere reads as monotony. `@ScaledMetric` for any spacing tied to text.

See [reference/responsive-design.md](responsive-design.md) for size classes, `ViewThatFits`, and breakpoint logic. See [reference/navigation.md](navigation.md) for `NavigationStack` vs `NavigationSplitView` vs `TabView` selection. See [reference/ios-vs-macos.md](ios-vs-macos.md) for platform-specific layout idioms (sidebars, inspectors, window chrome).

## Components

Every interactive component has: default, pressed, focused, disabled, loading, error. Don't ship with half of these.

- **Use system controls.** `Toggle`, `Stepper`, `Picker`, `Slider`, `DatePicker`, `Menu`, `ProgressView`, `Button` with `.borderedProminent` / `.bordered` / `.plain` styles. They match user expectations and adapt to platform automatically. A custom `Toggle` replacement is almost always wrong.
- **Loading states use `ProgressView` or skeleton views, not spinners floating in empty space.** A `ProgressView` inline at the action that triggered it. A `redacted(reason: .placeholder)` skeleton for content that's loading. Never a spinner centered in a blank screen.
- **Empty states use `ContentUnavailableView`.** Built into iOS 17+. It teaches the interface: why the list is empty, what to do next: instead of leaving a blank canvas. `ContentUnavailableView.search` for empty search results.
- **Consistent affordances across the surface.** Same button style. Same form-control vocabulary. Same icon weight and scale. If the "save" button looks different in two screens, one is wrong. SF Symbols within a single surface should share weight and scale: see [reference/sf-symbols.md](sf-symbols.md).
- **Materials over custom blurs.** `.regularMaterial`, `.thinMaterial`, `.thickMaterial`, `.ultraThinMaterial` for floating overlays, toolbars, and controls. Never `Color.white.opacity(0.8)` plus `.blur()`. Never `.ultraThinMaterial` as a baseline texture: see [reference/materials.md](materials.md) for the full Liquid Glass posture.

## Motion

- **150–250 ms on most transitions.** `.smooth` or `.snappy` (iOS 17+) cover most product needs. Users are in flow: don't make them wait for choreography.
- **Motion conveys state, not decoration.** State change, feedback, loading, reveal: nothing else. A `Toggle` that springs is wrong. A row that slides in when a list updates is right.
- **No orchestrated screen-load sequences.** Product loads into a task; users don't want to watch it load. `.transition(.opacity)` for content swaps. Cascading staggered reveals belong to brand register.
- **`.sensoryFeedback` on completion, error, and selection.** It's the iOS-native equivalent of audible feedback in macOS: confirms an action without a visual flourish. Tie it to the state it confirms, not to every tap.
- **Animate opacity, scale, offset, color, material: never layout.** Animating `.padding` or `.frame` triggers layout passes that read as jank. See [reference/motion-design.md](motion-design.md).
- **Respect `@Environment(\.accessibilityReduceMotion)`** on every animation that's not strictly informative. See [reference/accessibility.md](accessibility.md).

## Product bans (on top of the shared absolute bans)

- **Decorative motion that doesn't convey state.** A spring on every tap, a phase animator looping in the corner of a settings screen, a wiggle that means nothing.
- **Inconsistent component vocabulary across screens.** If `Toggle` is used for one preference and a custom switch for another, one is wrong. Same for `Picker` styles, button styles, list styles.
- **Display weights in UI labels, buttons, data.** `.largeTitle.weight(.heavy)` on a settings row label is wrong. Heavy weights are for `.largeTitle` headers, not body chrome.
- **Reinventing standard affordances.** Custom segmented controls, hand-built `DatePicker` replacements, non-standard `.sheet` presentations, fake pull-to-refresh that doesn't use `.refreshable`, custom search bars that don't use `.searchable`.
- **`.alert` for everything.** An `.alert` is a hard interrupt. Use it for confirmation of destructive action or error that blocks progress. For everything else: inline messaging, `.toast` patterns, contextual `.popover`, `Menu`.
- **Heavy color or full-saturation accents on inactive states.** A disabled button at full tint is wrong; let the system `.disabled(true)` handle it, or drop opacity to ~0.4 on a custom style.
- **`.ultraThinMaterial` as page background.** That's not what materials are for. They float over content; they don't replace content surfaces.

## Product permissions

Product can afford things brand surfaces can't.

- **System fonts and SF Pro defaults.** No custom display family needed. SF Pro's text styles cover the full hierarchy.
- **Standard navigation patterns.** `NavigationStack`, `NavigationSplitView`, `TabView`, breadcrumbs (on macOS via `.navigationSubtitle`), command palettes (`.searchable` with suggestions, or a custom `Menu`), keyboard shortcuts via `.keyboardShortcut(_:modifiers:)` on Mac and iPad.
- **Density.** Tables with many rows on macOS, settings panes with many labels, dense information when users need it. iPad's `Table` and macOS's multi-column `Table` are honest answers: don't pad them into list-row bloat.
- **Consistency over surprise.** Same visual vocabulary screen to screen is a virtue. Delight is saved for moments: a sensory feedback on completion, an SF Symbol that animates once on success: not pages.
- **Platform idioms over invention.** Cmd-, for Settings on Mac. `.contextMenu` on iPad and Mac. `Menu` in a toolbar on iOS. Swipe actions on `List` rows. Use them: see [reference/ios-vs-macos.md](ios-vs-macos.md) for the platform-by-platform breakdown.
