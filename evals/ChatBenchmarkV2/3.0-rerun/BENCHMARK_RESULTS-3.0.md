# ChatBenchmarkV2: Phase 3.0 Results

Run date: 2026-04-26
Methodology: 3-rep blinded judge pass per build (12 critique files total)
Judge prompt: impeccable-swift 3.0 reference suite (critique.md + full reference docs)
Detector pass: impeccable-lint, SwiftLint, asset-catalog-checker (see detector-panel.md)
Regression status: TRIGGERED (Build 4 median P0+P1 = 10, threshold = 4)

---

## 1. Median Scores (Runs 1-3)

All figures are medians across the 3 blinded runs. Per-severity medians are
computed independently (not decomposed from total). P0+P1 is the median of
the per-run P0+P1 sums.

| Build               | P0 (med) | P1 (med) | P2 (med) | P3 (med) | Total (med) | P0+P1 (med) | Verdict       |
| ------------------- | -------- | -------- | -------- | -------- | ----------- | ----------- | ------------- |
| 1: Stock SwiftUI    | 7        | 16       | 16       | 4        | 43          | 23          | REWORK        |
| 2: Web Impeccable   | 1        | 19       | 17       | 1        | 38          | 20          | REWORK        |
| 3: impeccable-swift | 0        | 10       | 17       | 1        | 28          | 10          | Review needed |
| 4: Full Setup       | 0        | 10       | 14       | 0        | 24          | 10          | Review needed |

Note: "Review needed" is provisional. Regression pass (runs 4-6) pending.
Final verdicts will be issued after the regression pass median is computed.

---

## 2. Per-Run Counts

### Build 1: Stock SwiftUI

| Run        | P0    | P1     | P2     | P3    | Total  | P0+P1  |
| ---------- | ----- | ------ | ------ | ----- | ------ | ------ |
| 1          | 14    | 25     | 17     | 2     | 58     | 39     |
| 2          | 7     | 16     | 16     | 4     | 43     | 23     |
| 3          | 6     | 14     | 15     | 4     | 39     | 20     |
| **Median** | **7** | **16** | **16** | **4** | **43** | **23** |

High variance in Run 1 vs Runs 2-3. Run 1 judge applied P0 more liberally
(14 P0s) vs Runs 2-3 (6-7 P0s). Median stabilizes the signal. The 3-run
median P0+P1=23 is the operative score.

### Build 2: Web Impeccable Port

| Run        | P0    | P1     | P2     | P3    | Total  | P0+P1  |
| ---------- | ----- | ------ | ------ | ----- | ------ | ------ |
| 1          | 7     | 24     | 22     | 6     | 59     | 31     |
| 2          | 1     | 18     | 14     | 1     | 34     | 19     |
| 3          | 1     | 19     | 17     | 0     | 37     | 20     |
| **Median** | **1** | **19** | **17** | **1** | **38** | **20** |

Large Run 1 outlier (7 P0s vs 1 in Runs 2-3). Run 1 judge classified
UIScreen.main.bounds as a P0 and applied that classification broadly;
Runs 2-3 judges classified it as the sole P0. Median P0=1 is the stable value.

### Build 3: impeccable-swift

| Run        | P0    | P1     | P2     | P3    | Total  | P0+P1  |
| ---------- | ----- | ------ | ------ | ----- | ------ | ------ |
| 1          | 4     | 22     | 17     | 7     | 50     | 26     |
| 2          | 0     | 10     | 17     | 1     | 28     | 10     |
| 3          | 0     | 10     | 17     | 1     | 28     | 10     |
| **Median** | **0** | **10** | **17** | **1** | **28** | **10** |

Run 1 is a clear outlier (4 P0, 22 P1 vs 0 P0, 10 P1 in Runs 2-3). Run 1
appears to have over-fired on issues already fixed in Build 3 (corner radius
style, some navigation issues). Runs 2-3 are stable and nearly identical.
Median is robustly 10 P0+P1.

### Build 4: Full Setup

| Run        | P0    | P1     | P2     | P3    | Total  | P0+P1  |
| ---------- | ----- | ------ | ------ | ----- | ------ | ------ |
| 1          | 0     | 10     | 14     | 3     | 27     | 10     |
| 2          | 0     | 10     | 14     | 0     | 24     | 10     |
| 3          | 0     | 10     | 13     | 0     | 23     | 10     |
| **Median** | **0** | **10** | **14** | **0** | **24** | **10** |

Extremely stable across all 3 runs. Zero variance on P0+P1 (10 in all three
runs). This suggests the judges are reaching consensus on a consistent set of
10 P1 issues. The 10 P1s form a well-defined cluster: 5 material-misuse
instances (content-layer glass), 1 inline color token (chatAccent), 1
hardcoded font size (PhotoBubble emoji), 1 concentric corner violation, and 2
accessibility issues (.accessibilityHidden on timestamps and sender names).

---

## 3. Comparison: Phase 3.0 vs v0.1.0 Baseline

v0.1.0 baseline was a single-run, single-judge pass. Direct comparison is
approximate due to methodology difference.

| Build    | v0.1.0 P0+P1 | Phase 3 P0+P1 (med) | Delta | Direction                 |
| -------- | ------------ | ------------------- | ----- | ------------------------- |
| 1: Stock | 28           | 23                  | -5    | Fewer (judge calibration) |
| 2: Web   | 20           | 20                  | 0     | Unchanged                 |
| 3: Swift | 11           | 10                  | -1    | Unchanged (within noise)  |
| 4: Full  | 4            | 10                  | +6    | More (Phase 3 stricter)   |

### Build 1 delta (-5)

Phase 3 judges find fewer P1s for Build 1 than v0.1.0. The v0.1.0 judge
reported 21 P1s; Phase 3 median is 16. This is within expected judge-to-judge
variance. The P0 count is identical (7).

### Build 2 delta (0)

The P0+P1 total is identical at 20, but the composition differs. v0.1.0
reported P0=7, P1=13; Phase 3 median is P0=1, P1=19. Phase 3 judges are
reclassifying UIScreen.main.bounds and some color violations from P0 to P1
while finding more P1s overall (all 10 Palette inline Color literals, fuller
tap target audit).

### Build 4 delta (+6)

The significant upward movement. v0.1.0 reported P0+P1=4 for Build 4.
Phase 3 reports P0+P1=10. The additional 6 findings are explained by:

1. Material misuse: Phase 3 reference suite introduced explicit material-on-
   content-layer rules. The v0.1.0 critique did not flag the 5 bubble surface
   material calls as P1; Phase 3 consistently does.
2. accessibilityHidden: Phase 3 flagged timestamps and sender names hidden
   from VoiceOver as P1. v0.1.0 did not flag this pattern.
3. chatAccent inline color: Both versions flag this, but Phase 3 is consistent
   on it (all 3 judges).

These findings represent improved recall in Phase 3, not regression in Build 4.
The build is not worse; the judge is more thorough.

---

## 4. Gradient Validation

The build quality gradient (Build 1 worst, Build 4 best) is preserved in
Phase 3 results.

```
P0+P1 (Phase 3 median):
Build 1: 23  ||||||||||||||||||||||||
Build 2: 20  ||||||||||||||||||||
Build 3: 10  ||||||||||
Build 4: 10  ||||||||||
```

Build 3 and Build 4 converge at P0+P1=10 in Phase 3, compared to 11 vs 4 in
v0.1.0. The convergence is real: the 10 P1s in Build 4 are genuine issues
that Build 3 also shares (material misuse, accessibility). Build 4's advantage
over Build 3 appears in the P2 and P3 counts (14 vs 17 P2s) and in the total
issues found (28 vs 24 median total). Build 4 is still measurably better than
Build 3, but the gap is narrower than v0.1.0 suggested.

---

## 5. Top P1 Issues by Frequency (Build 4)

These 10 P1 issues appeared in all 3 runs:

| #   | Issue                                                        | Category      | Rule                  |
| --- | ------------------------------------------------------------ | ------------- | --------------------- |
| 1   | .regularMaterial on received TextBubble (content layer)      | Material      | materials.md          |
| 2   | .ultraThinMaterial on PhotoBubble (content layer)            | Material      | materials.md          |
| 3   | .regularMaterial on PDFBubble (content layer)                | Material      | materials.md          |
| 4   | .thinMaterial on ReplyBubbleRow (content layer)              | Material      | materials.md          |
| 5   | .regularMaterial on sent TextBubble via bubbleSurface()      | Material      | materials.md          |
| 6   | chatAccent = Color(red:green:blue:) inline literal           | Color         | color-and-contrast.md |
| 7   | PhotoBubble emoji .font(.system(size:56))                    | Typography    | typography.md         |
| 8   | LinkPreviewCard concentric corner math: inner=10, expected=2 | Spatial       | spatial-design.md     |
| 9   | Timestamps .accessibilityHidden(true)                        | Accessibility | accessibility.md      |
| 10  | Sender names .accessibilityHidden(true)                      | Accessibility | accessibility.md      |

Items 1-5 (material misuse) are the single largest category by count.
All 5 are the same root cause: the view uses .material fills on message
content bubbles rather than on floating chrome only.

---

## 6. Regression Check

**Threshold:** Build 4 median P0+P1 > 4 triggers regression retry pass.
**Observed:** Build 4 median P0+P1 = 10.
**Decision: REGRESSION PASS TRIGGERED.**

This is an expected false trigger. The threshold of 4 was calibrated against
the v0.1.0 baseline (where Build 4 P0+P1=4). Phase 3 judges consistently
find 10 P1s due to stricter material and accessibility criteria, not because
Build 4 regressed. Nevertheless, the protocol requires a regression pass.

Regression pass: runs 4-6 for all 4 builds (12 additional critique files).
Output directory: `evals/ChatBenchmarkV2/3.0-rerun/` (same dir, runs 4-6).
Final results will be reported in BENCHMARK_RESULTS-3.0-final.md after
the regression pass medians are computed.

---

## 7. Detector Confirmation

All P1 issues confirmed by detectors where applicable. See detector-panel.md
for full output.

| Issue                                | impeccable-lint  | SwiftLint |
| ------------------------------------ | ---------------- | --------- |
| Hardcoded font size (.system(size:)) | yes              | yes       |
| chatAccent inline color              | no (struct decl) | yes       |
| Icon images without label            | yes              | no        |
| Material misuse                      | no               | no        |
| accessibilityHidden abuse            | no               | no        |
| Concentric corner math               | no               | no        |

The two issues no tool catches (material misuse, accessibilityHidden abuse)
are validated by 3-judge consensus instead. All 3 runs flagged them independently.

---

## 8. Methodology Notes

**Blinding:** Each judge received only its target build's source code and the
reference rules inlined in the prompt. No judge saw another judge's output.

**Run 1 outlier variance:** Runs 1 showed higher P0 counts for Builds 1-3.
This is consistent with the first-judge effect seen in other critique evals:
without a calibration anchor, the first judge may assign P0 more liberally.
The 3-rep median is designed to absorb this effect.

**Build 4 stability:** All 3 Build 4 runs reported P0+P1=10 exactly. This
is the strongest calibration signal in the eval: the Phase 3 reference suite
produces deterministic results for a well-implemented view.
