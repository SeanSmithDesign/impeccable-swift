# Typeset

Assess and improve typography that feels generic, inconsistent, or poorly structured. On Apple platforms the solution is almost never a different typeface: it is better role assignment, correct semantic styles, and weight discipline.

---

## Register

**Brand:** Typography is voice. Consult [`brand.md`](brand.md) for font selection and the reflex-reject list before committing to a custom face. For display moments, New York or SF Pro Rounded are platform-native options with strong personality: reach for them before importing a third-party font.

**Product:** SF Pro carries the whole UI. One well-tuned system family, correctly assigned to semantic roles, reads as native and scales with Dynamic Type. Custom fonts are justified only when a brand identity explicitly demands them.

---

## Assess Current Typography

Analyze what is weak or generic about the current type before changing anything.

1. **Font choices**: Are hardcoded `.font(.system(size:))` calls standing in for semantic roles? Are custom fonts being used without `@ScaledMetric` wiring? Is SF Rounded or New York being used where plain SF Pro would serve better (or vice versa)?

2. **Hierarchy**: Can you distinguish heading, body, and caption at a glance? Are `.headline` and `.body` used on the same visual tier (they share the 17pt default; the difference is weight, not scale: they signal emphasis within a tier, not tier separation)?

3. **Weight discipline**: More than two weights per surface is almost always a symptom of a broken hierarchy. Define two weights and commit.

4. **Readability**: Is body text comfortable in a reading passage? Is tracking applied where it helps (tight on large display type, slightly open on all-caps labels) and skipped where it hurts (body text)?

5. **Consistency**: Do same-role elements use the same semantic style throughout? Are weights used consistently for each role?

**CRITICAL:** The goal is not to make text "more designed." It is to make it clearer, more readable, and more intentional. Good typography disappears; bad typography distracts.

---

## Plan Typography Improvements

Read [`typography.md`](typography.md) before planning. That doc establishes the full SwiftUI mechanics: the 11-style reference table, `@ScaledMetric` wiring, single-line label patterns, weight discipline, numerics, line height, tracking, and rendering polish. This doc does not repeat those foundations; it shows how `typeset` applies them.

Create a systematic plan:

- **Role assignment**: Map each text element to the correct semantic style (`.headline` for the list row label, `.body` for reading prose, `.caption` for form hints). Size is a consequence of role.
- **Weight strategy**: Identify two weights per surface. Typical split: `.regular` for body, `.semibold` for headings and emphasis.
- **Design variant**: Does the context call for SF Pro Rounded (playful, approachable), SF Pro Mono / `.fontDesign(.monospaced)` (code, technical), or New York / `.fontDesign(.serif)` (editorial, reading-heavy)? Default is plain SF Pro.
- **Custom fonts**: If the host app has a registered custom font, confirm it is wrapped in `Font.custom(_:size:relativeTo:)` so Dynamic Type still applies. See [`typography.md`](typography.md) for registration and `@ScaledMetric` wiring.
- **Spacing**: Identify where `.lineSpacing()`, `.tracking()`, or a constrained reading frame add clarity.

---

## Improve Typography Systematically

### Font Selection

SF Pro is not the invisible default problem. It is the right choice for most product surfaces. The failure mode is using it _incorrectly_: wrong semantic style, missing weight contrast, hardcoded sizes that break Dynamic Type.

For the rare cases where a brand demands a custom face:

```swift
// CORRECT: custom font that still scales with Dynamic Type
struct BrandTitle: View {
    var body: some View {
        Text("Acme")
            .font(.custom("BrandFont-Semibold", size: 28, relativeTo: .title))
    }
}
```

`Font.custom(_:size:relativeTo:)` preserves Dynamic Type scaling. Raw `Font.custom(_:size:)` does not. See [`typography.md`](typography.md) for bundle registration and runtime loading.

SF Pro design variants: use them before reaching for a third-party font:

```swift
// Rounded: friendly, approachable, consumer apps
Text("Good morning").font(.system(.title3, design: .rounded, weight: .semibold))

// Monospaced: code, terminals, numeric data, technical register
Text(codeSnippet).font(.system(.body, design: .monospaced))

// Serif (New York): editorial, reading-heavy, long-form
Text(articleBody).font(.system(.body, design: .serif))
```

### Establish Hierarchy

Assign roles from the semantic style set. The size is a consequence of the role, not a target:

| Style          | Default | Role                                               |
| -------------- | ------- | -------------------------------------------------- |
| `.largeTitle`  | 34pt    | Navigation bar large title; primary screen title   |
| `.title`       | 28pt    | First-level heading within a view                  |
| `.title2`      | 22pt    | Second-level heading                               |
| `.title3`      | 20pt    | Third-level heading, subpage titles                |
| `.headline`    | 17pt    | List row primary label; semibold at body scale     |
| `.body`        | 17pt    | Primary reading text                               |
| `.callout`     | 16pt    | Secondary content in cards, sidebars               |
| `.subheadline` | 15pt    | Supporting text under a headline; metadata rows    |
| `.footnote`    | 13pt    | Timestamps, source attribution, supplementary info |
| `.caption`     | 12pt    | Image captions; form field labels below inputs     |
| `.caption2`    | 11pt    | Badges, micro-labels. Use sparingly.               |

**Weight contrast is hierarchy.** Five sizes within 3pt of each other is a muddy scale. Two strong weights (`.regular` and `.semibold`) plus generous size steps creates instant, scannable structure. Combine size + weight + color + spacing to differentiate levels; relying on size alone rarely works.

For repeated style sets, extract a `ViewModifier` rather than repeating modifier chains:

```swift
struct CardLabelStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(.footnote, design: .default, weight: .medium))
            .foregroundStyle(.secondary)
            .textCase(.uppercase)
            .tracking(0.6)
    }
}

extension View {
    func cardLabel() -> some View {
        modifier(CardLabelStyle())
    }
}
```

### Dynamic Type

Every text style auto-scales. That is the contract. Do not break it.

The current Dynamic Type size is available via `@Environment(\.dynamicTypeSize)` when you need to adapt layout, not font size:

```swift
struct AdaptiveRow: View {
    @Environment(\.dynamicTypeSize) private var typeSize

    var body: some View {
        if typeSize >= .accessibility1 {
            VStack(alignment: .leading) { label; detail }
        } else {
            HStack { label; Spacer(); detail }
        }
    }
}
```

Use `dynamicTypeSize` to switch layout direction, not to gate font sizing. See [`accessibility.md`](accessibility.md) for the full Dynamic Type support model, clamping rules, and minimum scale factors for single-line labels.

Supported range: `.xSmall` through `.accessibility5`. At `.accessibility5`, `.largeTitle` reaches ~56pt and `.caption2` reaches ~20pt. Layouts must accommodate this range. Use `ScrollView` on content that will overflow; never assume text fits in a fixed-height container.

### Fix Readability

- **Body size floor:** SF Pro Body at its default 17pt is the platform minimum for comfortable iPhone reading. Do not go smaller for prose. If a design comp shows 14pt body text, use `.callout` (16pt) or `.subheadline` (15pt) and accept the semantic style.
- **Line length:** Target 50-75 characters per reading line. Use `.frame(maxWidth: 640)` as a ceiling for reading columns; narrower on phones. Drive `maxWidth` off a `@ScaledMetric` value so it grows with type at large accessibility sizes.
- **Line spacing:** `.lineSpacing(4)` on prose-heavy views adds breathing room. The semantic styles already include their own leading; override only when you have a specific composition reason.
- **Dark-background compensation:** Light type on dark fields reads as lighter than it is. Fix on three axes: nudge `.lineSpacing` up 2-4pt, add subtle positive `.tracking(0.2)` to `.tracking(0.4)`, and consider stepping body weight up one notch (`.regular` to `.medium`).

### Refine Details

- **Tracking:** Apply negative tracking (`-0.5` to `-1.5`) on large display type (32pt+) to close what otherwise looks airy. Never apply negative tracking to body text: it compounds at large Dynamic Type sizes.
- **All-caps:** Any time you use `.textCase(.uppercase)`, pair it with positive tracking. Roughly 5-12% of the point size: 0.6-1.4pt at body scale, 1.5-4pt at display scale.
- **Tabular numerics:** Use `.monospacedDigit()` on counters, prices, timers, and any data that updates. Without it, digit-width variation causes visible jitter.
- **Semantic foreground styles:** Use `.foregroundStyle(.primary)`, `.secondary`, `.tertiary` rather than custom hex. These respect dark mode, high contrast, and accessibility color filters automatically.

---

## Verify Typography Improvements

- **Hierarchy**: Heading vs. body vs. caption: distinct at a glance?
- **Readability**: Body text comfortable in a reading passage?
- **Consistency**: Same-role elements use the same semantic style across every screen?
- **Dynamic Type**: All text scales from `.xSmall` to `.accessibility5` without truncation or layout breaks? Test in the Simulator with Settings > Accessibility > Larger Text.
- **Weight discipline**: Two weights per surface maximum?
- **Details**: Tabular numerics where needed? Tracking applied correctly? No hardcoded `.font(.system(size:))` calls?

---

## Detector Wiring

### impeccable-lint

```bash
swift run --package-path tools/impeccable-lint impeccable-lint <TargetDirectory>
```

Two checks feed typography findings:

- **Hardcoded point sizes**: Flags `.font(.system(size: 14))` and similar numeric literals not drawn from a semantic style or a named `AppFont` enum. Every hit is a Dynamic Type breakage at P1: the text will not scale.
- **Missing `.font()` modifiers**: Flags `Text` views with no explicit font assignment. These inherit the default `.body` style, which may be correct, but is often an oversight on subheadline or caption-role content. Verify intent; promote to explicit if the role differs.

### SwiftLint custom rules

```bash
swiftlint lint --config tools/.swiftlint.yml --reporter json
```

`tools/.swiftlint.yml` includes a custom rule flagging non-semantic font literals: any `Font` value constructed with a raw numeric size outside of a `@ScaledMetric` wrapper or a documented display-only exemption. Findings feed the **Responsive Design** dimension in `audit.md`.

### Inconsistent weight usage

`impeccable-lint` also catches surfaces where three or more distinct font weights appear within the same view hierarchy. The finding surface is the containing `View` file; review manually to confirm whether each weight is carrying a distinct semantic role or is weight-salad.

---

## Live-Mode Signature Params

Each typeset variant declares a `scale` param controlling the type hierarchy ratio. Express relative sizing through `@ScaledMetric` values driven by the param. Users slide from subdued to commanding.

```json
{
  "id": "scale",
  "kind": "range",
  "min": 0.85,
  "max": 1.3,
  "step": 0.05,
  "default": 1,
  "label": "Scale"
}
```

Where the variant riffs on a specific design variant (Rounded, Serif, Monospaced), expose the variant choice as a `steps` param. Each branch selects the appropriate `.fontDesign(_:)` value.

See [`reference/live.md`](live.md) for the full params contract (deferred to stub phase).

---

**Avoid:** Hardcoded `.font(.system(size:))` for any role-carrying text. More than two weights per surface. Custom fonts without `Font.custom(_:size:relativeTo:)` or `@ScaledMetric`. Clamping Dynamic Type globally. Non-tabular digits in data. Negative tracking on body text. Pairing two sans-serifs that are almost the same.
