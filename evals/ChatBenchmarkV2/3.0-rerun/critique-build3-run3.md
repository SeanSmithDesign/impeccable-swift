File: evals/ChatBenchmarkV2/ChatBenchmarkV2/Build3_ImpeccableSwift/Build3ChatConversationView.swift
Build: Build 3 -- impeccable-swift
Run: 3 of 3
Date: 2026-04-26
Judge: Sonnet 4.6 (critique-only, no detectors)

## Material

| #   | Finding                                                                                                                                                                                                                                                                       | Severity | Fix hint                                                                                                                                                     |
| --- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| 1   | `BubbleSurface` applies `.regularMaterial` to all message bubbles. Materials are for floating chrome (sheets, toolbars), not inline content surfaces. Sent tint `Color.accentColor.opacity(0.22)` layered over the material compounds the misuse and breaks in high-contrast. | P1       | Replace with a plain `.background(.primary.opacity(0.08))` for received and `.background(.tint.opacity(0.9))` for sent; reserve materials for chrome layers. |
| 2   | `linkCard` inside `LinkPreviewBubble` uses `.background(.regularMaterial)`. An embedded content card inside a bubble is not floating chrome.                                                                                                                                  | P1       | Use a plain tinted fill or system-grouped background color instead.                                                                                          |
| 3   | `ReplyThreadBubble` disclosure chip uses `.thinMaterial` Capsule. Inline content chip, not floating chrome.                                                                                                                                                                   | P2       | Use a plain filled background (`.fill(.secondary.opacity(0.15))`) for inline chips.                                                                          |

## Color

| #   | Finding                                                                                                                                                                                                          | Severity | Fix hint                                                                                                                                                      |
| --- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 4   | `SendButtonStyle` uses `.foregroundStyle(.white)`. Hardcoded white does not adapt to high-contrast or inverted color environments.                                                                               | P2       | Use `.foregroundStyle(.primary)` on a contrasting background, or confirm sufficient contrast via `UIColor.label` hierarchy.                                   |
| 5   | `linkCard` thumbnail uses `LinearGradient([.accentColor.opacity(0.35), .accentColor.opacity(0.14)])`. Opacity gradients over accentColor are fragile in high-contrast mode and may fall below contrast minimums. | P2       | Use full-opacity semantic colors with a `.colorScheme`-aware gradient, or skip the gradient in high-contrast via `@Environment(\.accessibilityHighContrast)`. |
| 6   | `PhotoBubble.photoSurface` uses the same `LinearGradient` pattern as the link card thumbnail. Same fragility in high-contrast.                                                                                   | P2       | Same fix as finding 5.                                                                                                                                        |
| 7   | `.foregroundStyle(.white)` on icons inside gradient thumbnails (`LinkPreviewBubble`, `PhotoBubble`). Hardcoded white.                                                                                            | P2       | Use `.foregroundStyle(.primary)` with a background that guarantees contrast, or check against high-contrast environments.                                     |

## Typography

| #   | Finding                                                                                                                               | Severity | Fix hint                                                                                                                  |
| --- | ------------------------------------------------------------------------------------------------------------------------------------- | -------- | ------------------------------------------------------------------------------------------------------------------------- |
| 8   | `PhotoBubble.photoSurface` uses `.font(.system(size: 56, weight: .semibold))`. Hardcoded point size does not scale with Dynamic Type. | P1       | Use a scaled font: `.font(.system(.largeTitle, design: .default, weight: .semibold))` or `@ScaledMetric` for icon sizing. |
| 9   | `ChatTitle` HStack uses `spacing: 10`. Off the 4pt scale (valid: 4, 8, 12, 16, 20, 24, 32, 44, 64).                                   | P2       | Change to `spacing: 8` or `spacing: 12`.                                                                                  |
| 10  | `ReplyThreadBubble` reply list `VStack` uses `spacing: 10`. Off the 4pt scale.                                                        | P2       | Change to `spacing: 8` or `spacing: 12`.                                                                                  |
| 11  | `LinkPreviewBubble`, `PhotoBubble`, `PDFAttachmentBubble`, `ReplyThreadBubble` outer VStack all use `spacing: 6`. Off the 4pt scale.  | P2       | Change to `spacing: 4` or `spacing: 8`.                                                                                   |
| 12  | `ReplyRow` VStack and `PDFAttachmentBubble` inner VStack use `spacing: 2`. Off the 4pt scale.                                         | P2       | Change to `spacing: 4`.                                                                                                   |

## Accessibility

| #   | Finding                                                                                                                                                                                         | Severity | Fix hint                                                                                                                                                                        |
| --- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 13  | No bubble view (except `ComposeBar`) reads `@Environment(\.accessibilityReduceTransparency)`. All `.regularMaterial` and `.thinMaterial` backgrounds ignore the reduce-transparency preference. | P1       | In every view using a material, add `@Environment(\.accessibilityReduceTransparency) var reduceTransparency` and substitute `.fill(.systemBackground)` or equivalent when true. |
| 14  | `ReplyThreadBubble.isExpanded` is `@State` (local). `LazyVStack` will recycle the view when scrolled off-screen, collapsing expanded threads silently.                                          | P1       | Lift expansion state into the message model or a parent `@StateObject` keyed by message ID.                                                                                     |
| 15  | `PDFAttachmentBubble` applies `.accessibilityAddTraits(.isButton)` with no `Button` wrapper or `onTapGesture`. The trait is false and misleads VoiceOver.                                       | P1       | Wrap the entire bubble content in a `Button` with a descriptive label, or remove the `.isButton` trait.                                                                         |
| 16  | `LinkPreviewBubble` linkCard has `.accessibilityHint("Opens the article")` but no `Button` or `onTapGesture`. False hint: VoiceOver announces an action that cannot be performed.               | P2       | Add a `Button` or `onTapGesture` to open the URL, or remove the misleading hint.                                                                                                |
| 17  | `PhotoBubble` has `.accessibilityHint("Opens the photo")` but no `Button` or gesture handler.                                                                                                   | P2       | Wrap in a `Button` that presents the full-screen photo, or remove the hint.                                                                                                     |
| 18  | `TextBubble` uses "Them" as the fallback sender name in the accessibility label. "Them" is ambiguous for VoiceOver users who cannot infer context from layout position.                         | P2       | Use the sender's actual name or a more descriptive fallback like "Unknown sender".                                                                                              |
| 19  | `DateHeader` outer HStack has no accessibility grouping. The `.isHeader` trait is applied only to the inner `Text`, leaving the HStack invisible to the accessibility tree as a landmark.       | P2       | Add `.accessibilityElement(children: .combine)` and `.accessibilityAddTraits(.isHeader)` on the outer HStack.                                                                   |

## Interaction

| #   | Finding                                                                                                                                             | Severity | Fix hint                                                                       |
| --- | --------------------------------------------------------------------------------------------------------------------------------------------------- | -------- | ------------------------------------------------------------------------------ |
| 20  | `ComposeBar` send button is `.frame(40, 40)`. Below the 44x44pt minimum tap target.                                                                 | P1       | Use `.frame(44, 44)` or add `.contentShape(Rectangle())` with a 44pt hit area. |
| 21  | `ComposeBar` attachment button is `.frame(40, 40)`. Same violation.                                                                                 | P1       | Same fix as finding 20.                                                        |
| 22  | `PhotoBubble` has no `Button` wrapper despite its accessibility hint implying interactivity. A non-interactive element is presented as interactive. | P1       | Wrap in a `Button` (see finding 17).                                           |
| 23  | `ReplyThreadBubble` disclosure chip uses `.frame(minHeight: 44)` but no `minWidth`. Short labels may produce a tap target under 44pt wide.          | P2       | Add `.frame(minWidth: 44, minHeight: 44)`.                                     |

## Composition

| #   | Finding                                                                                                                                                                                              | Severity | Fix hint                                                                                                                                                     |
| --- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| 24  | `MessageRow` uses `Spacer(minLength: 56)` as the only bubble width constraint. On a 1024pt iPad canvas, bubbles span ~912pt with no absolute cap. No `min(width * 0.75, 560)` or equivalent ceiling. | P2       | Add a `.frame(maxWidth: min(UIScreen.main.bounds.width * 0.75, 560))` on the bubble, or pass the geometry from a `GeometryReader` in the parent scroll view. |

## State Coverage

| #   | Finding                                                                                                                                                     | Severity | Fix hint                                                                                                                           |
| --- | ----------------------------------------------------------------------------------------------------------------------------------------------------------- | -------- | ---------------------------------------------------------------------------------------------------------------------------------- |
| 25  | No empty state when the message list is empty.                                                                                                              | P2       | Add a `ContentUnavailableView` (iOS 17+) when the messages array is empty.                                                         |
| 26  | No loading state while messages are being fetched.                                                                                                          | P2       | Add a `ProgressView` or skeleton placeholder during load.                                                                          |
| 27  | No error state for failed message fetch or send.                                                                                                            | P2       | Add an inline error banner or alert when an error condition is present.                                                            |
| 28  | `KeyboardOpenPreview` uses `Color.clear.frame(height: 291)` as a keyboard stub. Hardcoded height is device-specific and will be wrong on most screen sizes. | P3       | Use `@FocusState` with the real keyboard avoidance mechanism, or document the approximation clearly and accept it as preview-only. |

## Summary

| Severity  | Count  |
| --------- | ------ |
| P0        | 0      |
| P1        | 10     |
| P2        | 17     |
| P3        | 1      |
| **Total** | **28** |
