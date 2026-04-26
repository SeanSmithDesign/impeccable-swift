File: evals/ChatBenchmarkV2/ChatBenchmarkV2/Build4_FullSetup/Build4ChatConversationView.swift
Build: Build 4 -- Full Setup (+DM)
Run: 1 of 3
Date: 2026-04-26
Judge: Sonnet 4.6 (critique-only, no detectors)

## Color

| #   | Finding                                                                                                                                                                                                                                                  | Severity | Fix hint                                                                                                                                                              |
| --- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 1   | `chatAccent` is defined as an inline `Color(red:green:blue:)` literal, not an Asset Catalog Color Set. It is used in TextBubble foreground, LinkPreviewCard source label, PDFBubble icon, ReplyThreadBubble chip foreground, and send button foreground. | P1       | Move to an `.xcassets` Color Set named `ChatAccent` and reference via `Color("ChatAccent")` or a generated asset symbol so the value is overridable per color scheme. |
| 2   | `Color.white` hardcoded as sent-bubble text foreground in `TextBubble`. Does not adapt to high-contrast mode.                                                                                                                                            | P2       | Use `Color(.label)` inverted by context, or a dedicated Asset Catalog color set with a high-contrast variant.                                                         |

## Material

| #   | Finding                                                                                                                                                               | Severity | Fix hint                                                                                                                                |
| --- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------- | --------------------------------------------------------------------------------------------------------------------------------------- |
| 3   | `Material.ultraThinMaterial` used as fill on `PhotoBubble` content layer. Content bubbles are not floating chrome; this is the glassmorphism-as-default failure mode. | P1       | Replace with `Color(.secondarySystemBackground)` (already used in the `reduceTransparency` branch), making the opaque path the default. |
| 4   | `Material.ultraThinMaterial` used as fill on `LinkPreviewCard`. Same issue: embedded content, not floating chrome.                                                    | P1       | Replace with `Color(.tertiarySystemBackground)` (already used in the `reduceTransparency` branch).                                      |
| 5   | `Material.regularMaterial` used in `bubbleSurface` for received `TextBubble`. Content layer, not floating chrome.                                                     | P1       | Replace with `Color(.secondarySystemBackground)`.                                                                                       |
| 6   | `Material.regularMaterial` used as fill in `PDFBubble`. Content layer.                                                                                                | P1       | Replace with `Color(.secondarySystemBackground)`.                                                                                       |
| 7   | `Material.thinMaterial` used as fill in `ReplyBubbleRow`. Content layer.                                                                                              | P1       | Replace with `Color(.secondarySystemBackground)`.                                                                                       |
| 8   | `Material.thinMaterial` used as fill on `chipButton` Capsule in `ReplyThreadBubble`. An inline chip is not floating chrome.                                           | P2       | Replace with `Color(.secondarySystemBackground)` or a tinted opaque fill derived from `chatAccent` at low opacity.                      |

## Spacing

| #   | Finding                                                                                             | Severity | Fix hint                                       |
| --- | --------------------------------------------------------------------------------------------------- | -------- | ---------------------------------------------- |
| 9   | `padding(.top, 2)` on timestamp in `bubbleColumn`: 2 is not on the 4pt scale.                       | P2       | Use `padding(.top, 4)`.                        |
| 10  | `spacing: 2` in `bubbleColumn` VStack: 2 is not on the 4pt scale.                                   | P2       | Use `spacing: 4`.                              |
| 11  | `spacing: 6` in `ReplyThreadBubble` body VStack and chip-to-replies gap: 6 is not on the 4pt scale. | P2       | Use `spacing: 8`.                              |
| 12  | `spacing: 6` in `ReplyBubbleRow` inner VStack (sender name + body): 6 is not on the 4pt scale.      | P2       | Use `spacing: 4` or `spacing: 8`.              |
| 13  | `padding(.horizontal, 10)` in `ReplyBubbleRow`: 10 is not on the 4pt scale.                         | P2       | Use `padding(.horizontal, 12)`.                |
| 14  | `padding(.leading, 2)` on sender name Text in `bubbleColumn`: 2 is not on the 4pt scale.            | P2       | Remove or replace with `padding(.leading, 4)`. |
| 15  | `Spacer(minLength: 24)` for sent/received side gutters: 24 is not on the 4pt scale.                 | P2       | Use `minLength: 20` or `minLength: 32`.        |

## Typography

| #   | Finding                                                                                                                              | Severity | Fix hint                                                                                                                                                                             |
| --- | ------------------------------------------------------------------------------------------------------------------------------------ | -------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| 16  | `.font(.system(size: 72))` on the SF Symbol placeholder inside `PhotoBubble`: hardcoded point size does not scale with Dynamic Type. | P1       | Use `@ScaledMetric(relativeTo: .largeTitle) private var iconSize: CGFloat = 72` and apply `.font(.system(size: iconSize))`, or use `.font(.largeTitle)` with a larger `.imageScale`. |

## Accessibility

| #   | Finding                                                                                                                                                                                                       | Severity | Fix hint                                                                                                                          |
| --- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------- | --------------------------------------------------------------------------------------------------------------------------------- |
| 17  | Timestamps are marked `.accessibilityHidden(true)` in `bubbleColumn`. VoiceOver users cannot determine when messages were sent.                                                                               | P1       | Remove the hidden modifier from the timestamp, or include the formatted time in the parent bubble's combined accessibility label. |
| 18  | Sender names are marked `.accessibilityHidden(true)` in `bubbleColumn`. In a group-chat context this removes critical context for VoiceOver.                                                                  | P1       | Include the sender name in the bubble's combined accessibility label instead of hiding it.                                        |
| 19  | `PDFBubble` button has no explicit `.frame(minWidth: 44, minHeight: 44)` and no `.contentShape`. The tappable area relies solely on internal padding; at smaller Dynamic Type sizes this may fall below 44pt. | P2       | Add `.frame(minWidth: 44, minHeight: 44)` and `.contentShape(Rectangle())` on the `Button`.                                       |
| 20  | `chipButton` in `ReplyThreadBubble` has `.frame(minHeight: 44)` but `.contentShape(Capsule())`. A Capsule contentShape clips the tappable area; at narrow chip widths the hit area may be under 44pt wide.    | P2       | Add `.frame(minWidth: 44)` alongside `minHeight`, or switch to `.contentShape(Rectangle())` with a fixed minimum frame.           |

## Interaction

| #   | Finding                                                                                                                                                                                 | Severity | Fix hint                                                                                                 |
| --- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------- | -------------------------------------------------------------------------------------------------------- |
| 21  | `paperclip` attachment button in the compose bar has no `.symbolRenderingMode` set, while all other SF Symbols on the same surface use `.hierarchical`. Rendering mode is inconsistent. | P2       | Add `.symbolRenderingMode(.hierarchical)` to the paperclip Image.                                        |
| 22  | Thread expand/collapse in `ReplyThreadBubble` has no haptic feedback. The send action fires `.sensoryFeedback(.success)` but thread interactions are silent.                            | P3       | Add `.sensoryFeedback(.selection, trigger: isExpanded)` or fire a `UIImpactFeedbackGenerator` on toggle. |
| 23  | `ReplyBubbleRow` provides no `.accessibilityHint` for any possible interaction. Low severity but leaves VoiceOver context incomplete if replies become actionable.                      | P3       | Add `.accessibilityHint("Double-tap to view details")` if a tap action is added in the future.           |

## State Coverage

| #   | Finding                                                                                                                                        | Severity | Fix hint                                                                                                            |
| --- | ---------------------------------------------------------------------------------------------------------------------------------------------- | -------- | ------------------------------------------------------------------------------------------------------------------- |
| 24  | No empty state: when `messages` is empty (or `sections` is empty), the scroll view renders blank. No `ContentUnavailableView` or equivalent.   | P2       | Add a `ContentUnavailableView("No Messages", systemImage: "bubble.left.and.bubble.right")` when `sections.isEmpty`. |
| 25  | No loading/skeleton state for initial message fetch. A real DM view would show a `ProgressView` while messages load from the network or cache. | P2       | Add a loading flag; when true, show a centered `ProgressView` inside the scroll area.                               |
| 26  | No error state if message loading fails.                                                                                                       | P2       | Add an error flag and a `ContentUnavailableView` with a retry action when the error state is active.                |

## Composition

| #   | Finding                                                                                                                                                                                           | Severity | Fix hint                                                                                                          |
| --- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------- | ----------------------------------------------------------------------------------------------------------------- |
| 27  | `LinkPreviewCard` thumbnail has inner corner radius 10, but outer card corner radius is 14 and inner padding is 12. Concentric corner rule (inner = outer - padding) expects 14 - 12 = 2, not 10. | P1       | Change thumbnail `cornerRadius` to `max(2, 14 - 12)` = 2, or reduce thumbnail inset to make the radii concentric. |

## Summary

| Severity  | Count  |
| --------- | ------ |
| P0        | 0      |
| P1        | 10     |
| P2        | 14     |
| P3        | 3      |
| **Total** | **27** |
