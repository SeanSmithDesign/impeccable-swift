# Teach Flow

Gather design context for a Swift project and write two files at the project root:

- **PRODUCT.md** (strategic): register, target users, product purpose, brand personality, anti-references, strategic design principles. Answers "who/what/why".
- **DESIGN.md** (visual): visual theme, color sets, typography, materials, components, layout, spacing. Swift/SwiftUI flavored. Answers "how it looks".

Every other impeccable command reads these files before doing any work.

## Step 1: Load current state

Run the shared loader first so you know what already exists:

```bash
node .claude/skills/impeccable-swift/scripts/load-context.mjs
```

The output tells you whether PRODUCT.md and/or DESIGN.md already exist. If `migrated: true`, legacy `.impeccable.md` was auto-renamed to `PRODUCT.md`. Mention this once to the user.

Decision tree:

- **Neither file exists (empty project or no context yet)**: do Steps 2-4 (write PRODUCT.md), then decide on DESIGN.md based on whether there's code to analyze.
- **PRODUCT.md exists, DESIGN.md missing**: skip to Step 5, offer to run `/impeccable document` for DESIGN.md.
- **PRODUCT.md exists but has no `## Register` section (legacy)**: add it. Infer a hypothesis from the codebase (see Step 2), confirm with the user, write the field.
- **Both exist**: STOP and call the AskUserQuestion tool to clarify which to refresh. Skip the one the user does not want changed.
- **Just DESIGN.md exists (unusual)**: do Steps 2-4 to produce PRODUCT.md.

Never silently overwrite an existing file. Always confirm first.

If teach was invoked as a setup blocker by another command (such as `/impeccable-swift craft landing page`), pause that command here. Complete teach, re-run the loader, then resume. For craft, resume into shape next: teach creates project context but does not substitute for the task-specific shape interview and confirmed design brief.

## Step 2: Explore the codebase

Before asking questions, thoroughly scan the project to discover what you can:

- **README and docs**: Project purpose, target audience, any stated goals.
- **`Package.swift` / `*.xcodeproj` / `*.xcworkspace`**: Tech stack, deployment targets (iOS / macOS / visionOS), Swift Package dependencies, existing design libraries.
- **Existing SwiftUI views**: Current view hierarchy, spacing constants, typography modifiers, custom `ViewModifier` types, custom `ButtonStyle` / `LabelStyle` implementations.
- **`Assets.xcassets`**: Color Sets already defined (note Any Appearance vs Dark Appearance variants), Image Sets, Symbol Sets, App Icon, Accent Color.
- **`Info.plist`**: Custom fonts registered via `UIAppFonts`, supported orientations, scene delegate adoption, Liquid Glass capability flags.
- **Brand assets**: Logos, App Icon variants, marketing screenshots, any standalone style guide PDFs in the repo.
- **Design tokens**: Look for an `AppColor`, `AppSpacing`, `AppFont`, `AppShadow`, `Theme`, or similar enum/extension that names tokens. Check whether there's a `DESIGN.md` template already copied in from `~/Code/docs/DESIGN-SWIFT.md.template`.
- **Any in-repo style guide, brand book, or `docs/design/` folder.**

Also form a **register hypothesis** from what you find:

- Brand signals: marketing-shaped surfaces, single-screen storytelling, big hero typography, `ScrollView` driven reveals, App Store screenshot tooling, portfolio/conference shells, splash and one-time onboarding heroes, `AVPlayer`-driven brand video moments.
- Product signals: `NavigationStack` of content, `Form`, `List`, `Settings` scenes, sign-in flows, data-dense `Table` views (macOS), `SidebarListStyle`, repeated CRUD surfaces, authenticated app shells.

Register is a hypothesis at this point, not a decision. Step 3 confirms it.

## Step 3: Ask strategic questions (for PRODUCT.md)

STOP and call the AskUserQuestion tool to clarify. Focus only on what you could not infer from the codebase.

### Interview mode, not confirmation mode

If the repo is empty or the user's brief is sparse, run a short interview before proposing PRODUCT.md. Do **not** turn a one-sentence request into a complete inferred PRODUCT.md and ask for blanket confirmation.

- Use the harness's structured question tool when one exists. Otherwise, ask directly in chat and stop.
- Ask **2-3 questions per round**, then wait for answers.
- Use inferred answers as hypotheses or options, not as finished facts.
- Complete at least one real user-answer round before drafting PRODUCT.md, unless every required answer is directly discoverable from repo docs.
- Round 1 should establish register, users/purpose, and desired outcome.
- Round 2 should establish brand personality or references, anti-references, and accessibility needs.

### Register (ask first, it shapes everything below)

Every design task is either **brand** (marketing apps, landing surfaces, conference shells, portfolio apps, campaign experiences, hero onboarding: design IS the product) or **product** (app UI, settings, dashboards, lists, forms, navigation stacks, tools: design SERVES the product).

If Step 2 produced a clear hypothesis, lead with it: _"From the codebase, this looks like a [brand / product] surface, does that match your intent, or should we treat it differently?"_

If the signal is genuinely split (e.g. a product app with a big marketing onboarding hero), STOP and call the AskUserQuestion tool to clarify which register describes the **primary** surface. The register can be overridden per task later, but PRODUCT.md carries one default.

For the full criteria on each register, including the specific aesthetic lanes within brand, the slop tests, and the SwiftUI-specific failure modes, point the user (and yourself) at:

- [reference/brand.md](brand.md), the brand register
- [reference/product.md](product.md), the product register

### Users & Purpose

- Who uses this? What's their context when using it (commute, desk, late-night reading, in the field)?
- What job are they trying to get done?
- For brand: what emotions should the interface evoke (confidence, delight, calm, urgency, restraint, warmth)?
- For product: what workflow are they in? What's the primary task on any given screen?

For audience modeling and writing personas that drive concrete design decisions, see [reference/personas.md](personas.md).

### Brand & Personality

- How would you describe the brand personality in 3 words? Push for physical-object words, "warm and mechanical and opinionated", not "modern and clean and elegant".
- Reference apps or sites that capture the right feel? What specifically about them?
  - For brand, push for real-world references in the right lane (Klim-style specimen, Stripe-minimal, Liquid Death acid maximalism, Apple product page restraint, editorial magazine, brutalist grid, consumer warm), not generic "modern" adjectives.
  - For product, push for category best-tool references native to Apple platforms (Things, Reeder, Tot, Mail, Music, NetNewsWire, OmniFocus, the Mac Linear client, Mela, Soulver).
- What should this explicitly NOT look like? Any anti-references? Be specific: "not the default SwiftUI tutorial card stack", "not corporate SaaS gradient", "not wellness app pastels".

### Accessibility & Inclusion

- Specific accessibility requirements? (WCAG level, known user needs.)
- Considerations for Reduce Motion, Increase Contrast, Bold Text, color-blindness, VoiceOver, Switch Control, Dynamic Type at the largest tiers?
- Any localization commitments (RTL languages, languages with longer string lengths)?

Skip questions where the answer is already clear. **Do NOT ask about colors, fonts, radii, materials, or visual styling here.** Those belong in DESIGN.md, not PRODUCT.md.

## Step 4: Write PRODUCT.md

Write PRODUCT.md only after the user has confirmed the strategic answers from Step 3. If an inferred answer is uncertain or unconfirmed, ask before writing.

Synthesize into a strategic document:

```markdown
# Product

## Register

product

## Users

[Who they are, their context, the job to be done.]

## Product Purpose

[What this product does, why it exists, what success looks like.]

## Brand Personality

[Voice, tone, 3-word personality, emotional goals. Use physical-object words, not "modern/clean/elegant".]

## Anti-references

[What this should NOT look like. Specific bad-example apps, sites, or patterns to avoid. "Not the default SwiftUI tutorial stack of `cornerRadius(16)` cards with `.shadow(radius: 8)`."]

## Design Principles

[3-5 strategic principles derived from the conversation. Principles like "earned familiarity over invention", "show, don't tell", "expert confidence", NOT visual rules like "use SF Pro Semibold" or "terracotta accent".]

## Accessibility & Inclusion

[WCAG level, known user needs, Dynamic Type commitments, Reduce Motion behavior, localization scope.]
```

`Register` is either `brand` or `product` as a bare value. No prose, no commentary. The choice is informed by [reference/brand.md](brand.md) and [reference/product.md](product.md): PRODUCT.md just records which one this project lives in.

Write to `PROJECT_ROOT/PRODUCT.md`. If `.impeccable.md` existed, the loader already renamed it; merge into that content rather than starting from scratch.

## Step 5: Decide on DESIGN.md

Offer `/impeccable document` either way. Two paths:

- **Code exists** (Color Sets in `Assets.xcassets`, custom `ViewModifier` types, a running app, a `Theme` enum, an `AppColor` extension): "I can generate a DESIGN.md that captures your visual system (Color Sets, SF Pro tier choices, materials, components, spacing scale) so future variants stay on-brand. Want to do that now?"
- **Pre-implementation** (empty project, fresh `Package.swift`, no `Assets.xcassets` colors yet): "I can seed a starter DESIGN.md from a few quick questions about color strategy, type direction, material vocabulary, motion energy, and references. You can re-run once there's code, to capture the real tokens. Want to do that now?"

The Swift starter DESIGN.md should cover, at minimum:

- **Color Sets**: which roles exist (`background`, `backgroundElevated`, `textPrimary`, `textSecondary`, `accentPrimary`, `border`, `destructive`, `success`), and the asset-catalog notation for each (Any Appearance + Dark Appearance variants). Inline `Color(red:green:blue:)` and `Color(hex:)` are banned in views.
- **Typography**: the SF family in use (SF Pro Text, SF Pro Display, SF Pro Rounded, SF Compact, SF Mono, NY) plus the Dynamic Type tier ladder (`.largeTitle` through `.caption2`). Custom fonts only when the brand requires it, registered in `Info.plist` via `UIAppFonts`. Two weights typical (`.regular` + `.semibold`) unless the brand register justifies more.
- **Spacing**: the 4pt scale (`4, 8, 12, 16, 24, 32, 48, 64`), surfaced as an `AppSpacing` enum. Arbitrary values (13pt, 22pt, 7pt) are out.
- **Materials**: which Liquid Glass materials are approved for this project (e.g. `.regularMaterial`, `.thinMaterial`, `.ultraThinMaterial`, `.thickMaterial`, `.ultraThickMaterial`, plus the new tinted/floating/scrollEdge variants). Where each is used: sheet backgrounds, navigation bars, floating chips, scroll edge, and where they're explicitly avoided.
- **SF Symbols**: which symbols are first-class brand icons (the 5-15 symbols that recur in nav, primary actions, empty states), preferred rendering mode (monochrome, hierarchical, palette, multicolor), and any custom symbols shipped in `.symbolset` form.
- **Components**: which custom `ViewModifier` types or `ButtonStyle` / `LabelStyle` implementations exist (e.g. `PrimaryButtonStyle`, `CardModifier`, `SectionHeaderStyle`), and their canonical use sites.
- **Shapes**: corner-radius scale (`rounded.sm` 4pt, `rounded.md` 8pt, `rounded.lg` 12pt, `rounded.xl` 16pt) and the rule that `RoundedRectangle` always uses `style: .continuous`.
- **Depth**: the two-shadow ladder (card-level + modal-level). No decorative shadows, no colored shadows.

If the user agrees, delegate to `/impeccable document` (it auto-detects scan vs seed). Load its reference and follow that flow.

If the user prefers to skip, mention they can run `/impeccable document` any time later. Either way, point them at `~/Code/docs/DESIGN-SWIFT.md.template` as the starting structure.

## Step 6: Confirm and wrap up

Summarize:

- Register captured (brand / product)
- What was written (PRODUCT.md, DESIGN.md, or both)
- The 3-5 strategic principles from PRODUCT.md that will guide future work
- If DESIGN.md is pending, remind the user how to generate it later

**Critical: re-run the loader to refresh session context.** After writing PRODUCT.md, run `node .claude/skills/impeccable-swift/scripts/load-context.mjs` one final time and let its full JSON output land in conversation. This ensures subsequent commands in this session use the freshly-written PRODUCT.md, not a stale earlier version.

If teach was invoked as a blocker by another impeccable command (e.g. the user ran `/impeccable polish` with no PRODUCT.md), resume that original task now with the fresh context.

Optionally STOP and call the AskUserQuestion tool to clarify whether they'd like a brief summary of PRODUCT.md appended to CLAUDE.md for easier agent reference. If yes, append a short **Design Context** pointer section there.
