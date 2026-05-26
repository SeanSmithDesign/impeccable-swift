File: evals/ChatBenchmarkV2/ChatBenchmarkV2/Build5_Fonts/Build5ChatConversationView.swift
Build: Build 5 -- Fonts
Run: 3 of 3
Date: 2026-05-26
Judge: Sonnet 4.6 (critique-only, no detectors)

## Typography

| #    | Finding                                                                                                                                                   | Rule                        | Severity | Reference      | Fix hint                                                                                 |
| ---- | --------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------- | -------- | -------------- | ---------------------------------------------------------------------------------------- |
| T-1  | `WelcomeHeroHeader` applies `Font.custom("Fraunces", size: 34)` with `.italic()` to the hero headline (line 305). Fraunces is explicitly on the brand reflex-reject list; italic serif on a product/utility surface with no editorial rationale is a double violation. DESIGN.md mandates SF Pro system styles only. | monoculture_display_font + italic_serif_headline | P0 | typography.md, brand.md | Replace with `.font(.largeTitle)` or `.font(.title)`. Remove `.italic()`. No custom family. |
| T-2  | `WelcomeHeroHeader` subtitle also uses `Font.custom("Fraunces", size: 15)` (line 313). The monoculture hit repeats on body-scale text, compounding font-system incoherence; every text style in this component deviates from DESIGN.md. | monoculture_display_font    | P0       | typography.md  | Replace with `.font(.subheadline)` or `.font(.callout)`.                                  |
| T-3  | Navigation toolbar title uses `Font.custom("Fraunces", size: 20)` (line 127). A third Fraunces instance in chrome (navbar) where DESIGN.md is explicit: "do not declare a custom family." | monoculture_display_font    | P0       | typography.md  | Replace with `.font(.title3)` or `.font(.headline)` system style.                         |
| T-4  | `ModelPickerChip` uses `Font.custom("Plus Jakarta Sans", size: 13)` (line 547). Plus Jakarta Sans is also on the reflex-reject list. Introduces a second rogue family, creating a two-family monoculture. | monoculture_display_font    | P1       | typography.md, brand.md | Replace with `.font(.footnote)`. Delete Plus Jakarta Sans entirely.                        |
| T-5  | All `Font.custom` calls use absolute point sizes (`size: 34`, `size: 15`, `size: 20`, `size: 13`) without `@ScaledMetric` or the `relativeTo:` overload. None of these sizes scale with Dynamic Type. The `#Preview("Dynamic Type XL")` preview at `.accessibility2` will render all four views at fixed sizes. | dynamic_type_fixed_size     | P0       | typography.md  | Use `Font.custom(_:size:relativeTo:)` or replace with semantic styles entirely.            |
| T-6  | Nav title `Text(otherPartyName)` at `.custom("Fraunces", size: 20)` has `.lineLimit` absent and no `.minimumScaleFactor`. In a navigation bar (constrained, single-line context) long names will overflow without shrink-before-truncate behavior. | single-line-label discipline | P2      | typography.md  | Add `.lineLimit(1).minimumScaleFactor(0.75)` to the toolbar title Text.                   |

Category: P0 4, P1 1, P2 1, P3 0

## Color

| #    | Finding                                                                                                                                                     | Rule                      | Severity | Reference          | Fix hint                                                                                     |
| ---- | ----------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------- | -------- | ------------------ | -------------------------------------------------------------------------------------------- |
| C-1  | `Color.chatAccent` is defined as an inline `Color(red: 37/255, green: 99/255, blue: 235/255)` RGB literal (lines 8–12) — a cold cobalt blue. DESIGN.md specifies accent `#c97350` (warm rust / terracotta). The token is both the wrong value and wrong construction method (inline RGB vs. Asset Catalog). This is a ship-blocking brand error. | wrong_accent_token + inline_color_literal | P0 | color-and-contrast.md | Define accent in Asset Catalog as `chatAccent` color set with correct `#c97350` hex. Reference via `Color("chatAccent")`. |
| C-2  | `Color.gradientStart` (lines 15–19) and `Color.gradientEnd` (lines 22–26) are inline RGB literals with no Asset Catalog entries. These have no dark-mode variants. In dark mode they render the same cool-dark gradient, which may invert perceived contrast since materials behind them auto-adapt while the gradient does not. | inline_color_literal + missing_dark_variant | P1 | color-and-contrast.md | Move both gradient colors into Asset Catalog color sets with explicit Any / Dark Appearance values. |
| C-3  | The gradient background itself (`gradientStart` → `gradientEnd`, line 108–113) is a dark near-black wash that makes the app look like a "dark AI assistant" trope. DESIGN.md background: "system background, layered via materials on scroll." A hardcoded dark gradient prevents automatic light-mode readability and overrides system background adaptation. | wrong_background_strategy | P1       | color-and-contrast.md | Remove custom gradient. Use `.background(.background)` with compose bar as `.bar` material per DESIGN.md. |
| C-4  | Send button foreground uses `Color.chatAccent` (line 249) which resolves to the wrong cobalt blue (see C-1). Link preview source label also uses `Color.chatAccent` (line 591). All accent applications inherit the wrong color token. | wrong_accent_token (downstream) | P0 | color-and-contrast.md | Resolved by fixing C-1. No additional change needed if the token is corrected. |

Category: P0 2, P1 2, P2 0, P3 0

## Material

| #    | Finding                                                                                                                                                     | Rule                        | Severity | Reference    | Fix hint                                                                                             |
| ---- | ----------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------- | -------- | ------------ | ---------------------------------------------------------------------------------------------------- |
| M-1  | `WelcomeHeroHeader` applies `Material.regularMaterial` directly as the background fill of a `RoundedRectangle` that sits behind content-bearing `Text` views (lines 322–325). The comment in the code itself flags this as a violation: "material_on_content_layer." `regularMaterial` is appropriate for sidebars and primary panels that float over a scroll layer — not for a card that IS the content layer. | material_on_content_layer   | P1       | materials.md | Use a semantic surface color (e.g. `Color(.secondarySystemBackground)`) or an opaque fill with `reduceTransparency` branching already used elsewhere in the file. |
| M-2  | The compose bar correctly uses `Material.bar` with a `reduceTransparency` fallback. However, on iOS 26+, the compose bar floating above a scroll surface is a prime candidate for `.glassEffect()` rather than the older `Material.bar`. The app targets iOS 26+ per DESIGN.md. This is a polish-level miss, not a blocker. | missing_liquid_glass        | P2       | materials.md | Wrap compose bar background in `GlassEffectContainer` + `.glassEffect(.regular, in: .rect(...))` for iOS 26+. |

Category: P0 0, P1 1, P2 1, P3 0

## Accessibility

| #    | Finding                                                                                                                                                      | Rule                           | Severity | Reference       | Fix hint                                                                                              |
| ---- | ------------------------------------------------------------------------------------------------------------------------------------------------------------ | ------------------------------ | -------- | --------------- | ----------------------------------------------------------------------------------------------------- |
| A-1  | `bubbleColumn` hides sender name from VoiceOver via `.accessibilityHidden(true)` (line 434). The code comment itself calls this out as a violation: "Sender names are semantic labels — hiding them from VoiceOver leaves users without context for who said what." In a multi-party conversation, sender identity is load-bearing, not decorative. | accessibility_hidden_semantic_label | P0 | accessibility.md | Remove `.accessibilityHidden(true)` from the sender-name `Text`. If needed, ensure the parent `.accessibilityElement(children: .combine)` chain includes it. |
| A-2  | Timestamp `Text(message.sentAt, ...)` is hidden via `.accessibilityHidden(true)` (line 447). Timestamps in messaging carry meaningful information — "sent 2 minutes ago" is material context. This is a softer call (only shown on tail-of-run), but hiding it entirely rather than folding it into a combined parent element means VoiceOver users get no time reference at all. | accessibility_hidden_timestamp | P2       | accessibility.md | Instead of hiding, fold timestamp into the `bubbleColumn` `.accessibilityElement(children: .combine)` label, e.g. "Message from Lyra, sent 3:42 PM." |
| A-3  | `WelcomeHeroHeader` is a VStack with no accessibility grouping. The two `Text` views ("Ask me anything" + subtitle) will be traversed as separate VoiceOver stops. A `.accessibilityElement(children: .combine)` would improve navigation efficiency on this intro panel. | missing_accessibility_grouping | P3       | accessibility.md | Add `.accessibilityElement(children: .combine)` to `WelcomeHeroHeader`'s outer VStack.               |

Category: P0 1, P1 0, P2 1, P3 1

## Composition

| #    | Finding                                                                                                                                                      | Rule                      | Severity | Reference        | Fix hint                                                                                        |
| ---- | ------------------------------------------------------------------------------------------------------------------------------------------------------------ | ------------------------- | -------- | ---------------- | ----------------------------------------------------------------------------------------------- |
| Co-1 | `WelcomeHeroHeader` establishes an entirely separate visual language — italic serif display type on a material card — that contradicts the clean, focused product personality in DESIGN.md ("focused, fast, familiar. Closer in spirit to Messages than to Discord"). The hero pattern reads as brand-register editorial, not product-register messaging UI. | register_mismatch         | P1       | brand.md         | Simplify hero to system text styles. Consider a simple greeting `Text` in `.title2` weight with a subtle divider, or remove the hero entirely if it's only on first launch. |
| Co-2 | `ModelPickerChip` is compositionally disconnected from the rest of the chat surface. The strip introduces a UI pattern (model selection) that has no counterpart in any other component, uses a rogue font family, and sits outside the DESIGN.md brief scope. Its presence implies feature scope beyond what the brief describes. | out_of_scope_component    | P3       | brand.md         | If model-picking is in scope, align font to system styles and ensure the chip strip is positioned within the compose bar or a dedicated sheet, not floating inline in the conversation list. |

Category: P0 0, P1 1, P2 0, P3 1

## Summary

| Severity  | Count  |
| --------- | ------ |
| P0        | 7      |
| P1        | 5      |
| P2        | 3      |
| P3        | 2      |
| **Total** | **17** |
