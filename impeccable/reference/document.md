# Document

Generate a `DESIGN.md` file at the project root that captures the current visual design system, so AI agents generating new screens stay on-brand.

DESIGN.md follows the [official Google Stitch DESIGN.md format](https://stitch.withgoogle.com/docs/design-md/format/): YAML frontmatter carrying machine-readable design tokens, followed by a markdown body with exactly six sections in a fixed order. **Tokens are normative; prose provides context for how to apply them.** Sections may be omitted when not relevant, but **do not reorder them and do not rename them**. Section headers must match the spec character-for-character so the file stays parseable by other DESIGN.md-aware tools (Stitch itself, awesome-design-md, skill-rest, etc.).

## The frontmatter: token schema

The YAML frontmatter is the machine-readable layer. It's what Stitch's linter validates and what the live panel renders tiles from. Keep it tight; every entry should correspond to a token the project actually uses.

```yaml
---
name: <project title>
description: <one-line tagline>
colors:
  primary: AccentColor # Color Set name from Assets.xcassets
  surface: SurfaceBackground # semantic slug matching Color Set name
  # ...one entry per extracted Color Set; key = descriptive slug, value = Color Set name
typography:
  display:
    fontFamily: "New York, Georgia, serif"
    fontSize: "largeTitle" # use semantic style name, not pt value
    fontWeight: 300
    lineHeight: 1
    letterSpacing: "normal"
  body:
    fontFamily: "SF Pro"
    fontSize: "body"
    fontWeight: 400
    lineHeight: 1.5
rounded:
  sm: "8" # pt, not px
  md: "16"
  lg: "24"
spacing:
  sm: "8"
  md: "16"
  lg: "24"
components:
  button-primary:
    backgroundColor: "{colors.primary}"
    textColor: "{colors.surface}"
    rounded: "{rounded.sm}"
    padding: "14 32" # vertical horizontal, in pt
  button-primary-hover:
    backgroundColor: "{colors.primary-deep}"
---
```

**Swift-specific token conventions:**

- **Colors**: use the Color Set name from `Assets.xcassets`, never a hex literal or `Color(red:green:blue:)`. Asset Catalog Color Sets carry dark-mode variants automatically; the name is the stable identifier across both appearances. The `asset-catalog-checker` tool enumerates all Color Sets -- use its output directly.
- **Typography `fontSize`**: use the SwiftUI semantic style name (`largeTitle`, `title`, `headline`, `body`, `callout`, `subheadline`, `footnote`, `caption`, `caption2`) instead of point values. If a custom size is used via `Font.custom(_:size:)`, record the pt value and note it as non-dynamic. `impeccable-lint` surfaces both patterns during extraction.
- **Rounded / Spacing**: values are SwiftUI points (no `px` suffix). Match whatever scale constants the project already defines (`AppSpacing.md`, `DesignTokens.cornerRadius.card`, etc.).

Rules that matter:

- **Token refs** use `{path.to.token}` (e.g. `{colors.primary}`, `{rounded.md}`). Components may reference primitives; primitives may not reference each other.
- **Stitch validates colors as hex sRGB only.** The Swift DESIGN.md uses Color Set names, not hex -- accept the Stitch linter warning on color values. The semantic name is what AI agents and impeccable commands read; the warning is cosmetic.
- **Component sub-tokens** are limited to 8 props: `backgroundColor`, `textColor`, `typography`, `rounded`, `padding`, `size`, `height`, `width`. Shadows, motion, focus rings, materials -- none of those fit in the frontmatter. Carry them in the sidecar (Step 4b).
- **Scale keys are open-ended.** Use whatever names the project already uses (`warm-ash-cream`, `surface-container-low`). Don't rename to Material defaults.
- **Variants are naming convention, not schema.** `button-primary` / `button-primary-hover` / `button-primary-active` as sibling keys.

## The markdown body: six sections (exact order)

1. `## Overview`
2. `## Colors`
3. `## Typography`
4. `## Elevation`
5. `## Components`
6. `## Do's and Don'ts`

Optional evocative subtitles are allowed in the form `## 2. Colors: The [Name] Palette` -- Stitch's own outputs do this -- but the literal word in each header (Overview, Colors, Typography, Elevation, Components, Do's and Don'ts) must be present. Do NOT add extra top-level sections (Layout Principles, Responsive Behavior, Motion, Agent Prompt Guide). Fold that content into the six spec sections where it naturally belongs.

## When to run

- The user just ran `/impeccable teach` and needs the visual side documented.
- The skill noticed no `DESIGN.md` exists and nudged the user to create one.
- An existing `DESIGN.md` is stale (the design has drifted).
- Before a large redesign, to capture the current state as a reference.

If a `DESIGN.md` already exists, **do not silently overwrite it**. Show the user the existing file and STOP and call the AskUserQuestion tool to clarify whether to refresh, overwrite, or merge.

## Two paths

- **Scan mode** (default): the project has design tokens, components, or Asset Catalog Color Sets. Extract, then confirm descriptive language. Use when there's code to analyze.
- **Seed mode**: the project is pre-implementation (fresh teach, nothing built yet). Interview for five high-level answers, write a minimal DESIGN.md marked `<!-- SEED -->`. Re-run in scan mode once there's code.

Decide by scanning first (Scan mode Step 1). If the scan finds no Color Sets, no Swift token files, and no SwiftUI view code, offer seed mode -- don't silently switch. `/impeccable document --seed` forces seed mode regardless of code presence.

## Scan mode (auto-extract, then confirm descriptive language)

### Step 1: Find the design assets

Search the Swift project in priority order:

1. **Asset Catalog Color Sets**: Run `asset-catalog-checker` against the project's `Assets.xcassets` (or whichever `.xcassets` the target uses). The tool enumerates every Color Set, flags missing dark-mode variants, and surfaces contrast issues. Record the Color Set name, whether a Dark Appearance swatch exists, and any flagged contrast pairs.

   ```bash
   swift run --package-path tools/asset-catalog-checker asset-catalog-checker <Path/To/Assets.xcassets>
   ```

2. **Named token enums/extensions**: Look for `AppColor`, `AppSpacing`, `AppFont`, `AppRadius`, `DesignTokens`, `Theme`, or similar files. These are the project's canonical scale constants.

3. **`Font.custom()` and system font usage**: Run `impeccable-lint` to extract every `Font.custom(_:size:)` call and every `.font(.system(size:weight:design:))` call in the source tree. These reveal custom typefaces and any fixed point sizes that bypassed Dynamic Type.

   ```bash
   swift run --package-path tools/impeccable-lint impeccable-lint <TargetDirectory>
   ```

4. **Spacing and radius constants**: `impeccable-lint` also flags numeric literals used directly in `.padding(_:)`, `.frame(width:height:)`, and `.cornerRadius(_:)` / `.clipShape(RoundedRectangle(cornerRadius:))`. Record the literal values -- these seed the `spacing` and `rounded` frontmatter blocks.

5. **Materials**: Scan for `.regularMaterial`, `.thinMaterial`, `.ultraThinMaterial`, `.thickMaterial`, `.ultraThickMaterial`, and `.glassEffect()` usage in SwiftUI views. Materials define the elevation vocabulary; their presence or absence shapes the Elevation section. See [`materials.md`](materials.md) for the full material hierarchy.

6. **SF Symbols**: `impeccable-lint` finds every `Image(systemName:)` call and collects the symbol names used. Group by semantic role: navigation, actions, status indicators, decorative. See [`sf-symbols.md`](sf-symbols.md) for the one-rendering-mode-per-surface rule.

7. **Existing `ViewModifier` types and `ButtonStyle` / `LabelStyle` implementations**: These are the project's reusable component contracts. Catalog their parameter surface -- each becomes a component entry in the frontmatter.

8. **`Info.plist`**: Check `UIAppFonts` for custom font registrations. Any font listed here that does not appear in `impeccable-lint` output is likely unused -- note it.

### Step 2: Auto-extract what can be auto-extracted

Build a structured draft from the discovered assets. For each token class:

**Colors**: Use `asset-catalog-checker` output as the authoritative color inventory. The tool lists every Color Set by name. Group by semantic role rather than hue order:

- **Primary / Accent**: the tint color (`AccentColor` Color Set, or a named brand accent). Note whether the Color Set provides a dark-mode variant.
- **Background / Surface**: background Color Sets (`Background`, `SurfacePrimary`, `SurfaceSecondary`, `GroupedBackground`). On iOS 26+ with Liquid Glass, record which surfaces are glass vs. tonal fill.
- **Label / Text**: foreground Color Sets (`LabelPrimary`, `LabelSecondary`, `LabelTertiary`). These parallel `Color.primary`, `Color.secondary`, `Color.tertiary` if the project uses custom overrides.
- **Semantic / State**: destructive, warning, success, disabled Color Sets.

For dark-mode coverage: every Color Set flagged by `asset-catalog-checker` as missing a Dark Appearance swatch is a gap in the system. Note these in the Colors section prose so the next `audit` pass catches them. See [`accessibility.md`](accessibility.md) for contrast requirements.

**Typography**: `impeccable-lint` output includes two categories:

- `Font.custom(_:size:)` calls -- record the font family name, the point size, and whether the size is a constant (tokenized) or a literal (hardcoded). Group by family and weight.
- `.font(.system(size:weight:design:))` calls -- these are fixed-size system font uses. Compare against [`typography.md`](typography.md): any that replaces a semantic style (`.body`, `.headline`, etc.) with a numeric size is a Dynamic Type gap.

Map observed roles to the Material hierarchy: display / headline / title / body / label. A project using `Font.custom("NewYork-Regular", size: 34)` for hero text maps to the `display` role.

**Elevation**: Catalogue the material and shadow vocabulary:

- If the project uses `.glassEffect()` / `GlassEffectContainer` -- Liquid Glass is the elevation language. See [`materials.md`](materials.md).
- If the project uses `.regularMaterial` / `.thinMaterial` etc. -- traditional vibrancy-based depth.
- If the project uses `.shadow(color:radius:x:y:)` -- record the parameter sets as named elevation steps.
- If the project uses none of these -- flat elevation. State it explicitly; the Elevation section should say "this system is flat by design."

**Components**: For each `ButtonStyle`, `LabelStyle`, `ViewModifier`, or repeated view struct the project defines, extract its shape (radius), color assignment, and padding. These map directly to the `components` frontmatter block. `impeccable-lint` surfaces repeated `ZStack(alignment:)` and Card-like patterns as component candidates; confirm which are intentional reuse vs. coincidence.

**Spacing and radii**: `impeccable-lint` collects all numeric literals from `.padding(_:)` and `.cornerRadius(_:)`. Deduplicate and sort; the values that appear most frequently are the project's implicit spacing scale. Check whether the project has a named enum (`AppSpacing`, `Spacing`, `DesignTokens.spacing`) -- if so, use its keys as the frontmatter scale names.

**SF Symbols**: `impeccable-lint` output lists every `Image(systemName:)` symbol string. Group by semantic role:

- Navigation and wayfinding (`chevron.right`, `chevron.left`, `xmark`, `arrow.backward`)
- Actions (`plus`, `square.and.pencil`, `trash`, `square.and.arrow.up`)
- Status and indicators (`checkmark.circle.fill`, `exclamationmark.triangle`, `clock`)
- Decorative / illustration (large filled symbols used as hero art)

Note the rendering mode pattern: one rendering mode per surface is the rule. See [`sf-symbols.md`](sf-symbols.md).

### Step 2b: Stage the frontmatter

From the auto-extracted tokens, draft the YAML frontmatter now (write it at the top of DESIGN.md in Step 4). This is the machine-readable layer.

- **Colors**: one entry per Color Set. Key = descriptive slug (`warm-ash`, `surface-primary`). Value = the Color Set name from `Assets.xcassets` verbatim (e.g. `AccentColor`, `SurfaceBackground`). Do not use hex. Do not use `Color.primary` or semantic system colors as values -- those aren't named Color Sets.
- **Typography**: one entry per role (`display`, `headline`, `title`, `body`, `label`). Use the SwiftUI semantic style name for `fontSize` where the project honors Dynamic Type. Use the pt value only when the project uses `Font.custom()` at a fixed size (and flag it as non-dynamic in the prose).
- **Rounded / Spacing**: whatever scale steps the project actually uses, keyed by the project's own naming (`sm` / `md` / `lg`, or `card`, `button`, `sheet`).
- **Components**: one entry per variant. Reference primitives via `{colors.X}`, `{rounded.Y}`. Properties that Stitch's 8-prop set doesn't cover (material, shadow, glass) carry to the sidecar.

Skip anything the project doesn't have. Empty scale keys or fabricated tokens pollute the spec.

### Step 3: Ask the user for qualitative language

The following require creative input that cannot be auto-extracted. Group them into one `AskUserQuestion` interaction:

- **Creative North Star**: a single named metaphor for the whole system ("The Field Notes App", "The Precision Instrument", "The Still Room"). Offer 2-3 options that honor PRODUCT.md's brand personality.
- **Overview voice**: mood adjectives, aesthetic philosophy in 2-3 sentences, anti-references (what the system should not feel like).
- **Color character** (for auto-extracted Color Sets): descriptive names ("Deep Adaptive Teal", not "AccentColor"). Suggest 2-3 options per key color based on hue and function.
- **Elevation philosophy**: glass-first / tonal / flat / hybrid. On iOS 26+ the answer is usually glass-first for floating surfaces -- confirm whether this project commits to that or dials it back.
- **Component philosophy**: the feel of buttons, cards, inputs in one phrase ("tactile and confident" vs. "restrained and precise"). See [`brand.md`](brand.md) and [`product.md`](product.md) for register-appropriate vocabulary.

Quote a line from PRODUCT.md when possible so the user sees their own strategic language carry forward.

### Step 4: Write DESIGN.md

The file opens with the YAML frontmatter staged in Step 2b, then the markdown body using the structure below. Headers must match character-for-character. Optional evocative subtitles (e.g. `## 2. Colors: The Adaptive Palette`) are allowed.

```markdown
---
name: [Project Title]
description: [one-line tagline]
colors:
  # ... staged frontmatter from Step 2b
---

# Design System: [Project Title]

## 1. Overview

**Creative North Star: "[Named metaphor in quotes]"**

[2-3 paragraph holistic description: personality, density, aesthetic philosophy. Start from the North Star and work outward. State what this system explicitly rejects (pulled from PRODUCT.md's anti-references). End with a short **Key Characteristics:** bullet list.]

## 2. Colors

[Describe the palette character in one sentence.]

### Primary / Accent

- **[Descriptive Name]** (Color Set: `AccentColor`, dark-mode variant: yes/no): [Where and why. Be specific about context, not just role.]

### Background / Surface

- **[Descriptive Name]** (Color Set: `SurfacePrimary`): [Role -- base canvas, grouped content, etc.]

### Label / Text

- **[Descriptive Name]** (Color Set: `LabelPrimary`): [Role -- primary readable text, secondary metadata, etc.]

### Semantic / State (optional -- omit if the project has none)

- **[Descriptive Name]** (Color Set: `DestructiveRed`): [When and where destructive red appears.]

### Named Rules (optional, powerful)

**The [Rule Name] Rule.** [Short, forceful prohibition or doctrine -- e.g. "The One Voice Rule. The accent Color Set appears on 10% or less of any screen. Its scarcity is the point."]

## 3. Typography

**Display Font:** [Family name] ([Font.custom or system font])
**Body Font:** [Family] ([Dynamic Type semantic style])

**Character:** [1-2 sentence personality description of the pairing. See [`typography.md`](typography.md).]

### Hierarchy

- **Display** ([weight], [semantic style or pt], [line-height]): [Purpose -- hero headline, navigation large title, etc.]
- **Headline** ([weight], [semantic style]): [Purpose.]
- **Title** ([weight], [semantic style]): [Purpose.]
- **Body** ([weight], [semantic style]): [Purpose. Note if a line-length cap is enforced.]
- **Label** ([weight], [semantic style], [letter-spacing if uppercase]): [Purpose.]

### Named Rules (optional)

**The [Rule Name] Rule.** [Short doctrine about type use -- e.g. "The Dynamic Type Contract. Every text style in this app uses a semantic text style. Fixed pt sizes are banned outside badge glyphs and data visualizations."]

## 4. Elevation

[One paragraph: does this system use Liquid Glass, traditional materials, hand-rolled shadows, or flat surfaces? If glass-first on iOS 26+, name which surfaces are glass. If flat, say so explicitly and describe how depth is conveyed instead. See [`materials.md`](materials.md).]

### Material Vocabulary (if applicable)

- **Floating controls** (`.glassEffect()` / `GlassEffectContainer`): [Tab bars, toolbars, floating action clusters.]
- **[Material name]** (`.regularMaterial` / `.thinMaterial` etc.): [When this material appears.]
- **[Shadow role]** (`.shadow(color:radius:x:y:)` exact params): [When to use this shadow step.]

### Named Rules (optional)

**The [Rule Name] Rule.** [e.g. "The Glass-First Rule. Any surface that floats above content uses `.glassEffect()`. Custom blur stacks are prohibited."]

## 5. Components

For each component, lead with a short character line, then specify shape, color assignment, states, and any distinctive behavior.

### Buttons

- **Shape:** [radius described; exact pt value in parens]
- **Primary:** [Color Set assignment + padding, semantic + exact terms]
- **Hover / Press state:** [transitions, scale spring, `.buttonStyle` in use]
- **Secondary / Ghost / Destructive (if applicable):** [brief description]

### Cards / Containers

- **Corner Style:** [radius pt value and the `clipShape` or `.cornerRadius` pattern used]
- **Background:** [Color Set or material used]
- **Shadow / Material Strategy:** [reference Elevation section]
- **Border:** [if any -- Color Set, opacity, stroke width]
- **Internal Padding:** [spacing scale value]

### Inputs / Fields

- **Style:** [stroke, background Color Set, radius]
- **Focus:** [treatment -- `.focused`, highlight color, border shift]
- **Error / Disabled:** [if applicable -- Color Set, opacity rules]

### Navigation

- **Style, typography, default/active states, tab bar treatment (glass or custom).**
- See [`materials.md`](materials.md) for tab bar glass behavior on iOS 26+.

### SF Symbols usage

- **Rendering mode:** [`.monochrome` / `.hierarchical` / `.palette` / `.multicolor` -- one per surface]
- **Weight matching:** [which font weight the symbols track alongside text]
- See [`sf-symbols.md`](sf-symbols.md) for the one-rendering-mode rule.

### [Signature Component] (optional -- if the project has a distinctive custom component)

[Description, including the `ViewModifier` or `ButtonStyle` type name, radius, Color Set, behavior.]

## 6. Do's and Don'ts

Concrete, forceful guardrails. Lead each with "Do" or "Don't". Be specific -- include Color Set names, pt values, and named anti-patterns the user mentioned in PRODUCT.md. **Every anti-reference in PRODUCT.md should show up here as a "Don't" with the same language**, so the visual spec carries the strategic line through.

### Do:

- **Do** [specific prescription with Color Set names / semantic style names / pt values].
- **Do** [...]

### Don't:

- **Don't** use `Color(red:green:blue:)` literals. All colors must come from named Color Sets in `Assets.xcassets`.
- **Don't** use `.font(.system(size:))` numeric literals for body copy. Use semantic text styles that honor Dynamic Type.
- **Don't** [...]
```

### Step 4b: Write DESIGN.json sidecar (extensions only)

The frontmatter owns token primitives. The sidecar at `DESIGN.json` carries **what Stitch's schema can't hold**: Color Set dark-mode metadata, material tokens, shadow tokens, motion tokens, full SwiftUI component snippets (rendered into the live panel's shadow DOM as HTML/CSS approximations), and narrative (north star, rules, do's/don'ts). It extends the frontmatter; it does not duplicate it.

Regenerate the sidecar whenever you regenerate DESIGN.md. If the user only asks to refresh the sidecar, preserve DESIGN.md and write only DESIGN.json.

#### Schema

```json
{
  "schemaVersion": 2,
  "generatedAt": "ISO-8601 string",
  "title": "Design System: [Project Title]",
  "extensions": {
    "colorMeta": {
      "primary": {
        "role": "primary",
        "displayName": "Deep Adaptive Teal",
        "colorSetName": "AccentColor",
        "hasDarkVariant": true,
        "tonalRamp": ["...", "...", "..."]
      },
      "surface": {
        "role": "neutral",
        "displayName": "Elevated Surface",
        "colorSetName": "SurfacePrimary",
        "hasDarkVariant": true,
        "tonalRamp": ["...", "..."]
      }
    },
    "typographyMeta": {
      "display": {
        "displayName": "Display",
        "fontSource": "Font.custom(\"NewYork-Regular\", size: 34)",
        "dynamicType": false,
        "purpose": "Hero headlines only."
      },
      "body": {
        "displayName": "Body",
        "fontSource": ".font(.body)",
        "dynamicType": true,
        "purpose": "Primary reading text across all views."
      }
    },
    "materials": [
      {
        "name": "glass-floating",
        "api": ".glassEffect()",
        "container": "GlassEffectContainer",
        "usage": "Tab bars, toolbars, floating control clusters."
      },
      {
        "name": "regular-material",
        "api": ".regularMaterial",
        "usage": "Sheet backgrounds, sidebar fills."
      }
    ],
    "shadows": [
      {
        "name": "card-lift",
        "value": ".shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 4)",
        "purpose": "Resting elevation for card surfaces that are not glass."
      }
    ],
    "motion": [
      {
        "name": "spring-standard",
        "value": ".spring(response: 0.35, dampingFraction: 0.8)",
        "purpose": "Default easing for state transitions and push/pop navigation."
      }
    ],
    "sfSymbols": {
      "renderingMode": "hierarchical",
      "weightTracking": "matches surrounding text weight via .font()",
      "inventory": {
        "navigation": ["chevron.right", "chevron.left", "xmark"],
        "actions": ["plus", "square.and.pencil", "trash"],
        "status": ["checkmark.circle.fill", "exclamationmark.triangle"]
      }
    }
  },
  "components": [
    {
      "name": "Primary Button",
      "kind": "button",
      "refersTo": "button-primary",
      "swiftAPI": "Button(\"Label\") { }.buttonStyle(PrimaryButtonStyle())",
      "description": "Filled accent-color button. Used for the single primary action per screen.",
      "html": "<button class=\"ds-btn-primary\">GET STARTED</button>",
      "css": ".ds-btn-primary { background: #007AFF; color: #fff; padding: 14px 32px; font-weight: 600; font-size: 17px; border: none; border-radius: 14px; transition: opacity 0.15s; } .ds-btn-primary:hover { opacity: 0.85; } .ds-btn-primary:active { transform: scale(0.97); }"
    }
  ],
  "narrative": {
    "northStar": "The Precision Instrument",
    "overview": "2-3 paragraphs of the philosophy -- pulled from DESIGN.md Overview section.",
    "keyCharacteristics": ["...", "..."],
    "rules": [
      {
        "name": "The Dynamic Type Contract",
        "body": "...",
        "section": "typography"
      },
      { "name": "The Glass-First Rule", "body": "...", "section": "elevation" }
    ],
    "dos": ["Do use semantic text styles for all body copy."],
    "donts": ["Don't use Color(red:green:blue:) literals."]
  }
}
```

**What changed from schemaVersion 1.** Token primitive arrays (`tokens.colors[]`, `tokens.typography[]`) now live in the frontmatter. The sidecar carries only metadata that can't live there: Color Set dark-mode flags, `hasDarkVariant`, `colorSetName`, `fontSource`, `dynamicType`, material tokens, shadow tokens, motion tokens, and the SF Symbols inventory. Components still carry HTML/CSS for panel rendering.

#### Component translation rules

The `html` and `css` fields in each component entry must be **self-contained, drop-in snippets** that render correctly when injected into a shadow DOM. For Swift/SwiftUI components this is an approximation -- the panel cannot run SwiftUI -- so the goal is visual fidelity, not code accuracy. Include the `swiftAPI` field to show the real SwiftUI usage alongside the panel-compatible HTML/CSS.

1. **Color resolution.** The project uses Color Set names, not hex in its Swift source. For the sidecar's HTML/CSS, resolve the Color Set's light-appearance value to hex and reference it as a CSS custom property: `--color-primary: #007AFF`. Dark-mode values go in a `@media (prefers-color-scheme: dark)` block.
2. **Typography resolution.** Map SwiftUI semantic text styles to approximate px values for the panel: `body` 17px, `headline` 17px 600-weight, `title` 20px, `title2` 22px, `title3` 20px, `largeTitle` 34px.
3. **Radius resolution.** SwiftUI pt values translate 1:1 to CSS px in the panel.
4. **Materials.** `.glassEffect()` approximates as `backdrop-filter: blur(20px) saturate(1.8); background: rgba(255,255,255,0.25); border-radius: [value]px;` in the panel. Note this is a visual approximation; Liquid Glass renders differently on device.
5. **States.** Include `:hover` and `:active` rules. SwiftUI's `.buttonStyle` press states approximate as `transform: scale(0.97)` on `:active`.
6. **Scoped class names.** Prefix every class with `ds-` to avoid collisions in the shadow DOM.

#### What to include

Aim for **5-10 components** that represent the visual system:

- **Canonical primitives (always include if the project has them):** button (each variant as a separate entry), input/text field, navigation, chip/tag, card or container.
- **Signature components (include if distinctive):** hero layout patterns, custom ViewModifier-based surfaces, any pattern the user flagged as important in PRODUCT.md.
- **Skip the rest.** Wrapper layouts, utility views, internal scaffolding -- not worth documenting unless visually distinctive.

If the project has **no component library yet** (new project, nothing built), synthesize canonical primitives from the tokens using best-practice defaults consistent with the DESIGN.md rules. Every DESIGN.json has something to render.

#### Tonal ramps

For each Color Set in `colorMeta`, generate an 8-step `tonalRamp` array -- dark to light, same hue, stepped lightness. If the project defines a scale (`Primary50` through `Primary900`), use those values. Otherwise synthesize in OKLCH from the light-appearance value of the Color Set.

#### Narrative mapping

Pull directly from the DESIGN.md you just wrote:

- `narrative.northStar` the `**Creative North Star: "..."**` line from Overview
- `narrative.overview` the philosophy paragraphs from Overview
- `narrative.keyCharacteristics` the bulleted `**Key Characteristics:**` list
- `narrative.rules` every `**The [Name] Rule.** [body]` across all sections, tagged with `section`
- `narrative.dos` / `narrative.donts` the bullet lists from Do's and Don'ts verbatim

Do not reword. The panel shows these as secondary collapsible context.

### Step 5: Confirm, refine, and refresh session cache

1. Show the user the full DESIGN.md you wrote. Briefly highlight the non-obvious creative choices (descriptive Color Set names, atmosphere language, named rules).
2. Mention that `DESIGN.json` was also written -- the live panel will now render this project's actual component primitives.
3. Offer to refine any section: "Want me to revise a section, add component patterns I missed, or adjust the atmosphere language?"
4. **Refresh the session cache.** Run `node .claude/skills/impeccable-swift/scripts/load-context.mjs` one final time so the newly-written DESIGN.md lands in conversation. Subsequent commands in this session will use the fresh version automatically without re-reading.

## Seed mode

For projects with no visual system to extract yet. Produces a minimal scaffold, not a full spec.

### Step 1: Confirm seed mode

Before interviewing: "There's no existing visual system to scan -- no Color Sets, no token files, no SwiftUI views. I'll ask five quick questions to seed a starter DESIGN.md. You can re-run `/impeccable document` once there's code, to capture the real tokens and components. OK?"

If the user prefers to skip, stop. No file.

### Step 2: Five questions

Group into one `AskUserQuestion` interaction. Options must be concrete.

1. **Color strategy.** Pick one:
   - Restrained -- tinted neutrals + one accent Color Set used on 10% or less of the screen
   - Committed -- one saturated Color Set carries 30-60% of the surface
   - Full palette -- 3-4 named Color Set roles, each deliberate
   - Drenched -- the surface IS the color

   Then: one hue family or anchor reference ("deep teal", "dusty amber", "Klim #ff4500 orange").

2. **Typography direction.** Pick one (specific fonts come later):
   - Serif display (`Font.custom`) + SF Pro body
   - SF Pro only (warm / technical / geometric tone via weight contrast)
   - New York + SF Pro (Apple's own editorial pairing)
   - Display + mono (`SF Mono` for data or code surfaces)
   - Custom typeface throughout

3. **Motion energy.** Pick one:
   - Restrained -- state changes only, no choreography
   - Responsive -- feedback transitions, `.spring()` on state, no entrances
   - Choreographed -- orchestrated entrances, scroll-driven sequences, `matchedGeometryEffect`

4. **Three named references.** Apps, brands, printed objects. Not adjectives.

5. **One anti-reference.** What it should NOT feel like. Also named.

### Step 3: Write seed DESIGN.md

Use the six-section spec from Scan mode. Populate what the interview answers; leave the rest as honest placeholders. The seed is a scaffold, not a fabricated spec.

Lead the file with:

```markdown
<!-- SEED -- re-run /impeccable document once there's code to capture the actual tokens and components. -->
```

Per-section guidance in seed mode:

- **Overview**: Creative North Star and philosophy phrased from the answers. Reference the user's anti-reference directly.
- **Colors**: Color strategy as a Named Rule (e.g. _"The Restrained Accent Rule. The primary Color Set appears on 10% or less of any screen."_). Hue family or anchor reference. No Color Set names yet -- mark as `[to be resolved once Assets.xcassets has Color Sets]`.
- **Typography**: the direction the user picked. No font names yet -- `[font pairing to be chosen at implementation]`. Note whether Dynamic Type compliance is expected (almost always: yes).
- **Elevation**: inferred from motion energy. Restrained/Responsive suggests flat-by-default or glass-first; Choreographed suggests layered with material depth. One sentence. See [`materials.md`](materials.md).
- **Components**: omit entirely -- no components exist yet.
- **Do's and Don'ts**: carry PRODUCT.md's anti-references directly plus the anti-reference named in Q5.

Seed mode writes a minimal frontmatter with `name` and `description` only -- no colors, typography, rounded, spacing, or components yet. Real tokens land on the next Scan-mode run. Skip the `DESIGN.json` sidecar in seed mode: nothing to render.

### Step 4: Confirm and refresh session cache

1. Show the seed DESIGN.md. Call out that it is a seed (the `<!-- SEED -->` marker is the commitment).
2. Tell the user: "Re-run `/impeccable document` once you have Color Sets in `Assets.xcassets` and some SwiftUI views. That pass will extract real tokens and generate the sidecar."
3. Run `node .claude/skills/impeccable-swift/scripts/load-context.mjs` once so the seed lands in conversation for the rest of the session.

## Style guidelines

- **Frontmatter first, prose second.** Tokens go in YAML; prose contextualizes them. Don't redefine a token value in two places -- the frontmatter is normative.
- **Color Set names over hex everywhere.** The color's meaning is in the Color Set name; the hex is an implementation detail that changes across appearances. Use the name.
- **Cite PRODUCT.md anti-references by name** in the Do's and Don'ts section. If PRODUCT.md lists "SaaS dashboard defaults" or "AI tool template look" as anti-references, the DESIGN.md Don'ts should repeat those phrases verbatim so the visual spec enforces the strategic line.
- **Match the spec, don't invent new sections.** The six section names are fixed. Layout, motion, responsive content fold into Overview (philosophy-level) or Components (per-component behavior).
- **Descriptive over technical**: "Gently curved edges (16pt radius)" not "rounded-lg". Include the technical value in parens; lead with the description.
- **Functional over decorative**: for each token, explain WHERE and WHY it's used, not just WHAT it is.
- **Exact values in parens**: Color Set names, pt values, font weights -- always the precise value alongside the description.
- **Use Named Rules**: `**The [Name] Rule.** [short doctrine]`. These are memorable, citable, and much stickier for AI consumers than bullet lists. Aim for 1-3 per section.
- **Be forceful.** The voice of a design director. "Prohibited", "forbidden", "never", "always" -- not "consider", "might", "prefer".
- **Concrete anti-pattern tests.** A one-sentence audit test beats a paragraph of principle. "If a text view breaks at AX5, the font call is not using a semantic text style."
- **Reference PRODUCT.md.** The anti-references section of PRODUCT.md should directly inform the Do's and Don'ts. Quote or paraphrase.
- **Group colors by role**, not by hue order. Primary / Background / Label / Semantic is the ordering.

## Pitfalls

- Don't use hex values in the `colors` frontmatter. Use Color Set names from `Assets.xcassets`. The Color Set carries both appearances; the name is the stable reference.
- Don't extract every Color Set. Stop at what's actually reused in views -- Xcode-generated utility Color Sets and one-offs pollute the system.
- Don't invent components that don't exist. If the project only has a button and a card, only document those.
- Don't overwrite an existing DESIGN.md without asking.
- Don't duplicate content from PRODUCT.md. DESIGN.md is strictly visual -- colors, type, materials, components, elevation.
- Don't add a "Layout Principles" or "Motion" or "Responsive Behavior" or "SF Symbols" top-level section. The spec has six sections, not nine. Fold SF Symbol rules into Components; fold motion rules into Overview or Elevation.
- Don't rename sections even slightly. "Colors" not "Color Palette". "Typography" not "Type System". Tooling parsing depends on exact headers.
- Don't duplicate token values between frontmatter and prose. If a Color Set is in `colors.primary` as `AccentColor`, the prose can name it descriptively and explain its role -- but must not redefine it with a contradicting hex. The frontmatter is normative.
- Don't invent frontmatter token groups outside Stitch's schema. No `motion:`, `breakpoints:`, `shadows:`, `materials:` at the top level. Stitch's schema accepts only `colors`, `typography`, `rounded`, `spacing`, `components`. Anything else belongs in the sidecar's `extensions`.
- Don't flag non-dynamic `Font.custom()` uses as errors in the document -- note them as intentional display decisions and document them in `typographyMeta` with `"dynamicType": false`. The choice to use a fixed-size custom display font can be intentional; `impeccable-lint` flags it for review, not automatically as a bug.
- Don't assume a project's Color Sets map 1:1 to Stitch's Primary/Secondary/Tertiary/Neutral model. Group by how the Color Sets are actually used in the app, then apply descriptive slugs. Real projects have `SurfacePrimary`, `SurfaceSecondary`, `AccentBlue`, `DestructiveRed` -- not "primary", "secondary", "tertiary".
