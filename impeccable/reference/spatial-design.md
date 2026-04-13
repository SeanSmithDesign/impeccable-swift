# Spatial Design

Apple platforms use points (pt), not pixels (px). A point is a logical unit; at 1× it equals one pixel, at 2× (Retina) it's 4 pixels, at 3× (Super Retina) it's 9 pixels. Every spacing and sizing value in this doc is in pt. When Claude reaches for `px` out of web-memory reflex — stop it. SwiftUI has no `px`, no `rem`, no `em`, no `margin`. There is `.padding()`, `.frame()`, and `.spacing`, and they all take CGFloat values measured in points.

## Spacing Scale: 4pt Base

Use a 4pt base scale. 8pt is too coarse — you'll hit the 12pt and 20pt gaps constantly. The valid values:

**4, 8, 12, 16, 20, 24, 32, 44, 64**

Nothing else. Not 13, not 18, not 22, not 42. If a value isn't on the scale, either the design is wrong or you're measuring a screenshot carelessly. The scale is deliberately short so decisions are cheap: "slightly more air" is always the next step up.

```swift
// CORRECT — on-scale values
VStack(spacing: 16) {
    Text("Title").font(.title2)
    Text("Body copy here.").font(.body)
}
.padding(.horizontal, 20)
.padding(.vertical, 24)
```

**Anti-pattern: magic spacing.** `.padding(13)` and `.frame(height: 42)` mean someone measured a comp in Figma and copied the number directly. That number is wrong. Snap to the scale — 12 or 16, 40 or 44. Magic numbers compound: five off-scale values across a screen and the whole layout drifts a quarter-point off rhythm.

Define the scale once, use everywhere:

```swift
enum Space {
    static let xxs: CGFloat = 4
    static let xs:  CGFloat = 8
    static let sm:  CGFloat = 12
    static let md:  CGFloat = 16
    static let lg:  CGFloat = 20
    static let xl:  CGFloat = 24
    static let xxl: CGFloat = 32
    static let tap: CGFloat = 44  // Minimum tap target
    static let huge: CGFloat = 64
}
```

## 44pt Is the Floor for Taps

Apple's Human Interface Guidelines set **44×44pt as the minimum hit target** for any interactive element. This is not guidance — it is the line below which your app fails usability on a real device. An icon button can _look_ 24pt, but its tappable region must be 44pt.

```swift
Button { toggle() } label: {
    Image(systemName: "heart")
        .font(.system(size: 20))
}
.frame(minWidth: 44, minHeight: 44)   // Enforce tap target
.contentShape(Rectangle())             // Make full frame tappable
```

`.contentShape(Rectangle())` is essential — without it, only the pixels of the icon receive taps, not the whitespace around it. Users miss by 10pt and think the app is broken.

**Anti-pattern: ignoring the 44pt tap target.** A visually tight row of 16pt icons with 8pt spacing looks clean and is unusable. Expand the hit region even when it visually overlaps the neighbor — `.contentShape` extends taps, not pixels.

## Padding Replaces Margin

SwiftUI has no `margin`. Every bit of space around a view is padding — either on the view itself or on its container's `spacing:`.

```swift
VStack(alignment: .leading, spacing: 12) {
    Text("Heading").font(.headline)
    Text("Description that wraps.").font(.body)
    Button("Action") { }
}
.padding(20)  // Outer breathing room
```

Use a stack's `spacing:` parameter for sibling rhythm. Use `.padding()` for the gap between a view and its container's edge. Never fake a margin with a `Spacer().frame(height: 16)` — that's the CSS reflex talking.

## Concentric Corners

When a view with a corner radius contains another view with a corner radius, the inner radius must equal the outer radius minus the padding. This is the concentric corner rule, and breaking it is the single most common reason a Swift app looks "off."

```
Outer radius: 16pt, padding: 8pt  →  Inner radius must be 8pt
Outer radius: 20pt, padding: 12pt →  Inner radius must be 8pt
```

```swift
// Parent card, rounded 16pt, padded 8pt
RoundedRectangle(cornerRadius: 16, style: .continuous)
    .fill(.background)
    .overlay(
        // Child image, must be rounded 8pt (16 - 8)
        Image("cover")
            .resizable()
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .padding(8)
    )
```

Always use `style: .continuous` for rounded rectangles. The default `.circular` style uses a quadrant-arc curve that looks hard and mechanical next to Apple's `.continuous` (superellipse) curves. Mixing the two styles in the same view reads as a bug.

**Anti-pattern: square corners in soft contexts.** If the parent is rounded 16pt, a child with `.cornerRadius(0)` — a raw image, a flat button, a square avatar — shatters the composition. Everything nested inside a rounded container must be rounded. No exceptions.

## Hierarchy Through Multiple Dimensions

Spacing alone doesn't create hierarchy. Combine size, weight, color, and space. The squint test: blur the screen (literally, or step back six feet). Can you still identify the primary element? The second? The grouping? If everything blurs to the same gray weight, the hierarchy is broken.

| Tool                             | Strong Hierarchy           | Weak Hierarchy                        |
| -------------------------------- | -------------------------- | ------------------------------------- |
| **Size (via Dynamic Type role)** | `.largeTitle` vs `.body`   | `.title3` vs `.headline`              |
| **Weight**                       | `.semibold` vs `.regular`  | `.medium` vs `.regular`               |
| **Color**                        | `.primary` vs `.secondary` | `.primary` vs `.primary.opacity(0.9)` |
| **Position**                     | Top-leading                | Scattered                             |
| **Space**                        | 24pt of breathing room     | 4pt of crowding                       |

The best hierarchy uses two or three dimensions at once — a heading that is larger, heavier, AND has more space above it. Relying on size alone gives you flat, sterile layouts.

## Cards Are Not Required

Cards are the default AI-generated output and almost always wrong. Spacing and alignment create visual grouping naturally. Reach for a card only when content is genuinely distinct, genuinely actionable, and genuinely a grid of comparable items. Never nest cards inside cards — use spacing, type weight, and dividers for internal hierarchy.

## Depth and Elevation

Use `.shadow(radius:x:y:)` sparingly. A shadow should be felt, not seen — if you can clearly see the shadow, it's too strong. Two elevation levels cover most apps:

```swift
// Resting surface
.shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)

// Floating element (menu, popover)
.shadow(color: .black.opacity(0.12), radius: 24, x: 0, y: 8)
```

Prefer material backgrounds (`.regularMaterial`, `.thinMaterial`) over shadows when placing elements over content — they communicate depth without the decorative weight of a drop shadow.

Use `.zIndex` only within a single `ZStack` for explicit ordering. Never ship an arbitrary z-index scale — SwiftUI's layout hierarchy handles elevation.

## Optical Adjustments

Geometrically centered icons look off-center. Play/forward-pointing icons need to shift ~1pt right because their visual mass leans left. Apple's SF Symbols are pre-adjusted, so use them — only compensate when using custom artwork, and measure by eye, not by math.

Text aligned to `leading: 0` looks slightly indented due to letterform whitespace. This matters when a large-title text sits next to a leading-edge image in a header. A -1pt to -2pt `.padding(.leading, -1)` optically squares it. Rare — only for hero typography.

---

**Avoid:** Off-scale spacing values. Hit targets under 44pt. Square corners inside rounded parents. `.circular` rounded rectangles (always `.continuous`). Nested cards. Visible shadows. Hierarchy through size alone. Any occurrence of `px`, `rem`, `em`, or `margin` in your Swift code — those words do not exist on this platform.
