File: evals/ChatBenchmarkV2/ChatBenchmarkV2/Build4_FullSetup/Build4ChatConversationView.swift
Build: Build 4 -- Full Setup (+DM)
Run: 2 of 3
Date: 2026-04-26
Judge: Sonnet 4.6 (critique-only, no detectors)

## Color

| #   | Finding                                                                                                                                                              | Severity | Fix hint                                                                                                                               |
| --- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------- | -------------------------------------------------------------------------------------------------------------------------------------- |
| 1   | `chatAccent` defined as an inline `Color(red:green:blue:)` literal, not an Asset Catalog Color Set. Does not adapt to dark mode, high-contrast, or dynamic contexts. | P1       | Move to an Asset Catalog Color Set with light/dark/high-contrast variants; reference via `Color("ChatAccent")`.                        |
| 2   | `TextBubble`: `Color.white` hardcoded as foreground for sent messages. Does not adapt to high-contrast mode or alternate color schemes.                              | P2       | Use `Color.white.adaptingForAccessibility()` or a semantic white variant; at minimum test against `.accessibilityHighContrast` scheme. |

## Material

| #   | Finding                                                                                                                                                      | Severity | Fix hint                                                                                                                                           |
| --- | ------------------------------------------------------------------------------------------------------------------------------------------------------------ | -------- | -------------------------------------------------------------------------------------------------------------------------------------------------- |
| 1   | `PhotoBubble`: `Material.ultraThinMaterial` used as content area fill. `.ultraThinMaterial` is reserved for floating chrome overlays, not embedded content.  | P1       | Use `Color(.secondarySystemBackground)` or `Material.regularMaterial` only if a floating-chrome read is intended; prefer a solid fill for content. |
| 2   | `LinkPreviewCard`: `Material.ultraThinMaterial` used as card background. Embedded content card is not floating chrome.                                       | P1       | Replace with `Color(.tertiarySystemBackground)` for the non-reduce-transparency path.                                                              |
| 3   | `PDFBubble`: `Material.regularMaterial` used as bubble background. Content bubble is not floating chrome.                                                    | P1       | Replace with `Color(.secondarySystemBackground)`.                                                                                                  |
| 4   | `bubbleSurface`: `Material.regularMaterial` used for received `TextBubble` background. Content bubble is not floating chrome.                                | P1       | Replace with `Color(.secondarySystemBackground)`.                                                                                                  |
| 5   | `ReplyBubbleRow`: `Material.thinMaterial` used as inline reply card background. Inline content is not floating chrome.                                       | P1       | Replace with `Color(.secondarySystemBackground)`.                                                                                                  |
| 6   | `ReplyThreadBubble` chip button Capsule: `Material.thinMaterial` used for an inline chip. Borderline case; chip is embedded in content, not floating chrome. | P2       | Replace with `Color(.secondarySystemBackground)` for consistency; reserve materials for chrome layers.                                             |

## Typography

| #   | Finding                                                                                               | Severity | Fix hint                                                                                                                        |
| --- | ----------------------------------------------------------------------------------------------------- | -------- | ------------------------------------------------------------------------------------------------------------------------------- |
| 1   | `PhotoBubble`: `.font(.system(size: 72))` hardcodes SF Symbol size. Does not scale with Dynamic Type. | P1       | Use `@ScaledMetric(relativeTo: .largeTitle) private var symbolSize: CGFloat = 72` and apply `.font(.system(size: symbolSize))`. |
| 2   | `bubbleColumn` VStack: `spacing: 2` is not on the 4pt grid.                                           | P2       | Use `spacing: 4`.                                                                                                               |
| 3   | `ReplyBubbleRow` inner VStack: `spacing: 2` is not on the 4pt grid.                                   | P2       | Use `spacing: 4`.                                                                                                               |
| 4   | `ReplyThreadBubble` VStack: `spacing: 6` is not on the 4pt grid.                                      | P2       | Use `spacing: 8`.                                                                                                               |
| 5   | `ReplyBubbleRow` outer VStack: `spacing: 6` is not on the 4pt grid.                                   | P2       | Use `spacing: 8`.                                                                                                               |
| 6   | Sender name text: `.padding(.leading, 2)` is not on the 4pt grid.                                     | P2       | Use `.padding(.leading, 4)` or remove if not visually needed.                                                                   |
| 7   | Timestamp text: `.padding(.horizontal, 2)` and `.padding(.top, 2)` are not on the 4pt grid.           | P2       | Use `.padding(.horizontal, 4)` and `.padding(.top, 4)`.                                                                         |
| 8   | `ReplyBubbleRow`: `.padding(.horizontal, 10)` is not on the 4pt grid.                                 | P2       | Use `.padding(.horizontal, 12)`.                                                                                                |
| 9   | `ReplyBubbleRow`: `.padding(.vertical, 6)` is not on the 4pt grid.                                    | P2       | Use `.padding(.vertical, 8)`.                                                                                                   |

## Accessibility

| #   | Finding                                                                                                                                                                            | Severity | Fix hint                                                                                                                                                         |
| --- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 1   | `bubbleColumn`: Timestamps marked `.accessibilityHidden(true)`. VoiceOver users cannot determine when messages were sent.                                                          | P1       | Remove `accessibilityHidden` from timestamps; include time in the parent container's `.accessibilityLabel` or expose timestamp as a separate accessible element. |
| 2   | `bubbleColumn`: Sender name marked `.accessibilityHidden(true)`. In group chats, VoiceOver users cannot determine who sent a message.                                              | P1       | Remove `accessibilityHidden` from sender name; include sender identity in the bubble's `.accessibilityLabel`.                                                    |
| 3   | `PhotoBubble`: No `.contentShape(...)` modifier. Tap target area may be clipped to visible label bounds without an explicit hit test shape.                                        | P2       | Add `.contentShape(Rectangle())` after `buttonStyle`.                                                                                                            |
| 4   | `PDFBubble`: No explicit `.frame(minWidth: 44, minHeight: 44)` constraint. At small Dynamic Type sizes, vertical padding of 12pt on each side may yield a total height below 44pt. | P2       | Add `.frame(minHeight: 44)` to ensure minimum tap target.                                                                                                        |

## Composition

| #   | Finding                                                                                                                                                                                                               | Severity | Fix hint                                                                                                                                |
| --- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------- | --------------------------------------------------------------------------------------------------------------------------------------- |
| 1   | `LinkPreviewCard`: Concentric corner radius violation. Outer card uses `cornerRadius: 14` with `padding: 12`. Inner thumbnail uses `cornerRadius: 10`. Expected inner corner: 14 - 12 = 2, not 10.                    | P1       | Set thumbnail `cornerRadius` to `max(0, 14 - 12)` = 2, or adjust padding so inner radius matches `outerRadius - padding`.               |
| 2   | `ReplyThreadBubble` chip button: `.contentShape(Capsule())` with `.frame(minHeight: 44)` only constrains height. Short chip labels ("1 reply") may produce a tappable width below 44pt on the Capsule hit test shape. | P2       | Add `.frame(minWidth: 44)` alongside `minHeight`, or use `.contentShape(Rectangle())` with a minimum width to guarantee the tap target. |

## State Coverage

| #   | Finding                                                                                                                              | Severity | Fix hint                                                                                              |
| --- | ------------------------------------------------------------------------------------------------------------------------------------ | -------- | ----------------------------------------------------------------------------------------------------- |
| 1   | No empty state: when `messages` contains no sections, the scroll view renders blank with no `ContentUnavailableView` or placeholder. | P2       | Add a `ContentUnavailableView("No Messages", systemImage: "message")` branch when `sections.isEmpty`. |
| 2   | No loading state: no spinner or skeleton for in-flight message fetches.                                                              | P2       | Add a loading phase to the view model and show `ProgressView` centered in the scroll area.            |
| 3   | No error state: no indication if message loading fails.                                                                              | P2       | Add an error phase and surface a retry affordance via `ContentUnavailableView`.                       |

## Summary

| Severity  | Count  |
| --------- | ------ |
| P0        | 0      |
| P1        | 10     |
| P2        | 14     |
| P3        | 0      |
| **Total** | **24** |
