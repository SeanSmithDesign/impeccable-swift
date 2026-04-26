File: evals/ChatBenchmarkV2/ChatBenchmarkV2/Build3_ImpeccableSwift/Build3ChatConversationView.swift
Build: Build 3 -- impeccable-swift
Run: 2 of 3
Date: 2026-04-26
Judge: Sonnet 4.6 (critique-only, no detectors)

## Material

| #   | Finding                                                                                                                                                                                                                                                                                                              | Severity | Fix hint                                                                                                                                                 |
| --- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------- | -------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 1   | `BubbleSurface`: `.regularMaterial` applied to ALL inline message bubbles (both sent and received). `.regularMaterial` is designed for floating chrome (sheets, sidebars, overlays), not inline content rows. Every message becomes a floating-chrome surface, triggering the glassmorphism-as-default anti-pattern. | P1       | Use a flat fill for received bubbles (e.g. `Color(.systemGray5)`) and a solid tinted fill for sent bubbles. Reserve materials for truly floating chrome. |
| 2   | `BubbleSurface` sent path: `Color.accentColor.opacity(0.22)` overlaid via ZStack on top of `.regularMaterial`. Opacity-tinting a material compounds the misuse and produces inconsistent results across light/dark/high-contrast.                                                                                    | P1       | Replace with a solid `Color.accentColor` fill (or a semantic tint) directly, without a material base.                                                    |
| 3   | `linkCard` in `LinkPreviewBubble`: `.regularMaterial` applied to an inline content card. Same misuse as `BubbleSurface`.                                                                                                                                                                                             | P1       | Use a flat semantic background (e.g. `Color(.secondarySystemBackground)`) for inline content cards.                                                      |
| 4   | `ReplyThreadBubble` disclosure chip: `.thinMaterial` in `Capsule`. The chip is inline body content, not floating chrome. Minor escalation of the same pattern.                                                                                                                                                       | P2       | Use a flat secondary fill for inline chips.                                                                                                              |

## Color

| #   | Finding                                                                                                                                                                                       | Severity | Fix hint                                                                                                                                            |
| --- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------- | --------------------------------------------------------------------------------------------------------------------------------------------------- |
| 5   | `SendButtonStyle`: `.foregroundStyle(.white)` hardcoded. Does not adapt to high-contrast or inverted display modes.                                                                           | P2       | Use `.foregroundStyle(.white)` only inside a `.background(Color.accentColor)` context where the system can adapt, or prefer a semantic label color. |
| 6   | `linkCard` thumbnail gradient: `[Color.accentColor.opacity(0.35), Color.accentColor.opacity(0.14)]`. Opacity-based gradient is fragile in high-contrast mode; the 0.14 stop may be invisible. | P2       | Use opaque or near-opaque accent fills with reduced-transparency fallback.                                                                          |
| 7   | `linkCard` thumbnail icon: `.foregroundStyle(.white)` hardcoded over a gradient. Does not adapt to high-contrast.                                                                             | P2       | Use `.foregroundStyle(.primary)` or check `accessibilityReduceTransparency` to switch to a contrasting color.                                       |
| 8   | `PhotoBubble.photoSurface` gradient: `[Color.accentColor.opacity(0.45), Color.accentColor.opacity(0.18)]`. Same fragile opacity-gradient pattern.                                             | P2       | Use opaque semantic fills with reduce-transparency fallback.                                                                                        |
| 9   | `PhotoBubble.photoSurface` icon: `.foregroundStyle(.white)` hardcoded.                                                                                                                        | P2       | Same fix as finding 7.                                                                                                                              |
| 10  | `BubbleSurface` sent overlay: `Color.accentColor.opacity(0.22)` tint. At 0.22 opacity over a material, contrast ratio may fall below WCAG AA in high-contrast mode.                           | P2       | Use a higher-opacity or opaque fill; test under Increase Contrast.                                                                                  |

## Typography

| #   | Finding                                                                                                                                           | Severity | Fix hint                                                                                                            |
| --- | ------------------------------------------------------------------------------------------------------------------------------------------------- | -------- | ------------------------------------------------------------------------------------------------------------------- |
| 11  | `PhotoBubble.photoSurface`: `.font(.system(size: 56, weight: .semibold))` hardcoded point size on an SF Symbol. Does not scale with Dynamic Type. | P1       | Use `@ScaledMetric(relativeTo: .largeTitle) private var iconSize: CGFloat = 56` or substitute `.font(.largeTitle)`. |
| 12  | `replyList` VStack: `spacing: 10`. Not on the 4pt grid (valid steps: 4, 8, 12, 16, 20, 24).                                                       | P2       | Change to `spacing: 8` or `spacing: 12`.                                                                            |
| 13  | `LinkPreviewBubble`, `PhotoBubble`, `PDFAttachmentBubble`, `ReplyThreadBubble` VStacks: `spacing: 6`. Not on the 4pt grid.                        | P2       | Change to `spacing: 8`.                                                                                             |
| 14  | `ReplyRow` inner VStack and `PDFAttachmentBubble` inner VStack: `spacing: 2`. Not on the 4pt grid.                                                | P2       | Change to `spacing: 4`.                                                                                             |
| 15  | `PDFAttachmentBubble` metadata HStack and `ReplyRow` name/time HStack: `spacing: 6`. Not on the 4pt grid.                                         | P2       | Change to `spacing: 8`.                                                                                             |

## Accessibility

| #   | Finding                                                                                                                                                                                                             | Severity | Fix hint                                                                                                                                        |
| --- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------- | ----------------------------------------------------------------------------------------------------------------------------------------------- |
| 16  | No bubble view reads `@Environment(\.accessibilityReduceTransparency)`. All material-backed bubbles ignore this preference, leaving illegible low-contrast surfaces for users who have enabled Reduce Transparency. | P1       | Read `accessibilityReduceTransparency` in `BubbleSurface` and swap to an opaque fill when true. Apply the same to `linkCard` and `PhotoBubble`. |
| 17  | `ReplyThreadBubble.isExpanded` is `@State` local to the view. `LazyVStack` will recycle the cell when scrolled off-screen, resetting expanded state silently.                                                       | P1       | Lift expanded state to the parent as `Set<Message.ID>` (same pattern as Builds 2 and 4) and pass it down as a binding.                          |
| 18  | `PDFAttachmentBubble` declares `.accessibilityAddTraits(.isButton)` but has no `Button` wrapper or tap gesture. This adds a false interactive trait to a non-interactive element, misleading VoiceOver users.       | P1       | Either wrap the content in a `Button` (no-op is fine for the benchmark) or remove `.isButton`.                                                  |
| 19  | `linkCard` in `LinkPreviewBubble`: `.accessibilityHint("Opens the article")` on a non-interactive view with no tap gesture or `Button`. False affordance hint.                                                      | P2       | Remove the hint, or add an `.onTapGesture` / `Button` to make the element actually interactive.                                                 |
| 20  | `TextBubble` accessibility label for received messages falls back to "Them" when `senderName` is nil. "Them" is ambiguous and uninformative for VoiceOver users in a multi-participant thread.                      | P2       | Use the actual sender name from `senderInfo?.displayName`, or a meaningful fallback like "Other participant".                                   |

## Interaction

| #   | Finding                                                                                                                                                 | Severity | Fix hint                                                                                                |
| --- | ------------------------------------------------------------------------------------------------------------------------------------------------------- | -------- | ------------------------------------------------------------------------------------------------------- |
| 21  | Send button in `ComposeBar`: `.frame(width: 40, height: 40)`. Minimum touch target is 44x44pt per HIG.                                                  | P1       | Change to `.frame(width: 44, height: 44)` or use `.contentShape(Rectangle())` with a 44pt minimum area. |
| 22  | Attachment (plus) button in `ComposeBar`: `.frame(width: 40, height: 40)`. Same under-sized touch target.                                               | P1       | Change to `.frame(width: 44, height: 44)`.                                                              |
| 23  | Reply disclosure chip: `.frame(minHeight: 44)` ensures vertical target, but no `minWidth`. On a "1 reply" label, horizontal extent may fall under 44pt. | P2       | Add `.frame(minWidth: 44, minHeight: 44)`.                                                              |

## Composition

| #   | Finding                                                                                                                                                                                                        | Severity | Fix hint                                                                                                                                |
| --- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------- | --------------------------------------------------------------------------------------------------------------------------------------- |
| 24  | Bubble width constraint uses `Spacer(minLength: 56)` rather than a true max-width cap. On iPad or Stage Manager at 1024pt canvas width, bubbles can span ~968pt, breaking the conversational visual hierarchy. | P2       | Apply `.frame(maxWidth: UIScreen.main.bounds.width * 0.75)` or a fixed cap (e.g. 480pt) to the bubble, or use `containerRelativeFrame`. |
| 25  | `KeyboardOpenPreview`: hardcoded `Color.clear.frame(height: 291)` as keyboard stub. 291pt is device-specific and will render incorrectly on any device with a different keyboard height.                       | P3       | Use `.ignoresSafeArea(.keyboard)` or read the keyboard height from the focused field's geometry rather than a hardcoded constant.       |

## State Coverage

| #   | Finding                                                                                           | Severity | Fix hint                                                                          |
| --- | ------------------------------------------------------------------------------------------------- | -------- | --------------------------------------------------------------------------------- |
| 26  | No empty state when `sections` is empty. The scroll view renders a blank canvas with no guidance. | P2       | Add a `ContentUnavailableView` (iOS 17+) when `sections.isEmpty`.                 |
| 27  | No loading state.                                                                                 | P2       | Add a skeleton or `ProgressView` placeholder for the initial load phase.          |
| 28  | No error state.                                                                                   | P2       | Add an error banner or `ContentUnavailableView` variant for failed message loads. |

## Summary

| Severity  | Count  |
| --------- | ------ |
| P0        | 0      |
| P1        | 10     |
| P2        | 17     |
| P3        | 1      |
| **Total** | **28** |
