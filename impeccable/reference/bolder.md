# bolder

When asked for "bolder," AI defaults to the same tired tricks: cyan/purple gradients, glassmorphism on every surface, neon accents on dark backgrounds, gradient text on metric cards. These are the opposite of bold. Reject them first, then increase visual impact and personality through stronger hierarchy, committed scale, and decisive type.

---

## Register

Brand: "bolder" means distinctive. Extreme scale, unexpected color, typographic risk, committed POV.

Product: "bolder" rarely means theatrics: those undermine trust. It means stronger hierarchy, clearer weight contrast, one sharper accent, more committed density. The amplification is in clarity, not drama.

---

## Assess Current State

Analyze what makes the interface feel too safe or boring:

1. **Identify weakness sources**:
   - **Generic choices**: System default fonts at `.body` weight, standard `.tint` with no custom Color Set, boring `List` layouts
   - **Timid scale**: Everything is medium-sized with no drama
   - **Low contrast**: Everything has similar visual weight; `.regular` weight throughout
   - **Static**: No motion, no energy, no life
   - **Predictable**: Standard patterns with no surprises; stock `NavigationView` and `Form`
   - **Flat hierarchy**: Nothing stands out or commands attention

2. **Understand the context**:
   - What's the brand personality? (How far can we push?)
   - What's the purpose? (Marketing views can be bolder than financial dashboards)
   - Who's the audience? (What will resonate?)
   - What are the constraints? (Brand guidelines, accessibility, Dynamic Type compliance)

If any of these are unclear from the codebase, STOP and call the AskUserQuestion tool to clarify.

**CRITICAL**: "Bolder" does not mean chaotic or garish. It means distinctive, memorable, and confident. Think intentional drama, not random chaos.

**WARNING: AI SLOP TRAP**: Review ALL the DON'T guidelines from the parent impeccable skill before proceeding. Bold means distinctive, not "more effects."

---

## Plan Amplification

Create a strategy to increase impact while maintaining coherence:

- **Focal point**: What should be the hero moment? (Pick ONE, make it amazing)
- **Personality direction**: Maximalist chaos? Elegant drama? Playful energy? Dark and moody? Choose a lane.
- **Risk budget**: How experimental can we be? Push boundaries within constraints.
- **Hierarchy amplification**: Make big things BIGGER, small things smaller (increase contrast)

**IMPORTANT**: Bold design must still be usable. Impact without function is just decoration.

---

## Amplify the Design

Systematically increase impact across these dimensions:

### Typography Amplification

- **Bump weights deliberately**: Move body text from `.regular` to `.semibold`; move headlines from `.bold` to `.heavy` or `.black`. See [`typography.md`](typography.md) for the full weight ladder and pairing rules.
- **Extreme scale**: Create dramatic size jumps: a `72pt .black` hero title next to `13pt .regular` caption is bold; two sizes at `17pt` and `15pt` is not.
- **Weight contrast**: Pair `.black` with `.light`, not `.bold` with `.semibold`.
- **Unexpected choices**: Large display text set in `SF Pro Rounded` for warmth; monospace as an intentional accent for technical content, not as a lazy default.

```swift
// Before: timid
Text("Balance")
    .font(.title2)

// After: committed
Text("Balance")
    .font(.system(size: 52, weight: .black, design: .default))
    .tracking(-1.5)

// Body bump
Text(description)
    .font(.system(.body, design: .default, weight: .semibold))
```

### Color Intensification

Pull from named Color Sets in your Asset Catalog; do not hardcode hex values. Bold amplification means reaching for the bolder semantic variant:

- **Accent amplification**: Shift `.tint(.accentColor)` to the `accentBold` Color Set for fills, icons, or call-to-action buttons that need to own the frame.
- **Surface amplification**: Replace `surfacePrimary` backgrounds with `surfacePrimaryBold` for cards or hero sections that need more presence.
- **Dominant color strategy**: Let one bold color own 60% of the design. Everything else recedes.
- **Sharp accents**: High-contrast accent colors that pop against the surface, pulled from the `accentBold` slot, not derived on the fly.
- **Tinted neutrals**: Replace pure `.gray` with tinted neutrals that harmonize with your palette; define as `neutralWarm` or `neutralCool` Color Sets.

```swift
// Before: generic tint
Button("Get Started") { }
    .tint(.accentColor)

// After: committed bold
Button("Get Started") { }
    .background(Color("accentBold"))
    .foregroundStyle(.white)
    .fontWeight(.semibold)
    .cornerRadius(14)
```

### SF Symbol Weight Opcodes

SF Symbols respect font weight. Pair icon weight with surrounding text weight for a unified voice. When amplifying, walk the weight ladder upward: `.regular` → `.medium` → `.semibold` → `.bold` → `.heavy` → `.black`.

```swift
// Timid: weight-unspecified icon next to body text
Image(systemName: "arrow.right")

// Bold: weight-matched icon at display scale
Image(systemName: "arrow.right.circle.fill")
    .font(.system(size: 28, weight: .bold))
    .foregroundStyle(Color("accentBold"))

// Hero icon: maximum presence
Image(systemName: "star.fill")
    .font(.system(size: 72, weight: .black))
    .foregroundStyle(Color("accentBold"))
```

For variable-color symbols, amplify by adding a secondary color from `accentBold` rather than leaving the default multicolor rendering.

### Material Amplification

Materials communicate depth and separation. When a surface feels weak, reach for a heavier material. Cross-link: [`materials.md`](materials.md).

- **Shift upward on the material scale**: Replace `.ultraThinMaterial` with `.regularMaterial`; replace `.regularMaterial` with `.thickMaterial` for surfaces that need to assert themselves above content.
- **Liquid Glass for hero moments**: On iOS 26+ / macOS 26+, apply `.glassEffect()` to focal surfaces where you want a committed, modern material presence. Do not scatter it everywhere: one Liquid Glass surface per screen is the maximum before it reads as slop.
- **Material + bold tint**: Combine `.thickMaterial` with a `.colorMultiply(Color("accentBold").opacity(0.12))` tint to give the material a color personality without flattening it.

```swift
// Before: whisper-thin
RoundedRectangle(cornerRadius: 16)
    .fill(.ultraThinMaterial)

// After: committed presence
RoundedRectangle(cornerRadius: 20)
    .fill(.thickMaterial)

// Liquid Glass hero card (iOS 26+)
VStack { ... }
    .glassEffect(.regular.tinted(Color("accentBold").opacity(0.08)), in: .rect(cornerRadius: 24))
```

### Spatial Drama

- **Extreme scale jumps**: Make important elements 3-5x larger than surroundings; the hero number or title should dwarf supporting text.
- **Generous space**: Use whitespace dramatically; 80-120pt gaps between hero sections, not 20-40pt.
- **Asymmetric layouts**: Replace centered, balanced layouts with tension-filled asymmetry using `HStack` with `.frame(maxWidth: .infinity, alignment: .leading)`.
- **Overlap**: Layer elements intentionally for depth using `.offset` and `ZStack`.
- **Geometry amplification**: Increase `.cornerRadius` to `24-32pt` for friendlier, more confident card shapes; avoid the stock `10pt` default.

```swift
// Bold shadow for depth, not a stock drop shadow
.shadow(color: Color("accentBold").opacity(0.25), radius: 24, x: 0, y: 12)

// Hero corner radius
.cornerRadius(28)
```

### Visual Effects

- **Dramatic shadows**: Large, soft, color-tinted shadows using `accentBold` at low opacity, not the generic gray shadow on a white card.
- **Background treatments**: Mesh gradients (`MeshGradient` on iOS 18+/macOS 15+), noise textures via `Canvas`, geometric patterns, not purple-to-blue.
- **Texture and depth**: Grain, layered elements, intentional gradients that reinforce brand personality.
- **Borders and frames**: Thick 2-3pt borders using `accentBold` at 40% opacity; avoid the hairline border-on-one-side pattern.

### Motion and Animation

- **Entrance choreography**: Staggered, dramatic view-appear animations using `.transition(.asymmetric(...))` with 50-100ms delays between elements.
- **Micro-interactions**: Satisfying press feedback via `scaleEffect` on `.onLongPressGesture` or `ButtonStyle`. Scale down to `0.96` on press: not `0.98` (too subtle) or `0.88` (too violent).
- **Transitions**: Smooth, committed transitions using `.easeOut` or `.spring(duration:bounce:)` with `bounce: 0`. Avoid `bounce > 0.2`: it cheapens the effect.

```swift
// Bold entrance
Text("Balance")
    .transition(.move(edge: .bottom).combined(with: .opacity))
    .animation(.spring(duration: 0.5, bounce: 0), value: isVisible)

// Press scale
struct BoldButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.spring(duration: 0.2, bounce: 0), value: configuration.isPressed)
    }
}
```

### Composition Boldness

- **Hero moments**: Create one clear focal point with dramatic treatment: a massive number, a full-bleed image, a single word at `.black` weight.
- **Full-bleed elements**: Use `.ignoresSafeArea()` deliberately to push elements to the true screen edge for impact.
- **Unexpected proportions**: Try 70/30 or 80/20 horizontal splits rather than even columns.
- **Asymmetric alignment**: Anchor hero text to the leading edge, let whitespace accumulate on the trailing side.

---

## NEVER

- Add effects randomly without purpose (chaos does not equal bold)
- Sacrifice readability for aesthetics (body text must meet Dynamic Type at all size categories)
- Make everything bold (then nothing is bold; you need contrast)
- Ignore accessibility (bold design must still meet WCAG contrast ratios and VoiceOver semantics)
- Overwhelm with motion (animation fatigue is real; pick two or three moments, not twenty)
- Copy trendy aesthetics blindly (bold means distinctive, not derivative)
- Scatter `.glassEffect()` on every surface (one Liquid Glass surface per screen maximum)

---

## Verify Quality

Ensure amplification maintains usability and coherence:

- **NOT AI slop**: Does this look like every other AI-generated "bold" design? If yes, start over.
- **Still functional**: Can users accomplish tasks without distraction?
- **Coherent**: Does everything feel intentional and unified?
- **Memorable**: Will users remember this experience?
- **Performant**: Do all these effects run at 120fps on ProMotion displays?
- **Accessible**: Does it still meet Dynamic Type, VoiceOver, and contrast standards?

**The test**: If you showed this to someone and said "AI made this bolder," would they believe you immediately? If yes, you have failed. Bold means distinctive, not "more AI effects."

---

When the result feels right, hand off to `/impeccable polish` for the final pass.
