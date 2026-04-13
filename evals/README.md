# Evals — A/B Proof-of-Effect Harness

## What this is

This directory contains a cheap, rerunnable A/B protocol for producing **directional evidence** that the `impeccable-swift` skill family improves Claude's SwiftUI output. It is explicitly **not** a controlled scientific experiment — there is no blinding, no sample size planning, and no statistical test. It is POC-appropriate rigor: small, concrete briefs that anyone with a Claude account can paste into two fresh sessions (one with the skill installed, one without) and compare the results side by side.

If the skill works, the "with" outputs should look visibly different from the "without" outputs in ways that map to the reference docs shipped in `impeccable/reference/`.

## Protocol

1. **Pick a brief.** Choose any `brief-*.md` file in this directory, or write your own following the template at the bottom of this README.
2. **Run the "without" condition.**
   - Open a fresh Claude session with **no** `impeccable-swift` skill installed (and no other SwiftUI/design skill that could bias the result).
   - Paste the brief's prompt block verbatim.
   - Save the response as `outputs/<brief-name>-without.swift` (or `.md` if the response is multi-file).
3. **Run the "with" condition.**
   - Install `impeccable-swift`: `npx skills add SeanSmithDesign/impeccable-swift` once public. During the POC, clone the repo locally and point your skill manager at the path.
   - Open a fresh Claude session (new context window — do not reuse the "without" thread).
   - Paste the same brief verbatim.
   - Save the response as `outputs/<brief-name>-with.swift`.
4. **Record metadata.** For both conditions, capture Claude model name, date run, and skill version installed. Either as a header comment at the top of the `.swift` file, or in a companion `outputs/<brief-name>.meta` file.
5. **Diff the outputs.** Visually or with any diff tool. Signals to watch for:
   - Hardcoded hex colors vs. Asset Catalog / semantic color references
   - `.font(.system(size:))` with magic numbers vs. Dynamic Type text styles
   - Arbitrary spacing values vs. the 4pt scale
   - Fixed `.frame(width:height:)` on Text vs. layout that respects content size
   - Missing `.accessibilityLabel` on icon-only controls
   - PNG-backed `Image(...)` calls vs. SF Symbols
   - `cornerRadius(...)` without `.continuous` style vs. `RoundedRectangle(cornerRadius:style:.continuous)`
   - `Color.white.opacity(...)` stacks vs. `Material` surfaces
6. **Optionally run the detectors.** `swiftlint lint --config tools/.swiftlint.yml <output>` and `swift run impeccable-lint <output>` give a rough quantitative delta in violation counts.

## What counts as a positive result

- The "with" output contains **fewer violations** than the "without" when run through the linters.
- The "with" output uses **at least one Apple-specific idiom the "without" misses** — e.g. Liquid Glass material, `@ScaledMetric`, `ContentUnavailableView`, `#Preview` with Dynamic Type / color scheme variants, `Label` with SF Symbol, `.accessibilityLabel` on icon buttons.
- A designer reviewing the outputs **prefers the "with" version** on the success criteria listed in `docs/PLAN.md` (Success Metrics).

## What this proves and doesn't

- **Proves:** the skill content meaningfully moves Claude's output in the direction the reference docs describe.
- **Does not prove:** statistical significance, generalization beyond these three briefs, that every reference doc is exercised, or that the effect holds across Claude model versions.

## How to add a brief

Briefs should be **1–3 sentences**, exercise **3–5 reference docs**, and be small enough that Claude can respond in a single turn. Favor concrete UI surfaces (a screen, a flow, a component) over abstract prompts. Each brief file follows this template:

```markdown
# Brief NN — <name>

**Prompt:** _"<exact text to paste>"_

**Exercises:** <comma-separated reference doc slugs>

**Expected signals in the "with" output:**

- <checkable criterion>
- ...

**Known failure modes in the "without" output:**

- <what baseline Claude typically gets wrong>
- ...
```

## Disclosures

- POC-era: briefs were written by Sean (the skill author). No external reviewer blinding.
- Brief coverage is narrow — three briefs, each touching a subset of the reference docs. Not exhaustive.
- `outputs/` is intentionally empty in v0.1.0-poc. It will be populated during the Brakus dogfood cycle (Unit 9 of `docs/PLAN.md`) and by any third party who runs the protocol.
