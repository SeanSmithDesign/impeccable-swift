# Upstream Surveillance

**Pinned SHA:** `4af581e23f17d112d8f9d6b7a5b7ff37823494e1`
**Pinned on:** 2026-05-26
**Upstream:** https://github.com/pbakaus/impeccable

## Review Cadence

Monthly during active upstream dev; quarterly if upstream slows.

## Notable Upstream Events

- **2026-05-26: impeccable-swift v0.3.0 shipped.** Pin moved to `4af581e2` (`skill-v3.1.1`). 35 reference docs got STYLE.md tone pass; `codex.md` added as Swift-translated 36th port. Two new detector rules ship (`monoculture_display_font`, `italic_serif_headline`) and Build5_Fonts fixture validates them at P0+P1 median 12 / 5-build gradient holds (see `evals/ChatBenchmarkV2/3.1.1-rerun/BENCHMARK_RESULTS-3.1.1-final.md`).
- **2026-05-26: Impeccable 3.0.4 through 3.1.1 upstream.** 3.0.4-3.0.7 patch series: reference doc prose pass across all 27 docs plus two new detector rules (`monoculture_display_font`, `italic_serif_headline`). 3.1.0 minor: detector engine v2 modularization, Astro site migration, `impeccable-asset-producer` subagent, Live Mode browser picker + jsdom + Playwright integration, Critique persistence per-run snapshots. New `codex.md` reference doc (105 lines, Codex-specific image flow and user gates). 3.1.1: patch series cleanup and CLI fixes.
- **2026-04-24: Impeccable 3.0 merged upstream** (PR #109, merge commit `6816558`, HEAD `f5e82162`). Major re-architecture: 18 standalone skills consolidated into one `/impeccable` skill with 23 sub-commands via a router pattern; new `brand` / `product` register system; mandatory `load-context.mjs` for PRODUCT.md + DESIGN.md; browser-based Live Mode (~2,500 lines across 7 `.mjs` scripts); `pin.mjs` shortcut shims; `command-metadata.json` single source of truth; a11y moved into `audit.md`. Typography (+45 lines) and craft (+70 lines) are the only ported reference docs with substantive text changes; the other six are unchanged. See `docs/3.0-upgrade-plan.md` for the port scope and locked decisions.

## Reviewed Upstream Commits

| Date       | SHA Range                             | Reviewed By       | Incorporated                                                                            | Rejected (with rationale)                                                                                                         | Already Covered                                                                                    |
| ---------- | ------------------------------------- | ----------------- | --------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------- |
| 2026-04-12 | pinned at `00d485659`                 | initial pin       |:                                                                                       |:                                                                                                                                 |:                                                                                                  |
| 2026-04-16 | `00d485659` (no change)               | pre-launch review |:                                                                                       |:                                                                                                                                 | upstream main unchanged since pin; PR #56 (Chrome extension / v2.0) was already merged at pin time |
| 2026-04-24 | `00d485659`..`f5e82162` (127 commits) | 3.0 review        | Yes: v0.2.0. Port complete on `claude/impeccable-3-0-upgrade-4MsLs`, merged as v0.2.0. | Live Mode browser picker (no Apple-native analog; replaced with Xcode Previews + SnapshotPreviews stub under `reference/live.md`) |:                                                                                                  |
| 2026-05-26 | `f5e82162`..`4af581e23f17d112d8f9d6b7a5b7ff37823494e1` (94 commits) | 3.1.1 review | Yes: v0.3.0 shipped. Scope: 27 reference doc STYLE.md prose pass, new `codex.md` reference doc (Swift-translated), new detector rules (`monoculture_display_font`, `italic_serif_headline`), new ChatBenchmarkV2 Build5_Fonts fixture, 3.1.1 rerun. | Detector engine v2 modularization (3.1.0): our Swift detector stack is already modular. Astro site migration: no upstream site to mirror. `impeccable-asset-producer` subagent: deferred to v0.4.0+ per conservative scope decision. Live Mode browser picker, jsdom, Playwright: no Apple analog (stays as SnapshotPreviews stub). |:                                                                                                  |
