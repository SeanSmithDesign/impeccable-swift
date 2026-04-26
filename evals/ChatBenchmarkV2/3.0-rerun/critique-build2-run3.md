File: evals/ChatBenchmarkV2/ChatBenchmarkV2/Build2_WebImpeccable/Build2ChatConversationView.swift
Build: Build 2 -- Web Impeccable Port
Run: 3 of 3
Date: 2026-04-26
Judge: Sonnet 4.6 (critique-only, no detectors)

## Navigation

| #   | Finding                                                                                                                                            | Severity | Fix hint                                                                                                                              |
| --- | -------------------------------------------------------------------------------------------------------------------------------------------------- | -------- | ------------------------------------------------------------------------------------------------------------------------------------- |
| 1   | `MessageBubble.bubbleMaxWidth` uses `UIScreen.main.bounds.width * 0.75`: deprecated in iOS 16+, breaks multi-window, Split View, and Stage Manager | P0       | Use `GeometryReader` or a `containerRelativeFrame` approach instead                                                                   |
| 2   | Root view is a `VStack` with a custom `ConversationHeader`: no `NavigationStack`, losing system back gesture, keyboard avoidance, and toolbar APIs | P1       | Wrap in `NavigationStack` and use `.navigationTitle` / `.toolbar`                                                                     |
| 3   | `.background(Palette.background.ignoresSafeArea())` on root: cream background bleeds into safe areas uncontrolled                                  | P2       | Apply `.ignoresSafeArea()` only to the specific edges that require it, or use `.background(ignoresSafeAreaEdges: .all)` intentionally |

## Color

| #   | Finding                                                                                                                                    | Severity | Fix hint                                                                                              |
| --- | ------------------------------------------------------------------------------------------------------------------------------------------ | -------- | ----------------------------------------------------------------------------------------------------- |
| 4   | All 10 `Palette` entries are inline `Color(red:green:blue:)` literals: no Asset Catalog, no dark mode adaptation, no high-contrast support | P1       | Move all swatches to an Asset Catalog with Appearance variants                                        |
| 5   | No `reduceTransparency` handling anywhere: inline `Palette` colors are always used, ignoring the Accessibility setting                     | P1       | Check `accessibilityReduceTransparency` and substitute opaque fills for material/translucent surfaces |

## Material

| #   | Finding                                                                                                          | Severity | Fix hint                                                                               |
| --- | ---------------------------------------------------------------------------------------------------------------- | -------- | -------------------------------------------------------------------------------------- |
| 6   | `TextBubble` received: uses `.thinMaterial` fill on a content bubble, not floating chrome                        | P1       | Use a solid `Palette.surface` or `Palette.background`-derived fill for message bubbles |
| 7   | `LinkPreviewCard`: `.thinMaterial` fill on embedded content card                                                 | P1       | Replace with a solid surface color; material is for chrome that floats above content   |
| 8   | `PDFAttachmentCard`: `.thinMaterial` fill on an inline attachment row                                            | P1       | Replace with solid surface fill                                                        |
| 9   | No Liquid Glass usage (`GlassEffectContainer` / `.glassEffect()`) anywhere in the file despite targeting iOS 26+ | P1       | Evaluate appropriate surfaces (compose bar, header) for Liquid Glass adoption          |

## Typography

| #   | Finding                                                                                                                    | Severity | Fix hint                                                                            |
| --- | -------------------------------------------------------------------------------------------------------------------------- | -------- | ----------------------------------------------------------------------------------- |
| 10  | `.font(.system(size: 44, weight: .light))` in `LinkPreviewCard` thumbnail icon: hardcoded absolute size                    | P1       | Use a Dynamic Type step (e.g. `.font(.largeTitle)`) or `@ScaledMetric`              |
| 11  | `.font(.system(size: 64, weight: .light))` in `PhotoMessage` icon: hardcoded absolute size                                 | P1       | Use a Dynamic Type step or `@ScaledMetric`                                          |
| 12  | No `@ScaledMetric` usage anywhere in the file: all dimensional values are static `CGFloat` constants                       | P1       | Apply `@ScaledMetric` to spacing and size values that should grow with Dynamic Type |
| 13  | `DateFormatter` with `.dateFormat = "h:mm a"` in `MessageBubble.timestampText`: not locale-aware                           | P2       | Replace with `Date.formatted(.dateTime.hour().minute())`                            |
| 14  | `DateFormatter` with `.dateFormat = "EEEE, MMM d"` in `DateHeaderView.label`: not locale-aware                             | P2       | Replace with `Date.formatted(.dateTime.weekday(.wide).month(.abbreviated).day())`   |
| 15  | `DateFormatter` with `.dateFormat = "h:mm a"` in `ReplyThreadView.lastReplyTime`: not locale-aware                         | P2       | Replace with `Date.formatted(.dateTime.hour().minute())`                            |
| 16  | `DateFormatter` with `.dateFormat = "h:mm a"` in `ReplyRow.timestamp`: not locale-aware                                    | P2       | Replace with `Date.formatted(.dateTime.hour().minute())`                            |
| 17  | `.font(.system(size: size * 0.55))` in `Avatar`: computed hardcoded size with no scaling                                   | P2       | Use `@ScaledMetric` relative to a base size                                         |
| 18  | `VStack(spacing: 1)` in `ConversationHeader`: 1pt gap is off the 4pt scale                                                 | P2       | Use `Space.xs` (4pt) or 0                                                           |
| 19  | `spacing: 2` in `PDFAttachmentCard` and `ReplyRow` `VStack`: off the 4pt scale                                             | P2       | Use `Space.xs` (4pt) or 0                                                           |
| 20  | `.lineSpacing(2)` in `TextBubble` and `.lineSpacing(1.5)` in `ReplyRow`: off the 4pt scale                                 | P2       | Use multiples of 4pt or rely on Dynamic Type default leading                        |
| 21  | `ComposeField` uses `.frame(minHeight: 36)`: hardcoded height with no `@ScaledMetric`                                      | P2       | Wrap 36 with `@ScaledMetric(relativeTo: .body) var minHeight: CGFloat = 36`         |
| 22  | `Avatar` size 36pt used in `ConversationHeader`: 36 is not on the 4pt grid (valid steps: 4, 8, 12, 16, 20, 24, 32, 44, 64) | P2       | Change to 32pt or 40pt                                                              |

## Accessibility

| #   | Finding                                                                                                                     | Severity | Fix hint                                                                                                |
| --- | --------------------------------------------------------------------------------------------------------------------------- | -------- | ------------------------------------------------------------------------------------------------------- |
| 23  | `Back` button in `ConversationHeader`: `.frame(width: 32, height: 32)` is below the 44x44pt minimum tap target              | P1       | Expand hit area with `.contentShape(Rectangle().size(CGSize(width: 44, height: 44)))` or increase frame |
| 24  | `Info` button in `ConversationHeader`: `.frame(width: 32, height: 32)` is below minimum                                     | P1       | Same fix as back button                                                                                 |
| 25  | Download button in `PDFAttachmentCard`: `.frame(width: 32, height: 32)` is below minimum                                    | P1       | Expand to 44x44pt                                                                                       |
| 26  | Attachment button in `ComposeBar`: `.frame(width: 36, height: 36)` is below minimum                                         | P1       | Expand to 44x44pt                                                                                       |
| 27  | Send button in `ComposeBar`: `.frame(width: 36, height: 36)` is below minimum                                               | P1       | Expand to 44x44pt                                                                                       |
| 28  | Reply thread toggle button in `ReplyThreadView`: no explicit frame, relies on label padding alone                           | P1       | Add `.frame(minHeight: 44)` or confirm capsule height meets minimum                                     |
| 29  | `PhotoMessage` declares `.accessibilityHint("Double tap to expand")` on a non-interactive element: misleads VoiceOver users | P1       | Remove the hint or add a real tap action with `.onTapGesture` and `.accessibilityAddTraits(.isButton)`  |
| 30  | Timestamp `accessibilityLabel` in `MessageBubble` uses raw `DateFormatter` output ("Sent at h:mm a"): not localized         | P2       | Format using `Date.formatted()` with locale-aware style                                                 |

## Interaction

| #   | Finding                                                                                                                   | Severity | Fix hint                                                                  |
| --- | ------------------------------------------------------------------------------------------------------------------------- | -------- | ------------------------------------------------------------------------- |
| 31  | All animations use `.timingCurve` (cubic bezier): spring animations are preferred on iOS 26+ for physically-grounded feel | P2       | Replace with `.spring(duration:bounce:)` or `.interpolatingSpring`        |
| 32  | No `.sensoryFeedback` on send action: send tap has no haptic response                                                     | P1       | Add `.sensoryFeedback(.impact, trigger: sendTrigger)` to the send button  |
| 33  | Reply thread expand/collapse transition uses `.offset(y: -4)`: hardcoded non-scale value                                  | P2       | Use a spring transition without a fixed offset, or derive from `Space.xs` |

## State Coverage

| #   | Finding                                                                                       | Severity | Fix hint                                                               |
| --- | --------------------------------------------------------------------------------------------- | -------- | ---------------------------------------------------------------------- |
| 34  | No empty state: `Build2ChatConversationView` renders nothing visible when `messages` is empty | P2       | Add an empty-state placeholder with a prompt to start the conversation |
| 35  | No loading state: no skeleton or progress indicator while messages load                       | P2       | Add a `ProgressView` or skeleton cells during async fetch              |
| 36  | No error state: network or decode failures are silently swallowed                             | P2       | Surface an inline error banner or retry action                         |

## Composition

| #   | Finding                                                                | Severity | Fix hint                                                                                      |
| --- | ---------------------------------------------------------------------- | -------- | --------------------------------------------------------------------------------------------- |
| 37  | Only one `#Preview` defined with no dark-mode or Dynamic Type variants | P2       | Add `#Preview("Dark") { ... .preferredColorScheme(.dark) }` and an accessibility size variant |

## Summary

| Severity  | Count  |
| --------- | ------ |
| P0        | 1      |
| P1        | 19     |
| P2        | 17     |
| P3        | 0      |
| **Total** | **37** |
