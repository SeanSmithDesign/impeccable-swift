# Motion Design

Motion on Apple platforms is a spring-first system. Stop reaching for CSS reflexes — no `cubic-bezier`, no `transition: all 300ms ease`. Use SwiftUI's `.animation(_:value:)`, `withAnimation`, and `.transition()` against physical curves.

## Duration: The 100/300/500 Rule

Timing matters more than easing. These durations are non-negotiable for UI work:

| Duration      | Use Case            | Examples                                     |
| ------------- | ------------------- | -------------------------------------------- |
| **100–150ms** | Instant feedback    | Button press, toggle, selection highlight    |
| **200–300ms** | State changes       | Menu open, popover, hover-equivalent state   |
| **300–500ms** | Layout changes      | Sheet presentation, disclosure group, drawer |
| **500–800ms** | Entrance animations | Launch, hero reveal, onboarding step         |

Exit animations run at ~75% of entrance duration. Anything over 400ms on a state change reads as jank — the user has already moved on. Micro-interactions under 200ms, transitions 200–400ms, beyond that is dead time.

**Anti-pattern: programmer linear easing.** `.animation(.linear, value: ...)` on a state change reads as "nobody thought about this." Linear is for progress indicators and infinite loops, never for UI state.

## Springs Over Curves

Use springs for anything interactive. They encode physics the user already understands — mass, stiffness, damping — so motion feels like it's reacting to the gesture, not playing back a recording. This is the Swift-native default; it is not negotiable for touch-driven UI.

```swift
// The default. Snappy, settles quickly, reads as "native."
.animation(.spring(response: 0.35, dampingFraction: 0.8), value: isExpanded)

// Slightly softer — sheets, drawers, content reveals.
.animation(.smooth(duration: 0.4), value: isPresented)

// Playful but controlled — success states, celebratory beats.
.animation(.bouncy(duration: 0.5, extraBounce: 0.1), value: didSucceed)

// Interactive gesture tracking — follows the finger, settles on release.
.animation(.interactiveSpring(response: 0.28, dampingFraction: 0.86), value: dragOffset)
```

Reach for `.easeOut` only when you need strict timing for orchestrated sequences. `.easeInOut` belongs on there-and-back toggles. Never use a curve when a spring would do — the spring adapts to interruptions (tap during animation) while the curve restarts awkwardly.

**Anti-pattern: bouncy-everything.** `.bouncy` on every state change was trendy in 2015 and now reads as amateur. Real objects decelerate; they don't wobble to a stop. Use bounce sparingly — one or two celebratory moments per app, max.

## Reduce Motion Is Non-Negotiable

Vestibular disorders affect ~35% of adults over 40. Every non-trivial animation — anything involving translation, scale, rotation, or parallax — wraps in a reduce-motion check or degrades to a cross-fade. This is not optional polish; it is a hard rule.

```swift
struct ExpandingCard: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isExpanded = false

    var body: some View {
        CardContent()
            .scaleEffect(isExpanded ? 1.0 : 0.95)
            .opacity(isExpanded ? 1 : 0)
            .animation(
                reduceMotion
                    ? .easeInOut(duration: 0.2)   // Cross-fade only
                    : .spring(response: 0.4, dampingFraction: 0.8),
                value: isExpanded
            )
    }
}
```

When reduce-motion is on: strip the translation, keep the opacity. Progress indicators and spinners stay — they carry information — but slow them down. Focus rings and selection highlights stay crisp because they communicate system state, not spatial movement.

**Anti-pattern: ignoring `accessibilityReduceMotion`.** If the audit flags a `.transition(.slide)` or `.scaleEffect` without an environment check, it's broken. No exceptions.

## Animate the Cheap Properties

SwiftUI's render pipeline handles opacity, transform (scale/rotation/offset), and color interpolation cheaply. Frame and position animations are fine at the SwiftUI layer, but animating expensive modifiers (shadow radius, blur radius, gradient stops) in a tight loop will drop frames. If you need a shadow to animate, animate its opacity or use two shadow layers and cross-fade.

For list and stack reordering, use `.animation(_:value:)` on the collection, not per-row animation blocks — the latter guarantees spring-stacking (below).

## Anti-pattern: Spring-Stacking

Nested `withAnimation` calls compete. The outer spring wants to drive one value; the inner spring grabs a child and drives it on a different timeline. Result: visual drift, janky settle, interruption bugs.

```swift
// BROKEN — don't do this
withAnimation(.spring(response: 0.4)) {
    isOpen = true
    withAnimation(.spring(response: 0.2)) {  // Competes with outer
        childScale = 1.1
    }
}

// CORRECT — one animation context, one curve
withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
    isOpen = true
    childScale = 1.1
}
```

One animation per user-initiated event. If you genuinely need two curves (rare), use `.animation(_:value:)` on separate views bound to separate state, never nested `withAnimation` blocks.

## Transitions Are Paired

`.transition()` defines how a view enters and leaves. Pair them explicitly — an asymmetric transition tells the user "this thing came from there and went back there."

```swift
if isShowingDetail {
    DetailPanel()
        .transition(.asymmetric(
            insertion: .move(edge: .trailing).combined(with: .opacity),
            removal: .opacity
        ))
}
```

Wrap the toggle in `withAnimation` or bind the parent via `.animation(_:value:)`. Never use `.transition(.scale)` alone on a list item — it looks like a bug.

## Perceived Performance

Nobody cares how fast your app is — only how fast it feels. The brain buffers sensory input for ~80ms; under that threshold everything reads as instant. Target 80ms for tap feedback (highlight, haptic, state flip).

- **Start early.** Kick the transition the moment the user commits — don't wait for the network. iOS's zoom-into-icon is the canonical pattern.
- **Show progress granularly.** Skeleton views beat spinners. Streaming content beats a blank screen.
- **Optimistic UI for low-stakes actions.** Likes, saves, toggles update instantly; reconcile with the backend silently. Never use this for payments, deletes, or destructive operations.
- **Haptics are motion.** `.sensoryFeedback(.selection, trigger:)` confirms state changes your eyes might miss. Pair with animation, don't replace it.

---

**Avoid:** Animating everything (fatigue is real). Linear easing on state change. Nested `withAnimation` blocks. Skipping the reduce-motion check. Using bounce curves for utility UI. Animating blur or shadow radius in a tight loop.
