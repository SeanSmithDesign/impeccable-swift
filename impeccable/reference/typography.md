# Typography

Type on Apple platforms is a Dynamic Type system. Stop hardcoding point sizes. Every text style scales with the user's accessibility settings, or you are shipping a broken app.

## Dynamic Type Is the Contract

Use SwiftUI's semantic text styles — `.largeTitle`, `.title`, `.title2`, `.title3`, `.headline`, `.body`, `.callout`, `.subheadline`, `.footnote`, `.caption`, `.caption2`. Each one is a contract with the OS: "scale me according to the user's settings." Ship any font size that doesn't honor that contract and users with vision needs lose access to your app.

```swift
// CORRECT — scales with user preference, honors accessibility
Text("Welcome").font(.largeTitle)
Text("Your weekly summary").font(.title3)
Text("Body copy that scales.").font(.body)
Text("12 min read").font(.footnote).foregroundStyle(.secondary)
```

**Cardinal sin: fixed-pt body text.** `.font(.system(size: 15))` looks fine in the simulator and breaks the moment a user bumps their Dynamic Type setting. If you find yourself reaching for a numeric size, stop — pick the semantic style that matches the role. The only places a fixed size is defensible are single-character icons inside a fixed badge, and numbers inside a tight data visualization where wrapping would break the chart.

## @ScaledMetric for Custom Sizes

When a design calls for a size the semantic styles don't offer — a hero display type at 56pt, a condensed metric at 13pt — use `@ScaledMetric`. It scales your custom value proportionally with the user's Dynamic Type setting.

```swift
struct HeroHeadline: View {
    @ScaledMetric(relativeTo: .largeTitle) private var size: CGFloat = 56
    @ScaledMetric(relativeTo: .largeTitle) private var tracking: CGFloat = -1.2

    var body: some View {
        Text("Impeccable")
            .font(.system(size: size, weight: .semibold, design: .default))
            .tracking(tracking)
    }
}
```

`relativeTo:` anchors your custom size to the closest semantic style, so it scales on the same curve as other text of that role. A 56pt hero pinned to `.largeTitle` grows at the same rate as the OS's own large title — the hierarchy holds at every Dynamic Type level.

Clamp with `.dynamicTypeSize(...DynamicTypeSize.accessibility3)` only when a specific layout genuinely cannot accommodate larger sizes (a navigation bar, a dense table cell). Never clamp the whole app. The user set that preference for a reason.

## Weight Discipline

Two weights per surface. That's the rule. A body weight and a bold weight cover 95% of cases — `.regular` for prose, `.semibold` for headings and emphasis. Reach for a third only when you have a genuine structural need (a display weight on the hero, a caption weight in fine print).

**Anti-pattern: weight-salad.** If a screen uses `.regular`, `.medium`, `.semibold`, and `.bold` in the same visual hierarchy, the hierarchy is broken. The eye has nothing to latch onto because every element is competing for "slightly more important than the one next to it." Pick two weights. Commit.

Weight maps to semantic role, not to taste:

| Weight      | Role                                               |
| ----------- | -------------------------------------------------- |
| `.regular`  | Body text, secondary labels, metadata              |
| `.semibold` | Headings, active state, emphasis in-line           |
| `.bold`     | Reserved for display type and single-word emphasis |
| `.medium`   | Use only inside SF Symbols for icon-text alignment |

## SF Pro Is the Default

SF Pro is Apple's system font. It ships free with every Apple device, is optically adjusted for every size from 9pt to 96pt, includes the full SF Symbols set, and reads as native. Use it unless you have a deliberate brand reason not to.

If you must use a custom font, register it in `Info.plist` under `UIAppFonts` (iOS) or `ATSApplicationFontsPath` (macOS), then wrap it in `@ScaledMetric` so it still scales with Dynamic Type:

```swift
struct BrandHeadline: View {
    @ScaledMetric(relativeTo: .title) private var size: CGFloat = 28

    var body: some View {
        Text("Brakus")
            .font(.custom("NeueHaasGrotesk-Medium", size: size, relativeTo: .title))
    }
}
```

Never mix a custom font with SF Pro in the same hierarchy unless you intend the contrast — custom display face + SF Pro body is fine; custom sans + SF Pro for a subheading is visual noise.

## One Family, Multiple Weights

You rarely need a second font family. SF Pro has four optical variants — SF Pro Text (small sizes), SF Pro Display (large sizes), SF Pro Rounded (friendly/playful), SF Mono (code) — and the system picks the right variant automatically when you use semantic styles. That's already four fonts' worth of range.

If you do pair, contrast on multiple axes: a geometric display with a humanist body, a serif headline with a sans body. Never pair two sans-serifs that are "almost the same" — the eye perceives it as a rendering bug.

## Numerics: Tabular and Proportional

For any data display — tables, counters, timers, prices — use monospaced digits so the numbers don't jitter as they update:

```swift
Text(price, format: .currency(code: "USD"))
    .monospacedDigit()

// Or for a whole label:
Text("\(count)")
    .font(.body.monospacedDigit())
```

Without `.monospacedDigit()`, the `1` is narrower than the `8`, so a counter ticking from `188` to `189` visibly shifts. That jitter reads as a bug.

## Line Height, Tracking, Measure

SwiftUI handles line height automatically via the semantic styles. When you build custom layouts, target:

- **Measure:** 50–75 characters per line for body text. Use `.frame(maxWidth: 640)` as a rough ceiling for reading columns. Narrower on phones, wider is fine only for short blurbs.
- **Tracking:** Negative tracking (`-0.5` to `-1.5`) on large display type (32pt+) tightens what otherwise looks airy. Never apply negative tracking to body text.
- **Line spacing:** `.lineSpacing(4)` on prose-heavy views adds breathing room. The semantic styles already include their own leading; only override when you have a specific composition reason.

## Color, Contrast, Semantic Styles

Use SwiftUI's semantic colors, not custom hex:

```swift
Text("Primary").foregroundStyle(.primary)
Text("Secondary").foregroundStyle(.secondary)
Text("Tertiary").foregroundStyle(.tertiary)
```

`.primary`, `.secondary`, and `.tertiary` respect dark mode, high-contrast mode, and accessibility color filters automatically. Hardcoded hex values don't — they break in dark mode and fail contrast audits on anything but the exact light-mode background they were designed for.

---

**Avoid:** Hardcoded `.font(.system(size:))` for body text. More than two weights per surface. Custom fonts without `@ScaledMetric`. Clamping Dynamic Type globally. Non-tabular digits in data. Pairing two sans-serifs that are almost the same.
