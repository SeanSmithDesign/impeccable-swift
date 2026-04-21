# Research notes — impeccable-swift v0.1.0-poc

This is the depth layer for anyone curious about _how_ the v0.1.0-poc claims were produced and what they do and don't support. It's intentionally long-form — the README stays terse on purpose; this file is where the methodology receipts live.

If you're skimming: the most important sections are **Limitations** and **What was NOT tested**. Everything else is setup.

---

## Methodology

### Framing: this is a POC, not a benchmark

Before anything else: v0.1.0-poc is not trying to prove impeccable-swift is better than the alternatives. It's trying to show whether the philosophy — _declare the intent, explain the why, name the rule, flag the anti-pattern_ — can be faithfully ported from web to Swift, and whether that port changes the shape of generated code in a direction a Swift-literate designer would recognize as more idiomatic.

"More idiomatic" is doing a lot of work in that sentence. For this POC, more idiomatic means: reaches for the platform's built-in primitives (`Form`, `Label`, `role: .destructive`) before hand-rolling equivalents; honors accessibility signals (`@ScaledMetric`, `#Preview` under Dynamic Type); uses the Asset Catalog / semantic color channel instead of inline hex; writes copy in Apple voice (sentence case, short, plain). None of those are novel — they're straight out of HIG. The question is whether a skill can reliably guide an agent toward them on a blank-slate brief.

That framing matters because the methodology below is light by the standards of rigorous ML evaluation. It is directional evidence, not quantitative benchmark data.

The bar for a POC is lower than the bar for a v1.0: does the philosophy port cleanly, does the first brief show the expected shape of signal, does a real production-adjacent app benefit from running the skill against it. All three can be answered "yes, with named caveats" without needing a 100-brief benchmark. The 100-brief benchmark is the v1.0 bar.

One more framing note: impeccable-swift is a _design-quality_ skill, not a code-correctness skill. The question it asks is "does this SwiftUI code look like something a Swift-literate designer would have written," not "does this SwiftUI code compile and work." The ablation briefs are all designed so all four outputs compile; the differences are in taste, idiom, and accessibility — not correctness. That distinction keeps the evaluation tractable.

### The 4-way ablation

One brief (`brief-01-settings-screen.md` — a Settings screen with three toggles and a destructive Logout button) was generated four times under four different configurations. Each configuration was meant to represent a plausible real-world setup a working Swift developer might inherit:

- **C1 — no skill.** No impeccable, no project `DESIGN.md`, no custom system prompt. Pure "out of the box" SwiftUI.
- **C2 — impeccable (web).** The original web-oriented impeccable skill, applied to Swift without the Swift-native reference docs. This models what happens when a designer with strong web craft instincts translates their workflow to SwiftUI without porting the idiom.
- **C3 — impeccable-swift.** This fork, including the 4 Swift-native reference docs (sf-symbols, materials, navigation, ios-vs-macos) and the `critique` + `polish` skills.
- **C4 — Sean's personal Claude setup.** No impeccable skill, but _with_ `DESIGN-SWIFT.md.template` loaded (semantic `AppColor` enum, 4pt `AppSpacing` scale, 8pt corner radius tokens, 44pt tap-target minimums, sentence-case copy). This is the fair comparison: what a thoughtful developer with a good template but no skill produces.

All four outputs were generated to the same brief and constrained to the same SDK target (iOS 26). All four parse and typecheck cleanly against `xcrun swiftc -typecheck -sdk iphoneos -target arm64-apple-ios26.0`.

### How each condition was actually run

Honest disclosure: a subagent inherits one environment. I can't truly swap skill configurations mid-run the way four separate machines could. What I did instead, per condition:

- Loaded the reference docs, templates, or SKILL.md files specific to that condition into working context.
- Stripped or added project-specific configuration (`DESIGN-SWIFT.md.template` for C4 only, impeccable-swift reference docs for C3 only, impeccable web reference docs for C2 only).
- Held to the brief's constraints (SwiftUI, iOS 26, three toggles, destructive Logout).
- Generated the output in one pass, no iterative critique (the ablation is about initial generation, not polish).

This is role-play within a single session rather than environment isolation. It's the cheapest honest way to get directional signal; it's also the main reason the **Limitations** section below names sample size and single-session bias as the first things to fix.

### Brukas case study

Two passes, April 15 and April 21, on [Brukas](https://github.com/SeanSmithDesign/Pico-Timer) — a ~24-view SwiftUI focus app with a bespoke design system called Deep Espresso (evolved from "Warm Clay"). The first pass was a three-file sweep. The second pass (the marquee) was focused on `ChatScreen.swift` (829 lines, the primary view), using `/critique` to generate a prioritized findings table, then selecting the 2–4 highest-leverage visual fixes and committing each one separately with a conventional-commit message.

The full marquee pass is preserved at:

- Branch: `impeccable-swift-marquee-pass` in `SeanSmithDesign/Pico-Timer`
- Case study write-up: [`case-study-brukas-impeccable-swift.md`](https://github.com/SeanSmithDesign/Pico-Timer/blob/impeccable-swift-marquee-pass/docs/case-study-brukas-impeccable-swift.md)
- Raw critique output: [`case-study-brukas-critique-raw.md`](https://github.com/SeanSmithDesign/Pico-Timer/blob/impeccable-swift-marquee-pass/docs/case-study-brukas-critique-raw.md)

Branch is intentionally not merged. It's a public receipt of a single polish pass, not a proposed shipping change.

---

## Setup decisions

### Why a Settings screen for brief-01

A Settings screen exercises a lot of surface area in a small amount of code: toggles (interaction), destructive action (intent semantics), sectioning (spatial structure), copy casing (ux-writing), icons (if reached for), and color semantics (system vs. hand-rolled). Six reference docs get touched by one small view. That made it the most information-dense first brief we could run.

A more ambitious brief (say, a chat interface) would have pushed the ablation from "directional" to "wide open" — too many degrees of freedom, too hard to compare. A narrower brief (a single Toggle) wouldn't have produced meaningful differences. Settings sits in the middle on purpose.

### Why these four conditions

Each condition maps to a plausible starting point a real developer might occupy:

- **C1** is the honest baseline — the "AI SwiftUI tutorial screenshot" archetype that `impeccable/SKILL.md` warns about.
- **C2** is the "web-trained taste without Swift idiom" condition. It isolates whether impeccable's _philosophy_ transfers without the Swift-native reference docs.
- **C3** is the thing we're testing.
- **C4** is the most interesting comparison. `DESIGN-SWIFT.md.template` is the global baseline Sean ships with every new project — semantic color enum, 4pt spacing scale, 8pt radius, 44pt tap targets. This is what "a carefully configured personal setup without impeccable-swift" looks like, and it's the steel-man case: if C4 produces Swift that's indistinguishable from C3, the skill isn't pulling weight.

### Why the grid image shows code cards, not rendered UI

A reasonable first instinct is "render the four SwiftUI views and screenshot them side by side." Two problems:

1. **Headless SwiftUI rendering is not trivial.** You need a simulator boot per view, or an Xcode Preview harness with a snapshot target per variant. Either path is real infrastructure — the kind of thing that earns its own unit in the plan.
2. **The code-level differences already show the signal.** `Form` vs. hand-rolled `VStack`, `Label` + SF Symbol vs. no icons, `Button(role: .destructive)` vs. `.foregroundColor(.red)`, `@ScaledMetric` vs. fixed font sizes — those don't need a screenshot to be visible to someone reading Swift.

So the v0.1.0-poc grid shows code. A rendered-UI grid is on the backlog (see **What's next** in the README) and is a natural companion piece for the v0.2 release.

---

### Marquee pass scope

The marquee pass (2026-04-21) was deliberately narrow:

- **One file, one view.** `ChatScreen.swift` — the primary view in the app. 829 lines. Chosen because it has real surface area (empty state, conversation state, timer state) and because it was the view most likely to expose drift between the design system's stated rules and the code as shipped.
- **Visual-impact filter.** Of the 15 findings in the critique output, only fixes that would show as a visible difference in a before/after screenshot were eligible. Refactors, pure-a11y changes, and architectural extractions were deferred.
- **One concern per commit.** Three atomic commits, each revertable in isolation, each with inline reasoning in the code.
- **No functional change.** Polish only. Tests weren't re-run because there was no behavioral delta to test.

This scope was chosen because it mirrors what a working designer-developer would actually do on a Friday afternoon before a public post: pick 2–4 fixes that move the needle visually, commit each cleanly, ship to a branch, don't merge. The point of a case study isn't to demonstrate exhaustiveness; it's to show the shape of a real polish loop.

---

## What was tested

1. **Whether impeccable-swift changes the shape of generated Swift** — specifically, whether it shifts output toward `Form`, `Label` + SF Symbol, `@ScaledMetric`, `role: .destructive`, and multi-variant `#Preview`. Answer: yes, on this brief. C3 is the only condition that reaches for any of those.
2. **Whether a carefully configured personal setup (C4) reaches those Apple-specific idioms without the skill.** Answer: no. C4 produces cleaner Swift than C1 or C2 but does not reach for `Form`, `Label`, or `#Preview` variants.
3. **Whether the skill surfaces useful findings on a real production-adjacent codebase (Brukas).** Answer: yes, on magic numbers and typography collisions. The detector story on Swift is still weak (see Limitations).
4. **Whether the skill's output is voice-consistent with upstream impeccable.** Answer: yes — same declare/why/rule/anti-pattern structure; Swift-specific docs sit alongside without contradicting.

---

## What was NOT tested

This is the honest list. Each of these is either on the backlog or explicitly out of scope for v0.1.0-poc:

- **Rendered SwiftUI screenshots.** The ablation grid shows source code, not rendered UI. Rendering is future work.
- **More than one brief.** Brief-02 (list with empty state), brief-03 (onboarding flow), and brief-04 (chat conversation) exist in `evals/` but have not been run through the 4-way grid.
- **Blind designer review.** The observations in `RESULTS.md` were written by the same person who wrote the skill. A third-party reviewer with the quadrant labels stripped has not seen the outputs.
- **Quantitative detector counts.** We have `impeccable-lint` (the SwiftSyntax CLI) — it exists at `tools/impeccable-lint/`. It has not yet been wired into the `critique` skill output, and it didn't contribute automated findings to either the ablation or the Brukas pass. Every substantive Swift finding so far came from LLM reasoning backed by targeted `grep` passes.
- **Larger codebases.** Brukas is ~24 views. The skill has not been tested on a 100+ view codebase. Behavior at scale is unknown.
- **Contributor-authored briefs.** All four briefs in `evals/` were written by the skill author. That's another author-bias vector.
- **iOS <26 / macOS <26.** Explicitly out of scope for v1 — the skill assumes Liquid Glass, `#Preview`, and SF Symbols 6+ are available.
- **Automated regression against upstream drift.** `UPSTREAM.md` tracks the pinned SHA and review cadence, but there is no CI job that alerts when upstream changes touch a ported doc.

---

### What would make the next pass more rigorous

Pulled from `RESULTS.md` and kept here so the depth layer stays self-contained:

- **Four separate Claude sessions, four machines or four fresh profiles.** True environment isolation, not role-play. The cost is real (four times the generation time), but the signal-quality jump is worth it for v0.2.
- **Automated detector counts per file.** Run `swiftlint` + `impeccable-lint` + the asset-catalog-checker against each condition's `.swift` file and publish violation-count deltas. The infrastructure for this already exists in `tools/`; wiring is the missing piece.
- **Blind designer review.** Hand the four files to a third party with quadrant labels stripped. Ask them to rank on six dimensions (structure, type, color, interaction, a11y, copy) and record where the rankings cluster vs. diverge.
- **All four briefs across the grid.** Brief-01 was the first; brief-02/03/04 exist and haven't been run. A single brief can't generalize.
- **Rendered screenshots, not code cards.** Build a tiny SwiftUI harness that hosts each view and exports a `.png` per condition. That makes the grid scan as four UIs rather than four blocks of code, which is what a casual reader of the README actually wants.

---

## Limitations

Four concrete limitations worth naming rather than burying:

### 1. Author-as-evaluator bias

Sean wrote the skill, the reference docs, the ablation brief, and the observations. C3 is the condition Sean had in mind when writing the Swift-native reference docs. The RESULTS.md observations section is written to avoid "C3 wins" framing, but the risk is real. A blind designer pass is the mitigation; it hasn't been run yet.

### 2. Single-session role-play for the ablation

Ablating skill configurations cleanly would mean four isolated Claude sessions, four machines or four fresh profiles, no shared context. What actually happened: a single subagent constrained its own behavior to match each configuration, informed by actually reading the relevant reference docs, templates, and SKILL.md files for each condition. That's honest directional evidence, not clean-room experimental data.

### 3. Web detector can't parse Swift

The `/critique` skill on the web runs `npx impeccable` — a jsdom-based automated detector — in parallel with LLM review. That detector doesn't understand SwiftUI source. On Swift, the detector role is currently filled by targeted `grep` passes for anti-pattern shapes (`Image(systemName:)`, `Color.red`, inline hex, magic numbers). That's honest work, but it's not what "three-tool detector stack" implies in the README. v0.2's main job is to wire `impeccable-lint` into the skill so Swift gets real AST-backed findings.

### 4. Sample size of 1 brief + 1 app

Every claim in the README is built on one ablated brief (Settings) and one production-adjacent app (Brukas). That's a small evidence base. The directional signal is honest; anyone treating it as a benchmark should wait for more briefs to land.

### 5. The Brukas case study has its own caveats

The Brukas pass is a single-author, single-repo, same-person-who-wrote-the-skill exercise. Some specific caveats worth naming:

- **The fixes were selected for visual impact, which is a selection bias.** Plenty of findings in the critique output that would have been valuable (accessibility grouping, extract-to-subview refactors, timing constants) were skipped because they didn't satisfy the "visible in a screenshot" filter. A different selection rule would produce a different shape of commit set.
- **Deep Espresso is flat by design.** Brukas has globally-disabled shadows as a deliberate aesthetic choice (ceramic/terracotta physicality without Material Design drop shadows). That means a whole class of findings the skill might otherwise surface — shadow opacity, elevation hierarchy — doesn't apply here. Another app with a more conventional design system might generate a very different critique profile.
- **The detector baseline is ripgrep, not SwiftSyntax.** Every Brukas finding that the skill "caught" was caught by targeted `grep` for anti-pattern shapes, not by AST-level analysis. A change as simple as wrapping a magic number in a function call would evade detection; a change as clever as naming a variable `magic20` would falsely trigger it. This is what v0.2 is supposed to fix.

---

## Observations the ablation actually produced

For reference — this is what the four outputs looked like at the structural level. Full text is in the individual `.swift` files; this is the compressed read.

### `Form` adoption

- **C1:** hand-rolled `VStack` of rows with manual `Divider()` between each. No `Form`, no `List`, no `Section`.
- **C2:** hand-rolled grouped rows inside a card with a shadow. Closer to web-card treatment than iOS Settings.
- **C3:** `NavigationStack { Form { Section("General") { Toggle …, Toggle …, Toggle … } Section { Button(role: .destructive) … } } }.formStyle(.grouped)`. The HIG-blessed shape.
- **C4:** hand-rolled, but _cleanly_ hand-rolled — semantic color enum, 4pt spacing scale, 44pt tap targets. Better craftsmanship on a worse structural choice.

### Icons

- **C1, C2:** no icons. C2 doesn't reach for them because web-impeccable instincts don't default to SF Symbol as the icon channel.
- **C3:** `Label("Notifications", systemImage: "bell.fill")` per row; `rectangle.portrait.and.arrow.right` on Logout.
- **C4:** no icons. `DESIGN-SWIFT.md.template` doesn't mandate them, and the brief doesn't explicitly ask. Sean's preset defers icon decisions to the project.

### Destructive action

- **C1:** `.foregroundColor(.red)` on a plain Button. Color doesn't adapt to dark mode correctly, no system semantics.
- **C2:** custom RGB destructive tint with a 0.1 opacity background wash. Visually thoughtful, system-semantically wrong.
- **C3:** `Button(role: .destructive)` wrapped in `.confirmationDialog` with accessibility label and hint. System renders the appropriate dark-mode-aware destructive red; accessibility layer knows this is destructive.
- **C4:** `.tint(AppColor.destructive)` on `.borderedProminent`. Semantic color token, but no `role: .destructive` and no confirmation dialog.

### Copy casing

- **C1:** "Logout", "Dark Mode" — title case, AI-tutorial default.
- **C2, C3, C4:** "Log out", "Dark mode" — sentence case, Apple voice. All three skilled conditions got this right.
- **C3 only:** added a confirmation dialog copy — "You can sign back in anytime." — written in plain supportive voice.

### Dynamic Type and `#Preview` variants

- **C1, C2:** fixed `.font(.system(size: 16))` on labels. Default `#Preview` only.
- **C3:** `@ScaledMetric(relativeTo: .body) var iconSize: CGFloat = 22`; three `#Preview` variants (Light, Dark, Dynamic Type `accessibility2`).
- **C4:** semantic `Color` tokens, 44pt row heights, spacing scale that would scale cleanly under Dynamic Type — but no `@ScaledMetric` and no `#Preview` variants.

The pattern across all five dimensions: C3 is the only condition that reaches for the Apple-specific _idiom_, not just Apple-safe craft. C4 has craft without idiom. C2 has idiom from the wrong platform. C1 has neither.

---

## Open questions

These are the questions I'd want to answer before v1.0:

1. **How much of the C3 signal is the skill vs. the reference docs alone?** If you stripped the `critique` and `polish` skills but kept the 13 reference docs in a context file, would the output look the same? A C5 condition — reference docs only, no skills — would isolate this.
2. **Would a fine-tuned model match skill-only outputs?** The skill is essentially a curated context window plus a prompt structure. How much of its value comes from the curation vs. the prompt scaffolding vs. the interactive loop?
3. **How does this hold up at 100+ view codebases?** Brukas is small. On a large app, does the critique signal get lost in noise, or does the AST-level detector (once wired) become the primary value?
4. **What's the right granularity for "before/after" on polished code?** On Brukas, three atomic commits was the natural unit. Is that the right shape for every polish pass, or does it only work when the starting code is already pretty good?
5. **Are there Swift-specific voice anti-patterns we haven't named yet?** Upstream impeccable calls out specific font/layout tells (Syne, generic hero grids). The Swift equivalent — which SF Symbols are AI tells, which Liquid Glass patterns feel cargo-culted — is still being discovered. The PicoShadow moment is an example: a rule that was right to flag on April 15 turned out to be a deliberate choice documented in `agent-craft.md` by April 21.
6. **Does the two-layer precedence rule (`DESIGN.md` wins over universal reference docs) produce surprising edge cases at scale?** In theory: project wins, universals fill gaps. In practice on Brukas: worked cleanly for this pass. On a larger codebase with more conflicting tokens, unclear.
7. **What's the right evaluation rubric for "Swift feels idiomatic"?** Nielsen's heuristics give us ten reasonable UX signals. HIG gives us platform conformance. Neither is a clean fit for the narrower question "does this generated code feel like something a senior Swift engineer would have written." A Swift-specific rubric — something that scores on platform-primitive adoption, accessibility-first defaults, Asset Catalog discipline, preview variant coverage, and copy casing — would be a useful artifact in its own right.
8. **How often should UPSTREAM.md be reviewed, and by whom?** Current cadence is monthly during active upstream dev, quarterly otherwise. That's a guess. The right cadence depends on how often upstream changes touch a ported doc, which we don't have a year of history to estimate from yet.

---

## Related work and why this exists as a fork

A short note on framing, because it comes up:

- **Upstream impeccable (Paul Bakaus).** The original. Web-oriented, beautifully opinionated, Apache 2.0 licensed. impeccable-swift is a faithful port — same philosophy, same declare/why/rule/anti-pattern structure. Paul's voice is preserved; Swift-native docs are strictly additive. NOTICE.md has the attribution chain.
- **Anthropic's frontend-design skill.** Upstream impeccable itself builds on this. impeccable-swift inherits the lineage transitively.
- **Apple's HIG.** The HIG is the ultimate authority on Apple idiom; the Swift-native reference docs in this repo are scoped to the _design-quality_ overlay — they assume HIG compliance is the floor and teach taste on top. They are not a replacement for HIG.
- **SwiftLint.** Existing tool for line-local style rules. impeccable-swift ships 10 `custom_rules` that extend SwiftLint with design-specific checks (e.g., flag `Color.red`, flag inline hex, flag `Image(systemName:)` instead of `Label`). SwiftLint + our custom_rules is the first of the three detector tiers.
- **SwiftSyntax / swift-syntax.** Apple's official Swift AST library. `tools/impeccable-lint/` uses SwiftSyntax to check patterns that cross line boundaries (e.g., a `VStack` whose body could have been a `Form`). This is the detector tier that has the most room to mature in v0.2.

Why ship this as a fork rather than upstream contributions to Paul's repo: Swift/SwiftUI is a separate enough idiom that mixing it into upstream would force every web reader to scroll past Apple-specific content. A separate repo with clean attribution keeps both surfaces focused. Paul's voice on web stays web-shaped; the Swift-native additions live alongside without contaminating the upstream read.

---

## Raw data pointers

Everything below is committed to this repo or linked from it:

### In this repo

- [`evals/outputs/brief-01/RESULTS.md`](../evals/outputs/brief-01/RESULTS.md) — full observations and caveats
- [`evals/outputs/brief-01/C1-no-skill.swift`](../evals/outputs/brief-01/C1-no-skill.swift)
- [`evals/outputs/brief-01/C2-impeccable-web.swift`](../evals/outputs/brief-01/C2-impeccable-web.swift)
- [`evals/outputs/brief-01/C3-impeccable-swift.swift`](../evals/outputs/brief-01/C3-impeccable-swift.swift)
- [`evals/outputs/brief-01/C4-sean-claude-setup.swift`](../evals/outputs/brief-01/C4-sean-claude-setup.swift)
- [`evals/outputs/brief-01/grid-4-way.png`](../evals/outputs/brief-01/grid-4-way.png) — source of the hero visual
- [`evals/outputs/brief-01/screenshot-C1.png`](../evals/outputs/brief-01/screenshot-C1.png) through `screenshot-C4.png` — individual code cards
- [`evals/outputs/brief-01/generate-grid.sh`](../evals/outputs/brief-01/generate-grid.sh) + `render-harness/` — reproduce the grid from the four `.swift` files in one command
- [`evals/brief-01-settings-screen.md`](../evals/brief-01-settings-screen.md) — the brief itself
- [`tools/impeccable-lint/`](../tools/impeccable-lint/) — the SwiftSyntax CLI (not yet wired into the `critique` skill)
- [`docs/PLAN.md`](./PLAN.md) — full 10-unit plan, including U9 (Brukas dogfood) and U10 (public flip)

### In the Brukas repo

- Branch: [`impeccable-swift-marquee-pass`](https://github.com/SeanSmithDesign/Pico-Timer/tree/impeccable-swift-marquee-pass)
- [`docs/case-study-brukas-impeccable-swift.md`](https://github.com/SeanSmithDesign/Pico-Timer/blob/impeccable-swift-marquee-pass/docs/case-study-brukas-impeccable-swift.md) — full case study write-up
- [`docs/case-study-brukas-critique-raw.md`](https://github.com/SeanSmithDesign/Pico-Timer/blob/impeccable-swift-marquee-pass/docs/case-study-brukas-critique-raw.md) — raw critique output (15 findings)
- Diff: `git diff gtm-alpha-launch..impeccable-swift-marquee-pass -- "Pico Focus/Views/ChatScreen.swift"` — the three atomic polish commits

---

## Glossary

Quick definitions for terms that appear repeatedly in this file and in the reference docs. If you live in SwiftUI already, skip this section.

- **Ablation.** In ML evaluation, running the same task under variations that isolate one component at a time. Here: running brief-01 under four skill configurations to isolate the contribution of impeccable-swift specifically.
- **`Form`.** SwiftUI container that renders as a grouped-style list on iOS. The HIG-blessed shape for Settings-like screens. `.formStyle(.grouped)` makes the grouping explicit.
- **`Label`.** SwiftUI view that pairs a title with an icon. `Label("Notifications", systemImage: "bell.fill")` is the default way to render a row with an icon — cleaner than manually `HStack { Image(systemName: …); Text(…) }`.
- **`role: .destructive`.** Declarative semantic on `Button` that tells SwiftUI this action destroys data. System renders it in the appropriate red (dark-mode aware) and routes it correctly through accessibility.
- **`@ScaledMetric`.** Property wrapper that makes a numeric value scale with the user's Dynamic Type setting. `@ScaledMetric(relativeTo: .body) var iconSize: CGFloat = 22` gives you 22pt at default Dynamic Type, larger at accessibility sizes.
- **`#Preview`.** Swift 5.9+ macro for SwiftUI previews. Multiple `#Preview("…")` blocks let you render Light, Dark, Dynamic Type variants side by side in Xcode. The reference docs treat three-variant previews as the default.
- **`ContentUnavailableView`.** iOS 17+ system view for empty states. Standardizes the "nothing here yet" pattern so apps don't each reinvent it.
- **Liquid Glass.** Apple's iOS 26 material system — translucent, blur-behind, context-aware tint. First-class vocabulary in impeccable-swift's `materials.md` reference doc.
- **Asset Catalog semantic colors.** Colors defined in `Assets.xcassets` with explicit Any Appearance / Dark Appearance variants. The platform-native way to get automatic dark-mode support without conditionals.
- **SF Symbols.** Apple's icon font, 6000+ glyphs. The default icon channel on iOS/macOS. `Label("Settings", systemImage: "gearshape")` renders the SF Symbol at the correct weight and size for the surrounding text.
- **SwiftSyntax.** Apple's official Swift source parser. Used by `tools/impeccable-lint/` to check patterns that cross line boundaries — e.g., detecting a `VStack` of rows that could have been a `Form`.
- **HIG.** Human Interface Guidelines. Apple's canonical design document.
- **DESIGN.md.** Project-level design tokens file. impeccable-swift ships a `DESIGN-SWIFT.md.template` that each project customizes for its own brand. Two-layer precedence: project `DESIGN.md` wins over universal reference docs.

---

## A note on honesty

The single most important thing in this file is that nothing in it is tuned for marketing. If the skill's detector story is weak on Swift, that's named. If the ablation is author-biased, that's named. If the grid is code cards instead of rendered UI, that's named. If every substantive Swift finding on Brukas came from LLM reasoning rather than the advertised "three-tool detector stack," that's named.

The reason: a skill meant to teach Swift developers to resist AI design slop has to hold itself to the same standard. If v0.1.0-poc is going to earn trust, it earns it by stating limitations plainly and fixing them in v0.2.

---

## If you want to form your own opinion

A suggested reading order for someone who wants to verify rather than trust:

1. **Start at the artifacts, not the prose.** Open [`evals/outputs/brief-01/`](../evals/outputs/brief-01/) and read the four `.swift` files in order (C1 → C4). Form your own structural read before the `RESULTS.md` observations frame it for you.
2. **Then read `RESULTS.md`.** See whether the observations match what you saw in the code.
3. **Then open the Brukas branch.** `git diff gtm-alpha-launch..impeccable-swift-marquee-pass -- "Pico Focus/Views/ChatScreen.swift"` — 38 lines of real committed polish. Compare the commits against the critique findings.
4. **Only then read the case study write-up.** By this point you have your own read; use the case study to see where mine agrees or disagrees with yours.
5. **Point your agent at the three SKILL.md files and `impeccable/reference/`.** Ask it to sanity-check whether the skill's stated rules match the reference docs, and whether the reference docs match HIG. Where it flags a contradiction, file an issue — that's exactly the kind of signal v0.2 wants.

Whatever you conclude from doing that work is worth more than anything in this file. Everything here is the author's read. The receipts are the code.
