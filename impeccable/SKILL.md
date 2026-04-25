---
name: impeccable-swift
description: Use when the user wants to design, redesign, shape, critique, audit, polish, clarify, distill, harden, optimize, adapt, animate, colorize, extract, or otherwise improve a SwiftUI interface on Apple platforms (iOS 26+, iPadOS 26+, macOS 26+, visionOS, watchOS). Covers app shells, screens, views, components, navigation, modals, settings, onboarding, empty states, and marketing surfaces built in SwiftUI. Handles UX review, visual hierarchy, information architecture, cognitive load, accessibility (VoiceOver, Dynamic Type, Reduce Motion), performance (SwiftUI render cost, Instruments), theming (Dark Mode, Color Sets), responsive behavior (size classes, ViewThatFits, iPad multitasking), anti-patterns, typography (SF Pro, Dynamic Type, custom Font.custom), spacing, layout, alignment, color (OKLCH → Color, asset catalogs, Liquid Glass tinting), motion (.animation, spring physics, phase animators), micro-interactions, sensory feedback / haptics, SF Symbols (one set per surface, weight + scale consistency), Liquid Glass materials (.ultraThinMaterial → .thick, GlassEffectContainer), Apple HIG conformance, UX copy, error states, edge cases, String Catalog / i18n, and reusable design systems or tokens. Also use for bland SwiftUI that needs to become bolder or more delightful, loud SwiftUI that should become quieter, Xcode Previews iteration, or ambitious visual effects (Metal shaders, Canvas, custom spring physics) that should feel technically extraordinary on Apple platforms. Not for backend-only or non-UI tasks. Not for web / React / Tailwind work — use upstream `impeccable` for those.
version: 0.2.0
user-invocable: true
argument-hint: "[craft|shape · audit|critique · animate|bolder|colorize|delight|layout|overdrive|quieter|typeset · adapt|clarify|distill · harden|onboard|optimize|polish · teach|document|extract|live] [target]"
license: Apache 2.0. Based on Paul Bakaus's impeccable (Apache 2.0). See NOTICE.md.
allowed-tools:
  - Bash(node *)
---

Designs and iterates production-grade SwiftUI interfaces for Apple platforms. Real working code, committed design choices, exceptional craft. Points not pixels, Liquid Glass materials, SF Symbols, Dynamic Type, and Apple HIG defaults — not the beige, rounded-rect "AI SwiftUI" every model reaches for by default.

## Setup (non-optional)

Two steps before any design work. Both are required. Skipping either produces generic output that ignores the project.

### 1. Context gathering

Two files at the project root, case-insensitive:

- **PRODUCT.md** — required. Users, brand, tone, anti-references, strategic principles.
- **DESIGN.md** — optional, strongly recommended. Color Sets, typography (SF Pro / custom), spacing, components.

Load both in one call:

```bash
node .claude/skills/impeccable-swift/scripts/load-context.mjs
```

Consume the full JSON output. Never pipe through `head`, `tail`, `grep`, or `jq`.

If the output is already in this session's conversation history, don't re-run. Exceptions requiring a fresh load: you just ran `/impeccable-swift teach` or `/impeccable-swift document` (they rewrite the files), or the user manually edited one.

If PRODUCT.md is missing, empty, or placeholder (`[TODO]` markers, <200 chars): run `/impeccable-swift teach`, then resume the user's original task with the fresh context.

If DESIGN.md is missing: nudge once per session (_"Run `/impeccable-swift document` for more on-brand output"_), then proceed.

### 2. Register

Every design task is **brand** (marketing SwiftUI shells, landing surfaces, campaign pages, portfolio apps — design IS the product) or **product** (app UI, dashboards, admin tools, utilities — design SERVES the product).

Identify before designing. Priority: (1) cue in the task itself ("marketing shell" vs "settings screen"); (2) the surface in focus (the view, file, or feature being worked on); (3) `register` field in PRODUCT.md. First match wins.

If PRODUCT.md lacks the `register` field (legacy), infer it once from its "Users" and "Product Purpose" sections, then cache the inferred value for the session. Suggest the user run `/impeccable-swift teach` to add the field explicitly.

Load the matching reference: [reference/brand.md](reference/brand.md) or [reference/product.md](reference/product.md). The shared design laws below apply to both.

## Shared design laws

Apply to every design, both registers. Match implementation complexity to the aesthetic vision — maximalism needs elaborate code, minimalism needs precision. Interpret creatively. Vary across projects; never converge on the same choices. Claude is capable of extraordinary work — don't hold back.

### Color

- Use OKLCH when reasoning about color, then translate to `Color(red:green:blue:)` or asset-catalog Color Sets. Reduce chroma as lightness approaches 0 or 100 — high chroma at extremes looks garish.
- Never use pure `Color.black` or `Color.white` for surfaces. Tint every neutral toward the brand hue (chroma 0.005–0.01 is enough). Prefer system semantic colors (`.primary`, `.secondary`, `Color(.systemBackground)`) when they fit; tint only where you've earned the deviation.
- Pick a **color strategy** before picking colors. Four steps on the commitment axis:
  - **Restrained** — tinted neutrals + one accent ≤10%. Product default; brand minimalism.
  - **Committed** — one saturated color carries 30–60% of the surface. Brand default for identity-driven surfaces.
  - **Full palette** — 3–4 named roles, each used deliberately. Brand campaigns; product data viz.
  - **Drenched** — the surface IS the color. Brand heroes, campaign surfaces.
- The "one accent ≤10%" rule is Restrained only. Committed / Full palette / Drenched exceed it on purpose. Don't collapse every design to Restrained by reflex.

### Theme

Dark vs. light is never a default. Not dark "because tools look cool dark." Not light "to be safe." Dark Mode coverage is non-negotiable on Apple platforms — but the default appearance is still a deliberate choice.

Before choosing, write one sentence of physical scene: who uses this, where, on what device, under what ambient light, in what mood. If the sentence doesn't force the answer, it's not concrete enough — add detail until it does.

"Workout app" does not force an answer. "Runner glancing at split times on a 41mm Apple Watch in midday sun" does. Run the sentence, not the category.

### Typography

- Cap body line length around 65–75 characters. SwiftUI's `Text` already wraps at the container — set the container width.
- Hierarchy through scale + weight contrast (≥1.25 ratio between steps). Avoid flat scales. SF Pro's text styles (`.largeTitle`, `.title`, `.title2`, `.title3`, `.headline`, `.body`, `.callout`, `.subheadline`, `.footnote`, `.caption`, `.caption2`) already encode this — use them, don't fight them.
- Dynamic Type is non-negotiable. `@ScaledMetric` for any spacing or sizing tied to text. No fixed-point font sizes for body copy.

### Layout

- Vary spacing for rhythm. Same padding everywhere is monotony. Build hierarchy by varying the 4 / 8 / 16 / 24 scale across regions, not by setting `.padding()` everywhere with the same default.
- Cards are the lazy answer. Use them only when they're truly the best affordance. Nested cards are always wrong.
- Don't wrap everything in a container. Most things don't need one. Don't reach for `GroupBox` / `Form` / `List` by reflex when a tuned `VStack` is the honest answer.

### Motion

- Don't animate layout properties (padding, frame, spacing). Animate opacity, scale, offset, color, and material instead.
- Ease out with spring presets (`.spring(response:dampingFraction:)` tuned, or `.smooth` / `.snappy` / `.bouncy` from iOS 17+). No bounce-on-arrival, no elastic.
- Respect `@Environment(\.accessibilityReduceMotion)` on every animation that's not strictly informative.

### Absolute bans

Match-and-refuse. If you're about to write any of these, rewrite the view with different structure.

- **Side-stripe borders.** A 4–6pt colored stripe on the leading or trailing edge of cards, list rows, callouts, or alerts (`.overlay(Rectangle().frame(width: 4))` and friends). Never intentional. Rewrite with full borders, background tints, leading numbers/SF Symbols, or nothing.
- **Gradient text.** `.foregroundStyle(LinearGradient(...))` on `Text`. Decorative, never meaningful. Use a single solid `Color` or `.foregroundStyle(.tint)`. Emphasis via weight or size.
- **Glassmorphism as default.** `.ultraThinMaterial` slapped on every surface "for depth." Liquid Glass is a system vocabulary, not a decoration — reach for it where the surface genuinely floats over content (toolbars, controls, overlays), not as a baseline texture. `GlassEffectContainer` is for related floating controls, not page backgrounds.
- **The hero-metric template.** Big number, small label, supporting stats, gradient accent. SaaS cliché. Don't port it into a SwiftUI dashboard.
- **Identical card grids.** `LazyVGrid` of same-sized cards with `Image(systemName:)` + heading + body, repeated endlessly. Vary the rhythm or use a different layout primitive.
- **Modal as first thought.** `.sheet`, `.fullScreenCover`, and `.alert` are usually laziness. Exhaust inline / `NavigationLink` / progressive disclosure / `Menu` alternatives first.

### Copy

- Every word earns its place. No restated headings, no intros that repeat the title.
- **No em dashes.** Use commas, colons, semicolons, periods, or parentheses. Also not `--`.

### The AI slop test

If someone could look at this interface and say "AI made that" without doubt, it's failed. Cross-register failures are the absolute bans above. Register-specific failures live in each reference.

**Category-reflex check.** If someone could guess the theme and palette from the category name alone — "fitness → black + neon green", "finance → navy + gold", "meditation → muted lavender", "developer tool → dark gray + monospace" — it's the training-data reflex. Rework the scene sentence and color strategy until the answer is no longer obvious from the domain.

## SwiftUI Reflex Check

The model's natural failure mode in SwiftUI is identical to its failure mode in web design: it reaches for trained defaults and produces output that looks like every beginner tutorial. The following procedure forces enumeration before generation. Run this after the shared design laws above, before writing any view.

**Step 1.** Write down 3 words for what this screen should feel like in use. Not "clean" or "modern" — those are dead words. Something like: "focused and unhurried and a little ceremonial", "fast and dense and dismissible", "warm and tactile and forgiving".

**Step 2.** List the first 3 layout and surface decisions you would make. Write them down explicitly. They are most likely from this list:

<reflex_swiftui_patterns_to_reject>
Surface defaults:

- `.background(Color(.systemBackground))` — no material, no depth declaration
- White card with `cornerRadius(10)` and `shadow(radius: 4)` — the AI SwiftUI card
- Flat `VStack` of identical rows with a `Divider()` between them

Layout defaults:

- `List` for every scrolling collection regardless of visual intent
- `VStack { ForEach { HStack { ... } } }` as the only layout pattern
- Every section uses the same padding value (no hierarchy through spacing)

Typography defaults:

- `.title` + `.body` + `.caption` at system weight defaults, no contrast variation
- Every header the same weight, every body the same style
- No numeric formatting (raw integers, not `.monospacedDigit()` for time/counts)

Color defaults:

- `.accentColor` as the only brand expression
- No semantic color tokens — hardcoded Color values everywhere
- Dark Mode never considered beyond system `.primary`/`.secondary`

Interaction defaults:

- No custom `ButtonStyle` — system default press behavior on every tappable element
- No `.sensoryFeedback` on any completion, error, or selection state
- No `ContentUnavailableView` — empty collections just show nothing

Material defaults:

- No `Material` on any surface, even floating overlays
- Custom `Color.white.opacity(0.8)` + `.blur()` instead of system materials
- No `GlassEffectContainer` for related floating controls on iOS 26+
  </reflex_swiftui_patterns_to_reject>

**Step 3.** For any item in your Step 2 list that matches the reflex list: stop and find the system alternative or a more intentional choice. The reflex choice is not always wrong — but it must be a deliberate decision, not a default.

**Step 4.** Cross-check the result. Ask: does this layout look like a SwiftUI tutorial screenshot? Does every card look the same? Is the only design decision "light background, SF Pro, blue accent"? If yes, go back to Step 3.

The goal is not to be weird. The goal is to be intentional. A plain `List` is correct when a plain `List` is the right choice — but the model must be able to name _why_, not just reach for it.

## Commands

| Command              | Category | Description                                                                                               | Reference                                        |
| -------------------- | -------- | --------------------------------------------------------------------------------------------------------- | ------------------------------------------------ |
| `craft [feature]`    | Build    | Shape, then build a SwiftUI feature end-to-end with Xcode Previews iteration                              | [reference/craft.md](reference/craft.md)         |
| `shape [feature]`    | Build    | Plan SwiftUI UX/UI before writing code (HIG-aware discovery interview)                                    | [reference/shape.md](reference/shape.md)         |
| `teach`              | Build    | Set up PRODUCT.md and DESIGN.md context for a Swift project                                               | [reference/teach.md](reference/teach.md)         |
| `document`           | Build    | Generate DESIGN.md from existing SwiftUI code, asset catalogs, and Color Sets                             | [reference/document.md](reference/document.md)   |
| `extract [target]`   | Build    | Pull reusable SwiftUI patterns, ViewModifiers, and tokens into the design system                          | [reference/extract.md](reference/extract.md)     |
| `critique [target]`  | Evaluate | UX design review with heuristic scoring and impeccable-lint anti-pattern detection                        | [reference/critique.md](reference/critique.md)   |
| `audit [target]`     | Evaluate | Technical quality checks (a11y, perf, Dark Mode, size classes) — invokes Swift detector arm               | [reference/audit.md](reference/audit.md)         |
| `polish [target]`    | Refine   | Final quality pass on SwiftUI code before shipping                                                        | [reference/polish.md](reference/polish.md)       |
| `bolder [target]`    | Refine   | Amplify safe or bland SwiftUI through weight, scale, material, and contrast                               | [reference/bolder.md](reference/bolder.md)       |
| `quieter [target]`   | Refine   | Tone down aggressive or overstimulating SwiftUI surfaces                                                  | [reference/quieter.md](reference/quieter.md)     |
| `distill [target]`   | Refine   | Strip view hierarchies and modifier chains to their essence                                               | [reference/distill.md](reference/distill.md)     |
| `harden [target]`    | Refine   | Production-ready: errors, Task cancellation, optionals, String Catalog, overflow                          | [reference/harden.md](reference/harden.md)       |
| `onboard [target]`   | Refine   | First-run flows, empty states (`ContentUnavailableView`), activation moments                              | [reference/onboard.md](reference/onboard.md)     |
| `animate [target]`   | Enhance  | Purposeful SwiftUI animations, springs, phase animators (Reduce Motion aware)                             | [reference/animate.md](reference/animate.md)     |
| `colorize [target]`  | Enhance  | Add strategic color via Color Sets, `.tint()`, Liquid Glass tinting                                       | [reference/colorize.md](reference/colorize.md)   |
| `typeset [target]`   | Enhance  | SF Pro hierarchy, Dynamic Type, custom `Font.custom`, numeric styles                                      | [reference/typeset.md](reference/typeset.md)     |
| `layout [target]`    | Enhance  | SwiftUI spacing, rhythm, Grid / LazyVGrid, ViewThatFits                                                   | [reference/layout.md](reference/layout.md)       |
| `delight [target]`   | Enhance  | SF Symbol animations, sensory feedback, phase animators, Liquid Glass moments                             | [reference/delight.md](reference/delight.md)     |
| `overdrive [target]` | Enhance  | Metal shaders, custom spring physics, Canvas, scroll-driven reveals                                       | [reference/overdrive.md](reference/overdrive.md) |
| `clarify [target]`   | Fix      | Improve UX copy, String Catalog entries, accessibilityLabel parity                                        | [reference/clarify.md](reference/clarify.md)     |
| `adapt [target]`     | Fix      | Adapt across iPhone, iPad, Mac, visionOS, watchOS (size classes, ViewThatFits)                            | [reference/adapt.md](reference/adapt.md)         |
| `optimize [target]`  | Fix      | Diagnose SwiftUI perf — LazyVStack vs VStack, @Observable cost, Instruments                               | [reference/optimize.md](reference/optimize.md)   |
| `live`               | Iterate  | Variant iteration via Xcode Previews, Canvas, and SnapshotPreviews (no browser picker on Apple platforms) | [reference/live.md](reference/live.md)           |

Plus two management commands — `pin <command>` and `unpin <command>`, detailed below.

### Routing rules

1. **No argument** — render the table above as the user-facing command menu, grouped by category. Ask what they'd like to do.
2. **First word matches a command** — load its reference file and follow its instructions. Everything after the command name is the target.
3. **First word doesn't match** — general design invocation. Apply the setup steps, shared design laws, the SwiftUI Reflex Check, and the loaded register reference, using the full argument as context.

Setup (context gathering, register) is already loaded by then; sub-commands don't re-invoke `/impeccable-swift`.

## Pin / Unpin

**Pin** creates a standalone shortcut so `/<command>` invokes `/impeccable-swift <command>` directly. **Unpin** removes it. The script writes to every harness directory present in the project.

```bash
node .claude/skills/impeccable-swift/scripts/pin.mjs <pin|unpin> <command>
```

Valid `<command>` is any command from the table above. Report the script's result concisely — confirm the new shortcut on success, relay stderr verbatim on error.
