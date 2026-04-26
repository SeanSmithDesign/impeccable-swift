File: evals/ChatBenchmarkV2/ChatBenchmarkV2/Build1_Stock/Build1ChatConversationView.swift
Build: Build 1 -- Stock SwiftUI
Run: 2 of 3
Date: 2026-04-26
Judge: Sonnet 4.6 (critique-only, no detectors)

## Navigation

| #   | Finding                                                                                                                                                                   | Severity | Fix hint                                                                                        |
| --- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------- | ----------------------------------------------------------------------------------------------- |
| 1   | Root view is a bare `VStack` with `.navigationTitle("Alex")` but no `NavigationStack` ancestor. `.navigationTitle` has no effect without a `NavigationStack`.             | P0       | Wrap the root `VStack` in a `NavigationStack { }`.                                              |
| 2   | Compose bar pinned with `.padding(.bottom, 34)` hardcoded. Breaks on any device with a different bottom safe area (e.g. non-notch devices return 0, large phones differ). | P0       | Replace with `.safeAreaInset(edge: .bottom)` to pin the compose bar above the actual safe area. |
| 3   | `ScrollView` is missing `.scrollDismissesKeyboard(.interactively)`. Keyboard does not dismiss on scroll drag.                                                             | P1       | Add `.scrollDismissesKeyboard(.interactively)` to the `ScrollView`.                             |

## Color

| #   | Finding                                                                                                                               | Severity | Fix hint                                                                                                 |
| --- | ------------------------------------------------------------------------------------------------------------------------------------- | -------- | -------------------------------------------------------------------------------------------------------- |
| 4   | `Color.blue` used for outgoing bubble background and send button. Hardcoded system color, not adaptive, no Asset Catalog backing.     | P1       | Replace with a project token from the Asset Catalog (e.g. `Color("AccentBlue")`) or `Color.accentColor`. |
| 5   | `Color.gray` used for `foregroundColor` on timestamps and sender labels. Deprecated in SwiftUI.                                       | P1       | Replace with `.secondary` semantic color.                                                                |
| 6   | `Color.gray.opacity(0.1)` used as link preview inner background. Inline color with opacity, not a semantic token.                     | P1       | Replace with a named token or `.quaternarySystemFill`.                                                   |
| 7   | `.foregroundColor(.blue)` used for source label and reply button. Deprecated modifier.                                                | P2       | Replace with `.foregroundStyle(.blue)` and prefer an Asset Catalog token.                                |
| 8   | `.foregroundColor(.gray)` used throughout for secondary text. Deprecated modifier.                                                    | P2       | Replace with `.foregroundStyle(.secondary)`.                                                             |
| 9   | `.foregroundColor(.white)` hardcoded for outgoing bubble text. Fails dark mode contrast on `Color.blue` backgrounds on some displays. | P1       | Use `.foregroundStyle(.white)` and verify contrast against your resolved bubble color.                   |

## Material

| #   | Finding                                                                                                                                           | Severity | Fix hint                                                                     |
| --- | ------------------------------------------------------------------------------------------------------------------------------------------------- | -------- | ---------------------------------------------------------------------------- |
| 10  | Received message bubbles use plain `Color(.systemGray6)`. No material vocabulary applied.                                                         | P1       | Apply `.ultraThinMaterial` or `.regularMaterial` to received bubbles.        |
| 11  | Compose bar uses plain `Color(.systemBackground)` with no material. Missing `GlassEffectContainer` / `.glassEffect()` for Liquid Glass treatment. | P1       | Wrap the compose bar in a `GlassEffectContainer` and apply `.glassEffect()`. |
| 12  | Date header section dividers have no material backing and no visual separation from content.                                                      | P2       | Apply a subtle material or tinted background capsule behind the date label.  |

## Spacing

| #   | Finding                                                                                                                                                                  | Severity | Fix hint                                |
| --- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | -------- | --------------------------------------- |
| 13  | `VStack(alignment: .leading, spacing: 2)` used for bubble rows (lines 55, 68, 84, 113, 129, 148). `2` is not on the 4pt scale (valid: 4, 8, 12, 16, 20, 24, 32, 44, 64). | P2       | Replace `spacing: 2` with `spacing: 4`. |
| 14  | `VStack(alignment: .leading, spacing: 6)` used for reply list (line 153) and link preview inner card (line 89). `6` is not on the 4pt scale.                             | P2       | Replace `spacing: 6` with `spacing: 8`. |

## Typography

| #   | Finding                                                                                                | Severity | Fix hint                                                                         |
| --- | ------------------------------------------------------------------------------------------------------ | -------- | -------------------------------------------------------------------------------- |
| 15  | `timeText(_:)` uses `DateFormatter` with `.dateFormat = "h:mm a"`. Not localizable, not adaptive.      | P2       | Replace with `date.formatted(.dateTime.hour().minute())`.                        |
| 16  | `dateHeaderText(for:)` uses `DateFormatter.dateStyle = .medium`. Not a semantic format.                | P2       | Replace with `date.formatted(date: .abbreviated, time: .omitted)`.               |
| 17  | Timestamps rendered with `.font(.caption)` but no `.monospacedDigit()`. Digits jitter as time changes. | P2       | Append `.monospacedDigit()` to the timestamp font modifier.                      |
| 18  | Message body text has no explicit `.font(.body)` declaration. Relies on implicit default.              | P3       | Add `.font(.body)` to message body `Text` views for clarity and future-proofing. |

## Accessibility

| #   | Finding                                                                                                                                                                                                    | Severity | Fix hint                                                                                                                    |
| --- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------- | --------------------------------------------------------------------------------------------------------------------------- |
| 19  | Send `Button` has no `.accessibilityLabel`. VoiceOver will read "Send" from the `Text` child, but the button has no explicit label for context.                                                            | P0       | Add `.accessibilityLabel("Send message")` to the Send button.                                                               |
| 20  | Reply thread `Button` is only shown when thread is collapsed. When expanded, button disappears with no way to collapse. This violates user control: a control that opens a state must be able to close it. | P0       | Show the toggle button in both states, changing its label between "Show \(count) replies" and "Hide replies".               |
| 21  | No `.accessibilityLabel` on any message bubble content. Composite rows (sender name + body + timestamp) are not combined.                                                                                  | P1       | Add `.accessibilityElement(children: .combine)` to each bubble `VStack` so VoiceOver reads the full row as one element.     |
| 22  | Photo `Image` (line 118) has no `.accessibilityLabel` and is not marked `.accessibilityHidden(true)`.                                                                                                      | P1       | Add `.accessibilityLabel(attachment.accessibilityDescription)` or hide decorative images with `.accessibilityHidden(true)`. |
| 23  | PDF row (lines 123-135) has no `.accessibilityLabel` describing the file.                                                                                                                                  | P1       | Add `.accessibilityLabel("PDF: \(attachment.filename)")` to the row.                                                        |
| 24  | Link preview card has no combined accessibility element. Individual sub-labels are read separately.                                                                                                        | P1       | Add `.accessibilityElement(children: .combine)` to the link preview `VStack`.                                               |
| 25  | Decorative SF Symbol in link preview thumbnail (line 92) not marked `.accessibilityHidden(true)`.                                                                                                          | P2       | Add `.accessibilityHidden(true)` to the thumbnail `Image`.                                                                  |

## Interaction

| #   | Finding                                                                                                                                                       | Severity | Fix hint                                                                                       |
| --- | ------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------- | ---------------------------------------------------------------------------------------------- |
| 26  | Send button tap target is approximately 24pt wide + text width by ~34pt tall. Missing `.frame(minWidth: 44, minHeight: 44)` and `.contentShape(Rectangle())`. | P0       | Add `.frame(minWidth: 44, minHeight: 44)` and `.contentShape(Rectangle())` to the Send button. |
| 27  | Reply thread `Button` has no explicit frame or `contentShape`. Under 44pt tap target.                                                                         | P0       | Add `.frame(minHeight: 44)` and `.contentShape(Rectangle())` to the reply button.              |
| 28  | No `.sensoryFeedback` on send action.                                                                                                                         | P1       | Add `.sensoryFeedback(.impact, trigger: composeText)` or trigger feedback on send.             |
| 29  | No `@Environment(\.accessibilityReduceMotion)` guard. Any future animations will run unconditionally.                                                         | P1       | Read `@Environment(\.accessibilityReduceMotion)` and conditionalize animations.                |
| 30  | Thread expand/collapse has no animation. State change is abrupt.                                                                                              | P2       | Wrap the toggle in `withAnimation(.spring())`.                                                 |
| 31  | No `@FocusState` for compose `TextField`. Keyboard management is absent: no programmatic focus, no dismiss.                                                   | P1       | Add `@FocusState private var isComposeFocused: Bool` and bind it to the `TextField`.           |
| 32  | `TextField` uses `RoundedBorderTextFieldStyle()`. Web-era style, inconsistent with native iOS 26 appearance.                                                  | P2       | Remove explicit style or use a plain `TextField` inside a custom background shape.             |
| 33  | `TextField` missing `.submitLabel(.send)`. Return key shows default label.                                                                                    | P2       | Add `.submitLabel(.send)` to the compose `TextField`.                                          |
| 34  | `TextField` missing `.lineLimit(1...5)`. Input cannot grow for multi-line messages.                                                                           | P2       | Add `.lineLimit(1...5)` to allow multi-line input.                                             |

## Composition

| #   | Finding                                                                                                                                                     | Severity | Fix hint                                                                                                                     |
| --- | ----------------------------------------------------------------------------------------------------------------------------------------------------------- | -------- | ---------------------------------------------------------------------------------------------------------------------------- |
| 35  | `.cornerRadius(10)` used throughout without `.continuous` style. Produces non-continuous (circular arc) corners inconsistent with iOS 26 system components. | P1       | Replace `.cornerRadius(10)` with `.clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))` everywhere it appears. |
| 36  | Link preview thumbnail uses `.resizable()` + `.frame(width: 200, height: 100)` on an SF Symbol. SF Symbols must be sized with `.font()`, not frame-resized. | P1       | Remove `.resizable()` and `.frame`. Use `.font(.system(size: 64))` or similar to size the symbol.                            |
| 37  | Photo `Image` uses `.resizable()` + `.frame(width: 200, height: 150)`. Hardcoded frame is not adaptive to screen width or Dynamic Type.                     | P2       | Replace with `.resizable().scaledToFill().frame(maxWidth: .infinity).aspectRatio(4/3, contentMode: .fill)`.                  |
| 38  | No `@ScaledMetric` usage anywhere. Fixed padding and frame values do not scale with Dynamic Type.                                                           | P1       | Apply `@ScaledMetric` to spacing constants and bubble padding values.                                                        |
| 39  | PDF row shows no file size.                                                                                                                                 | P3       | Add `Text(attachment.formattedFileSize)` below the filename in the PDF row.                                                  |

## State Coverage

| #   | Finding                                                                            | Severity | Fix hint                                                                                     |
| --- | ---------------------------------------------------------------------------------- | -------- | -------------------------------------------------------------------------------------------- |
| 40  | No empty state when `messages` is empty. List shows nothing with no user guidance. | P2       | Add `ContentUnavailableView("No Messages", systemImage: "message")` when `messages.isEmpty`. |
| 41  | No loading state.                                                                  | P2       | Add a `@State private var isLoading: Bool` and show `ProgressView` while data loads.         |
| 42  | No error state.                                                                    | P2       | Add error state handling with a recovery action.                                             |
| 43  | Only one `#Preview` defined. No dark mode or Dynamic Type size variants.           | P3       | Add `#Preview("Dark") { ... .preferredColorScheme(.dark) }` and a large-text variant.        |

## Summary

| Severity  | Count  |
| --------- | ------ |
| P0        | 7      |
| P1        | 16     |
| P2        | 16     |
| P3        | 4      |
| **Total** | **43** |
