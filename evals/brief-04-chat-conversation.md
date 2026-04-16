# Brief 04 — Chat Conversation View

**Prompt:**

> Build a SwiftUI chat conversation view for a messaging app (think Slack, Telegram, or Discord). The conversation includes: plain text messages, a web article link preview, an inline photo, a PDF attachment, and a reply thread (collapsed by default, expandable). Messages are grouped by date with sticky date headers. Includes a compose bar pinned to the bottom that respects the keyboard. Target iOS 26+.

**Message types to include (as sample data):**

1. Received text message — short, single line
2. Sent text message — multiline
3. Received message with a web article link preview (title, description, thumbnail, source URL)
4. Received photo message — inline image, tappable to expand
5. Sent PDF attachment — filename, file size, filetype SF Symbol, download/open action
6. A reply thread — a message with 3 replies collapsed into a "3 replies" affordance, expandable inline

**Exercises:**

- `materials` (message bubble surfaces, compose bar background, link preview card)
- `spatial-design` (bubble padding, max-width constraint on bubbles, date header rhythm)
- `typography` (sender name, message body, timestamp, filename, reply count — each a distinct style)
- `interaction-design` (compose bar states, send button enabled/disabled, reply thread expand/collapse)
- `sf-symbols` (PDF glyph, reply glyph, attachment indicators, send button)
- `navigation` (keyboard avoidance, `.safeAreaInset` for compose bar)
- `responsive-design` (bubble max-width at different screen sizes, photo aspect ratio handling)
- `accessibility` (accessibilityLabel on media messages, trait on link previews, grouping on attachment rows)

**Expected signals in the "with" output:**

- Bubbles use a semantic surface or `Material` — not `Color.blue` / `Color(.systemGray6)` hardcoded per sender
- Sent bubbles sit at trailing edge with a max-width of ~75% of screen width via `.frame(maxWidth: UIScreen.main.bounds.width * 0.75, alignment: .trailing)` or a GeometryReader equivalent
- Timestamp uses `.caption2` with `.monospacedDigit()` so time values don't reflow
- Date headers use `.footnote.weight(.semibold)` centered, with a subtle separator — not a full `Divider()`
- Link preview card uses `RoundedRectangle` with `.continuous` corner style and a `Material` or semantic background — not a white rectangle with hardcoded shadow
- Photo message constrains to a max height (e.g. 240pt) with `.scaledToFill()` and `.clipped()`, and has an `.accessibilityLabel("Photo from [sender]")`
- PDF attachment row uses `Label` with a filetype SF Symbol (e.g. `doc.fill`) rather than a custom PNG; filename truncates with `.lineLimit(1)` and `.truncationMode(.middle)` so extension stays visible
- Reply thread affordance uses `.accessibilityElement(children: .combine)` on the collapsed row and announces "3 replies" to VoiceOver
- Compose bar is pinned via `.safeAreaInset(edge: .bottom)` — not a `VStack` that pushes content up manually
- Compose bar background uses `.regularMaterial` or `.bar` material — not a plain white/gray fill
- Send button uses a custom `ButtonStyle` with a visible pressed state; disabled when text field is empty
- `ScrollViewReader` + `.scrollTo` used to jump to bottom on new message or keyboard appearance — not a manual offset calculation
- `@Environment(\.accessibilityReduceMotion)` consulted before animating thread expand/collapse
- `#Preview` shows at least two states: populated conversation and keyboard-open compose state

**Known failure modes in the "without" output:**

- Hardcoded `Color.blue` for sent bubbles, `Color(.systemGray6)` for received — no material, no Dark Mode adaptation
- Bubble width unconstrained — messages stretch edge to edge like a form field, not a chat bubble
- Timestamp in `.caption` at default weight — numerals reflow when Dynamic Type changes
- Link preview as a plain `VStack` with a `Color.gray.opacity(0.1)` background and no corner radius or `.continuous` style
- Photo message at fixed `.frame(width: 200, height: 150)` — no aspect ratio handling, crops unexpectedly
- PDF attachment as a plain `Text("document.pdf")` with no SF Symbol and no file size
- Reply thread toggled with `if isExpanded { ... }` inside the same bubble — no accessibility grouping, no reduce-motion check
- Compose bar in a `VStack` at the bottom of the screen with `.padding(.bottom, 34)` hardcoded for home indicator — breaks on all other devices
- Compose bar background `Color(.systemBackground)` — no material, no visual separation from the message list
- Send button enabled regardless of text field state — tapping it with empty input either does nothing or crashes
- Single `#Preview` showing a populated conversation, no keyboard/empty state variant
