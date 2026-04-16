# HIG Gap Research

Research for filling 5 specific gaps in the impeccable-swift reference docs.
Each section is written in the `declare → why → rule → anti-pattern` voice of the existing 12 reference docs.
Sources: Apple SwiftUI documentation (developer.apple.com), Human Interface Guidelines.

---

## Gap 1: Haptic Semantic Mapping

### What Apple Says

`SensoryFeedback` (iOS 17+, watchOS 10+) is a value type that maps to UIKit's `UIFeedbackGenerator` family under the hood. The framework groups feedback into three semantic clusters:

**Outcome feedback** — communicates the result of a completed operation. Plays only on iOS and watchOS:

- `.success` — "Indicates that a task or action has completed."
- `.warning` — "Indicates that a task or action has produced a warning of some kind."
- `.error` — "Indicates that an error has occurred."

**Change/selection feedback** — communicates that a value or state is moving:

- `.selection` — "Indicates that a UI element's values are changing." Plays on iOS and watchOS. Equivalent to `UISelectionFeedbackGenerator`.
- `.increase` — "Indicates that an important value increased above a significant threshold." Plays on watchOS and visionOS only (not iOS).
- `.decrease` — "Indicates that an important value decreased below a significant threshold." Plays on watchOS and visionOS only.
- `.alignment` — "Indicates the alignment of a dragged item." Example use: drawing app when shape snaps into alignment with another shape. Plays on iOS and macOS.
- `.levelChange` — "Indicates movement between discrete levels of pressure." Example: fast-forward button reaching a new speed tier. Plays on macOS only.
- `.pathComplete` — "Indicates a drawn path has completed and/or recognized." Plays on iOS only. (iOS 17.5+)

**Physical impact feedback** — provides a physical metaphor to complement a visual experience:

- `.impact` — Base variant. "Use this to provide feedback for UI elements colliding." Plays on iOS and watchOS.
- `.impact(weight:intensity:)` — Weight: `.light`, `.medium` (default), `.heavy`. Intensity: 0.0–1.0. "Not all platforms will play different feedback for different weights and intensities."
- `.impact(flexibility:intensity:)` — Flexibility: `.rigid`, `.solid`, `.soft`. Used when the quality of the collision matters more than the mass.

**Critical platform note:** `.increase` and `.decrease` play only on watchOS/visionOS, not iOS. Attaching them to a UI slider on iPhone fires no feedback. `.levelChange` plays only on macOS (Force Touch trackpad). Never assume all types play on all platforms.

### SwiftUI APIs

```swift
// Outcome
.sensoryFeedback(.success, trigger: didSave)
.sensoryFeedback(.warning, trigger: validationFailed)
.sensoryFeedback(.error, trigger: networkError)

// Selection / change
.sensoryFeedback(.selection, trigger: selectedIndex)
.sensoryFeedback(.alignment, trigger: snapPoint)

// Impact — physical collision
.sensoryFeedback(.impact(weight: .medium), trigger: cardDropped)
.sensoryFeedback(.impact(weight: .light, intensity: 0.7), trigger: isFavorite) { _, new in new }

// Conditional form (fires only when condition returns true)
.sensoryFeedback(.success, trigger: saveCount) { old, new in new > old }
```

### The Rule

**Declare: map haptic type to semantic outcome, not to "this interaction feels important."**

Why: The haptic vocabulary is narrow — outcome (success/warning/error), selection change, and physical collision. Spending `.success` on a button tap that doesn't complete anything meaningful trains users to ignore haptics. The `.selection` type is for continuous value changes (pickers, sliders, drag-to-reorder). `.impact` is for visual objects colliding (card snap, drag-to-slot). Nothing else earns `.impact`.

Rule: One semantic type per interaction. Never stack multiple `sensoryFeedback` modifiers on the same trigger. Use the conditional form `{ old, new in }` when feedback should fire only on one direction of a toggle.

Anti-pattern:

```swift
// WRONG — impact on a simple button tap with no physical metaphor
Button("Save") { save() }
    .sensoryFeedback(.impact, trigger: saveCount)

// WRONG — success on every state toggle regardless of outcome
.sensoryFeedback(.success, trigger: isExpanded)

// CORRECT — success only when an async operation completes affirmatively
.sensoryFeedback(.success, trigger: uploadComplete) { _, new in new == true }
.sensoryFeedback(.error, trigger: uploadError) { _, new in new != nil }
```

---

## Gap 2: Modal Depth (Max 2 Levels)

### What Apple Says

**HIG position on modal depth:** Apple's Human Interface Guidelines explicitly state that apps should avoid presenting too many modals stacked on top of each other. The HIG rule is: never present a modal view on top of another modal view unless absolutely necessary. The canonical guidance is a maximum of one modal layer at a time — two is the outer limit, and only for clearly separated contexts (e.g., a share sheet triggered from inside a compose sheet).

**Sheet vs. fullScreen cover distinction** (from SwiftUI docs):

- `.sheet` — the standard modal. Partially covers the presenting view. The user can see (and be reminded of) the context behind the sheet. Supports `presentationDetents` for resizable sheets.
- `.fullScreenCover` — "Presents a modal view that covers as much of the screen as possible." Completely hides the presenting context. No swipe-to-dismiss by default. Requires an explicit dismiss mechanism.

The HIG guidance on when to use each:

- Use `.sheet` when: the task is self-contained but the user should retain awareness of context (settings panel, quick compose, filter picker).
- Use `.fullScreenCover` when: the content requires total visual focus, the experience is immersive (camera, onboarding, media playback fullscreen), or the action represents a complete context switch with no path back via swipe.

**Sheet sizing — `presentationDetents`** (iOS 16+):
By default, sheets use the `.large` detent (full height minus the safe area top). `presentationDetents([.medium, .large])` allows the user to drag between half-height and full-height. The `.medium` detent is approximately half the screen.

HIG guidance on detents: use `.medium` when the sheet's primary content fits in half the screen without scrolling — forcing a user to scroll inside a `.medium` sheet that should be `.large` is a friction error. If the content is complex or tall, default to `.large` or offer both and let the user resize.

### SwiftUI APIs

```swift
// Sheet — contextual task, user retains background awareness
.sheet(isPresented: $showCompose) {
    ComposeView()
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
}

// fullScreenCover — immersive, complete context switch
.fullScreenCover(isPresented: $showCamera) {
    CameraView()
}

// WRONG — sheet on top of sheet
.sheet(isPresented: $showProfile) {
    ProfileView()
        .sheet(isPresented: $showEditAvatar) { // Second modal layer — violates HIG
            AvatarEditor()
        }
}
```

### The Rule

**Declare: one modal layer at a time. Never present a sheet from inside a sheet. Use `fullScreenCover` only for immersive context switches, not to avoid thinking about sheet sizing.**

Why: Modal stacks break the mental model of "I can go back." A user inside a second-level sheet has no reliable gesture to dismiss both — swiping dismisses only the top sheet, leaving them stranded in the first. The system's back-navigation (swipe-to-dismiss) doesn't cascade. The user is trapped.

Rule: Maximum one active modal at a time. If you need sub-navigation inside a sheet, push onto a `NavigationStack` inside the sheet — don't present another `.sheet`. Reserve `.fullScreenCover` for genuinely immersive experiences (camera, media player, onboarding). If you find yourself reaching for `.fullScreenCover` to show a form, use `.sheet` with `.large` detent instead.

Anti-pattern:

```swift
// WRONG — sheet presenting sheet
ProfileView()
    .sheet(isPresented: $showEditAvatar) {
        AvatarEditor()  // Stacked modal — user is now 2 levels deep
    }

// WRONG — fullScreenCover for a simple settings panel
.fullScreenCover(isPresented: $showSettings) {
    SettingsView()  // No reason to cover the full screen — use .sheet
}

// CORRECT — NavigationStack inside sheet for sub-tasks
.sheet(isPresented: $showProfile) {
    NavigationStack {
        ProfileView()
            .navigationDestination(for: ProfileRoute.self) { route in
                view(for: route)  // Push, don't modal
            }
    }
}
```

---

## Gap 3: Accessibility

### 3a. accessibilityLabel vs. accessibilityHint

**What Apple says:**

`.accessibilityLabel` — "Adds a label to the view that describes its contents." Use when the view has no visible text, or the visible text is insufficient (an icon, a graphic, a custom control). The label IS the name of the element — VoiceOver reads it as the primary identification. **Do not include the element type** in the label ("Play button" is wrong because VoiceOver announces "button" automatically from the trait). **Do not include interaction instructions** in the label.

`.accessibilityHint` — "Communicates to the user what happens after performing the view's action." Written as a brief phrase: "Purchases the item" or "Downloads the attachment." The hint is optional context about the _outcome_ of the action. **VoiceOver automatically adds "double tap to activate"** — never include that phrase in a hint. Users can disable hints in accessibility settings; labels cannot be disabled. This means: if information is essential to using the control, it belongs in the label, not the hint.

**The distinction:**

- Label = what is this thing? (noun phrase or short identifier)
- Hint = what happens when you activate it? (verb phrase describing outcome)

**What NOT to include:**

- Do not include the element type in the label ("Play button" → just "Play")
- Do not include interaction instructions in the hint ("double tap to play" → just "Plays the track")
- Do not repeat the label content in the hint ("Play. Plays." is redundant)
- Do not add a hint to trivially obvious buttons (a "Cancel" button needs no hint)

### SwiftUI APIs

```swift
// Icon button — needs a label, the icon name means nothing to VoiceOver
Button(action: togglePlay) {
    Image(systemName: isPlaying ? "pause.fill" : "play.fill")
}
.accessibilityLabel(isPlaying ? "Pause" : "Play")
// No hint needed — outcome is obvious from label

// Non-obvious action — label + hint
Button(action: archiveMessage) {
    Image(systemName: "archivebox")
}
.accessibilityLabel("Archive")
.accessibilityHint("Moves the message to your archive")

// WRONG
Button(action: togglePlay) {
    Image(systemName: "play.fill")
}
.accessibilityLabel("Play button")           // "button" is already announced
.accessibilityHint("Double tap to play")     // VoiceOver says this automatically
```

### 3b. accessibilityElement(children:) — combine vs. ignore

**What Apple says:**

`.accessibilityElement(children: .combine)` — "Any child accessibility element's properties are merged into the new accessibility element." Use when you want a cluster of related views (image + name + subtitle) to read as one unit. The system merges labels, values, and traits from all non-hidden children. Some traits are not merged (e.g. a `Button` inside a combined group may become a named action rather than a button trait on the container).

`.accessibilityElement(children: .ignore)` — "Any child accessibility elements become hidden." The parent becomes a single element with no initial properties — you must add label, value, traits, and actions manually. "Before using the `ignore` behavior, consider using the `combine` behavior." Use `.ignore` when combining would produce incoherent output (e.g., a custom slider where the child labels are internal implementation details, not meaningful to the user).

`.accessibilityElement(children: .contain)` — a third option; makes the container an accessibility element that also contains its children as separate focusable elements. Use for containers that logically group elements without merging them.

### SwiftUI APIs

```swift
// .combine — card with image + name + detail, should read as one item
struct ContactCard: View {
    var contact: Contact
    var body: some View {
        HStack {
            AsyncImage(url: contact.avatar)
                .accessibilityHidden(true)  // Image is decorative; name covers it
            VStack(alignment: .leading) {
                Text(contact.name).font(.headline)
                Text(contact.role).font(.subheadline).foregroundStyle(.secondary)
            }
        }
        .accessibilityElement(children: .combine)
        // VoiceOver reads: "Sarah Kim, Designer" as one focusable element
    }
}

// .ignore — custom stepper where child structure is implementation detail
VStack {
    Button("−") { decrement() }
    Text("\(value)")
    Button("+") { increment() }
}
.accessibilityElement(children: .ignore)
.accessibilityLabel("Quantity")
.accessibilityValue("\(value)")
.accessibilityAdjustableAction { direction in
    if direction == .increment { increment() }
    else { decrement() }
}
```

Anti-pattern:

```swift
// WRONG — .ignore without adding required semantics
HStack { Image(...); Text(user.name) }
    .accessibilityElement(children: .ignore)
// VoiceOver focuses on this element and says nothing — label is missing

// WRONG — no grouping on a card, every sub-element is focusable
// Result: VoiceOver traverses avatar image, name text, role text as 3 separate stops
```

### 3c. accessibilityAddTraits / accessibilityRemoveTraits

**What Apple says:**

`AccessibilityTraits` describes how an element _behaves_, not what it looks like. SwiftUI's built-in controls set their traits automatically — `Button` gets `.isButton`, `Toggle` gets `.isButton` + `.isToggle`, `Text` gets `.isStaticText`. Custom views built from `View` primitives have no traits by default.

Key traits:

- `.isButton` — element performs an action on activation
- `.isHeader` — landmark for navigation; VoiceOver lets users jump between headers
- `.isSelected` — element is currently selected (tab bar item, segmented control segment)
- `.isImage` — element is an image (decorative images should use `.accessibilityHidden(true)` instead)
- `.isModal` — element is presented modally; VoiceOver should not navigate outside it
- `.updatesFrequently` — content changes often (a timer, live score); VoiceOver throttles updates
- `.isLink` — element navigates to a URL or external resource
- `.allowsDirectInteraction` — element accepts direct touch input (a drawing canvas, piano keyboard)

Use `.accessibilityAddTraits` when a custom view needs behavior traits its base type doesn't provide (e.g., a `VStack` acting as a button). Use `.accessibilityRemoveTraits` when SwiftUI adds a trait that doesn't apply (e.g., a `Button` styled to look like a header — remove `.isButton` if you're also adding `.isHeader`, to prevent double-announcement).

### SwiftUI APIs

```swift
// Custom tappable row — needs .isButton
HStack { Text(item.name); Spacer(); Image(systemName: "chevron.right") }
    .contentShape(Rectangle())
    .onTapGesture { select(item) }
    .accessibilityAddTraits(.isButton)
    .accessibilityLabel(item.name)

// Section header — mark as landmark
Text("Upcoming")
    .font(.headline)
    .accessibilityAddTraits(.isHeader)

// Tab item — selected state
Button(action: { selectedTab = .home }) {
    Label("Home", systemImage: "house")
}
.accessibilityAddTraits(selectedTab == .home ? .isSelected : [])

// Live updating label — throttle VoiceOver announcements
Text(timerDisplay)
    .accessibilityAddTraits(.updatesFrequently)
```

Anti-pattern:

```swift
// WRONG — custom tappable view with no traits
// VoiceOver focuses on it, reads the label, gives no affordance hint
ZStack { ... }
    .onTapGesture { open() }
// VoiceOver users don't know this is interactive
```

### 3d. Reduce Motion

**What Apple says:**

`@Environment(\.accessibilityReduceMotion)` returns `true` when the user has enabled Settings → Accessibility → Motion → Reduce Motion.

Apple's official guidance: "UI should avoid large animations, especially those that simulate the third dimension." The scope is broader than just 3D — any large spatial movement (slide transitions, scale reveals, parallax, expanding cards that grow from a point) qualifies. Vestibular disorders cause nausea and dizziness from visual motion that triggers the brain's balance system.

What to eliminate when reduceMotion is true:

- All `.transition(.slide)`, `.transition(.move)`, `.transition(.scale)` — replace with `.opacity`
- Scale effects that grow/shrink views across their full size range
- Parallax and depth effects (`.rotation3DEffect`, perspective transforms)
- Continuous looping animations that aren't informational (ambient motion, floating elements)

What to keep (these carry information, not just decoration):

- `ProgressView` and loading spinners — slow them down but keep them visible
- Focus rings and selection indicators
- Short opacity cross-fades (duration ≤ 0.2s)
- Scroll position changes triggered by user gesture (the user controls these)

Related environment values:

- `accessibilityPlayAnimatedImages` — if false, stop animated images (GIFs, Lottie)
- `accessibilityDimFlashingLights` — if true, dim content that flashes rapidly

### SwiftUI APIs

```swift
struct AnimatedCard: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isExpanded = false

    var body: some View {
        CardContent()
            .scaleEffect(isExpanded ? 1.0 : 0.95)
            .animation(
                reduceMotion
                    ? .easeInOut(duration: 0.15)   // Opacity only — strip scale
                    : .spring(response: 0.4, dampingFraction: 0.8),
                value: isExpanded
            )
    }
}

// Transition — slide out when reduce motion is off, fade when on
if showBanner {
    BannerView()
        .transition(reduceMotion
            ? .opacity
            : .asymmetric(insertion: .move(edge: .top).combined(with: .opacity),
                          removal: .opacity))
}
```

Anti-pattern:

```swift
// WRONG — spatial animation with no reduce-motion check
Text("Welcome")
    .transition(.move(edge: .leading).combined(with: .opacity))
// This slides in from the left regardless of the user's motion preference
```

### 3e. Reduce Transparency

**What Apple says:**

`@Environment(\.accessibilityReduceTransparency)` returns `true` when the user has enabled Settings → Accessibility → Display & Text Size → Reduce Transparency.

"If this property's value is true, UI (mainly window) backgrounds should not be semi-transparent; they should be opaque."

The practical implication: `.ultraThinMaterial`, `.thinMaterial`, `.regularMaterial`, and any custom translucent fill need an opaque fallback. Semi-transparent surfaces reduce contrast. Users who set Reduce Transparency need full opacity backgrounds to read overlaid text.

### SwiftUI APIs

```swift
struct CardBackground: View {
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    var body: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(reduceTransparency
                ? Color(.systemBackground)           // Opaque fallback
                : Material.ultraThinMaterial)         // Translucent default
    }
}

// Or with the ternary directly on the background modifier:
content
    .background(reduceTransparency
        ? AnyShapeStyle(Color(.systemBackground))
        : AnyShapeStyle(Material.regularMaterial))
```

Anti-pattern:

```swift
// WRONG — material with no fallback
content.background(Material.ultraThinMaterial)
// Fails for users with Reduce Transparency — text over a blurred background may be unreadable
```

### 3f. Switch Control Layout Expectations

Switch Control is Apple's full-device scanning input method. Users with motor impairments use a single switch to cycle through interactive elements and activate them. The traversal order follows the accessibility focus order, which defaults to reading order (top-to-bottom, leading-to-trailing).

Key rules for Switch Control compatibility:

- Interactive elements must be reachable in logical order — don't rely on visual proximity to imply relationship
- `.accessibilityElement(children: .contain)` groups elements so Switch Control can step into a group deliberately rather than scanning all children at the top level
- `.accessibilitySortPriority(_:)` adjusts the order when the visual layout doesn't match the logical interaction order (e.g., a primary action that appears at the bottom should be reachable before secondary actions)
- Hidden elements (`opacity(0)`, `frame(width: 0, height: 0)`) are still focusable by Switch Control unless explicitly hidden with `.accessibilityHidden(true)`

```swift
// Ensure hidden-but-present elements don't pollute the focus order
HiddenFormHelper()
    .frame(width: 0, height: 0)
    .accessibilityHidden(true)

// Prioritize the primary CTA in Switch Control scanning
VStack {
    SecondaryActions()       // Visually first
    PrimaryCallToAction()    // Visually below, but logically primary
        .accessibilitySortPriority(1)  // Scanned first
}
```

---

## Gap 4: presentationCompactAdaptation

### What Apple Says

`.popover` on SwiftUI automatically adapts on iPhone (horizontally compact size class): by default it becomes a `.sheet`. This is the correct HIG behavior — popovers require a large enough canvas to anchor to their source without covering the whole screen. On iPhone, that canvas doesn't exist.

`.presentationCompactAdaptation(_:)` (iOS 16.4+) controls this behavior explicitly. It takes a `PresentationAdaptation` value:

- `.automatic` — use the platform's default adaptation (popover → sheet on compact)
- `.none` — "Don't adapt for the size class, if possible." The popover stays a popover even on iPhone. Use sparingly; the popover may not have enough room to display correctly.
- `.sheet` — explicitly adapt to a sheet in compact environments
- `.fullScreenCover` — explicitly adapt to a full-screen cover in compact environments
- `.popover` — force popover presentation even in compact environments

There is also `presentationCompactAdaptation(horizontal:vertical:)` for separate horizontal vs. vertical compact control.

**When to use `.presentationCompactAdaptation`:**

- Use `.none` when the popover content is small (a color picker, an emoji selector) and the layout genuinely fits on iPhone without adaptation
- Use `.sheet` explicitly when you need the compact presentation to behave like a detented sheet (so you can apply `presentationDetents` to the compact version)
- Never use `.none` for content-heavy popovers that require scrolling — the system needs the sheet presentation for that content to be accessible

From the SwiftUI docs, the canonical example:

```swift
.sheet(isPresented: $showSettings) {
    SettingsView()
        .presentationDetents([.medium, .large])
        .presentationCompactAdaptation(.none)
}
```

This forces a detented sheet to stay as a sheet even in compact vertical (landscape iPhone) instead of expanding to full-screen cover.

### SwiftUI APIs

```swift
// Popover that stays a popover on iPhone (suitable only for small, contained content)
Button("Picker") { showPicker = true }
    .popover(isPresented: $showPicker) {
        ColorPickerContent()
            .frame(width: 280, height: 320)
            .presentationCompactAdaptation(.none)
    }

// Popover that explicitly becomes a sheet on iPhone (with detent control)
Button("Filter") { showFilter = true }
    .popover(isPresented: $showFilter) {
        FilterPanel()
            .presentationDetents([.medium, .large])
            .presentationCompactAdaptation(.sheet)
    }

// Different adaptations per dimension
.presentationCompactAdaptation(horizontal: .sheet, vertical: .none)
```

### The Rule

**Declare: popovers adapt to sheets on iPhone by default — control this explicitly with `presentationCompactAdaptation` when the default behavior is wrong, not to suppress adaptation on content that needs it.**

Why: The default `.automatic` adaptation (popover → sheet on compact) exists because popovers anchored to a source point work on iPad where there's room; on iPhone there isn't. Overriding with `.none` on a large popover creates a UI that partially covers content, has no clear dismiss gesture, and may clip content. `.none` is for genuinely small self-contained panels only.

Anti-pattern:

```swift
// WRONG — suppressing adaptation on a content-heavy popover
.popover(isPresented: $showFullMenu) {
    FullMenuView()          // Long scrollable content
        .presentationCompactAdaptation(.none)  // Now broken on iPhone
}

// WRONG — not specifying adaptation when default produces wrong behavior
// Detented sheet expanding to full-screen cover on landscape iPhone is jarring
.sheet(isPresented: $showFilter) {
    FilterPanel()
        .presentationDetents([.medium, .large])
        // Missing: .presentationCompactAdaptation(.none) to prevent full-cover on landscape
}
```

---

## Gap 5: Dynamic Type Scale Reference

### What Apple Says

Dynamic Type is a system-wide setting that scales text across 7 standard sizes (xSmall through xxxLarge) and 5 accessibility sizes (Accessibility1 through Accessibility5). The accessibility sizes are roughly 1.5–3× the standard xxxLarge. Every semantic text style scales on this curve.

**Full text style table — default (Large) sizes and semantic purpose:**

| SwiftUI Style  | Default Size | Weight   | Semantic Purpose                                                    |
| -------------- | ------------ | -------- | ------------------------------------------------------------------- |
| `.largeTitle`  | 34pt         | Regular  | Top-of-screen primary title. Navigation bar large title mode.       |
| `.title`       | 28pt         | Regular  | First-level hierarchical heading within a view.                     |
| `.title2`      | 22pt         | Regular  | Second-level heading.                                               |
| `.title3`      | 20pt         | Regular  | Third-level heading, subpage titles.                                |
| `.headline`    | 17pt         | Semibold | List row primary label, card header. The semibold body-scale style. |
| `.body`        | 17pt         | Regular  | Primary reading text. The default style for most content.           |
| `.callout`     | 16pt         | Regular  | Slightly smaller body. Secondary content in cards, sidebars.        |
| `.subheadline` | 15pt         | Regular  | Supporting text under a headline. Metadata rows.                    |
| `.footnote`    | 13pt         | Regular  | Supplementary info, timestamps, source attribution.                 |
| `.caption`     | 12pt         | Regular  | Image captions, form field labels below inputs.                     |
| `.caption2`    | 11pt         | Regular  | The smallest style. Use sparingly — badges, micro-labels.           |

Note: `.headline` and `.body` render at the same 17pt default size — they differ only in weight (semibold vs. regular). Use `.headline` for structural emphasis at body scale, never for both in the same hierarchy context without visual distinction.

WatchOS and visionOS have their own size curves. The table above is for iOS.

**Accessibility sizes:** At Accessibility5 (the maximum), `.largeTitle` reaches approximately 56pt and `.caption2` reaches approximately 20pt. Layouts must accommodate this range. Use `ScrollView` wrappers for content that will overflow, and never assume text fits in a fixed-height container.

**`@ScaledMetric` for custom values** — when a design needs a size not in the style table:

```swift
@ScaledMetric(relativeTo: .body) private var iconSize: CGFloat = 20
// Scales at the same rate as .body — stays proportionally correct at all DT sizes
```

**Clamping Dynamic Type** — `dynamicTypeSize` environment value or `.dynamicTypeSize(_:)` modifier. Use only when a specific layout genuinely breaks at extreme sizes:

```swift
NavigationBar()
    .dynamicTypeSize(...DynamicTypeSize.accessibility2)  // Cap at A2, not the full range
```

Never clamp the entire app. The user set their size preference for a reason — global clamping is an accessibility violation.

### Single-line labels that can't wrap

When a label must stay on one line (navigation bar title, tab label, compact metric):

**`.minimumScaleFactor(_:)`** — "Sets the minimum amount that text in this view scales down to fit in the available space." Pass a fraction (0.5 = can shrink to 50% of the current font size). The text shrinks to fit before truncating.

**`.lineLimit(1)` + `.truncationMode(.tail)`** — hard cap to one line; truncate with "…" at the end. Use when shrinking below ~0.7× produces illegible text.

**The discipline:** `.minimumScaleFactor(0.75)` is a reasonable floor for most single-line labels. Below 0.75 the text is unreadably small at normal accessibility sizes. Always pair `lineLimit` with `minimumScaleFactor` — without `lineLimit`, `minimumScaleFactor` has no effect (the text just wraps).

### SwiftUI APIs

```swift
// Semantic style usage — correct hierarchy
VStack(alignment: .leading, spacing: 4) {
    Text("Today's Summary").font(.title2)         // Section title
    Text("3 tasks completed").font(.headline)      // Primary stat (semibold body)
    Text("Last updated 2 min ago").font(.caption)  // Metadata
}

// Single-line label that must not wrap
Text(item.name)
    .font(.subheadline)
    .lineLimit(1)
    .minimumScaleFactor(0.75)
    .truncationMode(.tail)

// Custom size that scales with body
struct RatingBadge: View {
    @ScaledMetric(relativeTo: .caption) private var badgeSize: CGFloat = 18

    var body: some View {
        Circle()
            .frame(width: badgeSize, height: badgeSize)
    }
}
```

### The Rule

**Declare: assign text styles by semantic role, not by desired output size. If you know the pixel size you want but not the semantic role, you're doing it wrong.**

Why: The semantic style encodes two things: the scale curve AND the role in the information hierarchy. `.caption2` isn't just "11pt text" — it's "the least important text in a view, which the system will scale to remain readable." Using `.font(.system(size: 11))` for the same role breaks Dynamic Type and removes the accessibility contract.

Anti-pattern:

```swift
// WRONG — hardcoded size for all the wrong reasons
Text("New").font(.system(size: 10, weight: .semibold))  // Tiny badge label
// At Accessibility3, this is still 10pt while surrounding body text is 30pt

// CORRECT — semantic style scales proportionally
Text("New")
    .font(.caption2.weight(.semibold))
    .lineLimit(1)
    .minimumScaleFactor(0.8)

// WRONG — using .title where .headline is meant
Text("Due Today")
    .font(.title)  // Intended as a section label inside a list, not a screen title
// Creates false heading hierarchy

// WRONG — clamping the whole app
ContentView()
    .environment(\.dynamicTypeSize, .large)  // Forces everyone to Large — ignores user preference
```
