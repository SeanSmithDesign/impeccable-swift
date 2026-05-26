# Animate

Add motion that conveys state, gives feedback, and clarifies hierarchy. Cut motion that exists only for decoration. Animation fatigue is a real cost; spend the budget on the moments that need it.

> **Additional context needed**: performance constraints, target register (product vs. brand).

---

## Register

Brand: orchestrated entry sequences, staggered reveals, scroll-driven animation. Motion is part of the voice; one well-rehearsed entrance beats scattered micro-interactions. Longer orchestrated motion is appropriate for brand surfaces: landing screens, onboarding heroes, and launch moments where the user is watching, not working.

Product: 150–250ms on most transitions. Motion conveys state: feedback, reveal, loading, transitions between views. No page-load choreography; users are in a task and won't wait for it.

Full duration table, spring presets, and the anti-pattern catalogue live in [`motion-design.md`](motion-design.md). Cross-reference that doc for timing decisions; do not re-derive durations inline.

---

## Assess Animation Opportunities

Analyze where motion would improve the experience:

1. **Identify static areas**:
   - **Missing feedback**: Actions without visual acknowledgment (button press, form submit, destructive confirm)
   - **Jarring transitions**: Instant state changes that feel abrupt (show/hide, route push, sheet dismiss)
   - **Unclear relationships**: Spatial or hierarchical relationships that aren't obvious (detail panels, parent-child drill)
   - **Lack of delight**: Functional but joyless interactions (empty states, success confirmations)
   - **Missed guidance**: Opportunities to direct attention or explain behavior (onboarding, first use)

2. **Understand the context**:
   - What's the personality? (Playful vs. serious, energetic vs. calm)
   - What's the performance budget? (Low-end device? Backgrounded? Scrolling at 120hz?)
   - Who's the audience? (Motion-sensitive users: see Reduce Motion below; or power users who want speed?)
   - What matters most? (One hero animation vs. many micro-interactions: pick one)

If any of these are unclear from the codebase, stop and call the AskUserQuestion tool to clarify.

**CRITICAL**: Respect `accessibilityReduceMotion`. Always provide a non-animated fallback path for users who need it. See the Reduce Motion section below.

---

## Plan Animation Strategy

Create a purposeful animation plan before writing a single modifier:

- **Hero moment**: What's the ONE signature animation? (Hero entry? Key interaction? Completion beat?)
- **Feedback layer**: Which interactions need acknowledgment? (Tap, toggle, submit)
- **Transition layer**: Which state changes need smoothing? (Reveal, collapse, navigation push)
- **Delight layer**: Where can the experience surprise, without exhausting, the user?

**IMPORTANT**: One well-orchestrated experience beats scattered animations everywhere. Focus on high-impact moments. Animation fatigue is real.

---

## Implement Animations

### SwiftUI Animation Primitives

Four entry points. Use the right one for the situation:

**`.animation(_:value:)`: declarative, state-bound (prefer this)**

Attach to the view being animated; fires whenever `value` changes. No manual `withAnimation` needed. Clean, testable, interruptible.

```swift
CardView()
    .scaleEffect(isSelected ? 1.05 : 1.0)
    .animation(.spring(response: 0.3, dampingFraction: 0.75), value: isSelected)
```

**`.transition()`: view insertion and removal**

Drives how a view enters or exits the hierarchy. Pair insertion and removal explicitly with `.asymmetric`.

```swift
if isShowingBanner {
    BannerView()
        .transition(.asymmetric(
            insertion: .move(edge: .top).combined(with: .opacity),
            removal: .opacity
        ))
}
```

Built-in transitions: `.opacity`, `.scale`, `.move(edge:)`. Combine them with `.combined(with:)`. Wrap the toggle in `withAnimation` or bind via `.animation(_:value:)` on the parent.

**`withAnimation { ... }`: imperative state updates**

Use when you need to animate a state change triggered outside a view body (button actions, gesture callbacks, async completions).

```swift
Button("Expand") {
    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
        isExpanded.toggle()
    }
}
```

Avoid nested `withAnimation` blocks: they produce spring-stacking. See [`motion-design.md`](motion-design.md) for the full anti-pattern.

**`PhaseAnimator` and `KeyframeAnimator`: choreographed sequences (iOS 17+)**

Use for multi-step animations where each phase drives a distinct visual state, or for precise keyframe control over a single property timeline.

```swift
// Phase animator: cycles through discrete states automatically
PhaseAnimator([false, true]) { phase in
    CheckmarkIcon()
        .scaleEffect(phase ? 1.2 : 1.0)
        .opacity(phase ? 1.0 : 0.6)
} animation: { phase in
    phase ? .spring(response: 0.3, dampingFraction: 0.6) : .easeOut(duration: 0.15)
}

// Keyframe animator: per-property timing control
KeyframeAnimator(initialValue: ButtonState()) { value in
    ConfirmButton()
        .scaleEffect(value.scale)
        .opacity(value.opacity)
} keyframes: { _ in
    KeyframeTrack(\.scale) {
        LinearKeyframe(0.95, duration: 0.08)
        SpringKeyframe(1.0, duration: 0.25, spring: .bouncy)
    }
    KeyframeTrack(\.opacity) {
        LinearKeyframe(1.0, duration: 0.0)
    }
}
```

Reserve `PhaseAnimator` for looping states (loading pulses, idle breathing) and `KeyframeAnimator` for one-shot choreography with precise timing requirements.

---

### Spring Physics

Springs are the default. See [`motion-design.md`](motion-design.md) for the full rationale: use these presets:

```swift
// Snappy: instant feedback, toggle, selection
.animation(.snappy, value: isHighlighted)

// Spring: state changes, card expansion, reveal
.animation(.spring(response: 0.35, dampingFraction: 0.8), value: isExpanded)

// Smooth: sheet entry, modal presentation, content reveal
.animation(.smooth(duration: 0.4), value: isPresented)

// Bouncy: success states, celebratory moments (use sparingly)
.animation(.bouncy(duration: 0.5, extraBounce: 0.1), value: didComplete)

// Interactive: follows a gesture, settles on release
.animation(.interactiveSpring(response: 0.28, dampingFraction: 0.86), value: dragOffset)
```

Never use `.linear` for state changes. Never use `.bouncy` for utility UI.

---

### Micro-interactions

**Button feedback:**

```swift
Button(action: submitForm) {
    Label("Submit", systemImage: "checkmark")
}
.buttonStyle(ImpeccableButtonStyle())  // or custom press-state modifier

// Press state via sensory feedback + scale
.scaleEffect(isPressed ? 0.96 : 1.0)
.animation(.snappy, value: isPressed)
.sensoryFeedback(.impact(flexibility: .soft), trigger: isPressed)
```

**Toggle and checkbox:**

```swift
Toggle("Notifications", isOn: $notificationsEnabled)
    .animation(.spring(response: 0.25, dampingFraction: 0.7), value: notificationsEnabled)
    .sensoryFeedback(.selection, trigger: notificationsEnabled)
```

**Form validation:**

```swift
// Shake on error: offset-based, GPU-friendly
.offset(x: validationError ? shakeOffset : 0)
.animation(.interactiveSpring(response: 0.2, dampingFraction: 0.4), value: validationError)

// Success: scale pulse
.scaleEffect(didSucceed ? 1.08 : 1.0)
.animation(.spring(response: 0.3, dampingFraction: 0.5), value: didSucceed)
```

---

### State Transitions

**Show/hide:**

```swift
// Never: instant show/hide with no animation
// Always: fade or slide with appropriate spring

if isShowingDetail {
    DetailView()
        .transition(.opacity.combined(with: .scale(scale: 0.96)))
}
```

**Expand/collapse (disclosure groups, accordions):**

```swift
DisclosureGroup("Details", isExpanded: $isExpanded) {
    DetailContent()
}
.animation(.spring(response: 0.35, dampingFraction: 0.8), value: isExpanded)
```

**Loading states: skeleton over spinner:**

```swift
if isLoading {
    SkeletonRow()
        .redacted(reason: .placeholder)
        .transition(.opacity)
} else {
    ContentRow(item: item)
        .transition(.opacity)
}
```

**Success/error confirmation:**

```swift
StatusIcon(state: submitState)
    .symbolEffect(.bounce, value: submitState == .success)
    .foregroundStyle(submitState == .error ? .red : .green)
    .animation(.spring(response: 0.3), value: submitState)
```

---

### Navigation and Flow

**Sheet and full-screen cover entry** use system-provided transitions: do not add a second `.transition()` on top of a `.sheet`; it double-animates.

**Tab switching:** Animate the selection indicator, not the content swap: the content transition is system-managed.

**Scroll-driven reveal:** Use `ScrollView` with `.scrollTransition` (iOS 17+) for scroll-aware entrance effects:

```swift
ContentCard()
    .scrollTransition { content, phase in
        content
            .opacity(phase.isIdentity ? 1 : 0.5)
            .scaleEffect(phase.isIdentity ? 1 : 0.95)
    }
```

---

### Entrance Animations

**Product register:** No page-load choreography. If content loads asynchronously, cross-fade in with `.transition(.opacity)`. Do not stagger rows in a task-flow list: it reads as decoration, not feedback.

**Brand/onboarding register:** Stagger is appropriate here. Use offsets between phase or keyframe steps, not `Task.sleep`:

```swift
PhaseAnimator([0, 1, 2, 3]) { phase in
    HeroContent(activePhase: phase)
}
```

---

### Delight Moments

```swift
// Empty state illustration: gentle idle float
.offset(y: idleOffset)
.animation(
    .easeInOut(duration: 2.0).repeatForever(autoreverses: true),
    value: idleOffset
)

// Completion beat: SF Symbols bounce effect
Image(systemName: "checkmark.seal.fill")
    .symbolEffect(.bounce, value: didComplete)

// Confetti or particle: use a TimelineView for continuous effects
TimelineView(.animation) { context in
    ParticleCanvas(date: context.date)
}
```

Delight moments are punctuation, not prose. One or two per app. See [`motion-design.md`](motion-design.md) for the bouncy-everything anti-pattern.

---

## Animate GPU-Friendly Properties

Animate these; they are composited off the main layer and do not trigger relayout:

| Property             | SwiftUI modifier                             |
| -------------------- | -------------------------------------------- |
| Opacity              | `.opacity(_:)`                               |
| Scale                | `.scaleEffect(_:)`                           |
| Offset / Translation | `.offset(x:y:)`                              |
| Rotation             | `.rotationEffect(_:)`                        |
| Color interpolation  | `.foregroundStyle(_:)` with animated binding |

**Do NOT animate layout properties.** These trigger a full relayout pass on every frame and will drop frames:

```swift
// BROKEN: animates layout recalculation every frame
Text("Label")
    .frame(width: isExpanded ? 300 : 150)   // layout property
    .padding(isExpanded ? 24 : 12)          // layout property
    .font(.system(size: isExpanded ? 18 : 14))  // layout property

// CORRECT: animate transform; let layout be static
Text("Label")
    .scaleEffect(isExpanded ? 1.2 : 1.0)   // composited
    .offset(x: isExpanded ? 8 : 0)         // composited
    .opacity(isExpanded ? 1.0 : 0.7)       // composited
```

The same rule applies to `BlurEffect`, `shadow(radius:)`, and gradient stop positions: animating these in a tight loop will stall the render thread. If you need an animated shadow, animate its opacity, or use two shadow layers and cross-fade between them.

---

## Reduce Motion

Vestibular disorders affect ~35% of adults over 40. Every non-trivial animation involving translation, scale, rotation, or parallax must include a reduce-motion path. This is not optional polish; it is a hard accessibility rule.

```swift
struct AnimatedCard: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isExpanded = false

    var body: some View {
        CardContent()
            .scaleEffect(reduceMotion ? 1.0 : (isExpanded ? 1.05 : 1.0))
            .offset(y: reduceMotion ? 0 : (isExpanded ? -8 : 0))
            .opacity(isExpanded ? 1.0 : 0.85)
            .animation(
                reduceMotion
                    ? .easeInOut(duration: 0.2)   // Cross-fade only; no spatial movement
                    : .spring(response: 0.4, dampingFraction: 0.8),
                value: isExpanded
            )
    }
}
```

**When reduce-motion is on:**

- Strip all translation, scale, and rotation
- Keep opacity transitions: they carry information without vestibular risk
- Keep progress indicators and spinners; they communicate system state, not spatial movement. Slow them down if they pulse rapidly
- Keep focus rings and selection highlights; they are not decorative

For cross-reference on `@Environment(\.accessibilityReduceMotion)` usage in the audit pipeline, see [`accessibility.md`](accessibility.md). The `impeccable-lint` detector flags `.transition(.slide)` and `.scaleEffect` modifiers that appear without an environment check.

---

## Performance

- Target 60fps (120fps on ProMotion devices). Monitor with Instruments > Animation Hitches.
- Prefer `.animation(_:value:)` over `withAnimation` in hot paths: it avoids extra state reconciliation.
- For list animations, attach `.animation(_:value:)` to the collection binding, not per-row blocks. Per-row blocks guarantee spring-stacking.
- Avoid animating blur radius or shadow radius in a tight loop. Animate their opacity instead.
- `.drawingGroup()` rasterizes a complex view subtree onto a single Metal layer: use it for views with many overlapping opaque layers, not as a general optimization. It breaks views that rely on compositingGroup blending.

---

## Verify Quality

Before shipping any animated feature:

- **60fps on device**: No hitch reports in Instruments on a physical device (not Simulator)
- **Feels natural**: Springs settle cleanly; nothing wobbles past its target or resets abruptly on interruption
- **Appropriate timing**: Micro-interactions under 200ms; state transitions 200–400ms; brand/orchestrated motion beyond that only where the user is watching, not working
- **Reduce Motion works**: Test in Settings > Accessibility > Motion > Reduce Motion; confirm no translation, scale, or rotation remains
- **Doesn't block interaction**: Users can tap during animations unless blocking is intentional
- **Adds value**: Every animation has a reason: feedback, orientation, delight. No decoration-only motion

---

**NEVER:**

- Animate layout properties (frame, padding, spacing, font size): use transform instead
- Use `.linear` easing on state changes: it reads as an oversight
- Use bounce or elastic easing on utility UI: reserve for one or two celebratory moments per app
- Nest `withAnimation` blocks: they produce spring-stacking and interrupt bugs
- Skip the reduce-motion check on any translation, scale, rotation, or parallax animation
- Animate without purpose: every animation needs a reason
- Animate everything: animation fatigue makes interfaces feel exhausting
- Block interaction during animations unless blocking is clearly intentional

---

When the motion clarifies state instead of decorating it, hand off to `/impeccable polish` for the final pass.
