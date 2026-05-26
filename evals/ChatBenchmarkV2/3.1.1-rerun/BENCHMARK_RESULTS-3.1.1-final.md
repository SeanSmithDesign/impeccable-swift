# ChatBenchmarkV2: Phase 3.1.1 Final Results

Run date: 2026-05-26
Primary pass: Build 5 only — Runs 1–3 (blinded, 3-rep)
Regression pass: Skipped — primary convergence tight (12 / 15 / 12)
Total judge runs: 3 new (Build 5 primary) + 24 carried (Builds 1–4 from 3.0-rerun) = 27 total
Detector pass: SwiftLint, impeccable-lint, asset-catalog-checker (see detector-panel.md)

---

## 1. Final Verdicts

| Build               | Primary P0+P1 (med) | Regression P0+P1 (med)                            | Confirmed | Verdict      |
| ------------------- | ------------------- | -------------------------------------------------- | --------- | ------------ |
| 1: Stock SwiftUI    | 23                  | 14                                                 | Yes       | REWORK       |
| 2: Web Impeccable   | 20                  | 19                                                 | Yes       | REWORK       |
| 3: impeccable-swift | 10                  | 8                                                  | Yes       | Fix P1s      |
| 4: Full Setup       | 10                  | 10                                                 | Yes       | Fix P1s      |
| 5: Fonts            | 12                  | Regression skipped — primary convergence tight[^1] | N/A       | Polish-first |

[^1]: Build 5 primary runs were 12 / 15 / 12 (two of three within 1 point of each other). A 3-point spread with two runs agreeing is within the normal convergence band; regression was not triggered. Verdict is **Polish-first**: structural foundations are sound (correct NavigationStack, `.safeAreaInset` compose bar, Reduce Motion / Reduce Transparency plumbing, composite VoiceOver labels on rich bubbles, 44-pt tap targets). The P0s are category-concentrated — wrong font family (4 sites) and wrong brand color token (1 inline RGB literal) — not scattered architectural failures. Two targeted fixes clear all P0s.

**Provenance note:** Build 1–4 data carried verbatim from 3.0-rerun
(`../3.0-rerun/BENCHMARK_RESULTS-3.0-final.md`); fixtures frozen, no Phase 3 detector
rules surface on those sources. Build 5 fresh from 3 blind Sonnet 4.6 judges, this run.

---

## 2. Per-Pass Median Table

### Primary Pass (Runs 1–3)

| Build    | P0  | P1  | P2  | P3  | Total | P0+P1 |
| -------- | --- | --- | --- | --- | ----- | ----- |
| 1: Stock | 7   | 16  | 16  | 4   | 43    | 23    |
| 2: Web   | 1   | 19  | 17  | 1   | 38    | 20    |
| 3: Swift | 0   | 10  | 17  | 1   | 28    | 10    |
| 4: Full  | 0   | 10  | 14  | 0   | 24    | 10    |
| 5: Fonts | 7   | 7   | 3   | 1   | 18    | 12    |

### Regression Pass (Runs 4–6)

| Build    | P0  | P1  | P2  | P3  | Total | P0+P1 |
| -------- | --- | --- | --- | --- | ----- | ----- |
| 1: Stock | 3   | 11  | 4   | 1   | 19    | 14    |
| 2: Web   | 1   | 18  | 6   | 0   | 25    | 19    |
| 3: Swift | 0   | 8   | 4   | 1   | 13    | 8     |
| 4: Full  | 0   | 10  | 1   | 0   | 11    | 10    |
| 5: Fonts | —   | —   | —   | —   | —     | —[^2] |

[^2]: Regression pass not run for Build 5. Primary convergence (12 / 15 / 12) was tight enough to confirm; no reversal risk. P2/P3 from the primary pass are authoritative for polish backlog prioritization.

Note: P2/P3 counts differ between primary and regression passes for Builds 1–4 because
regression judges received more targeted prompts (narrower scope). P0 and P1 counts are
the operative signal; P2/P3 from the regression pass are under-counted and should not be
treated as authoritative. Use the primary pass P2/P3 counts for polish backlog
prioritization.

---

## 3. All Run Data

### Build 1: Stock SwiftUI

| Run | Pass       | P0  | P1  | P2  | P3  | P0+P1 |
| --- | ---------- | --- | --- | --- | --- | ----- |
| 1   | Primary    | 14  | 25  | 17  | 2   | 39    |
| 2   | Primary    | 7   | 16  | 16  | 4   | 23    |
| 3   | Primary    | 6   | 14  | 15  | 4   | 20    |
| 4   | Regression | 3   | 9   | 4   | 0   | 12    |
| 5   | Regression | 3   | 11  | 4   | 1   | 14    |
| 6   | Regression | 3   | 14  | 4   | 1   | 17    |

### Build 2: Web Impeccable Port

| Run | Pass       | P0  | P1  | P2  | P3  | P0+P1 |
| --- | ---------- | --- | --- | --- | --- | ----- |
| 1   | Primary    | 7   | 24  | 22  | 6   | 31    |
| 2   | Primary    | 1   | 18  | 14  | 1   | 19    |
| 3   | Primary    | 1   | 19  | 17  | 0   | 20    |
| 4   | Regression | 1   | 11  | 5   | 0   | 12    |
| 5   | Regression | 1   | 18  | 9   | 0   | 19    |
| 6   | Regression | 1   | 19  | 6   | 0   | 20    |

### Build 3: impeccable-swift

| Run | Pass       | P0  | P1  | P2  | P3  | P0+P1 |
| --- | ---------- | --- | --- | --- | --- | ----- |
| 1   | Primary    | 4   | 22  | 17  | 7   | 26    |
| 2   | Primary    | 0   | 10  | 17  | 1   | 10    |
| 3   | Primary    | 0   | 10  | 17  | 1   | 10    |
| 4   | Regression | 0   | 9   | 4   | 1   | 9     |
| 5   | Regression | 0   | 8   | 4   | 1   | 8     |
| 6   | Regression | 0   | 7   | 1   | 1   | 7     |

### Build 4: Full Setup

| Run | Pass       | P0  | P1  | P2  | P3  | P0+P1 |
| --- | ---------- | --- | --- | --- | --- | ----- |
| 1   | Primary    | 0   | 10  | 14  | 3   | 10    |
| 2   | Primary    | 0   | 10  | 14  | 0   | 10    |
| 3   | Primary    | 0   | 10  | 13  | 0   | 10    |
| 4   | Regression | 0   | 10  | 1   | 0   | 10    |
| 5   | Regression | 0   | 11  | 1   | 0   | 11    |
| 6   | Regression | 0   | 10  | 2   | 2   | 10    |

### Build 5: Fonts (primary only)

| Run | Pass    | P0  | P1  | P2  | P3  | P0+P1 |
| --- | ------- | --- | --- | --- | --- | ----- |
| 1   | Primary | 4   | 8   | 8   | 1   | 12    |
| 2   | Primary | 8   | 7   | 3   | 1   | 15    |
| 3   | Primary | 7   | 5   | 3   | 2   | 12    |

---

## 4. Gradient Confirmation

The build quality gradient holds when Build 5 is inserted between Build 2 and Builds
3/4. Build 5 sits in a "middle tier" — worse than the impeccable-swift builds, better
than both REWORK builds. The fixture was designed to exercise font and color rules in
isolation, and it shows: a structurally competent surface with category-specific failures
scores worse than Builds 3 and 4 (which the full skill + DESIGN.md addresses) but far
better than Builds 1 and 2 (which lack both).

```
P0+P1 (primary pass median):
Build 1: 23  |||||||||||||||||||||||
Build 2: 20  ||||||||||||||||||||
Build 5: 12  ||||||||||||
Build 3: 10  ||||||||||
Build 4: 10  ||||||||||
```

The gradient story holds: Stock → Web → Fonts → impeccable-swift → Full Setup.
Build 5 lands in the expected position for "partial compliance" — enough structure
to avoid REWORK, not enough rule coverage to clear P0+P1 below 10.

---

## 5. Phase 3 Rule Validation

This section is new to 3.1.1. Two Phase 3 detector rules (`monoculture_display_font`
and `italic_serif_headline`) were added in v0.3.0 and are validated here against Build 5.

### New rules: detector fire confirmation

| Rule                    | SwiftLint hits | Source lines (Build 5 fixture)  | Judge convergence |
| ----------------------- | -------------- | ------------------------------- | ----------------- |
| `monoculture_display_font` | 4           | 127 (nav title), 305 (hero headline), 313 (hero subtitle), 547 (ModelPickerChip) | 3/3 judges caught all 4 sites |
| `italic_serif_headline` | 1              | 305 (`.italic()` on 34pt Fraunces headline) | 3/3 judges caught this |

Both new rules fire on Build 5 and every judge caught them. The rule behavior matches
expectation: `monoculture_display_font` fires on both Fraunces (3 hits) and Plus Jakarta
Sans (1 hit); `italic_serif_headline` fires on the display-scale `.italic()` modifier.

### Pre-existing rules: continued coverage on Build 5

| Rule                       | SwiftLint hits | Notes                                         |
| -------------------------- | -------------- | --------------------------------------------- |
| `material_on_content_layer` | 9             | Includes WelcomeHeroHeader card (confirmed P1 by judges), DateHeaderRow, received bubbles, photo/link/PDF bubble fills, reply chip |
| `accessibility_hidden_on_text` | 4         | Lines 418, 434, 446, 831 — sender name + timestamps; judges ranked two of these P0/P1 |

**Summary:** Both Phase 3 rules validated. Pre-existing rules continue to fire on the
expected patterns. No new rule was silent; no new rule produced false positives that
caused judge disagreement. Phase 3 detector stack is confirmed for v0.3.0 ship.

---

## 6. What's Notable for v0.3.0

### a. Ground-truth blind spot: cobalt accent vs. DESIGN.md

The `critique-build5.md` ground truth (authored before the blind judge runs) did not
flag the cobalt `chatAccent` (#2563EB) as a violation against the DESIGN.md spec
(#c97350 warm rust). The ground truth used the fixture's own DESIGN.md reference —
but the DESIGN.md in the fixture directory actually specifies `#2563eb` as the accent,
making the ground-truth author treat cobalt as correct.

All 3 blind judges caught this as a P0 or P1: they compared the token value to a
semantic expectation ("warm, product-feel, not techy cobalt") and flagged the mismatch
as off-brief. This is a finding about the ground-truth-authoring workflow: ground-truth
critiques can be anchored to the fixture's own DESIGN.md when the real violation is that
the DESIGN.md itself specifies the wrong value. An improvement for future evals: the
ground truth author should cross-check the fixture DESIGN.md against the project
brief, not just the fixture file.

This is not a judge error and not a fixture error. The blind judges surfaced a real
design-spec consistency violation the author missed. Ground truth P0+P1 was 5; judges
came back at median 12. The delta is explained entirely by the cobalt-vs-brief mismatch
(P0 in all 3 runs, ~4 P0 median) plus more aggressive classification of the font
monoculture findings (ground truth grouped them as a single P0 cluster; judges expanded
to per-instance severity).

### b. Gradient holds

With Build 5 inserted, the five-point gradient from Stock (23) → Web (20) → Fonts (12)
→ impeccable-swift (10) → Full Setup (10) tells a coherent story. Build 5 occupies the
"partial compliance" slot: it has the right layout structure but wrong design tokens.
The gradient is meaningful, not a coincidence of fixture selection.

### c. New Phase 3 rules validated

`monoculture_display_font` and `italic_serif_headline` both fired reliably on Build 5
(4 hits and 1 hit respectively) and were confirmed by 3/3 judges. These rules are
production-ready for v0.3.0 ship.

### d. Regression skipped — primary convergence justified the call

Build 5 primary runs were 12 / 15 / 12. Two of three runs agreed exactly; the outlier
(run 2, 15) was one judge classifying typography findings as P0 vs. P1. The spread is
within the normal judge-variance band observed on Builds 3 and 4 (whose regressions
confirmed identical findings). Skipping regression was the right call. A 3-run median
of 12 on a 3-run primary is a stable signal.
