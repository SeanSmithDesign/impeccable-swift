# impeccable-swift

v0.1.0-poc — proof of concept, not production-grade. Faithful Swift/SwiftUI port.

impeccable-swift builds on [impeccable](https://github.com/pbakaus/impeccable) by Paul Bakaus (Apache 2.0). See NOTICE.md for full attribution chain.

Based on impeccable pinned at `00d485659` (2026-04-12).

## Install

```
npx skills add SeanSmithDesign/impeccable-swift
```

## What this is

A Swift/SwiftUI-flavored design-quality skill family, scoped to iOS 26+ and macOS 26+ with Liquid Glass as first-class vocabulary. Three skills ship in v1:

- **impeccable-swift** — umbrella skill carrying the 12 reference docs (8 ported from upstream + 4 Swift-native).
- **critique** — evaluate a SwiftUI file or view against the reference docs and the project's `DESIGN.md` tokens.
- **polish** — tighten generated SwiftUI code against the same rules.

Behind the skills is a three-tool detector stack: SwiftLint `custom_rules` for line-local patterns, a `SwiftSyntax` CLI (`impeccable-lint`) for AST-level checks, and an asset-catalog checker for SF Symbol vs PNG resolution.

## Why a Swift port

Web impeccable is brilliant for web — it teaches taste against HTML, CSS, and shadcn. Swift and SwiftUI have their own idiom: Liquid Glass as a material, `@ScaledMetric` for Dynamic Type, `ContentUnavailableView` for empty states, `Label` + SF Symbol as the default icon channel, `#Preview` variants for Light/Dark/Dynamic Type, and Asset Catalog semantic colors with light/dark pairs. This fork ports the philosophy — declare intent, state the why, name the rule, flag the anti-pattern — into the native vocabulary. Paul's voice and structure are preserved; Apple-specific docs are additive.

## How we tested

Two directions. First, a **4-condition ablation** on brief-01 (a plain Settings screen): C1 no skill, C2 impeccable (web, cross-ported), C3 impeccable-swift, C4 Sean's personal Claude setup with `DESIGN-SWIFT.md.template` but no skill. All four outputs parse and typecheck against the iOS 26 SDK. Full findings in [`evals/outputs/brief-01/RESULTS.md`](./evals/outputs/brief-01/RESULTS.md).

Second, a **production-adjacent case study**: the skill was run twice against [Brukas](https://github.com/SeanSmithDesign/Pico-Timer) — a ~24-view SwiftUI focus app with its own "Deep Espresso" design system. Three atomic polish commits on the primary chat view. Branch: [`impeccable-swift-marquee-pass`](https://github.com/SeanSmithDesign/Pico-Timer/tree/impeccable-swift-marquee-pass).

Honest caveats:

- The `critique` skill's automated detector is web-oriented (jsdom-based). On Swift source it currently falls back to LLM reasoning backed by targeted `grep` passes — real detector-backed Swift findings are v0.2 work.
- Author-as-evaluator bias in the ablation — I wrote the skill and the eval. A blind designer pass is on the backlog.
- Rendered SwiftUI screenshots are pending. Headless subagents can't drive Xcode Previews reliably; the ablation grid renders source-code cards, not rendered UI.

## Early results

![4-way ablation grid — C1 no-skill, C2 impeccable (web), C3 impeccable-swift, C4 Sean's Claude setup](./docs/media/grid-4-way.png)

Side-by-side code outputs from the four conditions (not rendered UIs). The strongest differentiator is `Form` adoption — only C3 reaches for `NavigationStack { Form { Section { Toggle … } } }`; C1, C2, and C4 all hand-roll a `VStack` of rows. `@ScaledMetric`, SF Symbols via `Label`, `Button(role: .destructive)`, and multi-variant `#Preview` cluster in C3 alone. C4 is visibly more tasteful than C1 or C2 — semantic color enum, 4pt spacing scale, 44pt tap targets — but doesn't reach for Apple-specific idioms the `DESIGN-SWIFT.md.template` doesn't mandate.

The honest selling point: even a carefully configured personal setup without impeccable-swift produces competent Swift, but leaves platform-specific affordances on the table.

The Brukas takeaway matches: cumulative wins rather than wow-moments. The skill reliably surfaced six off-grid CGFloat literals (including a 2pt math drift hidden in a code comment) and flagged a two-headline typography collision on the empty state. It surfaces candidates; the human decides which to fix and which to skip.

### The `PicoShadow` moment

On 2026-04-15 the skill flagged `PicoShadow.opacity = 0` as a latent bug — a shadow token silently rendering no shadow. On 2026-04-21 the same value is documented in `agent-craft.md` as the deliberate "Deep Espresso is flat" rule. Both readings were correct at their moment: findings age, design systems evolve, and a skill's job is to surface the tension, not resolve it. Worth remembering the next time a lint complains about something that turned out to be on purpose.

## What's next

- **Wire `impeccable-lint` into `critique`** — the SwiftSyntax CLI already exists at `tools/impeccable-lint/`; the skill should consume its AST-level findings instead of ripgrep fallbacks. This is the main v0.2 scope target: detector-grounded critique for Swift, not LLM-only reasoning.
- **More eval briefs across all 4 conditions** — brief-02 (list + empty state), brief-03 (onboarding), brief-04 (chat) all exist in `evals/` but haven't been run through the ablation grid yet.
- **Case studies on 2–3 more apps beyond Brukas.**
- **Blind designer review pass** on the ablation outputs to remove author-as-evaluator bias.
- **SwiftUI Preview-based screenshot capture harness** — so future grids show rendered UIs rather than code cards.
- **Community contributions welcome** — `CONTRIBUTING.md` coming in v0.2.

## For readers scanning with their agent

Hand this repo to your coding agent and point it at these four files first:

1. The three `SKILL.md` files — `impeccable/SKILL.md`, `critique/SKILL.md`, `polish/SKILL.md` — for what each skill does and how they compose.
2. `impeccable/reference/` — 13 reference docs (2,207 lines) covering typography, color, spatial, motion, interaction, responsive, ux-writing, craft, and the four Swift-native docs (sf-symbols, materials, navigation, ios-vs-macos).
3. `evals/README.md` — the A/B protocol and brief format.
4. `NOTICE.md` — attribution chain and license.

The single most interesting artifact is `evals/outputs/brief-01/` — four SwiftUI outputs side by side with the full observations write-up. Read those before forming an opinion.

## What this isn't

- Not a production-grade release — explicitly a proof of concept.
- Not a backport. iOS <26 / macOS <26 are not supported in v1.
- Not a rebrand. Paul's voice, structure, and philosophy are preserved; Swift-specific docs are additive.

## Links

- [NOTICE.md](./NOTICE.md) — attribution chain.
- [UPSTREAM.md](./UPSTREAM.md) — upstream surveillance log and pinned SHA.
- [CHANGELOG.md](./CHANGELOG.md) — release notes.
- [docs/research-notes.md](./docs/research-notes.md) — methodology, limitations, open questions.
