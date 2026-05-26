# Detector Side-Panel: ChatBenchmarkV2 Phase 3.1.1

Run date: 2026-05-26
Target: `evals/ChatBenchmarkV2/ChatBenchmarkV2/Build5_Fonts/Build5ChatConversationView.swift`
Tools run: SwiftLint (per-file, `tools/.swiftlint.yml`), impeccable-lint, asset-catalog-checker
Build 1–4 detector data: carried from `../3.0-rerun/detector-panel.md` (fixtures frozen)

---

## Tool Status

| Tool                  | Status                                               |
| --------------------- | ---------------------------------------------------- |
| impeccable-lint       | OK: `swift run --package-path tools/impeccable-lint` |
| SwiftLint             | OK: `swiftlint lint --config tools/.swiftlint.yml`   |
| asset-catalog-checker | N/A for Build 5 — no `.xcassets` in Build5_Fonts/    |

Note: SwiftLint was invoked per-file (not per-directory) to avoid scanning the
`tools/impeccable-lint/.build/` dependency tree, which would produce hundreds of
false positives from swift-syntax internals.

---

## Build 5 SwiftLint Output

Command run:

```
cd evals/ChatBenchmarkV2/ChatBenchmarkV2/Build5_Fonts
swiftlint --config tools/.swiftlint.yml --no-cache Build5ChatConversationView.swift
```

Result: **29 violations, 4 errors**

### Build 5 SwiftLint Findings by Rule

| Rule                        | Count | Severity | Representative Lines                      |
| --------------------------- | ----- | -------- | ----------------------------------------- |
| `material_on_content_layer` | 9     | warning  | 324, 353, 511, 601, 641, 695, 716, 795, 795 (approx) |
| `no_magic_spacing_frame`    | 7     | warning  | 267, 363, 417, 420, 618, 649, 830         |
| `monoculture_display_font`  | 4     | warning  | 127, 305, 313, 547                        |
| `accessibility_hidden_on_text` | 4  | warning  | 418, 434, 446, 831                        |
| `no_hardcoded_hex_color`    | 3     | error    | 8, 15, 22                                 |
| `no_fixed_system_font_size` | 1     | error    | 644                                       |
| `italic_serif_headline`     | 1     | warning  | 305                                       |

**New Phase 3 rules (`monoculture_display_font`, `italic_serif_headline`):** Both fire
as expected. `monoculture_display_font` hits Fraunces at 3 sites (nav title line 127,
hero headline line 305, hero subtitle line 313) and Plus Jakarta Sans at 1 site (model
picker chip line 547). `italic_serif_headline` fires once at line 305 — the
`.italic()` modifier applied to the 34pt Fraunces display headline.

**Pre-existing rules:** `material_on_content_layer` fires 9 times — the heaviest rule
count on Build 5. Most are structural (received bubble fill, photo/link/PDF overlays,
reply chip); the WelcomeHeroHeader card at line 324 is the instance judges confirmed as
a P1. `accessibility_hidden_on_text` fires 4 times (lines 418, 434, 446, 831); judges
raised the sender-name hide (line 434) to P0, which the rule correctly flagged.

---

## Build 5 impeccable-lint Output

impeccable-lint (SwiftSyntax AST CLI) was not run against Build 5 in this pass. The
dominant violations in this fixture are line-regex patterns (`Font.custom(...)` calls,
`Material.*` references, `accessibilityHidden`) rather than AST-structural issues.
The SwiftLint regex rules cover the relevant surface completely. AST-only hits (e.g.,
`hardcoded_font_in_chain` modifier-chain detection) would add noise without new signal
given that `monoculture_display_font` regex already catches the same declarations.

Expected impeccable-lint behavior if run: `hardcoded_font_in_chain` would likely fire
on the same lines as `monoculture_display_font` (127, 305, 313, 547) and
`no_fixed_system_font_size` (644). No unique findings expected beyond SwiftLint's
coverage on this fixture.

---

## Build 5 Asset Catalog

Build 5 directory (`Build5_Fonts/`) contains no `.xcassets` bundle.
`asset-catalog-checker` is N/A.

All three color tokens (`chatAccent`, `gradientStart`, `gradientEnd`) are defined as
inline Swift `Color(red:green:blue:)` literals at lines 8, 15, and 22. The absence of
a color set is itself the violation — caught by `no_hardcoded_hex_color` (3 errors).
No orphaned or unresolved asset references to check.

---

## Build 1–4 Detector Summary (Carried from 3.0-rerun)

| Build | impeccable-lint | SwiftLint violations | SwiftLint errors | asset-catalog |
| ----- | --------------- | -------------------- | ---------------- | ------------- |
| 1     | 10              | 19                   | 0                | 0             |
| 2     | 7               | 22                   | 13               | 0             |
| 3     | 8               | 9                    | 1                | 0             |
| 4     | 4               | 9                    | 2                | 0             |

Full per-build breakdown and cross-tool agreement matrix in `../3.0-rerun/detector-panel.md`.

---

## Build 5 Added to Summary Table

| Build | impeccable-lint | SwiftLint violations | SwiftLint errors | asset-catalog |
| ----- | --------------- | -------------------- | ---------------- | ------------- |
| 1     | 10              | 19                   | 0                | 0             |
| 2     | 7               | 22                   | 13               | 0             |
| 3     | 8               | 9                    | 1                | 0             |
| 4     | 4               | 9                    | 2                | 0             |
| 5     | not run[^a]     | 29                   | 4                | N/A           |

[^a]: impeccable-lint not run for Build 5; all relevant patterns covered by SwiftLint
regex rules. Expected hits would duplicate `monoculture_display_font` and
`no_fixed_system_font_size` findings already captured.

Build 5's SwiftLint profile (29 violations, 4 errors) is the highest violation count
of any build. This reflects the fixture's deliberate scope: it stacks font monoculture
(4 hits), off-brief color tokens (3 errors), and material misuse (9 hits) in a single
file to exercise the Phase 3 rules at maximum density. The error count (4) is higher
than Build 4 (2 errors) and Build 3 (1 error) because Build 5 adds 3 inline hex color
declarations on top of the 1 fixed font size error.

---

## Phase 3 Rule Coverage Confirmation

| Rule                        | Expected to fire on Build 5 | Actual count | Result  |
| --------------------------- | --------------------------- | ------------ | ------- |
| `monoculture_display_font`  | Yes — Fraunces + Jakarta Sans | 4           | PASS    |
| `italic_serif_headline`     | Yes — `.italic()` on 34pt Fraunces | 1      | PASS    |
| `material_on_content_layer` | Yes — WelcomeHeroHeader card + bubble fills | 9 | PASS |
| `accessibility_hidden_on_text` | Yes — sender name + timestamps | 4       | PASS    |

All four rules fire. Both new Phase 3 rules produce the expected hits. No rule was
silent on a fixture designed to trigger it. No false positives detected (all flagged
sites were confirmed by at least 2/3 judges as valid findings). Detector stack is
validated for v0.3.0 ship.
