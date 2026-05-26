# Quieter

Quiet design is harder than bold design. Subtlety needs precision. Reduce visual intensity in SwiftUI interfaces that are too loud, aggressive, or overstimulating without losing personality or making the result generic.

---

## Register

Brand: "quieter" means more restrained palette, more whitespace, more typographic air. Drama is reduced, not eliminated: the POV stays intact.

Product: "quieter" means reducing visual noise: fewer background accents, flatter cards, less color, less motion. The tool should disappear more completely into the task.

---

## Assess Current State

Analyze what makes the design feel too intense:

1. **Identify intensity sources**:
   - **Color saturation**: Overly bright or saturated colors
   - **Contrast extremes**: Too much high-contrast juxtaposition
   - **Visual weight**: Too many bold, heavy elements competing
   - **Animation excess**: Too much motion or overly dramatic effects
   - **Complexity**: Too many visual elements, patterns, or decorations
   - **Scale**: Everything is large and loud with no hierarchy

2. **Understand the context**:
   - What's the purpose? (Marketing vs tool vs reading experience)
   - Who's the audience? (Some contexts need energy)
   - What's working? (Don't throw away good ideas)
   - What's the core message? (Preserve what matters)

If any of these are unclear from the codebase, STOP and call the AskUserQuestion tool to clarify.

**CRITICAL**: "Quieter" doesn't mean boring or generic. It means refined and easier on the eyes. Think luxury, not laziness.

## Plan Refinement

Create a strategy to reduce intensity while maintaining impact:

- **Color approach**: Desaturate or shift to more sophisticated tones?
- **Hierarchy approach**: Which elements should stay bold (very few), which should recede?
- **Simplification approach**: What can be removed entirely?
- **Sophistication approach**: How can we signal quality through restraint?

**IMPORTANT**: Subtlety requires precision. Quiet without intent collapses to generic.

## Refine the Design

Systematically reduce intensity across these dimensions:

### Color Refinement

- **Reduce saturation**: Shift from fully saturated to 70-85% saturation
- **Soften palette**: Replace bright colors with muted, sophisticated tones: use `accentMuted` and `surfaceSecondary` Color Sets from the Asset Catalog (see [`color-and-contrast.md`](color-and-contrast.md))
- **Reduce color variety**: Use fewer colors more thoughtfully
- **Neutral dominance**: Let neutrals do more work, use color as accent (10% rule); reach for `surfaceQuaternary` for the quietest background tier
- **Gentler contrasts**: High contrast only where it matters most; stay within WCAG AA minimums: cross-check with [`color-and-contrast.md`](color-and-contrast.md)
- **Tinted grays**: Use warm or cool tinted grays instead of pure gray: adds sophistication without loudness
- **Never gray on color**: If you have gray text on a colored background, use a darker shade of that color or a reduced-opacity version instead

```swift
// Too loud: fully saturated accent on every control
Button("Continue") { }
    .foregroundStyle(Color("accent"))        // bold blue or brand color

// Quieter: muted accent; recedes unless focused
Button("Continue") { }
    .foregroundStyle(Color("accentMuted"))   // same hue, lower chroma

// Quietest surface: for secondary backgrounds and cards
RoundedRectangle(cornerRadius: 12)
    .fill(Color("surfaceQuaternary"))        // near-transparent neutral
    .overlay {
        Text(label)
            .foregroundStyle(.secondary)
    }
```

### Visual Weight Reduction

- **Typography**: Reduce font weights (`900 → 600`, `700 → 500`); drop body to `.regular`, headlines to `.medium` or `.semibold`; reduce tracking (see [`typography.md`](typography.md))
- **Hierarchy through subtlety**: Use weight, size, and space instead of color and boldness
- **White space**: Increase breathing room, reduce density; let elements breathe
- **Borders and lines**: Reduce thickness, decrease opacity, or remove entirely

```swift
// Too heavy
Text(headline)
    .font(.system(size: 28, weight: .bold))
    .kerning(1.2)

// Quieter: medium weight, tighter tracking removed, more air
Text(headline)
    .font(.system(size: 26, weight: .medium))
    .padding(.bottom, 8)    // extra breathing room below
```

### Material Softening

Reduce surface weight by stepping down the material hierarchy. See [`materials.md`](materials.md) for the full hierarchy.

- **Step down materials**: `.regularMaterial` → `.thinMaterial` or `.ultraThinMaterial`
- **Soft shadows**: Replace multi-layer aggressive shadows with a single quiet shadow

```swift
// Loud: heavy material and dramatic shadow
RoundedRectangle(cornerRadius: 16)
    .fill(.regularMaterial)
    .shadow(color: .black.opacity(0.25), radius: 20, y: 8)

// Quieter: thinner material, restrained shadow
RoundedRectangle(cornerRadius: 16)
    .fill(.thinMaterial)
    .shadow(color: .black.opacity(0.08), radius: 4, y: 2)

// Quietest non-glass surface: near-invisible lift
RoundedRectangle(cornerRadius: 16)
    .fill(.ultraThinMaterial)
    .shadow(color: .black.opacity(0.06), radius: 3, y: 1)
```

**Rule**: One shadow layer only. Multi-layer shadow stacks (`shadow()` chained multiple times) are decoration, not depth. A single `opacity(0.06...0.12)` shadow communicates elevation without drama.

### Simplification

- **Remove decorative elements**: Gradients, heavy shadows, patterns, textures that don't serve purpose
- **Simplify shapes**: Reduce border radius extremes, simplify custom shapes
- **Reduce layering**: Flatten visual hierarchy where possible
- **Clean up effects**: Reduce or remove blur effects, glows, multiple shadows

### Motion Reduction

- **Reduce animation intensity**: Shorter distances (10-20 pt instead of 40 pt), gentler easing
- **Remove decorative animations**: Keep functional motion, remove flourishes
- **Subtle micro-interactions**: Replace dramatic effects with gentle feedback
- **Refined springs**: `.smooth` over `.bouncy`; avoid elastic and over-damped springs

```swift
// Too dramatic
withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
    isExpanded.toggle()   // high bounce, long tail
}

// Quieter: smooth, understated
withAnimation(.smooth(duration: 0.2)) {
    isExpanded.toggle()
}

// Quietest: simple ease-out for state changes
withAnimation(.easeOut(duration: 0.18)) {
    isExpanded.toggle()
}
```

Quieter animations naturally align with Reduce Motion preferences. Always cross-check against the `accessibilityReduceMotion` environment value (see [`accessibility.md`](accessibility.md)):

```swift
@Environment(\.accessibilityReduceMotion) var reduceMotion

withAnimation(reduceMotion ? nil : .smooth(duration: 0.2)) {
    isExpanded.toggle()
}
```

- **Remove animations entirely** if they are not serving a clear purpose

### Composition Refinement

- **Reduce scale jumps**: Smaller contrast between sizes creates a calmer feeling
- **Align to grid**: Bring rogue elements back into systematic alignment
- **Even out spacing**: Replace extreme spacing variations with consistent rhythm; prefer 8-pt multiples throughout

**NEVER**:

- Make everything the same size or weight (hierarchy still matters)
- Remove all color (quiet does not equal grayscale)
- Eliminate all personality (maintain character through refinement)
- Sacrifice usability for aesthetics (functional elements still need clear affordances)
- Make everything small and light (some anchors are needed)

## Verify Quality

Ensure refinement maintains quality:

- **Still functional**: Can users still accomplish tasks easily?
- **Still distinctive**: Does it have character, or is it generic now?
- **Better reading**: Is text easier to read for extended periods?
- **Restrained, not absent**: Does the POV survive the cuts?
- **Contrast compliance**: Verify reduced-contrast areas still meet WCAG AA (4.5:1 for body, 3:1 for large text) using [`color-and-contrast.md`](color-and-contrast.md)
- **Reduce Motion alignment**: Confirm all non-essential animations respect `accessibilityReduceMotion` (see [`accessibility.md`](accessibility.md))

When the result feels right, hand off to `impeccable polish` for the final pass.
