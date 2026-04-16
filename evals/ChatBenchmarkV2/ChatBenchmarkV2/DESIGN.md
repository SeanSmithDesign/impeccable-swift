# DESIGN.md — ChatBenchmark

This is the design context a SwiftUI sub-agent needs to make good decisions on this project. Tokens here override the impeccable-swift reference docs where explicit. Where this file is silent, the reference docs apply; where both are silent, Apple HIG decides.

## Product context

- **Product:** A direct-messaging app for general consumers. One-to-one and small-group conversations, media sharing, light reply threading.
- **Audience:** Everyday messaging users across all ages. Non-technical. High expectation for the app to "feel Apple."
- **Brand personality:** Clean, focused, fast, reliable. Not playful. Not corporate. Closer in spirit to Messages than to Discord. Understated confidence.
- **Emotional target (3 words):** focused, fast, familiar.

## Platform

- iOS 26+ only. No macOS, iPadOS, visionOS, watchOS targets for this benchmark.
- Liquid Glass materials are in-scope and should be used where they earn their place (compose bar, floating overlays).

## Tokens

### Color

- **Accent:** `#c97350` — a warm rust / terracotta. Used sparingly: send-button fill when enabled, active reply thread affordance, link preview source label. Never as a full-bleed background.
- **Sent bubble surface:** Accent color with appropriate contrast text, OR accent-tinted material. Decide based on reference doc guidance — not a raw `Color.blue`.
- **Received bubble surface:** `Material` (`.regularMaterial` or a semantic surface). Not `Color(.systemGray6)`.
- **Background:** System background, but layered via materials on scroll so the compose bar feels distinct.
- **Dark Mode:** Must work. Accent holds across both appearances; materials carry the surface work.

### Typography

- **Family:** SF Pro (system default — do not declare a custom family).
- **Dynamic Type:** All text scales. Use `@ScaledMetric` for any fixed spacing that must scale with text (bubble min-height, reply-count chip).
- **Sender name (group-chat header above a run):** `.footnote.weight(.semibold)`, secondary color.
- **Message body:** `.body` at default weight.
- **Timestamp:** `.caption2` with `.monospacedDigit()` so numerals don't reflow.
- **Link preview title:** `.subheadline.weight(.semibold)`.
- **Link preview description:** `.footnote`, two-line truncation.
- **Link preview source label:** `.caption2` in accent color.
- **Filename (PDF):** `.subheadline`, `.lineLimit(1)`, `.truncationMode(.middle)`.
- **File size:** `.caption`, secondary color.
- **Date header:** `.footnote.weight(.semibold)`, centered, tertiary color.
- **Reply count affordance:** `.footnote.weight(.medium)`.

### Spacing

- **Rhythm:** 4 / 8 / 12 / 16 / 24.
- **Bubble padding (internal):** 12 vertical, 14 horizontal.
- **Gap between bubbles from different senders:** 12.
- **Gap between consecutive bubbles from the same sender:** 4.
- **Gap around date header row:** 16 above, 8 below.
- **Compose bar internal padding:** 12 vertical, 16 horizontal.
- **Safe area:** handled via `.safeAreaInset(edge: .bottom)` for the compose bar. Do not hardcode bottom padding.

### Shape

- **Bubble corner radius:** 18, `.continuous` style. No tail/pointer — this is a flat bubble language, not iMessage.
- **Link preview card corner radius:** 14, `.continuous`.
- **Inline photo corner radius:** 14, `.continuous`.
- **PDF attachment row corner radius:** 14, `.continuous`.
- **Send button:** capsule.

### Material & elevation

- **Compose bar:** `.bar` material, pinned via `.safeAreaInset`.
- **Received bubbles:** `.regularMaterial` (or `.thinMaterial` if tests show insufficient contrast against the background).
- **Sent bubbles:** accent-tinted surface; see Color.
- **Link preview card:** `.ultraThinMaterial` over a subtle stroke.
- **Elevation:** no drop shadows. Material does the separation.

### Motion

- Reply-thread expand/collapse: spring animation with `.spring(duration: 0.35, bounce: 0.15)`. Respect `@Environment(\.accessibilityReduceMotion)` — fade + instant layout when reduced.
- Keyboard: let SwiftUI handle it via `.safeAreaInset` + `ScrollViewReader.scrollTo`. No manual offset math.

### SF Symbols

- One set per surface. PDF uses `doc.fill`. Reply glyph uses `arrowshape.turn.up.left.fill`. Send button uses `arrow.up.circle.fill` (enabled) / `arrow.up.circle` (disabled). Attachment picker uses `paperclip`.
- Weight: `.semibold` for action glyphs, `.regular` for inline content glyphs. Don't mix.

### Interaction

- **Send button:** custom `ButtonStyle` with visible pressed state (scale ~0.96, opacity shift). Disabled when the text field is empty or whitespace-only. Tapping plays `.sensoryFeedback(.success, trigger:)`.
- **Reply thread affordance:** tappable row with a clear pressed state; announces "3 replies — tap to expand" to VoiceOver via `.accessibilityElement(children: .combine)` + `.accessibilityLabel`.
- **Photo message:** tappable (no-op for the benchmark, but wire up the gesture and accessibility label).

### Accessibility

- All media messages carry `.accessibilityLabel("Photo from [sender]")` / `.accessibilityLabel("PDF from [sender], [filename], [size]")`.
- Link preview uses `.accessibilityAddTraits(.isLink)`.
- Reply thread uses `.accessibilityElement(children: .combine)` on the collapsed row.
- All interactive elements are at least 44×44 in hit area.

## Anti-patterns (explicit for this project)

- No `Color.blue` / `Color(.systemGray6)` hardcoded anywhere.
- No `cornerRadius(10)` with a raw number. Use `.continuous` style and a token.
- No `VStack { ... Spacer() ComposeBar() }` for keyboard avoidance — `.safeAreaInset` only.
- No emoji in code comments. No decorative shadows.
- No custom font family. SF Pro via system text styles only.
