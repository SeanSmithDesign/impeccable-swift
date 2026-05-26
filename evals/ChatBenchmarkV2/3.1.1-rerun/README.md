# ChatBenchmarkV2 — 3.1.1 Rerun

## Purpose

Validate the two detector rules added in v0.3.0 Phase 3 against all five Build fixtures:

- `monoculture_display_font` — flags `.font(.custom("<TrendFont>", ...))` on display/nav-title sites
- `italic_serif_headline` — flags `.font(.custom("<SerifFace>", ...)).italic()` at large type scale

## Fixture scope

| Build | Directory | Role |
|-------|-----------|------|
| Build1 | `Build1_Stock` | Stock AI draft — no skill, no DESIGN.md |
| Build2 | `Build2_WebImpeccable` | Web impeccable brief only |
| Build3 | `Build3_ImpeccableSwift` | impeccable-swift skill only |
| Build4 | `Build4_FullSetup` | Full setup: skill + DESIGN.md |
| Build5 | `Build5_Fonts` | NEW: exercises v0.3.0 font/italic rules + v0.2.0 issues |

## Protocol

6-rep median, independent judges, same 4-condition structure as prior runs.
Baseline for comparison: 3.0-rerun results in `evals/ChatBenchmarkV2/3.0-rerun/`.
Results file will be written here by the orchestrator after the eval run completes.

## FAIL gate

Per `feedback_unattended-fail-gates.md`: halt to Sean on any FAIL verdict. Do not auto-continue.
