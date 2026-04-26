# Detector Side-Panel: ChatBenchmarkV2 Phase 3

Run date: 2026-04-26
Target: `evals/ChatBenchmarkV2/ChatBenchmarkV2/Build{1,2,3,4}/Build{N}ChatConversationView.swift`
Tools run: impeccable-lint (SwiftSyntax CLI), SwiftLint, asset-catalog-checker

---

## Tool Status

| Tool                  | Status                                               |
| --------------------- | ---------------------------------------------------- |
| impeccable-lint       | OK: `swift run --package-path tools/impeccable-lint` |
| SwiftLint             | OK: `swiftlint lint --config tools/.swiftlint.yml`   |
| asset-catalog-checker | OK: `swift tools/asset-catalog-checker/check.swift`  |

Note: SwiftLint was invoked per-file (not per-directory) to avoid scanning
the `tools/impeccable-lint/.build/` dependency tree, which would have
produced hundreds of false positives from swift-syntax internals.

---

## impeccable-lint Findings

### Build 1 (Stock): 10 findings

| Rule                  | Count | Representative Lines          |
| --------------------- | ----- | ----------------------------- |
| `continuous_corner`   | 7     | 27, 60, 73, 91, 126, 140, 160 |
| `accessibility_label` | 3     | 96, 126, 141                  |

All 7 `.cornerRadius(_:)` calls use square corners. Every icon-only Image
has no label. No Dynamic Type, material, or hardcoded-hex rules triggered
because the view uses only named system colors (Color.blue, Color.gray),
which are caught by SwiftLint's `no_literal_system_color` rule instead.

### Build 2 (Web Impeccable Port): 7 findings

| Rule                      | Count | Representative Lines |
| ------------------------- | ----- | -------------------- |
| `accessibility_label`     | 4     | 418, 471, 507, 682   |
| `hardcoded_font_in_chain` | 3     | 418, 471, 682        |

The `.font(.system(size:))` detections at lines 418 and 471 co-locate with
`accessibility_label` hits at the same line: the emoji/icon views in
LinkPreviewCard (44pt) and PhotoMessage (64pt) are both hardcoded-size and
unlabeled. Line 682 is a third hardcoded-font occurrence without an
accompanying label.

impeccable-lint did NOT flag the 10 inline `Color(red:green:blue:)` Palette
constants at lines 11-20 because those are struct property declarations,
not modifier-chain calls. SwiftLint's `no_hardcoded_hex_color` regex catches
these; impeccable-lint's `hardcoded_font_in_chain` syntactic check does not
scan struct bodies for color literals. This is a known coverage gap and a
planned enhancement.

### Build 3 (impeccable-swift): 8 findings

| Rule                      | Count | Representative Lines              |
| ------------------------- | ----- | --------------------------------- |
| `accessibility_label`     | 7     | 151, 232, 379, 454, 479, 500, 621 |
| `hardcoded_font_in_chain` | 1     | 454                               |

The single hardcoded font is the PhotoBubble emoji display at line 454
(`.font(.system(size: 56))`). The 7 accessibility_label hits cover the
back chevron, attachment picker, camera, send button, link icon, PDF icon,
and avatar image. These are the same symbol images the LLM critique flagged
as P1 accessibility gaps.

No material misuse, no hardcoded colors, no magic corners: the
impeccable-swift APIs handle those correctly. The accessibility_label gap
is a systematic omission rather than a beginner error.

### Build 4 (Full Setup): 4 findings

| Rule                      | Count | Representative Lines |
| ------------------------- | ----- | -------------------- |
| `accessibility_label`     | 3     | 352, 523, 737        |
| `hardcoded_font_in_chain` | 1     | 548                  |

Four findings total. The hardcoded font is the PhotoBubble emoji at line 548
(`.font(.system(size: 56))`), same pattern as Build 3. The three label gaps
are the attachment picker (352), the camera button (523), and the thread
expand chevron (737). The chatAccent inline color literal at line 8 is not
caught by impeccable-lint; SwiftLint's regex picks it up.

---

## SwiftLint Findings

### Build 1 (Stock): 19 violations, 0 errors

| Rule                      | Count | Severity |
| ------------------------- | ----- | -------- |
| `no_literal_system_color` | 17    | warning  |
| `no_magic_spacing_frame`  | 2     | warning  |

17 literal system color references span Color.blue (sent bubble fill),
Color.gray (received bubble, timestamps, placeholders), Color.red
(destructive inline), and Color.white/Color.black. No errors: Build 1
does not use hardcoded hex, fixed font sizes, or framed SF Symbols.

### Build 2 (Web Impeccable Port): 22 violations, 13 errors

| Rule                        | Count | Severity |
| --------------------------- | ----- | -------- |
| `no_hardcoded_hex_color`    | 10    | error    |
| `no_fixed_system_font_size` | 3     | error    |
| `no_magic_spacing_frame`    | 9     | warning  |

10 inline Color(red:green:blue:) declarations (Palette struct, lines 11-20)
fire the error-severity `no_hardcoded_hex_color` rule. The 3 fixed font
sizes are the same as impeccable-lint flagged. The 9 magic frame sizes
include the 32x32 and 36x36 tap target frames for toolbar buttons (under
the 44pt minimum) and the 6x6 attachment thumbnail.

### Build 3 (impeccable-swift): 9 violations, 1 error

| Rule                        | Count | Severity |
| --------------------------- | ----- | -------- |
| `no_magic_spacing_frame`    | 8     | warning  |
| `no_fixed_system_font_size` | 1     | error    |

Down to 1 error (same hardcoded emoji font as impeccable-lint caught).
The 8 magic frame sizes include the send button frame (40x40, under 44pt),
the attachment button frame, avatar image frame, and several thumbnail sizes.
No color rule violations: Build 3 uses no inline hex, no system color
literals, relying on Color.accentColor and .primary/.secondary semantics.

### Build 4 (Full Setup): 9 violations, 2 errors

| Rule                        | Count | Severity |
| --------------------------- | ----- | -------- |
| `no_magic_spacing_frame`    | 7     | warning  |
| `no_fixed_system_font_size` | 1     | error    |
| `no_hardcoded_hex_color`    | 1     | error    |

The `no_hardcoded_hex_color` error at line 8 is the chatAccent token:
`Color(red: 201.0/255.0, green: 115.0/255.0, blue: 80.0/255.0)`. This is
the primary finding the LLM judges also flagged as P1: a named brand color
that should be an Asset Catalog Color Set, not an inline literal. The 7
magic frame sizes are similar to Build 3 (attachment, send, avatar frames).

---

## Asset Catalog Health

Single xcassets at `evals/ChatBenchmarkV2/ChatBenchmarkV2/Assets.xcassets`.
Contents: AccentColor.colorset, AppIcon.appiconset.

**0 findings.** No orphaned Color Sets. No unreferenced Material assets.

Note: all four builds define their color tokens as inline Swift literals,
not as Asset Catalog Color Sets. The asset-catalog-checker correctly reports
zero orphaned entries because no custom Color Sets were registered in the
first place. The _absence_ of Color Sets is itself a P1 finding flagged by
SwiftLint's `no_hardcoded_hex_color` and `no_literal_system_color` rules.

---

## Cross-Tool Agreement Matrix

The table below shows whether each major finding was caught by LLM judges,
impeccable-lint, and/or SwiftLint. Cells marked "yes" confirm the finding;
cells marked "no" indicate a miss.

| Finding                            | Build | LLM (median) | impeccable-lint               | SwiftLint                       |
| ---------------------------------- | ----- | ------------ | ----------------------------- | ------------------------------- |
| No NavigationStack                 | B1    | yes (P0)     | no                            | no                              |
| Hardcoded safe area inset          | B1    | yes (P0)     | no                            | no                              |
| Square corners (.cornerRadius)     | B1    | yes (P1)     | yes (continuous_corner)       | no                              |
| Literal system colors (Color.blue) | B1    | yes (P1)     | no                            | yes (no_literal_system_color)   |
| Icon images missing label          | B1-B4 | yes (P1)     | yes (accessibility_label)     | no                              |
| UIScreen.main.bounds (deprecated)  | B2    | yes (P0)     | no                            | no                              |
| Inline hex Color palette           | B2    | yes (P1)     | no                            | yes (no_hardcoded_hex_color)    |
| Hardcoded font sizes               | B2-B4 | yes (P1)     | yes (hardcoded_font_in_chain) | yes (no_fixed_system_font_size) |
| Material on content layer          | B2-B4 | yes (P1)     | no                            | no                              |
| Tap targets under 44pt             | B2-B3 | yes (P1)     | no                            | yes (no_magic_spacing_frame)    |
| LazyVStack @State recycling        | B3    | yes (P1)     | no                            | no                              |
| chatAccent inline color            | B4    | yes (P1)     | no                            | yes (no_hardcoded_hex_color)    |
| Timestamps accessibilityHidden     | B4    | yes (P1)     | no                            | no                              |
| Concentric corner violation        | B4    | yes (P1)     | no                            | no                              |

### Notable gaps

**impeccable-lint does not catch:** Material misuse, UIScreen.main.bounds,
LazyVStack state recycling, NavigationStack absence, concentric corner math,
accessibilityHidden abuse, or inline color struct declarations (only chain calls).

**SwiftLint does not catch:** Material misuse, LazyVStack recycling, accessibility
hidden abuse, concentric corner violations, NavigationStack absence, or
deprecated API usage.

**LLM judges caught:** all of the above, plus architectural issues neither
static tool can detect. The detectors serve as a reliable second signal
for the pattern classes they do cover (font sizes, colors, corner style,
label gaps) and as a falsification check against LLM hallucination. In this
run, no detector finding contradicts any LLM finding: all are confirmed.

---

## Detector Finding Totals by Build

| Build | impeccable-lint | SwiftLint violations | SwiftLint errors | asset-catalog |
| ----- | --------------- | -------------------- | ---------------- | ------------- |
| 1     | 10              | 19                   | 0                | 0             |
| 2     | 7               | 22                   | 13               | 0             |
| 3     | 8               | 9                    | 1                | 0             |
| 4     | 4               | 9                    | 2                | 0             |

The Build 4 detector profile (4 + 9 total, 2 errors) is significantly cleaner
than Build 2 (7 + 22 total, 13 errors) and Build 1 (10 + 19 total, 0 errors
only because it uses named system colors rather than hex). The detector
signal tracks the LLM severity gradient: Build 4 is genuinely better, not
just differently broken.
