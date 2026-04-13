# Color & Contrast

Color in SwiftUI is a token system, not a palette. Every color the user sees should come from the Asset Catalog with per-appearance values and a semantic name. Hardcoded values are debt.

## Color Lives In The Asset Catalog

**Stop hardcoding colors in SwiftUI.** Every color is a decision that needs a light value, a dark value, a name, and one place to change it. Inline `Color(red:green:blue:)` calls are the SwiftUI equivalent of magic numbers — they fragment the palette across the codebase and make theming impossible.

**Rule:** Every color used by the UI lives in the Asset Catalog as a named color set with explicit Any Appearance and Dark Appearance values. Reference it via `Color("text.primary")` or a typed extension.

```swift
// Anti-pattern
Text("Hello")
    .foregroundColor(Color(red: 0.12, green: 0.12, blue: 0.14))
    .background(Color(red: 0.98, green: 0.98, blue: 0.96))

Text("Hello")
    .foregroundColor(.blue) // system palette, not a token

// Rule
extension Color {
    static let textPrimary = Color("text.primary")
    static let surfaceBase = Color("surface.base")
    static let brandPrimary = Color("brand.primary")
}

Text("Hello")
    .foregroundColor(.textPrimary)
    .background(.surfaceBase)
```

**Anti-pattern — "The Inline Hex."** A designer says "make this warmer" and the engineer reaches for `Color(red: 0.8, green: 0.5, blue: 0.2)`. The value now exists nowhere else and cannot be updated in one place. Every inline color is a future bug in dark mode or theming.

**Anti-pattern — "`.foregroundColor(.blue)`."** The system palette (`.blue`, `.red`, `.green`) is a debug tool, not a design system. Those values change across OS versions, don't match your brand, and teach the codebase that "blue" is a valid token. It isn't.

## Two Layers Of Tokens

**Separate primitives from semantics.** The Asset Catalog holds _primitive_ color sets (`brand.50` through `brand.900`, `neutral.50` through `neutral.950`). SwiftUI views reference _semantic_ tokens (`.textPrimary`, `.surfaceBase`, `.borderSubtle`) which resolve to primitives.

This gives you one knob to change the brand (swap primitives) without touching views, and one knob to restructure hierarchy (swap semantics) without touching primitives.

```swift
// Semantic extension (Color+Semantic.swift)
extension Color {
    // Surfaces
    static let surfaceBase    = Color("surface.base")
    static let surfaceRaised  = Color("surface.raised")
    static let surfaceOverlay = Color("surface.overlay")

    // Text
    static let textPrimary   = Color("text.primary")
    static let textSecondary = Color("text.secondary")
    static let textTertiary  = Color("text.tertiary")

    // Brand + semantic
    static let brandPrimary = Color("brand.primary")
    static let destructive  = Color("semantic.destructive")
    static let success      = Color("semantic.success")
}
```

## Tinted Neutrals, Not Pure Gray

**Pure gray is dead.** A neutral with zero saturation reads as lifeless next to any brand color. Every neutral in the palette should carry a tiny amount of the brand hue — small enough to read as "neutral" but enough to feel cohesive with the brand.

**Rule:** Build neutrals by taking the brand hue and desaturating it to roughly 2–5% saturation. Never ship a gray scale that is truly chromatic zero.

**Anti-pattern — "The Stock Gray Ramp."** Designer uses Apple's `systemGray` 1 through 6. It's adequate but generic — every app on the platform ships with that ramp. A two-tick hue shift toward your brand color makes the surfaces belong to _this_ product.

The hue you tint toward must come from _this_ project's brand. If the brand is terracotta, neutrals lean warm. If the brand is teal, they lean cool. There is no default. Do not reach for blue-tinted or warm-tinted neutrals by reflex — those are the AI-design defaults, not the right answer.

## Palette Roles, Not Palette Counts

**A complete palette has roles, not just colors.**

| Role     | Purpose                              | Scale                     |
| -------- | ------------------------------------ | ------------------------- |
| Brand    | CTAs, key actions, selection         | 1 color, 3–5 shades       |
| Neutral  | Text, backgrounds, borders, surfaces | 9–11 shade scale          |
| Semantic | Success, error, warning, info        | 4 colors, 2–3 shades each |
| Surface  | Base, raised, overlay                | 2–3 elevation levels      |

**Skip secondary and tertiary brand colors unless the product needs them.** Most apps work with one accent. Adding more creates decision fatigue at the design level and visual noise at the UI level.

## The 60-30-10 Rule

**This is about visual weight, not pixel count.** 60% neutral surfaces, 30% secondary (text, borders, inactive chrome), 10% accent (CTAs, focus, highlights). The mistake is using the accent color everywhere "because it's on-brand." Accents work _because_ they're rare. Overuse kills their power.

## Contrast Is Non-Negotiable

**WCAG thresholds apply on Apple platforms too.** SF Pro being beautiful does not lift the contrast floor.

| Content                           | AA Minimum | AAA Target |
| --------------------------------- | ---------- | ---------- |
| Body text                         | 4.5:1      | 7:1        |
| Large text (20pt+ or 17pt bold)   | 3:1        | 4.5:1      |
| UI components, icons, focus rings | 3:1        | 4.5:1      |

**The gotcha: placeholder text.** The default `.placeholder` color in `TextField` fails 4.5:1 on most light surfaces. If placeholders carry information, they need to meet body text contrast. If they carry format hints only, mark the field's accessibility value explicitly and accept that placeholders are a visual affordance, not a primary channel.

### Dangerous Combinations

- Light gray text on white — the #1 accessibility fail on the platform
- Gray text on any tinted surface — reads washed out; darken the surface hue instead
- Red text on green or vice versa — 8% of men cannot distinguish these
- Yellow text on white — almost always fails
- Thin text (`.font(.subheadline).weight(.light)`) over imagery — contrast becomes unpredictable

**Never use pure white or pure black for large surfaces.** `Color.white` and `Color.black` don't exist in nature — every real surface has a cast. Even a 2% tint toward the brand hue makes backgrounds feel intentional instead of default.

## Dark Mode Is A Design, Not An Inversion

**Dark mode is not `.preferredColorScheme(.dark)` applied to light mode tokens.** It is a separate set of design decisions that share the brand hue but diverge on surface, elevation, weight, and saturation.

**Rule:** Every semantic token has an explicit Dark Appearance value in the Asset Catalog, chosen for dark mode specifically — not derived by inverting the light value.

| Light mode                 | Dark mode                                        |
| -------------------------- | ------------------------------------------------ |
| Depth via shadows          | Depth via surface lightness                      |
| Dark text on light         | Light text on dark, slightly lighter weight      |
| Saturated accents          | Desaturate accents ~10–15%                       |
| Pure-ish whites            | Never pure black — use dark gray with brand tint |
| `Color.primary` reads dark | `Color.primary` reads light (handled by system)  |

In dark mode, elevation comes from lightness, not shadow. Build a three-step surface scale where raised surfaces are _lighter_ than base, not the same color with a shadow. Use the same hue and chroma as the brand, vary only lightness (e.g. 12% / 16% / 20% L\*).

**Anti-pattern — "Inverted light mode."** A view uses `.background(.white)` and `.foregroundColor(.black)`. In dark mode these become `.black` / `.white` and the contrast inverts. But the brand token that looked great on white now vibrates on black. Dark mode needs its own token values, not a color flip.

## Detect Scheme Deliberately

**Read `@Environment(\.colorScheme)` when a token cannot express the answer.** 95% of the time the Asset Catalog handles appearance for you. The exception is when a component renders an image or asset that depends on scheme, or when a spring-physics effect needs different parameters.

```swift
struct Hero: View {
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        Image(scheme == .dark ? "hero.dark" : "hero.light")
            .resizable()
            .scaledToFill()
    }
}
```

Do not use `colorScheme` to compute colors at runtime. That's the Asset Catalog's job.

## Alpha Is A Design Smell

**Heavy use of `.opacity(_:)` usually means an incomplete palette.** Transparency creates unpredictable contrast against whatever sits behind it, costs performance on stacked layers, and introduces inconsistency across contexts. Every repeated alpha value is a token that wants to exist.

**Rule:** Define explicit overlay colors per context in the Asset Catalog (`surface.overlay.sheet`, `surface.overlay.toast`, `border.subtle`). Reserve `.opacity` for focus rings, press states, and Material effects where see-through is genuinely required.

**Anti-pattern — "`.opacity(0.6)` everywhere."** Every secondary text in the app uses `.foregroundColor(.primary).opacity(0.6)`. That 0.6 is a token — give it a name (`.textSecondary`) and ship it as a proper Asset Catalog color with its own light/dark values. It will contrast more predictably and won't composite over random backgrounds.

## Testing

**Don't trust your eyes.** Verify contrast with tools.

- Xcode → Accessibility Inspector → Audit
- `.dynamicTypeSize(.accessibility5)` preview + contrast check
- Apple's Accessibility Inspector → Color Contrast calculator
- Simulate Protanopia / Deuteranopia / Tritanopia via Settings → Accessibility → Display & Text Size → Color Filters during device testing

---

**Avoid:** Hardcoding hex or RGB inline. Using `.foregroundColor(.blue)` or other system palette names as tokens. Shipping `Color.white` / `Color.black` for large surfaces. Inverting light mode to produce dark mode. Relying on color alone to convey state (always pair with icon, label, or shape). Skipping color-blindness testing.
