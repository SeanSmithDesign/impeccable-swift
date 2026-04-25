# Overdrive

Push an interface past conventional limits. On Apple Silicon with SwiftUI, "extraordinary" has a precise meaning: Metal shaders running at 8.3ms frames on ProMotion displays, `MeshGradient` fluid color fields that respond to gesture, `Canvas` particle systems that feel physically alive. This isn't about visual effects for their own sake. It's about using the full power of the platform to make any part of the interface feel like something users didn't think software could do.

**EXTRA IMPORTANT**: Context determines what "extraordinary" means. A Metal displacement shader on a creative portfolio is impressive. The same shader on a settings page is embarrassing. But a settings page with spring-driven optimistic updates and animated state transitions? That's extraordinary too. Understand the app's register and audience before choosing a technique.

---

## Propose Before Building

This command has the highest potential to misfire. Do NOT jump straight into implementation.

1. **Think through 2-3 different directions**: consider different techniques, levels of ambition, and aesthetic approaches. For each direction, briefly describe what the result would look and feel like in the hands of the user.
2. **Stop and present these directions to the user.** Explain trade-offs (device support floor, frame budget impact, build complexity). Wait for a pick.
3. Only proceed with the direction the user confirms.

**Iterate in Xcode Canvas.** Technically ambitious effects almost never read correctly on the first build. Use `#Preview` with `PreviewProvider` to iterate visually. The gap between "technically works" and "looks extraordinary" is closed through visual iteration, not code alone.

Skipping the propose step risks building something that needs to be thrown away.

---

## Assess What "Extraordinary" Means Here

Before choosing a technique, ask: what would make a user of THIS specific interface say "that's not possible on a phone"?

### For visual and marketing surfaces

Hero sections, paywalls, onboarding flows, portfolio showcases. The "wow" is often sensory: a `MeshGradient` that breathes with gesture, a Metal color effect that distorts content behind a glass panel, a `Canvas` generative background that settles into a stable composition.

### For functional UI

Lists, forms, navigation, dialogs. The "wow" is in how it FEELS: a row expanding with a `.bouncy` spring that overshoots and snaps, a search field that filters instantly via `async`/`await` off the main actor, a scroll reveal that maps content opacity to offset with `.visualEffect`.

### For performance-critical UI

The "wow" is invisible but felt: a data table that scrolls through 100k items without a dropped frame using `LazyVStack` with identifier stability, a chart that animates between data states at 60fps via `Canvas` direct rendering, a form that never blocks input because mutations happen on a background actor.

**The common thread**: something about the implementation exceeds what users expect from native software. The technique serves the experience, not the engineer's portfolio.

---

## The Toolkit

Organized by what you are trying to achieve, not by framework name.

### Make rendering feel alive: Metal shaders

SwiftUI exposes Metal shader effects directly on any view. These run on the GPU and compose cleanly with `glassEffect()` layering. See [`materials.md`](materials.md) for shader-on-material composition rules.

**`.colorEffect`**: per-pixel color transforms. Use for color grading, chromatic aberration, noise overlays, inverted-color moments.

```swift
// MyShaders.metal defines colorShift(float4 color, float time)
Image("hero")
    .colorEffect(ShaderLibrary.colorShift(.float(phase)))
    .onAppear {
        withAnimation(.linear(duration: 4).repeatForever(autoreverses: false)) {
            phase = .pi * 2
        }
    }
```

**`.layerEffect`**: reads neighboring pixels. Use for blur-as-shader, ripple distortion, scanlines, pixel-sorting aesthetics.

**`.distortionEffect`**: displaces source pixels. Use for warp fields, liquid morphing, elastic drag feedback.

```swift
// Applies a Metal displacement map driven by drag state
canvas
    .distortionEffect(ShaderLibrary.warpField(.float2(dragOffset)), maxSampleOffset: CGSize(width: 80, height: 80))
```

Minimum target: iOS 17+. All three modifiers are available on iOS 17 and macOS 14. Write shader files in `.metal` inside the app target; Xcode compiles them at build time.

### Make color feel fluid: MeshGradient

`MeshGradient` (iOS 18+, macOS 15+) renders a grid of color control points with smooth bicubic interpolation. Animate the control points or colors directly: SwiftUI interpolates between states automatically.

```swift
@State private var points: [[SIMD2<Float>]] = MeshGradient.defaultGrid(rows: 3, columns: 3)

MeshGradient(width: 3, height: 3, points: points, colors: palette)
    .ignoresSafeArea()
    .onAppear {
        withAnimation(.easeInOut(duration: 6).repeatForever(autoreverses: true)) {
            points = perturbedGrid()
        }
    }
```

Use for: hero backgrounds, paywall surfaces, onboarding screens, animated lock screens. Cross-link [`materials.md`](materials.md) when layering `MeshGradient` behind a `glassEffect()` surface: glass refracts whatever is behind it, so the gradient animates through the glass.

### Draw procedurally: Canvas

`SwiftUI.Canvas` is a 2D GPU-accelerated drawing context. It renders every frame on a background thread and composites the result. Use for: particle systems, generative art, custom charts with thousands of data points, procedural backgrounds.

```swift
Canvas { context, size in
    for particle in particles {
        var path = Path()
        path.addEllipse(in: CGRect(center: particle.position, radius: particle.radius))
        context.fill(path, with: .color(particle.color.opacity(particle.life)))
    }
}
.drawingGroup() // composites to a single Metal layer before blending with the view hierarchy
```

Pair `Canvas` with `TimelineView` to drive 60fps animation from the display link schedule:

```swift
TimelineView(.animation) { timeline in
    Canvas { context, size in
        let elapsed = timeline.date.timeIntervalSinceReferenceDate
        // update + draw particles using elapsed
    }
}
```

`TimelineView(.animation)` schedules at display refresh rate: 60Hz on standard displays, 120Hz on ProMotion. Do not use a manual `Timer` or `Task.sleep` loop for animation.

### Push interaction feel: spring physics and gesture animation

Interactive spring physics are the primary differentiator between native and web feel. See [`motion-design.md`](motion-design.md) for budget vocabulary.

**`.interactiveSpring()`**: tracks gesture velocity and continues motion from where the user releases. Use on drag gestures, pull-to-refresh, swipe reveals.

```swift
.gesture(
    DragGesture()
        .onChanged { value in offset = value.translation.height }
        .onEnded { _ in
            withAnimation(.interactiveSpring(response: 0.4, dampingFraction: 0.7)) {
                offset = 0
            }
        }
)
```

**`.bouncy`**: shorthand for a spring with visible overshoot. Use on expansion, selection, or success moments where the extra energy communicates completion.

```swift
withAnimation(.bouncy) {
    isExpanded.toggle()
}
```

**Gesture-driven animation without `withAnimation`**: use `Animation.interactiveSpring()` inside `DragGesture.onChanged` to drive state without a discrete snap.

### Tie content to scroll: scroll-driven reveals

**`.scrollTransition`** (iOS 17+): applies a transform or opacity change as a view enters or exits the scroll viewport.

```swift
Text("Section title")
    .scrollTransition(.animated(.spring(response: 0.4))) { content, phase in
        content
            .opacity(phase.isIdentity ? 1 : 0)
            .scaleEffect(phase.isIdentity ? 1 : 0.92)
            .blur(radius: phase.isIdentity ? 0 : 4)
    }
```

**`.visualEffect`** (iOS 17+): reads geometry without breaking view layout. Use for parallax offsets, depth-based blur, reading scroll offset without a `GeometryReader` wrapper.

```swift
Image("cover")
    .visualEffect { content, proxy in
        content.offset(y: proxy.frame(in: .scrollView).minY * 0.4)
    }
```

For complex multi-element choreography where `.scrollTransition` does not compose cleanly, use `GeometryReader` + `PreferenceKey` to broadcast scroll offset to a parent and drive individual view states from there. Avoid `GeometryReader` at list row scope: it breaks `LazyVStack` identity stability.

### Bridge to game-feel: SpriteKit particle systems

`SpriteView` embeds a full `SKScene` in a SwiftUI layout. Use for: confetti bursts, physics-driven particle emitters, celebration moments. `SKEmitterNode` with `.particleTexture` gives GPU-accelerated particle counts SwiftUI `Canvas` cannot match.

```swift
SpriteView(scene: ParticleScene(), options: [.allowsTransparency])
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .ignoresSafeArea()
    .allowsHitTesting(false)
```

`ParticleScene` is an `SKScene` subclass that configures an `SKEmitterNode` from a `.sks` particle file and removes itself after the burst completes.

### 3D and spatial content: RealityView

`RealityView` (iOS 18+, visionOS 2+) embeds RealityKit entities in a SwiftUI view. Use for: 3D product showcases, spatial onboarding diagrams, AR surface detection previews. On iOS it renders in perspective projection to a flat Metal layer; on visionOS it uses the full passthrough pipeline.

```swift
RealityView { content in
    if let entity = try? await ModelEntity(named: "ProductModel") {
        entity.generateCollisionShapes(recursive: true)
        content.add(entity)
    }
}
```

This is high surface area. Only reach for `RealityView` when the design brief explicitly calls for 3D or spatial content, not to impress.

### Hand-rolled 60/120fps: CADisplayLink

When SwiftUI's animation primitives do not fit (physics simulations, audio-reactive visualizations, custom interpolators), use `CADisplayLink` directly.

```swift
final class DisplayLinkDriver: ObservableObject {
    private var link: CADisplayLink?
    @Published var state: SimulationState = .initial

    func start() {
        link = CADisplayLink(target: self, selector: #selector(tick))
        link?.add(to: .main, forMode: .common)
    }

    @objc private func tick(_ link: CADisplayLink) {
        let dt = link.targetTimestamp - link.timestamp
        state = state.stepped(by: dt)
    }
}
```

`targetTimestamp` gives the deadline for the next frame: use it as `dt` for physics integration, not wall clock deltas. On ProMotion devices, `dt` is ~8.3ms at 120Hz.

---

## Performance Ceiling

ProMotion 120Hz (iPhone Pro, iPad Pro, Studio Display) targets 8.3ms per frame. Standard 60Hz targets 16.6ms. These are hard ceilings, not averages.

**Frame budget rules:**

- Shader effects must stay below 4ms GPU time or they starve composition. Profile in Metal System Trace in Instruments.
- `Canvas` with `drawingGroup()` composites to a Metal texture once and blends: this is fast. Without `drawingGroup()`, every `Canvas` draw is a separate pass.
- `MeshGradient` animation is cheap when point count stays at 9-25. Beyond 49 points, profile before shipping.
- `SpriteView` particle systems are GPU-bound. Test on iPhone 12 (not just the current Pro) before committing to high particle counts.
- `CADisplayLink` work must complete before `targetTimestamp` or the frame is dropped. Keep simulation steps O(n) and move anything heavier off the main actor.

Cross-link [`motion-design.md`](motion-design.md) for animation duration and spring budget vocabulary that informs how much motion to stack.

**Profile before shipping**: open Instruments, run Metal System Trace + Core Animation on a physical ProMotion device, and verify frame times. Do not assume smooth because the simulator is smooth.

---

## Accessibility Ceiling

Technically ambitious effects must degrade gracefully when user preferences signal it. This is not optional.

### Reduce Motion

Check `accessibilityReduceMotion` before committing to particle systems, continuous `TimelineView` animation, or shader-driven movement.

```swift
@Environment(\.accessibilityReduceMotion) private var reduceMotion

var body: some View {
    if reduceMotion {
        StaticHeroBackground()
    } else {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                // animated particle system
            }
        }
    }
}
```

The static fallback must be beautiful on its own. A flat color is not a fallback. A carefully chosen `MeshGradient` with no animation is.

### Reduce Transparency

Check `accessibilityReduceTransparency` before applying `.colorEffect` or `.layerEffect` shaders that reduce contrast or blend content in ways that hurt legibility.

```swift
@Environment(\.accessibilityReduceTransparency) private var reduceTransparency

Image("hero")
    .colorEffect(
        reduceTransparency
            ? ShaderLibrary.identity()
            : ShaderLibrary.chromaticAberration(.float(intensity))
    )
```

Cross-link [`accessibility.md`](accessibility.md) for the full accessibility runtime checklist. Overdrive surfaces are the most likely to introduce accessibility regressions: review that doc before shipping.

---

## Implement with Discipline

### Context before ambition

Choose the technique to serve the design brief, not the other way around. A `MeshGradient` background on a medical records form is wrong regardless of how well it executes. A spring-physics drag-to-dismiss on that same form is right.

### Pause off-screen rendering

Stop `CADisplayLink` and `TimelineView`-driven simulation when the view is not visible. Use `.onDisappear` to invalidate links, and `TimelineView(.pausableAnimation(paused: !isVisible))` where available.

```swift
.onDisappear { displayLinkDriver.stop() }
.onAppear { displayLinkDriver.start() }
```

### Polish is the difference

The gap between "cool" and "extraordinary" is the last 20%: the easing curve on a spring overshoot, the timing offset in a staggered reveal, the secondary motion on a particle that makes it feel like it has mass. Do not ship the first version that works. Ship the version that feels inevitable.

**NEVER**:

- Ignore `accessibilityReduceMotion` or `accessibilityReduceTransparency`: these are runtime requirements, not suggestions
- Ship effects that drop frames on iPhone 12 or equivalent mid-range devices
- Use Metal shader effects without a static or reduced-motion fallback
- Layer multiple competing extraordinary moments: focus creates impact, excess creates noise
- Use technical ambition to mask weak design fundamentals: fix those first with other commands

---

## Verify the Result

- **The wow test**: Show it to someone who has not seen it. Do they react?
- **The removal test**: Take it away. Does the experience feel diminished, or does nobody notice?
- **The device test**: Run on iPhone 12, iPad (non-Pro), and the simulator at 1x. Still smooth?
- **The accessibility test**: Enable Reduce Motion and Reduce Transparency in Settings. Still beautiful?
- **The context test**: Does this technique match THIS app's register and audience?

Remember: "technically extraordinary" is not about using the newest API. It's about making an interface feel like something users didn't think software running on their device could do.
