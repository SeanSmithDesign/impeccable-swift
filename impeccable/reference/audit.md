# Audit

Run systematic **technical** quality checks and generate a comprehensive report. Don't fix issues: document them for other commands to address.

This is a code-level audit, not a design critique. Check what's measurable and verifiable in the implementation.

## Swift Detector Arm

Before the manual scan, run the three automated detectors. Their findings feed directly into the scored dimensions below. A detector hit is a pre-confirmed finding: skip re-verification and jump straight to severity tagging.

### Run: SwiftLint custom rules

```bash
swiftlint lint --config tools/.swiftlint.yml --reporter json
```

`tools/.swiftlint.yml` enforces two custom rules that feed this audit:

- **`hardcoded_color_literals`**: Flags `Color(red:green:blue:)` and `UIColor(red:green:blue:alpha:)` that bypass the Asset Catalog Color Set system. Every hit is a **Theming** finding; severity is P1 if it appears on a user-visible surface, P2 if confined to preview scaffolding.
- **`missing_accessibility_label`**: Flags `Image(systemName:)`, `Image(_:)`, and any `Button` whose label is a bare `Image` without `.accessibilityLabel(_:)`. Every hit is an **Accessibility** finding at P1 (WCAG 1.1.1 Non-text Content).

### Run: impeccable-lint

```bash
swift run --package-path tools/impeccable-lint impeccable-lint <TargetDirectory>
```

`tools/impeccable-lint/` is a SwiftSyntax CLI with two detectors:

- **Missing `@Environment` propagation**: Catches views that consume a value (e.g., `colorScheme`, `dynamicTypeSize`, `accessibilityReduceMotion`) via local reads instead of `@Environment`. Results feed **Theming** (color scheme) and **Accessibility** (reduce-motion, type size) dimensions.
- **Hardcoded sizes and spacing constants**: Flags numeric literals used directly in `.frame(width:height:)`, `.padding(_:)`, and `.font(.system(size:))` that are not drawn from a named token enum (e.g., `AppSpacing`, `AppFont`). Results feed **Responsive Design** and **Theming** dimensions.

### Run: asset-catalog-checker

```bash
swift run --package-path tools/asset-catalog-checker asset-catalog-checker <Path/To/Assets.xcassets>
```

`tools/asset-catalog-checker/` inspects the Asset Catalog for:

- **Missing dynamic-color variants**: Color Sets with an "Any Appearance" swatch but no "Dark Appearance" swatch. Every hit is a **Theming** finding at P1.
- **Contrast checks**: Foreground/background Color Set pairs are checked against WCAG 4.5:1 (AA normal text) and 3:1 (AA large text). Failures are **Accessibility** findings at P1 or P0 depending on text size context.

Detector output is JSON; paste hits into the relevant dimension sections below.

## Diagnostic Scan

Run comprehensive checks across 5 dimensions. Score each dimension 0-4 using the criteria below. Merge detector hits with manual inspection findings before scoring.

### 1. Accessibility (A11y)

See [`accessibility.md`](accessibility.md) for the full SwiftUI accessibility model.

**Check for:**

- **Contrast issues**: Text contrast ratios below 4.5:1 (AA) or 7:1 (AAA). Asset-catalog-checker reports these automatically; manual check any Color Set pairs the tool cannot infer context for.
- **Missing accessibility labels**: `Image(systemName:)` and decorative-but-tappable elements without `.accessibilityLabel(_:)`. SwiftLint `missing_accessibility_label` rule catches these at lint time.
- **Semantic containers**: Use `.accessibilityElement(children: .combine)` for grouped content; bare `HStack` groupings without it produce noisy VoiceOver traversal.
- **Focus management**: Modal presentations (`.sheet`, `.fullScreenCover`) must move VoiceOver focus to the new context. Use `.accessibilityFocused(_:)` and confirm with Accessibility Inspector.
- **Dynamic Type scaling**: All text must use `.font(.body)` style-based sizes, not `.font(.system(size: 14))` literals. impeccable-lint catches the literals; verify scaling behavior manually at AX5.
- **Reduce Motion compliance**: Animations gated on `@Environment(\.accessibilityReduceMotion)`. impeccable-lint flags views that read this value outside of the environment system.
- **Keyboard and Switch Control navigation**: Test tab order in forms and modal stacks. See [`navigation.md`](navigation.md) for focus ring and keyboard shortcut patterns.
- **Form labeling**: `TextField` and `Toggle` without a descriptive `label` parameter or companion `.accessibilityLabel`.

**Score 0-4**: 0=Inaccessible (fails WCAG A, no labels), 1=Major gaps (few labels, no Dynamic Type, no reduce-motion gate), 2=Partial (some effort, significant gaps), 3=Good (WCAG AA mostly met, minor gaps), 4=Excellent (WCAG AA fully met, approaches AAA, tested with VoiceOver)

### 2. Performance

**Check for:**

- **Layout thrashing in SwiftUI**: Reading geometry inside `GeometryReader` and immediately triggering state changes that re-layout. Prefer `PreferenceKey` for bottom-up measurement.
- **Expensive animations**: Animating `frame`, `padding`, or `offset` without `.animation(.interactiveSpring(), value:)` specificity. Animating layout-driving properties causes full re-render passes. Animate opacity, scale (`scaleEffect`), and `offset` only; do not animate `padding` or `frame` directly.
- **Missing `LazyVStack` / `LazyHStack`**: Large collections rendered in eager stacks. Any `VStack` or `HStack` containing more than ~20 child views without data-driven pagination.
- **Unnecessary view re-evaluation**: `@StateObject` created unnecessarily high in the hierarchy, or `@EnvironmentObject` used where a scoped `@State` suffices. Profile with Instruments (SwiftUI template) to confirm.
- **Image asset weight**: Uncompressed or excessively large image assets in the bundle. Check Asset Catalog for missing 1x/2x/3x variants and unnecessary vector-to-raster duplication.
- **Render performance**: Missing `Equatable` conformance on views that receive frequently-changing bindings but don't need full re-render (use `.equatable()`).

**Score 0-4**: 0=Severe issues (layout thrash, unoptimized everything), 1=Major problems (eager stacks for large data, expensive animations), 2=Partial (some optimization, gaps remain), 3=Good (mostly optimized, minor improvements), 4=Excellent (Instruments-clean, lean view tree)

### 3. Theming

**Check for:**

- **Hardcoded color literals**: `Color(red:green:blue:)`, `.white`, `.black`, or `UIColor(red:green:blue:alpha:)` used in production views. SwiftLint `hardcoded_color_literals` catches these. Every hardcoded literal is a theming gap.
- **Missing dark-mode variants**: Color Sets in `Assets.xcassets` without a Dark Appearance swatch. Asset-catalog-checker reports these. A missing dark variant guarantees broken contrast in dark mode.
- **Inconsistent token use**: Mixing named Color Set references (`Color("AccentPrimary")`) with hardcoded alternatives for the same semantic role.
- **Missing `@Environment(\.colorScheme)` propagation**: Views that conditionally branch on light/dark without reading from `@Environment`. impeccable-lint catches these. Use Asset Catalog adaptive colors instead of branching in code wherever possible.
- **Theme-switching failures**: Values that remain static after `.preferredColorScheme` changes in Preview. Verify by toggling the Appearance in Xcode Previews.
- **Materials and vibrancy**: Hardcoded opaque backgrounds where `Material` (`.ultraThinMaterial`, `.regularMaterial`) would adapt correctly to context. See [`materials.md`](materials.md) for the correct material vocabulary.

**Score 0-4**: 0=No theming (hardcoded everything), 1=Minimal tokens (mostly hardcoded), 2=Partial (some Color Sets, gaps remain), 3=Good (Color Sets used consistently, minor hardcoded values), 4=Excellent (full Color Set system, dark mode verified, materials used correctly)

### 4. Responsive Design

**Check for:**

- **Hardcoded frame sizes**: `.frame(width: 320)` or `.frame(height: 44)` literals not drawn from a token. impeccable-lint flags numeric literals in frame modifiers. On iPad in Stage Manager or Slide Over, fixed widths shatter.
- **Touch target minimums**: Interactive elements below 44x44 pt. Use `.frame(minWidth: 44, minHeight: 44)` on tappable views, or verify `ButtonStyle` provides the tap area even when the label is smaller.
- **Size class adaptation**: Views that don't respond to `horizontalSizeClass`. Does a `TabView` collapse to a `NavigationSplitView` sidebar on iPad? Does a `HStack` flow to `VStack` in compact width? See [`navigation.md`](navigation.md) for layout-switching patterns.
- **Dynamic Type scaling**: Text containers that clip or truncate at AX5 (`xxxLarge`) without providing a scroll or truncation fallback. Test each screen at AX5 in Simulator.
- **Landscape and multitasking**: On iPad, test Slide Over (320pt), Split View (half-screen), and Stage Manager (freeform). On iPhone, test landscape: are `NavigationStack` columns sensible?
- **Safe area awareness**: Content behind `.ignoresSafeArea()` that is also interactive. Navigation bar-obscured tap targets.

**Score 0-4**: 0=Fixed-width everywhere (breaks on iPad, SE, or landscape), 1=Major issues (some adaptations, many failures), 2=Partial (works on primary device, rough on others), 3=Good (responsive across idioms, minor edge cases), 4=Excellent (Slide Over, AX5, all orientations pass)

### 5. Anti-Patterns (CRITICAL)

Check against all **DON'T** rules from the parent `impeccable-swift` skill. Look for AI slop tells and SwiftUI-specific anti-patterns:

**AI slop tells in SwiftUI:**

- Gradient text via `.foregroundStyle(LinearGradient(...))` applied to body copy (not display heroes)
- Glassmorphism applied by default (`.background(.ultraThinMaterial)` on every card instead of purposefully)
- Hero-metric template: giant number in a `VStack`, subtitle beneath, no contextual hierarchy
- Identical card grids: `LazyVGrid` of visually uniform rounded rectangles with icon + label + value
- Generic SF Symbols at `.regular` weight with no relationship to the surface's character
- `ZStack` shadow halos (multiple `.shadow()` stacked for a "glow" effect)
- Side-stripe accent borders: a `Rectangle().frame(width: 4)` at leading of every card

**SwiftUI structural anti-patterns:**

- `.sheet` as first-thought navigation instead of `NavigationStack` push or `NavigationSplitView`
- Deeply nested `ZStack` used for layout instead of `overlay` or `background`
- `GeometryReader` wrapping entire screens to get a single measurement
- `AnyView` type-erasure scattered through view hierarchy (kills `diffing`)
- `@EnvironmentObject` used for values that never change (use a `let` constant instead)

**Score 0-4**: 0=AI slop gallery (5+ tells), 1=Heavy AI aesthetic (3-4 tells), 2=Some tells (1-2 noticeable), 3=Mostly clean (subtle issues only), 4=No AI tells, intentional and distinctive

## Generate Report

### Audit Health Score

| #         | Dimension         | Score     | Key Finding                            |
| --------- | ----------------- | --------- | -------------------------------------- |
| 1         | Accessibility     | ?         | [most critical a11y finding or "none"] |
| 2         | Performance       | ?         |                                        |
| 3         | Theming           | ?         |                                        |
| 4         | Responsive Design | ?         |                                        |
| 5         | Anti-Patterns     | ?         |                                        |
| **Total** |                   | **??/20** | **[Rating band]**                      |

**Rating bands**: 18-20 Excellent (minor polish), 14-17 Good (address weak dimensions), 10-13 Acceptable (significant work needed), 6-9 Poor (major overhaul), 0-5 Critical (fundamental issues)

### Anti-Patterns Verdict

**Start here.** Pass/fail: Does this look AI-generated or template-cloned? List specific tells. Be brutally honest. A SwiftUI codebase that passes the anti-patterns check earns credibility for the rest of the audit.

### Executive Summary

- Audit Health Score: **??/20** ([rating band])
- Total issues found (count by severity: P0/P1/P2/P3)
- Detector arm summary: SwiftLint hits / impeccable-lint hits / asset-catalog-checker hits
- Top 3-5 critical issues
- Recommended next steps

### Detailed Findings by Severity

Tag every issue with **P0-P3 severity:**

- **P0 Blocking**: Prevents task completion or crashes: fix immediately
- **P1 Major**: Significant difficulty or WCAG AA violation: fix before release
- **P2 Minor**: Annoyance, workaround exists: fix in next pass
- **P3 Polish**: Nice-to-fix, no real user impact: fix if time permits

For each issue, document:

- **[P?] Issue name**
- **Location**: View, file, line (use detector output for exact lines)
- **Category**: Accessibility / Performance / Theming / Responsive / Anti-Pattern
- **Detector source**: SwiftLint / impeccable-lint / asset-catalog-checker / manual
- **Impact**: How it affects users or the system
- **WCAG/Standard**: Which standard it violates (if applicable)
- **Recommendation**: How to fix it
- **Suggested command**: Which command to use (prefer: `/impeccable adapt`, `/impeccable animate`, `/impeccable bolder`, `/impeccable clarify`, `/impeccable colorize`, `/impeccable critique`, `/impeccable delight`, `/impeccable distill`, `/impeccable document`, `/impeccable harden`, `/impeccable layout`, `/impeccable onboard`, `/impeccable optimize`, `/impeccable overdrive`, `/impeccable polish`, `/impeccable quieter`, `/impeccable shape`, `/impeccable typeset`)

### Patterns and Systemic Issues

Identify recurring problems that signal systemic gaps rather than one-off mistakes:

- "SwiftLint `hardcoded_color_literals` fired in 12 view files: introduce a `Color` extension or `AppColor` enum and audit all call sites."
- "Touch targets consistently below 44pt throughout the detail view stack: add a shared `ButtonStyle` that pads to minimum."
- "impeccable-lint found 23 hardcoded spacing constants: centralize into an `AppSpacing` enum."

### Positive Findings

Note what is working well. Good patterns to maintain and replicate across the codebase.

## Recommended Actions

List recommended commands in priority order (P0 first, then P1, then P2):

1. **[P?] `/impeccable <command>`**: Brief description (specific context from audit findings)
2. **[P?] `/impeccable <command>`**: Brief description (specific context)

**Rules**: Only recommend commands from: `/impeccable adapt`, `/impeccable animate`, `/impeccable bolder`, `/impeccable clarify`, `/impeccable colorize`, `/impeccable critique`, `/impeccable delight`, `/impeccable distill`, `/impeccable document`, `/impeccable harden`, `/impeccable layout`, `/impeccable onboard`, `/impeccable optimize`, `/impeccable overdrive`, `/impeccable polish`, `/impeccable quieter`, `/impeccable shape`, `/impeccable typeset`. End with `/impeccable polish` as the final step if any fixes were recommended.

After presenting the summary, tell the user:

> You can ask me to run these one at a time, all at once, or in any order you prefer.
>
> Re-run `/impeccable audit` after fixes to see your score improve.

**IMPORTANT**: Be thorough but actionable. Too many P3 findings creates noise. Focus on what actually matters.

**NEVER:**

- Report issues without explaining impact (why does this matter to the user?)
- Provide generic recommendations (be specific and actionable, cite the file and line)
- Skip positive findings (celebrate what works)
- Forget to prioritize (everything cannot be P0)
- Report detector hits as findings without confirming they are not false positives in scaffolding or test targets

Remember: You are a technical quality auditor for SwiftUI. Run the detector arm first, merge its output with manual inspection, prioritize ruthlessly, and provide clear paths to improvement.
