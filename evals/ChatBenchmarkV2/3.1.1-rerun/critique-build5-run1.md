File: evals/ChatBenchmarkV2/ChatBenchmarkV2/Build5_Fonts/Build5ChatConversationView.swift
Build: Build 5 -- Fonts
Run: 1 of 3
Date: 2026-05-26
Judge: Sonnet 4.6 (critique-only, no detectors)

## Typography

| #    | Finding                                                                                                                                                       | Rule                          | Severity | Reference       | Fix hint                                                                                                 |
| ---- | ------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------- | -------- | --------------- | -------------------------------------------------------------------------------------------------------- |
| T-1  | `WelcomeHeroHeader` uses `Font.custom("Fraunces", size: 34).italic()` (line 305) — a monoculture display font with an italic serif on a product surface        | monoculture_display_font + italic_serif_headline | P0 | typography.md   | Remove Fraunces entirely; use `.font(.largeTitle)` or `.title` (SF Pro) to match the product register   |
| T-2  | `WelcomeHeroHeader` subtitle uses `Font.custom("Fraunces", size: 15)` (line 313) — second hit of same monoculture font, now at body-copy scale                | monoculture_display_font      | P1       | typography.md   | Replace with `.font(.subheadline)` — system semantic style, SF Pro, scales with Dynamic Type            |
| T-3  | Nav toolbar title uses `Font.custom("Fraunces", size: 20)` (line 127) — custom font hardcoded at a fixed pt size; won't scale with Dynamic Type               | monoculture_display_font + no_dynamic_type | P1 | typography.md   | Replace with `.font(.headline)` or `.title3`; if a custom face is needed, wrap in `@ScaledMetric`       |
| T-4  | `ModelPickerChip` uses `Font.custom("Plus Jakarta Sans", size: 13)` (line 547) — a second custom family that is on the brand reflex-reject list               | monoculture_display_font (Plus Jakarta Sans) | P1 | brand.md        | Replace with `.font(.footnote)` (SF Pro); no second custom family is warranted on this product surface  |
| T-5  | All three `Font.custom(…, size: X)` call sites use raw pt sizes without `relativeTo:` or `@ScaledMetric` — none of them scales with the user's Dynamic Type setting | no_dynamic_type          | P1       | typography.md   | Use `Font.custom("…", size: size, relativeTo: .body)` with a `@ScaledMetric` backing value              |
| T-6  | `WelcomeHeroHeader` headline is constrained to `.center` multiline alignment (line 307) while the DESIGN.md brief gives no editorial justification for centered display type on this product surface | weight_discipline     | P3       | typography.md   | Left-align or follow the DESIGN.md layout rhythm; centered display type is a brand-register move        |

Category: P0 1, P1 4, P2 0, P3 1

## Color

| #    | Finding                                                                                                                                                      | Rule                       | Severity | Reference          | Fix hint                                                                                                     |
| ---- | ------------------------------------------------------------------------------------------------------------------------------------------------------------ | -------------------------- | -------- | ------------------ | ------------------------------------------------------------------------------------------------------------ |
| C-1  | `Color.chatAccent` is defined as an inline `Color(red:green:blue:)` literal (lines 8–12) — cobalt blue (`#2563EB`) instead of the DESIGN.md token `#c97350` (warm rust) | wrong_accent_color + inline_rgb | P0 | color-and-contrast.md | Replace with an Asset Catalog color set named `accent` with `#c97350` (light) and appropriate dark-mode value |
| C-2  | `Color.gradientStart` and `Color.gradientEnd` (lines 15–26) are inline RGB literals for a dark navy/indigo palette that has no grounding in the DESIGN.md brief | inline_rgb_literal        | P1       | color-and-contrast.md | DESIGN.md specifies system background + materials; remove the gradient or derive it from brand tokens       |
| C-3  | The dark indigo/navy gradient applied as the global background (lines 107–114) conflicts with the DESIGN.md brief ("system background, layered via materials") — it creates a "dark AI-assistant visual trope" the file's own comment acknowledges (line 106) | off_brand_background | P1 | color-and-contrast.md | Replace with `Color(.systemBackground)` + material-based surface separation per the brief                  |
| C-4  | All three inline `Color(red:green:blue:)` definitions bypass the Asset Catalog; they have no Dark Mode variants and no single-source-of-truth update point    | no_asset_catalog_color     | P2       | color-and-contrast.md | Move all brand colors into the Asset Catalog as named color sets; reference via typed extensions             |

Category: P0 1, P1 2, P2 1, P3 0

## Material

| #    | Finding                                                                                                                                                         | Rule                         | Severity | Reference    | Fix hint                                                                                                            |
| ---- | --------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------- | -------- | ------------ | ------------------------------------------------------------------------------------------------------------------- |
| M-1  | `WelcomeHeroHeader` applies `Material.regularMaterial` as the fill of a `RoundedRectangle` directly behind content-bearing `Text` views (lines 323–325) — material on the content layer, not a chrome/background surface | material_on_content_layer | P1 | materials.md | Materials declare elevation above content; the hero panel is content. Use `Color(.secondarySystemBackground)` or remove the card altogether |
| M-2  | The compose bar uses `Material.bar` (line 262), which is correct per DESIGN.md — no finding. The `DateHeaderRow` uses `Material.thinMaterial` (line 354) and `ReplyThreadBubble` chip uses `Material.thinMaterial` (line 795): three different material levels in the message list layer (`thinMaterial`, `regularMaterial`, `ultraThinMaterial`) without a clear hierarchy rationale | material_soup                | P2       | materials.md | Audit material assignments against the DESIGN.md token table; collapse to a coherent two-level system (received bubbles = `.regularMaterial`, chips/overlays = `.thinMaterial`, link previews = `.ultraThinMaterial` is acceptable if documented) |

Category: P0 0, P1 1, P2 1, P3 0

## Accessibility

| #    | Finding                                                                                                                                                          | Rule                         | Severity | Reference       | Fix hint                                                                                                       |
| ---- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------- | -------- | --------------- | -------------------------------------------------------------------------------------------------------------- |
| A-1  | `bubbleColumn` hides the sender-name `Text` from VoiceOver via `.accessibilityHidden(true)` (line 434) — sender names are semantic content that tell a VoiceOver user who is speaking; hiding them removes context | accessibilityHidden_semantic | P0 | accessibility.md | Remove `.accessibilityHidden(true)` from the sender name; fold it into the bubble's combined accessibility label via `.accessibilityElement(children: .combine)` on the bubble column |
| A-2  | The timestamp `Text` row (line 440) is also hidden from VoiceOver (line 446) when it is the tail of a run — time of message is meaningful, not purely decorative | accessibilityHidden_semantic | P2       | accessibility.md | Include timestamp in the combined accessibility label of the message bubble rather than hiding it entirely      |
| A-3  | `WelcomeHeroHeader` has no accessibility wrapping — four `Text` views are individually focusable with no `.accessibilityElement(children: .combine)`, producing fragmented VoiceOver reads | missing_combine              | P2       | accessibility.md | Add `.accessibilityElement(children: .combine)` to the hero `VStack` so VoiceOver reads it as one banner element |

Category: P0 1, P1 0, P2 2, P3 0

## SF Symbols

| #    | Finding                                                                                                                                                          | Rule                           | Severity | Reference    | Fix hint                                                                                                     |
| ---- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------ | -------- | ------------ | ------------------------------------------------------------------------------------------------------------ |
| SF-1 | `avatarSlot` wraps `Image(systemName:)` in a `.frame(width: 28, height: 28)` (line 417) — sizing a symbol via frame rather than `.font` or `.imageScale` clips the bounding box without scaling the glyph | frame_sizing_symbol          | P2       | sf-symbols.md | Size the avatar symbol with `.font(.title3)` alone (which is already set on line 415) and remove the explicit `.frame`; use `.frame(width: 28, height: 28)` only as a layout spacer on the clear placeholder, not on the glyph itself |
| SF-2 | The surface mixes rendering modes: `avatarSlot` uses default (monochrome) while `send button`, `attachment`, and link preview thumbnail use `.hierarchical` (lines 248, 623) and `PDF icon` uses `.hierarchical` (line 682) — rendering mode is inconsistent across the surface | mixed_rendering_modes          | P2       | sf-symbols.md | Pick one rendering mode for action glyphs; `.hierarchical` is a good choice; apply consistently             |

Category: P0 0, P1 0, P2 2, P3 0

## Platform

| #    | Finding                                                                                                                                                          | Rule                           | Severity | Reference    | Fix hint                                                                                                     |
| ---- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------ | -------- | ------------ | ------------------------------------------------------------------------------------------------------------ |
| P-1  | The compose bar and floating surfaces do not use `.glassEffect()` despite the project targeting iOS 26+, where the compose bar is the canonical Liquid Glass surface per the DESIGN.md ("Liquid Glass materials are in-scope … compose bar") | missing_liquid_glass           | P1       | materials.md | Wrap the compose bar HStack content in a `GlassEffectContainer` and apply `.glassEffect()` on the bar; the current `Material.bar` fallback is correct for pre-iOS 26 but insufficient as the primary treatment on iOS 26+ |

Category: P0 0, P1 1, P2 0, P3 0

## Composition

| #    | Finding                                                                                                                                                          | Rule                           | Severity | Reference    | Fix hint                                                                                                     |
| ---- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------ | -------- | ------------ | ------------------------------------------------------------------------------------------------------------ |
| CO-1 | The overall color palette (cobalt blue accent, dark navy/indigo gradient) conflicts with the DESIGN.md brand tokens (warm rust accent `#c97350`, system backgrounds) at a systemic level — this is not isolated to one component but pervades every tinted surface and sent-bubble fill in the fixture | systemic_token_mismatch        | P0       | color-and-contrast.md | The entire color token layer needs replacing: swap `chatAccent` to terracotta `#c97350`, remove the gradient background, and re-evaluate every accent-colored element |

Category: P0 1, P1 0, P2 0, P3 0

## Summary

| Severity  | Count  |
| --------- | ------ |
| P0        | 4      |
| P1        | 8      |
| P2        | 8      |
| P3        | 1      |
| **Total** | **21** |
