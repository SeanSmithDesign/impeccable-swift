# Accessibility

Accessibility on Apple platforms is a first-class runtime — not a post-launch checklist item. VoiceOver, Switch Control, Dynamic Type, Reduce Motion, and Reduce Transparency are all user preferences that affect your app at any time. Build for them from the start or audit against them every release.

## accessibilityLabel vs. accessibilityHint

**Declare: every interactive element with no visible text gets an `.accessibilityLabel`. Use `.accessibilityHint` only when the outcome of the action is not obvious from the label alone.**

**Why:** VoiceOver reads the label as the primary identification of a control — it's the name. The hint is optional supplementary context about what happens when the control fires. Users can turn hints off in Settings → Accessibility → VoiceOver → Verbosity. If critical information lives in the hint, some users never hear it. Put essential identification in the label; the hint is for non-obvious outcomes only.

**What NOT to include:**

- Don't include the element type in the label ("Play button" is wrong — VoiceOver announces "button" automatically from the trait)
- Don't include interaction instructions in the hint ("Double tap to play" is wrong — VoiceOver prepends this automatically, producing "double tap to double tap to play")
- Don't repeat the label in the hint ("Play. Plays the track." — the first word is already read)
- Don't add a hint to trivially obvious buttons — "Cancel" needs no hint

```swift
// Icon-only button — needs a label, systemName is meaningless to VoiceOver
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
```

**Anti-pattern — "The Redundant Hint":**

```swift
Button(action: togglePlay) {
    Image(systemName: "play.fill")
}
.accessibilityLabel("Play button")       // "button" is already announced
.accessibilityHint("Double tap to play") // VoiceOver already says this — produces double-announcement
```

## accessibilityElement(children:) — Combine Before Ignore

**Declare: use `.accessibilityElement(children: .combine)` to merge related views into one focusable unit. Reach for `.ignore` only when combining would produce incoherent output, and only after adding the required semantics manually.**

**Why:** VoiceOver traverses every accessible leaf in the hierarchy by default. A card with an avatar, name, and subtitle becomes three separate focus stops. `.combine` merges them into one — the user hears "Sarah Kim, Designer" as one element and moves on. `.ignore` silences all children and leaves the parent a blank slate — useful for custom controls whose internal structure is an implementation detail, but dangerous if you forget to provide the label yourself.

Three values:

- `.combine` — merges children into the parent element. Children's labels, values, and traits are combined. Default choice for composite views.
- `.ignore` — hides all children. You own all semantics from here. Use for custom controls (steppers, sliders, canvases) where child structure is meaningless to VoiceOver.
- `.contain` — makes the container accessible while keeping children separately focusable. Use for logical groupings where each child still needs to be reachable individually.

```swift
// .combine — card reads as one item
struct ContactCard: View {
    var contact: Contact
    var body: some View {
        HStack {
            AsyncImage(url: contact.avatar)
                .accessibilityHidden(true)  // Decorative — name text covers its content
            VStack(alignment: .leading) {
                Text(contact.name).font(.headline)
                Text(contact.role).font(.subheadline).foregroundStyle(.secondary)
            }
        }
        .accessibilityElement(children: .combine)
        // VoiceOver reads: "Sarah Kim, Designer"
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

**Anti-pattern — "The Silent .ignore":**

```swift
// WRONG — .ignore without adding the required semantics
HStack { Image(...); Text(user.name) }
    .accessibilityElement(children: .ignore)
// VoiceOver focuses here and reads nothing — the element exists but has no identity
```

## Traits — Tell VoiceOver How Elements Behave

**Declare: every custom interactive view that isn't a native SwiftUI control adds `.accessibilityAddTraits` to declare its behavior.** A `VStack` used as a button is invisible to VoiceOver unless you tell it otherwise.

**Why:** SwiftUI's built-in controls set their traits automatically — `Button` gets `.isButton`, `Toggle` gets `.isToggle`. Views built from layout primitives (`HStack`, `ZStack`, `VStack`) have no traits and appear to VoiceOver as inert text. Missing traits mean users don't know the element is interactive and won't know to double-tap it.

Key traits:

| Trait                      | Use when                                                                       |
| -------------------------- | ------------------------------------------------------------------------------ |
| `.isButton`                | A custom tappable view performs an action                                      |
| `.isHeader`                | A text label acts as a section landmark (VoiceOver users jump between headers) |
| `.isSelected`              | An element is in a selected state (tab bar item, segmented control segment)    |
| `.isModal`                 | A view is presented modally — VoiceOver should not navigate outside it         |
| `.updatesFrequently`       | Content changes often — VoiceOver throttles updates (timers, live scores)      |
| `.isLink`                  | Element navigates to a URL or external resource                                |
| `.allowsDirectInteraction` | Element accepts raw touch (drawing canvas, piano keyboard)                     |

```swift
// Custom tappable row — needs .isButton
HStack { Text(item.name); Spacer(); Image(systemName: "chevron.right") }
    .contentShape(Rectangle())
    .onTapGesture { select(item) }
    .accessibilityAddTraits(.isButton)
    .accessibilityLabel(item.name)

// Section header — VoiceOver rotor landmark
Text("Upcoming")
    .font(.headline)
    .accessibilityAddTraits(.isHeader)

// Tab item — communicate selected state
Button(action: { selectedTab = .home }) {
    Label("Home", systemImage: "house")
}
.accessibilityAddTraits(selectedTab == .home ? .isSelected : [])

// Live-updating timer — prevent VoiceOver from reading every tick
Text(timerDisplay)
    .accessibilityAddTraits(.updatesFrequently)
```

**Anti-pattern — "The Invisible Interaction":**

```swift
// WRONG — custom tappable view with no traits
ZStack { backgroundShape; contentLabel }
    .onTapGesture { open() }
// VoiceOver focuses here, reads the label, gives no hint this is interactive.
// Users who rely on VoiceOver will not know to double-tap.
```

## Reduce Motion

**Declare: check `@Environment(\.accessibilityReduceMotion)` and eliminate spatial translations, scale reveals, and parallax when it's true.** Replace with short opacity cross-fades.

**Why:** Vestibular disorders cause nausea and disorientation from visual motion that simulates three-dimensional movement. This is a real medical condition — it's not a preference for "less flashy animations." Sliding transitions, expanding cards that grow from a point, and parallax depth effects are the primary triggers. These are exactly the animations designers reach for by default.

**What to eliminate when reduceMotion is true:**

- `.transition(.slide)`, `.transition(.move)`, `.transition(.scale)` — replace with `.transition(.opacity)`
- Scale effects that grow/shrink views across their full range
- Parallax, `.rotation3DEffect`, perspective transforms
- Continuous ambient motion (floating elements, breathing animations)

**What to keep (these carry information, not just decoration):**

- `ProgressView` and loading spinners — slow them if needed, keep them visible
- Focus rings and selection indicators
- Short opacity cross-fades (≤ 0.2s)
- Scroll position changes triggered by user gesture

Related environment values: `accessibilityPlayAnimatedImages` (stop GIFs/Lottie when false), `accessibilityDimFlashingLights` (dim rapidly flashing content when true).

```swift
struct AnimatedCard: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isExpanded = false

    var body: some View {
        CardContent()
            .scaleEffect(isExpanded ? 1.0 : 0.95)
            .animation(
                reduceMotion
                    ? .easeInOut(duration: 0.15)
                    : .spring(response: 0.4, dampingFraction: 0.8),
                value: isExpanded
            )
    }
}

// Transition — slide when motion is fine, fade when reduced
if showBanner {
    BannerView()
        .transition(reduceMotion
            ? .opacity
            : .asymmetric(
                insertion: .move(edge: .top).combined(with: .opacity),
                removal: .opacity))
}
```

**Anti-pattern — "The Unconditional Slide":**

```swift
// WRONG — spatial animation with no reduce-motion check
Text("Welcome")
    .transition(.move(edge: .leading).combined(with: .opacity))
// This slides regardless of vestibular sensitivity
```

## Reduce Transparency

**Declare: every view using `.ultraThinMaterial`, `.thinMaterial`, `.regularMaterial`, or any custom translucent fill provides an opaque fallback when `accessibilityReduceTransparency` is true.**

**Why:** Semi-transparent surfaces reduce the contrast between background content and overlaid text. Users who enable Reduce Transparency have indicated their visual system requires full-opacity backgrounds. A translucent card with `.ultraThinMaterial` that looks elegant at default settings may render overlaid text unreadable at high contrast or Reduce Transparency settings.

```swift
struct CardBackground: View {
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    var body: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(reduceTransparency
                ? Color(.systemBackground)    // Opaque fallback
                : Material.ultraThinMaterial) // Translucent default
    }
}

// Inline shorthand with AnyShapeStyle
content
    .background(reduceTransparency
        ? AnyShapeStyle(Color(.systemBackground))
        : AnyShapeStyle(Material.regularMaterial))
```

**Anti-pattern — "The Material Without a Fallback":**

```swift
// WRONG — no fallback
content.background(Material.ultraThinMaterial)
// Text over blurred content may be unreadable with Reduce Transparency enabled
```

## Switch Control Layout

**Declare: ensure every interactive element is reachable in logical order, every hidden-but-present element is explicitly hidden from accessibility, and primary actions are sorted before secondary ones.**

**Why:** Switch Control users traverse the entire interface using a single switch — they scan through every focusable element in order and activate when they reach the target. An element they can't reach, or a decorative element they have to skip through, multiplies their interaction cost by every element in the way.

Rules:

- Use `.accessibilityElement(children: .contain)` to let Switch Control step into a group deliberately rather than scanning all children at the root level
- Use `.accessibilitySortPriority(_:)` when the primary action appears visually below secondary actions — higher values scan first
- Zero-size or invisible elements (`frame(width: 0, height: 0)`, `opacity(0)`) are still focusable unless explicitly hidden with `.accessibilityHidden(true)`

```swift
// Hidden implementation helper — must be explicitly excluded from focus order
HiddenFormHelper()
    .frame(width: 0, height: 0)
    .accessibilityHidden(true)

// Primary CTA below secondary actions visually — promote it in scan order
VStack {
    SecondaryActions()
    PrimaryCallToAction()
        .accessibilitySortPriority(1)  // Scanned first despite being visually lower
}
```

---

**Avoid:** Missing `.accessibilityLabel` on icon-only controls. Including "button" or "double tap" in labels and hints. Using `.accessibilityElement(children: .ignore)` without adding label, value, and traits. Spatial animations without `accessibilityReduceMotion` checks. Material surfaces without `accessibilityReduceTransparency` fallbacks. Zero-size elements in the focus order.
