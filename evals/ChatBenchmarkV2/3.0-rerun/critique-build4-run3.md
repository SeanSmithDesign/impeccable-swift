File: evals/ChatBenchmarkV2/ChatBenchmarkV2/Build4_FullSetup/Build4ChatConversationView.swift
Build: Build 4 -- Full Setup (+DM)
Run: 3 of 3
Date: 2026-04-26
Judge: Sonnet 4.6 (critique-only, no detectors)

## Color

| #   | Finding                                                                                         | Severity | Fix hint                                                                                                               |
| --- | ----------------------------------------------------------------------------------------------- | -------- | ---------------------------------------------------------------------------------------------------------------------- |
| 1   | `chatAccent` defined as inline `Color(red:green:blue:)` literal, not an Asset Catalog Color Set | P1       | Move to `Assets.xcassets` as a Color Set; reference via `Color("ChatAccent")` or a typed extension                     |
| 2   | `TextBubble` sent foreground uses `Color.white` hardcoded, not an adaptive semantic color       | P2       | Use `.white` only when the bubble background is guaranteed dark; prefer a semantic color or check contrast dynamically |

## Material

| #   | Finding                                                                                             | Severity | Fix hint                                                                                                                                                        |
| --- | --------------------------------------------------------------------------------------------------- | -------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 3   | Received `TextBubble` uses `Material.regularMaterial` as bubble fill for a content surface          | P1       | Content bubbles should use a solid adaptive fill (e.g., `Color(.secondarySystemBackground)` when reduce-transparency is off, or the same solid fallback always) |
| 4   | `LinkPreviewCard` uses `Material.ultraThinMaterial` as background fill for an embedded content card | P1       | Prefer `ultraThinMaterial` only for chrome overlays; use a slightly opaque fill (e.g., `thinMaterial` or a solid tertiary surface) for embedded cards           |
| 5   | `PhotoBubble` uses `Material.ultraThinMaterial` as a content bubble surface                         | P1       | Match the received `TextBubble` material level or use a solid surface; `ultraThinMaterial` is too transparent for a primary content container                   |
| 6   | `PDFBubble` uses `Material.regularMaterial` as a content bubble surface                             | P1       | Consistent with received `TextBubble` but reconsider: content bubbles should use solid fills, not materials                                                     |
| 7   | `ReplyBubbleRow` uses `Material.thinMaterial` for an inline reply content row                       | P1       | Inline reply content rows are content, not chrome; use a solid fill matching the nesting context                                                                |
| 8   | `ReplyThreadBubble` chip button uses `Material.thinMaterial` as the Capsule fill                    | P2       | An inline interactive chip should use a solid or lightly tinted fill; `thinMaterial` introduces unnecessary blur layering                                       |

## Typography

| #   | Finding                                                               | Severity | Fix hint                                                                                                                                |
| --- | --------------------------------------------------------------------- | -------- | --------------------------------------------------------------------------------------------------------------------------------------- |
| 9   | `PhotoBubble` uses `.font(.system(size: 72))` hardcoded point size    | P1       | Use a scaled font: `.font(.system(size: 72)).dynamicTypeSize(...limit...)` or replace with an SF Symbol image scaled with `.imageScale` |
| 10  | `bubbleColumn` VStack uses `spacing: 2`, off the 4pt scale            | P2       | Use `spacing: 4` minimum                                                                                                                |
| 11  | `ReplyThreadBubble` outer VStack uses `spacing: 6`, off the 4pt scale | P2       | Use `spacing: 8`                                                                                                                        |
| 12  | `ReplyBubbleRow` inner VStack uses `spacing: 2`, off the 4pt scale    | P2       | Use `spacing: 4` minimum                                                                                                                |
| 13  | `ReplyBubbleRow` inner HStack uses `spacing: 6`, off the 4pt scale    | P2       | Use `spacing: 8`                                                                                                                        |
| 14  | Sender name label uses `.padding(.leading, 2)`, off the 4pt scale     | P2       | Use `.padding(.leading, 4)`                                                                                                             |
| 15  | Timestamp uses `.padding(.horizontal, 2)`, off the 4pt scale          | P2       | Use `.padding(.horizontal, 4)`                                                                                                          |
| 16  | Timestamp uses `.padding(.top, 2)`, off the 4pt scale                 | P2       | Use `.padding(.top, 4)`                                                                                                                 |
| 17  | `ReplyBubbleRow` uses `.padding(.horizontal, 10)`, off the 4pt scale  | P2       | Use `.padding(.horizontal, 12)`                                                                                                         |
| 18  | `ReplyBubbleRow` uses `.padding(.vertical, 6)`, off the 4pt scale     | P2       | Use `.padding(.vertical, 8)`                                                                                                            |

## Composition

| #   | Finding                                                                                                                         | Severity | Fix hint                                                                                                                                                                                 |
| --- | ------------------------------------------------------------------------------------------------------------------------------- | -------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 19  | `LinkPreviewCard` concentric corner violation: outer radius 14, padding 12, thumbnail inner radius 10; expected inner radius ~2 | P1       | Apply the concentric corner formula: inner radius = outer radius minus inset padding (14 - 12 = 2); set thumbnail `clipShape` to `RoundedRectangle(cornerRadius: 2, style: .continuous)` |

## Accessibility

| #   | Finding                                                                                                                                    | Severity | Fix hint                                                                                                                                                                                                      |
| --- | ------------------------------------------------------------------------------------------------------------------------------------------ | -------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 20  | Timestamp views are marked `.accessibilityHidden(true)` across `bubbleColumn`; VoiceOver users cannot know when messages were sent         | P1       | Remove `.accessibilityHidden(true)` from timestamps; combine with the message text in a single `.accessibilityElement(children: .combine)` group, or expose via `.accessibilityLabel` on the bubble container |
| 21  | Sender name labels are marked `.accessibilityHidden(true)` in `bubbleColumn`; VoiceOver cannot identify the sender in a group conversation | P1       | Incorporate sender name into the bubble container's `.accessibilityLabel` so VoiceOver reads "Alice: Hello, 2:34 PM" rather than omitting both                                                                |

## State Coverage

| #   | Finding                                                                                             | Severity | Fix hint                                                                                                               |
| --- | --------------------------------------------------------------------------------------------------- | -------- | ---------------------------------------------------------------------------------------------------------------------- |
| 22  | No empty state: when a section has no messages, there is no `ContentUnavailableView` or placeholder | P2       | Add a `ContentUnavailableView` (or equivalent) guarding the `LazyVStack` when the section's message array is empty     |
| 23  | No loading state: the view has no in-progress indicator while messages are being fetched            | P2       | Add a `ProgressView` or skeleton placeholder that shows while the message list is loading                              |
| 24  | No error state: the view has no feedback path for failed message fetch or send errors               | P2       | Add an error banner or alert driven by an `errorMessage: String?` binding, shown in the `.safeAreaInset` or as a sheet |

## Summary

| Severity  | Count  |
| --------- | ------ |
| P0        | 0      |
| P1        | 10     |
| P2        | 13     |
| P3        | 0      |
| **Total** | **23** |
