# Delight

Find the moments where personality and unexpected polish turn a functional interface into one users remember and tell people about. Add only where the moment earns it. Delight everywhere reads as noise.

> **Additional context needed**: what's appropriate for the domain (playful vs professional vs quirky vs elegant), and which register the surface lives in.

---

## Register

Brand: delight can be distributed across animated hero moments, expressive type motion, seasonal palette shifts, personality woven into every section transition. The whole surface is the canvas.

Product: delight at specific moments, not pages. Completion, first-time actions, error recovery, milestone crossings. Reliability and consistency carry the rest. Delight pushed into every task state reads as noise and undermines trust.

**The register governs the distribution, not the technique.** SF Symbol animations and haptics are available to both. The difference is scope: brand gets generous, product gets surgical.

---

## Assess Delight Opportunities

Identify where delight would enhance (not distract from) the experience:

1. **Find natural delight moments**:
   - **Success states**: Completed actions (save, send, publish, delete-with-undo)
   - **Empty states**: First-time experiences, onboarding, post-completion blank slates
   - **Loading states**: Waiting periods that could carry personality
   - **Achievements**: Milestones, streaks, completions
   - **Interactions**: Toggle, swipe, drag-and-drop, selection
   - **Errors**: Softening frustrating moments with empathy, not jokes
   - **Easter eggs**: Hidden discoveries for curious users

2. **Understand the context**:
   - What's the brand personality? (Playful? Professional? Quirky? Elegant?)
   - Who's the audience? (Tech-savvy? Creative? Corporate?)
   - What's the emotional context? (Accomplishment? Exploration? Frustration?)
   - What's appropriate? (Banking app is not a gaming app)

3. **Define the delight strategy**:
   - **Subtle sophistication**: Refined symbol animations, spring physics on feedback (productivity tools, premium product UI)
   - **Playful personality**: Whimsical haptic choreography, expressive symbol sequences (consumer apps)
   - **Sensory richness**: Haptics + symbol motion coordinated, mesh gradient moments (creative tools, brand shells)

Delight should enhance usability, never obscure it. If users notice the delight more than finishing their task, you have gone too far.

---

## Delight Principles

### Delight Amplifies, Never Blocks

- Delight moments should be quick (under 1 second unless it's a deliberate hero beat)
- Never delay core functionality for delight
- Make delight skippable or ambient enough to ignore
- Respect the user's time and task focus

### Surprise and Discovery

- Hide delightful details for users to discover on their own
- Reward exploration: long-press a hero image, hold a toggle, tap a logo three times
- Do not announce every delight moment; let it emerge
- Designed discoveries get shared; designed announcements get skipped

### Appropriate to Context

- Match delight to the emotional moment: celebrate success, empathize with errors
- Do not be playful during critical failure states (data loss warnings, payment failures)
- Match brand personality and audience expectations; calibrate, do not generalize
- Cultural sensitivity: what is delightful varies by region and by profession

### Compound Over Time

- Delight should remain fresh with repeated use
- Vary responses: not the same symbol animation every time
- Reveal deeper layers with continued use
- Build subtle anticipation through established patterns

---

## SF Symbol Animations

SF Symbol animations are the primary Apple-native delight layer for icon-driven moments. Available from iOS 17+, extended significantly in iOS 17.2+. Prefer `.symbolEffect` modifiers over custom `withAnimation` loops on image state.

### Discrete Effects (one-shot on trigger)

```swift
// Bounce: draws attention to a completed or changed state
Image(systemName: "checkmark.circle.fill")
    .symbolEffect(.bounce, value: didSave)

// Scale: subtle emphasis without locomotion
Image(systemName: "star.fill")
    .symbolEffect(.scale.up, value: isFavorited)

// Pulse: repeating ambient attention (badges, live-activity icons)
Image(systemName: "bell.fill")
    .symbolEffect(.pulse, isActive: hasUnread)

// Variable color: progress or signal strength animation
Image(systemName: "wifi")
    .symbolEffect(.variableColor.iterative.reversing, isActive: isConnecting)

// Appear / disappear: for icons that enter or leave the composition
Image(systemName: "checkmark")
    .symbolEffect(.appear, value: isVisible)
    .symbolEffect(.disappear, value: !isVisible)
```

### Content Transitions (icon swap)

When an icon identity changes in place, use `.contentTransition(.symbolEffect(.replace))` instead of a plain conditional swap. This crossfades the glyph paths rather than popping between two static images.

```swift
Button {
    isPlaying.toggle()
} label: {
    Image(systemName: isPlaying ? "pause.fill" : "play.fill")
        .contentTransition(.symbolEffect(.replace))
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPlaying)
}
```

**Rule**: Use `.contentTransition(.symbolEffect(.replace))` any time the `systemName` string changes in response to user action. Do not swap images by conditionally rendering two separate `Image` views; that produces a hard cut.

See [`sf-symbols.md`](sf-symbols.md) for symbol weight, rendering mode, and sizing rules that govern all symbol usage.

---

## Haptics

Haptics are the most underused Apple delight surface. They work without visual bandwidth. On iPhone they are free: no animation budget required. They confirm, celebrate, and warn at a physical layer no animation reaches. Use them.

### Declarative: `.sensoryFeedback` (preferred, iOS 17+)

SwiftUI's `.sensoryFeedback` modifier ties haptic output to a state binding. This is the preferred form: no UIKit bridging, no trigger plumbing, no `prepare()` calls.

```swift
// Success: save completed, upload finished, form submitted
.sensoryFeedback(.success, trigger: didSave)

// Warning: destructive action preview, partial failure
.sensoryFeedback(.warning, trigger: showsDestructiveConfirmation)

// Error: network failure, validation failure
.sensoryFeedback(.error, trigger: submitFailed)

// Selection: picker movement, segment change, list row highlight
.sensoryFeedback(.selection, trigger: selectedTab)

// Impact: calibrated weight
.sensoryFeedback(.impact(flexibility: .solid, intensity: 0.8), trigger: didDrop)
.sensoryFeedback(.impact(weight: .light), trigger: didToggle)
.sensoryFeedback(.impact(weight: .medium), trigger: didReorder)
.sensoryFeedback(.impact(weight: .heavy), trigger: didDelete)
```

**Pattern: coordinate haptic with symbol animation**:

```swift
struct SaveButton: View {
    @State private var saved = false

    var body: some View {
        Button {
            saved = true
        } label: {
            Image(systemName: saved ? "checkmark.circle.fill" : "arrow.up.circle")
                .contentTransition(.symbolEffect(.replace))
                .symbolEffect(.bounce, value: saved)
        }
        .sensoryFeedback(.success, trigger: saved)
    }
}
```

The haptic fires the same frame the symbol bounces. The user feels and sees the confirmation simultaneously. This pairing is the canonical product delight moment.

### Imperative: UIKit generators (fallback)

Use the UIKit generators when you need precise timing control (for example, inside a gesture recognizer's update callback, or coordinated with a physics simulation).

```swift
// Impact feedback
let generator = UIImpactFeedbackGenerator(style: .light)   // .light, .medium, .heavy, .soft, .rigid
generator.prepare() // call ~100ms before the event
generator.impactOccurred()

// Selection change feedback
let selectionGen = UISelectionFeedbackGenerator()
selectionGen.selectionChanged()

// Notification feedback
let notifGen = UINotificationFeedbackGenerator()
notifGen.notificationOccurred(.success)  // .success, .warning, .error
```

Use imperative form for drag-and-drop snap events, custom gesture feedback, and programmatic list reordering where `.sensoryFeedback` cannot attach cleanly to a state binding.

### macOS haptics

`NSHapticFeedbackManager` on macOS is narrowly scoped to trackpad haptic actuators. Use it sparingly: not all Macs have a force-touch trackpad, and it has no effect on external mice.

```swift
#if os(macOS)
NSHapticFeedbackManager.defaultPerformer.perform(.alignment, performanceTime: .now)
// .alignment: snapping feedback (dragging to a grid)
// .levelChange: slider step or scroll snap
// .generic: unclassified feedback
#endif
```

Guard all macOS haptic calls behind `#if os(macOS)` or a runtime capability check. Do not fire haptics on scroll events, hover, or passive interactions; it feels like a broken trackpad.

---

## Material and Visual Delight

### Liquid Glass moments

Liquid Glass (iOS 26+, macOS 26+) is a delight layer, not just a surface material. Animated refractions, real-time blur adaptation, and the edge highlight that makes a floating control feel genuinely elevated are built in. Reaching for a custom blur stack to replicate this is rebuilding the system poorly.

Reserved, specific Liquid Glass moments that read as delight (not decoration):

- A floating playback cluster that morphs from a compact pill into a full-width tray with a spring transition
- A context menu that materializes from a long-press, borrowing Liquid Glass depth from the content beneath
- A toolbar that appears on scroll with the refraction live-adapting to the color passing behind it

See [`materials.md`](materials.md) for `.glassEffect()`, `GlassEffectContainer`, and the full material hierarchy.

### Animated mesh gradients (iOS 18+)

`MeshGradient` produces organic, fluid color fields that animate at low performance cost. Use them for brand hero surfaces, onboarding backgrounds, and success state celebrations: not as persistent backgrounds in dense product UI.

```swift
struct DelightBackground: View {
    @State private var phase: Float = 0

    var body: some View {
        TimelineView(.animation) { timeline in
            let t = Float(timeline.date.timeIntervalSince1970)
            MeshGradient(
                width: 3,
                height: 3,
                points: [
                    [0.0, 0.0], [0.5, 0.0], [1.0, 0.0],
                    [0.0, 0.5], [Float(0.5 + 0.1 * sin(t)), Float(0.5 + 0.1 * cos(t * 0.7))], [1.0, 0.5],
                    [0.0, 1.0], [0.5, 1.0], [1.0, 1.0]
                ],
                colors: [
                    .purple, .indigo, .blue,
                    .blue, .teal, .cyan,
                    .teal, .green, .mint
                ]
            )
        }
        .ignoresSafeArea()
    }
}
```

**Rule**: Respect `accessibilityReduceMotion` (see section below). Freeze `t` or switch to a static gradient when reduce motion is enabled.

### Particle and canvas delight

`Canvas` supports lightweight particle systems without SpriteKit overhead. Use for confetti on major milestones, sparkle on achievement unlock, or a subtle floating particle field behind a brand hero. Keep particle count under 200 for smooth 60fps; test on a physical iPhone 12 or older before shipping.

```swift
Canvas { context, size in
    for particle in particles {
        context.fill(
            Path(ellipseIn: CGRect(x: particle.x, y: particle.y, width: 6, height: 6)),
            with: .color(particle.color.opacity(particle.opacity))
        )
    }
}
.allowsHitTesting(false)
.ignoresSafeArea()
```

See [`materials.md`](materials.md) for guidance on layering visual effects without compounding blur stacks.

---

## Micro-interactions and Animation

See [`motion-design.md`](motion-design.md) for duration ranges and spring parameters. Delight lives in the same timing rules: under 150ms for instant feedback, 200-350ms for state changes, springs over curves. Do not design animations first and add haptics as an afterthought; design the sensation pairing together.

### Toggle delight

```swift
Toggle(isOn: $isEnabled) {
    Label("Notifications", systemImage: isEnabled ? "bell.fill" : "bell.slash")
        .contentTransition(.symbolEffect(.replace))
}
.sensoryFeedback(.impact(weight: .light), trigger: isEnabled)
.animation(.spring(response: 0.3, dampingFraction: 0.8), value: isEnabled)
```

### Drag-and-drop delight

- Scale to 1.05 on lift: `.scaleEffect(isDragging ? 1.05 : 1.0)`
- Spring back on drop: `.animation(.spring(response: 0.35, dampingFraction: 0.6), value: isDragging)`
- `.sensoryFeedback(.impact(weight: .medium), trigger: didDrop)` on placement

### Progress and achievement celebrations

```swift
// Progress bar that bounces at 100%
.sensoryFeedback(.success, trigger: progress >= 1.0)
.symbolEffect(.bounce, value: progress >= 1.0)

// Streak milestone
.sensoryFeedback(.success, trigger: streakCrossedMilestone)
```

### Loading state personality

Write loading messages specific to what your product does:

```swift
// Specific to what your product does
let messages = [
    "Crunching your latest changes...",
    "Syncing with your team...",
    "Preparing your review...",
]

// AI slop: instantly recognizable as machine-generated
// "Herding pixels", "Teaching robots to dance", "Consulting the magic 8-ball"
```

---

## Copy Personality

### Empty states

```
// Before (generic):
"No projects yet"

// After (voice-matched):
"Your canvas awaits. Start something."
"Inbox zero. You're crushing it."
```

Match copy personality to register. Product register can be warm; it should not be wacky. Brand register has more latitude but must match the specific voice: a luxury travel app should not be chirpy.

### Error states

```
// Before:
"Connection failed"

// After (empathetic, not cute):
"Your connection dropped. We have your changes. Tap to retry."
```

Empathy, not humor, in error states. Humor often lands as dismissive when the user is frustrated.

---

## Reduced Motion and Transparency Fallbacks

Every animation and every material effect needs a non-animated, non-translucent fallback. Reduce Motion and Reduce Transparency are system-level accessibility preferences. Not optional.

### Reduce Motion

```swift
@Environment(\.accessibilityReduceMotion) private var reduceMotion

// Conditional animation
.animation(reduceMotion ? nil : .spring(response: 0.35, dampingFraction: 0.8), value: isExpanded)

// Symbol effects: disable or substitute a static state change
Image(systemName: didSave ? "checkmark.circle.fill" : "circle")
    .symbolEffect(.bounce, value: reduceMotion ? false : didSave)

// MeshGradient: freeze the animation parameter
let animatedT: Float = reduceMotion ? 0.0 : Float(timeline.date.timeIntervalSince1970)
```

**Rule**: When `reduceMotion` is true, state changes can still occur, just without animation. Replace spring transitions with instant cuts, symbol bounces with static icon swaps, and mesh gradient motion with a frozen color field.

### Reduce Transparency

```swift
@Environment(\.accessibilityReduceTransparency) private var reduceTransparency

// Liquid Glass fallback: switch to an opaque material
.background(
    reduceTransparency
        ? AnyView(Rectangle().fill(.regularMaterial))
        : AnyView(Color.clear.glassEffect())
)
```

**Rule**: When `reduceTransparency` is true, glass surfaces and blur-backed overlays become opaque materials. The depth cue collapses into a flat system material, which is fine. Text and controls must remain legible.

See [`accessibility.md`](accessibility.md) for the full accessibility model, including Dynamic Type, VoiceOver, and contrast requirements.

---

## Register-Specific Delight Playbook

### Brand register: distributed delight

Brand surfaces earn more aggressive delight distribution because the experience IS the product. Visitors are not mid-task; they are forming an impression.

**Hero moment (landing / onboarding)**:

- Animated `MeshGradient` or particle field as hero background, keyed to `accessibilityReduceMotion`
- Logo or wordmark with a subtle entrance animation (`.appear` + `opacity` + `offset`, spring-driven)
- SF Symbol in the hero icon animating on first appear: `.symbolEffect(.bounce)` or `.symbolEffect(.variableColor)`
- Liquid Glass floating action cluster that materializes above the hero content

**Section transitions**:

- Each section reveal uses a coordinated spring: opacity + vertical offset, staggered by index
- `MeshGradient` color palette shifts between sections to carry the journey

**Discovery rewards**:

- Long-press on a logo triggers a subtle symbol animation or palette shift
- Third tap on an easter-egg target plays a `.sensoryFeedback(.success)` + confetti canvas burst
- Dark mode toggles the mesh gradient to a cool-shifted variant with a crossfade

See [`brand.md`](brand.md) for the brand slop test, typography selection, and when brand register applies.

### Product register: moment-specific delight

Product surfaces earn delight at specific, meaningful moments. Outside those moments, the interface should be invisible: the tool disappearing into the task.

**The canonical product delight moments**:

| Moment              | Haptic                                            | Symbol animation                              |
| ------------------- | ------------------------------------------------- | --------------------------------------------- |
| Save / publish      | `.sensoryFeedback(.success, ...)`                 | `.symbolEffect(.bounce)` on checkmark         |
| Destructive confirm | `.sensoryFeedback(.warning, ...)`                 | `.symbolEffect(.bounce)` on warning icon      |
| Milestone / streak  | `.sensoryFeedback(.success, ...)`                 | confetti canvas + badge appear                |
| Toggle on           | `.sensoryFeedback(.impact(weight: .light), ...)`  | `.contentTransition(.symbolEffect(.replace))` |
| Error / failure     | `.sensoryFeedback(.error, ...)`                   | static icon swap, no bounce                   |
| List reorder snap   | `.sensoryFeedback(.impact(weight: .medium), ...)` | none                                          |
| Pull-to-refresh     | built-in `RefreshControl`                         | none (don't override the system)              |

**What product register does NOT do**:

- Animate every row appearance in a `List`
- Add spring motion to static labels
- Bounce symbols on background data refresh (the user is not watching)
- Fire haptics on scroll, hover, or navigation transitions
- Animate anything when the user is mid-composition in a text field

See [`product.md`](product.md) for the product slop test and the "tool disappearing into the task" bar.

---

## Implementation Notes

**Coordinate haptic with animation on the same frame.** Haptics fired in a `Button` action and animations triggered by the resulting state change naturally align: Swift's rendering pass schedules them together.

**Never call `prepare()` speculatively.** `UIImpactFeedbackGenerator.prepare()` is appropriate 100ms before a known interaction (e.g., drag start). Do not call it on `onAppear` for a future button tap: it wastes battery and the taptic engine is ready within a single frame anyway.

**File size and performance.** `MeshGradient` is cheap. `Canvas` particle systems with 200+ elements on older hardware are not. Lottie files add bundle weight; prefer `symbolEffect` or `Canvas` before reaching for Lottie. If you do ship Lottie, lazy-load it.

**NEVER**:

- Delay core functionality for delight
- Force users through a delightful moment they cannot skip
- Use delight to mask poor UX (a satisfying bounce does not fix a confusing flow)
- Fire haptics on passive events: scroll, hover, background refresh
- Animate when `accessibilityReduceMotion` is true
- Use Liquid Glass without a `reduceTransparency` fallback

---

## Verify Delight Quality

- **User reactions**: Do users smile? Share screenshots? Mention it in reviews?
- **Survives repetition**: Still pleasant after the 100th interaction, or has it become friction?
- **Does not block**: Can users ignore or opt out of every delight moment?
- **Performant**: No frame drops. Test on a physical device. Instruments: Time Profiler during a Canvas burst.
- **Appropriate**: Matches register (brand vs product), brand personality, and emotional context
- **Accessible**: Works correctly with Reduce Motion, Reduce Transparency, and VoiceOver. Test all three in the Simulator and on device.
