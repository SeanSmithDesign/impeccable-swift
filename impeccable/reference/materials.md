# Materials

Liquid Glass is the default surface vocabulary on iOS 26+ and macOS 26+. Not a progressive enhancement, not an opt-in flourish — the native language of elevated surfaces. This doc covers when to reach for `.glassEffect()` vs. the material hierarchy (`.regularMaterial`, `.thinMaterial`, and the rest), how materials declare relationships between layers, and the concentric corner rule. It does not cover color, which belongs in color-and-contrast.

## Liquid Glass Is The Surface Language

**On iOS 26+ and macOS 26+, elevated and floating surfaces use Liquid Glass.** Toolbars, sidebars, popovers, floating controls, tab bars, contextual overlays — these are glass. Not "consider glass if it fits." Glass is the system's answer for surfaces that hover above content, because it carries the depth cue (refraction + blur + subtle edge highlight) that replaces the old shadow-and-card metaphor. Reaching past `.glassEffect()` for a custom blur stack is rebuilding the system poorly.

```swift
GlassEffectContainer {
    HStack(spacing: 12) {
        Button("Play",  systemImage: "play.fill") { }
        Button("Skip",  systemImage: "forward.fill") { }
        Button("Queue", systemImage: "list.bullet") { }
    }
    .padding(.horizontal, 16)
    .padding(.vertical, 10)
}
.glassEffect()
```

**Rule:** If the surface floats above content (toolbar, tab bar, popover, floating action cluster), it is glass. Use `.glassEffect()` on the floating surface and wrap related glass elements in `GlassEffectContainer` so their refraction merges into one coherent pane instead of fragmenting per-view.

**Why:** Glass is not decoration — it's a depth declaration. The blur reads "this is above." The edge highlight reads "this is bounded." Skipping it and hand-rolling a white-rect-with-shadow tells the user the surface is printed onto the background instead of hovering over it.

## Regular vs. Clear — Two Glass Variants

**Declare: choose `.regular` for glass surfaces with significant text or controls; choose `.clear` only for surfaces floating above visually rich media backgrounds.**

Liquid Glass has two variants with different optical properties:

- **`.regular`** — blurs and adjusts the luminosity of background content to maintain legibility. Most system components (sidebars, tab bars, alerts, popovers) use this. Use it when background content might create legibility issues or when the glass surface contains a significant amount of text.
- **`.clear`** — highly translucent. Prioritizes the visibility of underlying content — background detail stays prominent and immersive. Use it only for surfaces floating above photos, videos, or other media. The content behind it must be the star.

```swift
// Regular — toolbar over scrollable content
.glassEffect(Glass.regular, in: .capsule)

// Clear — floating control over a photo viewer
.glassEffect(Glass.clear, in: .capsule)
```

**Dimming layer rule for clear glass:** Clear glass over bright backgrounds loses legibility. When the underlying content is bright, add a dark dimming layer at 35% opacity behind the glass surface. If the content is sufficiently dark, or if you're using AVKit's media controls (which include their own dimming layer), skip the dimming layer.

```swift
// Clear glass over potentially bright content — add a dimming layer
ZStack {
    Color.black.opacity(0.35)  // Dimming layer for legibility
    controlContent
}
.glassEffect(Glass.clear, in: .capsule)
```

## Glass Is For Floating Chrome, Not Content Layer

**Declare: never apply `.glassEffect()` to elements in the content layer.** Glass establishes the functional layer (controls, navigation) floating above the content layer (what the app is actually about). Mixing them collapses the hierarchy.

**Why:** Apple's HIG is explicit: "Don't use Liquid Glass in the content layer. Including it in the content layer can result in unnecessary complexity and a confusing visual hierarchy." The distinction is structural — glass says "I am chrome." Content says "I am what the user came for."

**Exception:** Sliders and toggles inside the content layer take on a glass appearance when activated — this is system behavior, not something to replicate on custom controls.

**Anti-pattern — "The cargo-cult Glass."** Every view gets `.glassEffect()` because glass looks modern. List rows become glass. Cards become glass. The hierarchy collapses. Before applying glass, ask: does this surface genuinely float above content the user is reading? If no, use a plain background or a standard `Material`.

## Materials Declare Hierarchy, Not Mood

**Stop treating materials as a vibe toggle.** `.regularMaterial`, `.thinMaterial`, `.ultraThinMaterial`, `.thickMaterial`, and `.ultraThickMaterial` are a ranked scale that encodes _how much the surface separates from what's behind it_. Thicker = more separation = higher in the visual stack. Pick by relationship, not by taste.

| Material              | Use for                                              |
| --------------------- | ---------------------------------------------------- |
| `.ultraThinMaterial`  | Floating toolbars, pill controls sitting over media  |
| `.thinMaterial`       | Overlays, inline glass chips, subtle separations     |
| `.regularMaterial`    | Sidebars, sheet backgrounds, primary panels          |
| `.thickMaterial`      | Modals that must dominate attention                  |
| `.ultraThickMaterial` | Menu bar, system-level surfaces over vibrant content |

```swift
SidebarView()
    .background(.regularMaterial)

FloatingToolbar()
    .background(.ultraThinMaterial, in: .capsule)
```

**Rule:** Pick the material that matches the surface's role in the hierarchy. A sidebar is `.regularMaterial`. A floating pill over a photo is `.ultraThinMaterial`. Decide once per surface, document it in the brief, move on.

## One Material Per Surface

**Never stack or mix materials on a single surface.** Materials are a hierarchy; choosing three levels on one panel means you chose none. The layering reads as incoherent — the user's eye can't find the ground plane because every sub-region claims a different altitude.

**Anti-pattern — "Material soup."** A settings sheet where the nav bar is `.thinMaterial`, the outer container is `.regularMaterial`, and a contained card bumps back up to `.thickMaterial`. The sheet now has three depth planes competing for dominance. Collapse to one material for the sheet. If a child element genuinely needs separation, raise it with concentric corners and an inset, not another material.

## The Backdrop-Filter Transplant Is Banned

**Anti-pattern — "The backdrop-filter transplant."** `Color.white.opacity(0.3)` behind content with `.blur(radius: 20)` on top, reproducing the CSS `backdrop-filter: blur()` trick. This is a web habit; on Apple platforms it produces a gray mush without refraction, without vibrancy, without the edge treatment the system provides. It also doesn't adapt to Dark Mode or Increase Contrast.

**Rule:** Use `.glassEffect()` for floating chrome or one of the `Material` values for non-floating surfaces. Never hand-roll translucency with `Color.opacity` + `.blur`.

**Why:** System materials sample the content behind them, desaturate appropriately, respect accessibility settings (Reduce Transparency collapses them to solid surfaces), and update correctly when the wallpaper or scroll position changes. A hand-rolled blur does none of this.

## Concentric Corners Or It Reads Broken

**Child corner radius = parent corner radius − padding.** When a card with 16pt radius contains an inner surface with 12pt padding, that inner surface must be 4pt. Break this rule and the corners look wonky — the inner rectangle either bulges past the outer curve or sits inside it with an awkward gap.

```swift
RoundedRectangle(cornerRadius: 16, style: .continuous)
    .fill(.regularMaterial)
    .overlay(
        RoundedRectangle(cornerRadius: 8, style: .continuous)   // 16 − 8 padding
            .fill(.background)
            .padding(8)
    )
```

**Rule:** Always use `.continuous` corner style — Apple's squircle — not the default circular corner. And compute inner radii against outer radii minus padding. If the math goes negative, the inner surface shouldn't be rounded at all.

**Rule:** Before applying `.glassEffect()`, answer: does this surface genuinely float above content the user is reading or scrolling through? If no, use a plain background. If yes, wrap it in `GlassEffectContainer` with siblings so they read as one pane.

---

**Avoid:** Hand-rolled `Color.opacity` + `.blur` translucency. Stacking multiple material levels on one surface. Applying `.glassEffect()` to non-floating content. Using default circular corners instead of `.continuous`. Ignoring concentric math on nested rounded rectangles.
