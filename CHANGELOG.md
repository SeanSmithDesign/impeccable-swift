# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## v0.1.0-poc — Public flip (2026-04-21)

- Added 4-way ablation outputs for brief-01 (Settings screen): C1 no-skill / C2 impeccable (web) / C3 impeccable-swift / C4 Sean's personal Claude setup. See `evals/outputs/brief-01/RESULTS.md`.
- Added hero visual `docs/media/grid-4-way.png` (code-card composition, not rendered UI — honest limitation noted in RESULTS.md).
- README enriched: Why Swift / How we tested / Early results / Backlog / Reader guidance.
- Added `docs/research-notes.md` as the depth layer for the methodology.
- Brukas case study shipped to `impeccable-swift-marquee-pass` branch in SeanSmithDesign/Pico-Timer — not merged.
- U9 (Brukas dogfood) and U10 (public flip) complete in `docs/PLAN.md`.

## [0.1.0-poc] — 2026-04-16

- 12 reference docs: 8 ported from upstream (typography, color-and-contrast, spatial-design, motion-design, interaction-design, responsive-design, ux-writing, craft) + 4 Swift-native (sf-symbols, materials, navigation, ios-vs-macos) + 1 accessibility doc from HIG gap analysis
- 3 skills: impeccable-swift (umbrella), critique (evaluate + score), polish (tighten generated code)
- Three-tool detector stack: SwiftLint custom_rules (10 line-regex rules), impeccable-lint SwiftSyntax CLI (4 AST checks), asset-catalog-checker
- SnapshotPreviews convention docs and per-platform setup guide
- A/B evals: 4 briefs + ChatBenchmark V2 (4-condition, independent judges) — P0+P1 findings drop from 28 (stock) → 4 (impeccable-swift + DESIGN.md)
- Upstream pinned at `00d485659` (2026-04-12); no upstream drift at launch
