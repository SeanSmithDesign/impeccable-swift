# Colorize

Strategically introduce color to designs that are too monochromatic, gray, or lacking in visual warmth and personality. On Swift platforms, "color" means Asset Catalog Color Sets with semantic names, dark-mode variants, and contrast-checked values: not hex literals scattered across view files.

> **Additional context needed**: existing brand colors and whether the host app already has a Color extension.

---

## Register

**Brand:** palette IS voice. Pick a color strategy first (Restrained / Committed / Full palette / Drenched) and follow its dosage. Committed, Full palette, and Drenched deliberately exceed the 10-percent rule: that rule is Restrained only.

**Product:** semantic-first and almost always Restrained. Accent color is reserved for primary action, current selection, and state indicators: not decoration. Every color has a consistent meaning across every screen.

---

## The Asset Catalog Is The Palette

Before reaching for any color, read [`color-and-contrast.md`](color-and-contrast.md). That doc establishes the two-layer token model (primitives + semantics), dark-mode design rules, and WCAG contrast tables. This doc does not repeat those foundations; it shows how `colorize` applies them.

**Rule:** Every color the UI sees lives in the Asset Catalog as a named Color Set with explicit Any Appearance and Dark Appearance values. Reference via a typed Swift extension. No hex literals, no `Color(red:green:blue:)`, no `.blue`.

```swift
// Anti-pattern
Label("Confirm", systemImage: "checkmark.circle.fill")
    .foregroundStyle(Color(red: 0.2, green: 0.72, blue: 0.4))

// Rule
extension Color {
    static let feedbackSuccess = Color("feedbackSuccess")
    static let accentPrimary   = Color("accentPrimary")
}

Label("Confirm", systemImage: "checkmark.circle.fill")
    .foregroundStyle(.feedbackSuccess)
```

---

## Assess Color Opportunity

Analyze the current state before touching anything:

1. **Color absence**: Pure gray surfaces? One timid system accent? No semantic states?
2. **Missed opportunities**: Where could color add meaning, hierarchy, or delight?
3. **Context**: What domain and audience? What emotional register is appropriate?
4. **Brand**: Does the host app have a Color extension or existing Asset Catalog Color Sets?

If any of these are unclear from the codebase, stop and ask before proceeding.

**Critical:** More color does not mean better. Strategic color beats visual noise every time. Every color should have a purpose.

---

## Plan Color Strategy

Choose a strategy and a small palette before writing a single line of code:

- **Color palette**: 2-4 colors beyond neutrals. Name them before you place them.
- **Dominant color**: Which color owns 60% of colored elements?
- **Accent colors**: 30% and 10% supporting and highlight roles.
- **Application plan**: Which Color Set appears where, and why?

---

## Build Color Sets In The Asset Catalog

Each color requires three slots in the Asset Catalog:

| Slot            | Purpose                                                     |
| --------------- | ----------------------------------------------------------- |
| Any Appearance  | Light mode value, also the fallback                         |
| Dark Appearance | Dark mode value, chosen for dark: not a light inversion    |
| High Contrast   | Increases contrast by ~10-15% for Increase Contrast setting |

### Semantic Color Set Naming Convention

Use camelCase semantic names. Avoid encoding the raw color value in the name.

```
accentPrimary         : brand CTA, selection, focus ring
accentSecondary       : supporting accent, 30% role
surfaceQuaternary     : subtle tinted background wash
feedbackSuccess       : green semantic state
feedbackWarning       : amber semantic state
feedbackError         : red semantic state
feedbackInfo          : blue semantic state
```

### Color Extension (Color+Semantic.swift)

```swift
extension Color {
    // Accent
    static let accentPrimary   = Color("accentPrimary")
    static let accentSecondary = Color("accentSecondary")

    // Surfaces
    static let surfaceQuaternary = Color("surfaceQuaternary")

    // Semantic feedback
    static let feedbackSuccess = Color("feedbackSuccess")
    static let feedbackWarning = Color("feedbackWarning")
    static let feedbackError   = Color("feedbackError")
    static let feedbackInfo    = Color("feedbackInfo")
}
```

If the project organizes brand colors behind a namespace:

```swift
extension Color {
    enum brand {
        static let amber  = Color("brand.amber")
        static let forest = Color("brand.forest")
    }
}

// Usage
Icon()
    .foregroundStyle(Color.brand.amber)
```

---

## Introduce Color Strategically

### Semantic Color (States)

Semantic colors carry meaning. They must be consistent across every screen.

```swift
// Success state: icon + label, never color alone
HStack(spacing: 6) {
    Image(systemName: "checkmark.circle.fill")
    Text("Saved")
}
.foregroundStyle(.feedbackSuccess)

// Warning badge
Text(pendingCount, format: .number)
    .font(.caption.bold())
    .foregroundStyle(.feedbackWarning)

// Error inline message
Text(errorMessage)
    .font(.footnote)
    .foregroundStyle(.feedbackError)
```

For WCAG contrast requirements on semantic colors and the full success/warning/error palette guidance, see [`color-and-contrast.md`](color-and-contrast.md) and [`accessibility.md`](accessibility.md).

**Never use color as the only state indicator.** Pair with an icon, label, or shape.

### Accent Color Application

**System tinting: `.tint`:** The fastest, most consistent way to colorize interactive system components. `.tint` propagates to buttons, toggles, sliders, links, and focus rings.

```swift
// Tint an entire view hierarchy
ContentView()
    .tint(.accentPrimary)

// Scope to a single control
Button("Get Started") { onGetStarted() }
    .buttonStyle(.borderedProminent)
    .tint(.accentPrimary)

Toggle("Enable", isOn: $isEnabled)
    .tint(.accentPrimary)
```

**Explicit foreground: `.foregroundStyle`:** Use when control type or semantic meaning needs a specific color that is not the global tint.

```swift
// Icon colorized to category semantic
Image(systemName: category.symbol)
    .foregroundStyle(.feedbackInfo)

// Colored heading
Text("Collections")
    .font(.headline)
    .foregroundStyle(.accentPrimary)
```

**Rule:** Prefer `.tint` for system components. Use `.foregroundStyle` when the semantic needs to deviate from the global tint.

### Background and Surfaces

Use `.background` with Color Set references. Never reach for a material unless the surface genuinely floats above content: see [`materials.md`](materials.md) for the material/glass decision.

```swift
// Tinted section background
List {
    Section {
        content
    }
    .listRowBackground(Color.surfaceQuaternary)
}

// Accent-washed card background
RoundedRectangle(cornerRadius: 12, style: .continuous)
    .fill(Color.accentPrimary.opacity(0.08))
    .overlay {
        cardContent
    }
```

**On opacity:** A repeated `.opacity` value is a token that should exist in the Asset Catalog. If `accentPrimary.opacity(0.08)` appears on more than two surfaces, define `surfaceAccentWash` as a proper Color Set.

### Tinted Neutrals, Not Pure Gray

Pure gray surfaces are dead. Tint every neutral slightly toward the brand hue. Two to five percent saturation is invisible as "color" but audible as "warmth."

Build the neutral scale from the brand hue: if the brand is amber, neutrals lean warm. If the brand is teal, they lean cool. Do not reach for a blue-tinted or warm-tinted neutral by reflex.

See [`color-and-contrast.md`](color-and-contrast.md) for the tinted neutral pattern.

### Borders and Accents

Use hairline borders (1pt, full perimeter). No side-stripe borders (border-left / border-right greater than 1pt as a colored accent): use a full hairline border, a background tint, or a leading glyph instead.

```swift
// Hairline accent border on a card: full perimeter
RoundedRectangle(cornerRadius: 12, style: .continuous)
    .strokeBorder(Color.accentPrimary.opacity(0.35), lineWidth: 1)
```

### Typography Color

```swift
// Colored section header
Text(sectionTitle)
    .font(.subheadline.weight(.semibold))
    .foregroundStyle(.accentSecondary)

// Category label / tag
Text(tag.name)
    .font(.caption.weight(.medium))
    .foregroundStyle(.feedbackInfo)
    .padding(.horizontal, 8)
    .padding(.vertical, 3)
    .background(Color.feedbackInfo.opacity(0.12), in: Capsule())
```

---

## Balance and Refinement

### Hierarchy: 60-30-10

| Weight | Role      | Token examples                     |
| ------ | --------- | ---------------------------------- |
| 60%    | Neutral   | `surfaceBase`, `surfaceRaised`     |
| 30%    | Secondary | `textSecondary`, `borderSubtle`    |
| 10%    | Accent    | `accentPrimary`, `feedbackSuccess` |

Accents work because they are rare. Overuse kills their power.

### Dark Mode

Every Color Set gets an explicit Dark Appearance value chosen for dark mode. Not an inversion of the light value. See [`color-and-contrast.md`](color-and-contrast.md) for the full dark-mode design model.

Key dark-mode divergences for color sets:

- Desaturate accents by 10-15% in dark mode so they don't vibrate
- Semantic feedback colors shift lightness, not hue
- `surfaceQuaternary` uses a lighter-than-base dark value for elevation, not a shadow

### Accessibility

WCAG contrast tables (4.5:1 normal, 3:1 large), dangerous combinations, and color-blindness guidance live in [`color-and-contrast.md`](color-and-contrast.md) and [`accessibility.md`](accessibility.md). Do not duplicate them here.

**Key rules:**

- Every semantic state (success/warning/error) pairs color with an icon, label, or shape
- Simulate Protanopia, Deuteranopia, Tritanopia before shipping any red/green pairing
- Verify placeholder text contrast in light and dark mode (the default fails 4.5:1 on most light surfaces)

### Cohesion

- Same color meanings everywhere: `feedbackSuccess` always means success
- Temperature consistency: warm palette stays warm, cool stays cool
- Colors come from the Asset Catalog only: no ad-hoc additions to fill a one-off screen

**Never:**

- Use more than 2-4 colors beyond neutrals
- Apply color randomly without semantic meaning
- Use pure system colors (`.blue`, `.red`) as design tokens
- Default to purple-blue gradients (AI-slop aesthetic)
- Use color as the sole indicator of state

---

## Detector Wiring

### asset-catalog-checker

```bash
swift run --package-path tools/asset-catalog-checker asset-catalog-checker <Path/To/Assets.xcassets>
```

`tools/asset-catalog-checker/` reports:

| Finding                        | Severity | What to fix                                        |
| ------------------------------ | -------- | -------------------------------------------------- |
| Missing Dark Appearance swatch | P1       | Add dark-mode value to every Color Set             |
| Missing High Contrast swatch   | P2       | Add high-contrast value; minimum 10-15% boost      |
| Missing accent Color Set       | P1       | `accentPrimary` or equivalent must exist           |
| Contrast failure 4.5:1         | P1       | Adjust lightness until text/surface pair passes AA |
| Contrast failure 3:1           | P1       | Large text and UI components must clear this floor |

Every detector hit is a confirmed finding. Tag severity (P0/P1/P2) and hand to the relevant fix command.

### SwiftLint (tools/.swiftlint.yml)

```bash
swiftlint lint --config tools/.swiftlint.yml --reporter json
```

The `hardcoded_color_literals` rule flags:

- `Color(red:green:blue:)`: bypasses Asset Catalog
- `Color(hex:)`: custom hex initializer, same bypass
- `Color(.sRGB, red:green:blue:alpha:)`: explicit color space form

Every hit is a **Theming** finding at P1 on a user-visible surface, P2 if limited to preview scaffolding.

---

## Verify Color Addition

Before calling this done:

- Better hierarchy: does color guide attention to the right elements?
- Clearer meaning: does color help users understand states and categories?
- More engaging: does the interface feel warmer and more inviting?
- Still accessible: do all Color Set pairs meet WCAG AA in both light and dark?
- Not overwhelming: is color balanced and purposeful?
- asset-catalog-checker: zero P1 findings (no missing dark variants, no contrast failures)
- SwiftLint: zero `hardcoded_color_literals` hits outside of preview files

---

**Avoid:** Inline `Color(red:green:blue:)` or hex initializers. System palette names as tokens (`.blue`, `.red`). Missing Dark Appearance or High Contrast variants in the Asset Catalog. Pure gray ramps with no brand tint. Inverting light-mode values to produce dark-mode values. Using color as the sole indicator of semantic state. Side-stripe colored borders. Purple-blue gradients.
