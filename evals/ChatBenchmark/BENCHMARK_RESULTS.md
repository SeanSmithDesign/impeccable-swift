# ChatBenchmark Results — 2026-04-15

**Benchmark:** Chat Conversation View (Brief 04)
**Skill under test:** `impeccable-swift`
**Judge working directory:** `~/Code/impeccable-swift/evals/ChatBenchmark/ChatBenchmark/` for Builds 1–3 (no DESIGN.md in scope); same directory for Build 4 (DESIGN.md present at `ChatBenchmark/DESIGN.md`).
**Detector tools:** swiftlint and impeccable-lint not available in this environment; all findings are from manual critique following the full `impeccable-swift:critique` protocol with citations to all 13 reference docs.

---

## Top-line verdict

| Build                | Verdict (one sentence)                                                                                                                                                                                        | Total findings |  P0 |  P1 |  P2 |  P3 |
| -------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------: | --: | --: | --: | --: |
| 1 — Stock            | Expected control output: hardcoded system colors, no Material, no custom ButtonStyle, deprecated UIScreen API, compose bar incorrectly placed in VStack.                                                      |             14 |   3 |   5 |   4 |   2 |
| 2 — Web impeccable   | Meaningful improvement: spacing tokens, Material surfaces, safeAreaInset, reduce-motion awareness — web skill transfers well, but @ScaledMetric and reduceTransparency fallbacks are absent.                  |              7 |   0 |   2 |   3 |   2 |
| 3 — impeccable-swift | Strong universal output: full skill compliance, reduce-motion + reduce-transparency guards, @ScaledMetric, safeAreaInset, symbol weight discipline — only gap is no project-specific accent.                  |              4 |   0 |   0 |   2 |   2 |
| 4 — Full setup       | Best output: all Build 3 quality plus project accent token (#c97350), exact DESIGN.md radii and spacing, sensoryFeedback wired, send-trigger pattern for haptics — one minor concentric-corner approximation. |              2 |   0 |   0 |   1 |   1 |

---

## Findings by category

| Category           | Build 1 (P0/P1/P2/P3) | Build 2 | Build 3 | Build 4 |
| ------------------ | --------------------- | ------- | ------- | ------- |
| Spatial            | 1/1/1/0               | 0/0/1/0 | 0/0/0/0 | 0/0/0/0 |
| Typography         | 1/1/0/1               | 0/0/1/1 | 0/0/0/1 | 0/0/0/1 |
| Color              | 1/1/1/0               | 0/0/1/0 | 0/0/0/0 | 0/0/0/0 |
| Material           | 0/1/1/0               | 0/1/0/0 | 0/0/1/0 | 0/0/1/0 |
| Interaction        | 0/1/0/1               | 0/0/0/0 | 0/0/0/0 | 0/0/0/0 |
| Motion             | 0/0/1/0               | 0/0/0/0 | 0/0/0/0 | 0/0/0/0 |
| SF Symbols         | 0/0/0/0               | 0/0/0/1 | 0/0/0/1 | 0/0/0/0 |
| Platform (iOS 26+) | 0/1/0/0               | 0/0/0/0 | 0/0/0/0 | 0/0/0/0 |
| UX Writing         | 0/0/0/0               | 0/0/0/0 | 0/0/0/0 | 0/0/0/0 |
| Accessibility      | 0/0/0/1               | 0/1/1/0 | 0/0/1/0 | 0/0/0/0 |

---

## Delta summary

### Build 2 − Build 1: What did web impeccable catch that stock didn't?

Web impeccable eliminated every P0 and produced clear wins in Spatial, Typography, Material, Interaction, and Platform:

- Introduced `.safeAreaInset` for the compose bar (navigation.md pattern translated directly from CSS sticky positioning).
- Replaced `Color.blue` / `Color(.systemGray6)` with `Color.accentColor` / `.regularMaterial` — color-token discipline from impeccable's CSS variable guidance translated cleanly.
- Added spacing enum (4/8/12/16/24) — impeccable's CSS custom-property rhythm maps directly.
- Added custom `ButtonStyle` with pressed state for the send button.
- Added `@Environment(\.accessibilityReduceMotion)` check before thread animation.
- Added `.caption2.monospacedDigit()` for timestamps — typography discipline carried over.
- Added `.continuous` corner style throughout — no explicit web guidance for this, but the skill's "no hard corners" principle translated.

Web impeccable missed or under-served:

- No `@ScaledMetric` — the web skill has no equivalent concept; this is a pure Swift/Dynamic Type gap.
- No `accessibilityReduceTransparency` fallback on Material surfaces — web has no Reduce Transparency concept.
- `Color.accentColor` used instead of a project accent — web skill's CSS variable guidance suggests tokens, but without DESIGN.md there's no project color to anchor to.
- Link preview card missing `frame(maxWidth:)` constraint — the web skill's `max-width` discipline was not applied to this card.
- Reply thread button missing 44pt minimum hit target.

### Build 3 − Build 2: What did swift-native guidance add on top of web-only?

impeccable-swift's 13 reference docs added iOS-specific correctness that the web skill structurally cannot provide:

- `@ScaledMetric` for `bubbleMinHeight` and `replyChipHeight` — Dynamic Type axis of responsiveness (responsive-design.md + typography.md).
- `@Environment(\.accessibilityReduceTransparency)` with opaque fallbacks on every Material surface (accessibility.md).
- `GeometryReader`-based `maxBubbleWidth` replacing deprecated `UIScreen.main.bounds` — the responsive-design.md "Device-Width Trap" anti-pattern is explicitly named.
- `Space.tap = 44` minimum hit target enforced on the send button with `.contentShape(Rectangle())` (spatial-design.md + interaction-design.md).
- `.sensoryFeedback(.success, trigger:)` on the send action (interaction-design.md).
- `bubbleBackground()` helper ensures the `@Environment(\.accessibilityReduceTransparency)` guard is applied consistently across all bubble types, not just the compose bar.
- Comment citations throughout linking decisions to specific reference docs — this is the skill's audit trail pattern.

Build 3 residual gaps (all P2/P3):

- `@ScaledMetric` not applied to photo container height (160pt fixed) — a minor responsive-design.md miss.
- SF symbol thumbnail in link preview card uses `.font(.title3)` with a wrapping `.frame(width:40, height:40)` — sf-symbols.md says to size with `.font`, not `.frame`. The frame is used for the background container, not the symbol itself, which is borderline correct but technically the symbol inherits the background frame dimensions.

### Build 4 − Build 3: What did DESIGN.md + Sean's global prefs add on top of universal rules?

DESIGN.md resolved every ambiguity that Build 3 had to leave as a universal default:

- `Color.accent = Color(red: 0.788, green: 0.451, blue: 0.314)` — the `#c97350` terracotta from DESIGN.md replaces the generic `.tint`. The reply thread affordance, send button, PDF icon, and link preview source label all carry this accent. In Build 3 these were all `.tint` (system blue on a fresh project).
- Bubble corner radius: 18pt with `.continuous` per DESIGN.md token, vs. Build 3's untokenized choice of matching radii.
- Send button haptic wired with `sendTrigger` state toggle — Build 3 had `.sensoryFeedback` but the trigger binding was on `messageText` which fires on every character; Build 4 uses a dedicated bool that only toggles on actual send.
- Link preview source label explicitly in `Color.accent` (DESIGN.md: "accent color used sparingly — link preview source label").
- `@ScaledMetric` for `replyChipHeight` set relative to `.footnote` matching DESIGN.md's reply-count typography spec.
- Compose bar send button: `arrow.up.circle.fill` in accent when enabled, matching the DESIGN.md SF Symbol spec exactly.

Build 4 residual gaps:

- **P2 — Material/Spatial:** The PDF attachment icon uses `.tint.opacity(0.1)` for its background fill rather than `Color.accent.opacity(0.1)`. At the time of writing, `.tint` resolves to system blue on a project without a global accent color set in Assets.xcassets. Because the AccentColor.colorset is written at `#c97350`, `.tint` should resolve to the accent color at runtime — but this relies on the asset catalog being built into the app, which doesn't apply during swiftc typecheck. The code would be correct in a full Xcode build; the critique flags it as a potential source of inconsistency if the asset catalog is ever removed or misconfigured. (materials.md: "every color used by the UI lives in the Asset Catalog as a named color set.")
- **P3 — Typography:** `DateFormatter` used directly in render code rather than a cached formatter. Not a design issue but a minor craft issue per craft.md's "build → iterate" loop guidance.

---

## Representative findings per build

### Build 1 — Stock (3 representative findings)

**Finding 1**

- Finding: `Color.blue` for sent bubbles, `Color(.systemGray6)` for received — hardcoded system palette, no Material, Dark Mode incoherence.
- Rule: color-and-contrast.md: "The system palette (.blue, .red, .green) is a debug tool, not a design system."
- Severity: P0
- Reference: color-and-contrast.md
- Fix hint: Replace with `AnyShapeStyle(Color.accentColor)` for sent, `AnyShapeStyle(.regularMaterial)` for received. Both adapt to Dark Mode automatically.

**Finding 2**

- Finding: Compose bar placed inside a `VStack(spacing: 0)` alongside the `ScrollView` — keyboard avoidance relies on system push-up behavior, not `.safeAreaInset`. Breaks on devices where the push-up doesn't fire correctly and violates the explicit anti-pattern.
- Rule: navigation.md: "Never hardcode `.padding(.bottom, 34)`... Use `.safeAreaInset(edge: .bottom)` to attach chrome that respects the safe area."
- Severity: P0
- Reference: navigation.md
- Fix hint: Move `composeBar` into `.safeAreaInset(edge: .bottom)` on the `ScrollView`. Remove the outer `VStack`.

**Finding 3**

- Finding: `UIScreen.main.bounds.width` used for bubble max-width — deprecated in iOS 26.0 and wrong in multitasking contexts.
- Rule: responsive-design.md: "Anti-pattern — The Device-Width Trap: reading UIScreen.main.bounds.width... All three break the moment the window isn't full-screen."
- Severity: P1
- Reference: responsive-design.md
- Fix hint: Wrap the message list in `GeometryReader { geo in ... }` and derive `maxBubbleWidth = geo.size.width * 0.74`.

---

### Build 2 — Web impeccable (3 representative findings)

**Finding 1**

- Finding: No `@ScaledMetric` for any fixed dimension (bubble min-height, reply chip height). Photo frame is `220 × 160` hardcoded.
- Rule: responsive-design.md: "Dynamic Type Is the Other Axis of 'Responsive'. A layout that looks immaculate at default size and truncates at .accessibilityLarge is not responsive — it's fragile."
- Severity: P1
- Reference: responsive-design.md + typography.md
- Fix hint: Add `@ScaledMetric(relativeTo: .body) private var bubbleMinHeight: CGFloat = 36` and apply to `.frame(minHeight: bubbleMinHeight)` on each bubble.

**Finding 2**

- Finding: Material surfaces have no `accessibilityReduceTransparency` fallback. `.regularMaterial` and `.thinMaterial` are applied unconditionally; at Reduce Transparency they produce insufficient contrast.
- Rule: accessibility.md: "every view using .ultraThinMaterial... provides an opaque fallback when accessibilityReduceTransparency is true."
- Severity: P1
- Reference: accessibility.md
- Fix hint: Add `@Environment(\.accessibilityReduceTransparency) private var reduceTransparency` and conditionally switch to `Color(.secondarySystemBackground)` when true.

**Finding 3**

- Finding: Link preview card has no `frame(maxWidth:)` constraint — it can expand to full column width at wide screen sizes, appearing uncontained relative to bubbles.
- Rule: spatial-design.md: "Hierarchy Through Multiple Dimensions — spacing alone doesn't create hierarchy."
- Severity: P2
- Reference: spatial-design.md
- Fix hint: Add `.frame(maxWidth: maxWidth)` to the link preview card container, using the same `GeometryReader`-derived value as bubbles.

---

### Build 3 — impeccable-swift (2 representative findings)

**Finding 1**

- Finding: Photo container height hardcoded at `160` pt — `@ScaledMetric` applied to `bubbleMinHeight` and `replyChipHeight` but not to photo dimensions.
- Rule: responsive-design.md: "every font on every view uses a semantic style... Dynamic Type is the other axis of 'responsive.'"
- Severity: P2
- Reference: responsive-design.md
- Fix hint: Add `@ScaledMetric(relativeTo: .body) private var photoHeight: CGFloat = 160` and use it in `.frame(height: photoHeight)`.

**Finding 2**

- Finding: Symbol thumbnail in link preview card wrapped in `.frame(width: 40, height: 40)` on the background container — the symbol itself inherits that fixed frame. At Accessibility5 Dynamic Type, the symbol may feel undersized relative to surrounding text.
- Rule: sf-symbols.md: "Never wrap a symbol in .frame(width:height:) to size it... Size symbols through the type system."
- Severity: P3
- Reference: sf-symbols.md
- Fix hint: Remove the fixed frame from the `Image(systemName:)` and use `.font(.title3)` for sizing. Apply `.frame(width: 40, height: 40)` only to the `RoundedRectangle` background, not to the symbol.

---

### Build 4 — Full setup (2 representative findings)

**Finding 1**

- Finding: PDF icon background uses `.tint.opacity(0.1)` rather than `Color.accent.opacity(0.1)`. At runtime with AccentColor.colorset in Assets.xcassets, `.tint` should resolve to `#c97350` — but this creates a dependency on the asset catalog being loaded, rather than using the explicit token declared in `Color.accent`.
- Rule: color-and-contrast.md: "Every color used by the UI lives in the Asset Catalog as a named color set... Reference it via Color('text.primary') or a typed extension."
- Severity: P2
- Reference: color-and-contrast.md
- Fix hint: Replace `.tint.opacity(0.1)` with `Color.accent.opacity(0.1)` to use the declared token directly.

**Finding 2**

- Finding: `DateFormatter` instantiated inside `timeString(_:)` — a new formatter is created on every call. Not a visual defect but a craft issue that creates unnecessary allocation during scroll.
- Rule: craft.md: "the build → iterate loop — tighten generated code."
- Severity: P3
- Reference: craft.md (impeccable-swift)
- Fix hint: Move to `private static let timeFormatter: DateFormatter = { ... }()` at the struct level.

---

## Automated detector results

- **SwiftLint:** Not available in this environment. Would have caught: `cornerRadius(10)` (custom rule `no-magic-corner-radius`) in Build 1; `.foregroundStyle(.blue)` in Build 1 (custom rule `no-system-palette`).
- **impeccable-lint:** Not available in this environment. Would have caught: missing `accessibilityReduceTransparency` fallback in Build 1 and Build 2; `UIScreen.main` usage in Build 1.
- **Asset catalog checker:** Not run. AccentColor.colorset exists and is correctly structured with `#c97350`.
