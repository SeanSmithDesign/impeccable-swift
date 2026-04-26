File: evals/ChatBenchmarkV2/ChatBenchmarkV2/Build1_Stock/Build1ChatConversationView.swift
Build: Build 1 -- Stock SwiftUI
Run: 3 of 3
Date: 2026-04-26
Judge: Sonnet 4.6 (critique-only, no detectors)

## Navigation

| #   | Finding                                                                                                                                           | Severity | Fix hint                                                                  |
| --- | ------------------------------------------------------------------------------------------------------------------------------------------------- | -------- | ------------------------------------------------------------------------- |
| 1   | `.navigationTitle("Alex")` has no effect: `Build1ChatConversationView` is not hosted inside a `NavigationStack`, so the title is silently dropped | P0       | Wrap the call site in `NavigationStack` or add one internally for preview |
| 2   | Compose bar uses `.padding(.bottom, 34)` hardcoded safe area assumption: breaks on devices with different home indicator heights                  | P0       | Remove the magic constant; use `.safeAreaInset(edge: .bottom)` instead    |
| 3   | No `.scrollDismissesKeyboard(.interactively)` on the `ScrollView`: keyboard stays pinned when user scrolls up                                     | P1       | Add `.scrollDismissesKeyboard(.interactively)` to the `ScrollView`        |

## Color

| #   | Finding                                                                                                                                                                                                 | Severity | Fix hint                                                           |
| --- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------- | ------------------------------------------------------------------ |
| 4   | `Color.blue` hardcoded in sent bubble, compose Send button, and PDF bubble: not Asset Catalog, not adaptive to dark mode or high-contrast                                                               | P1       | Replace with a named Asset Catalog color or `Color.accentColor`    |
| 5   | `Color.gray` hardcoded in caption labels and date header: deprecated semantic alias; loses adaptive behavior                                                                                            | P1       | Replace with `.secondary` (foreground) or `Color(.secondaryLabel)` |
| 6   | `Color.gray.opacity(0.1)` inline in link preview card background                                                                                                                                        | P1       | Replace with a named Asset Catalog color or a system material      |
| 7   | `.foregroundColor(.blue)`, `.foregroundColor(.gray)`, and `.foregroundColor(.white)` used throughout: `.foregroundColor` is deprecated in favor of `.foregroundStyle` (3 distinct call sites clustered) | P2       | Replace all with `.foregroundStyle(...)`                           |

## Material

| #   | Finding                                                                                                                 | Severity | Fix hint                                                                               |
| --- | ----------------------------------------------------------------------------------------------------------------------- | -------- | -------------------------------------------------------------------------------------- |
| 8   | All message bubbles use `Color(.systemGray6)`: no platform material vocabulary, no adaptive translucency                | P1       | Use `.ultraThinMaterial` or a custom shape-fill with `Material` for received bubbles   |
| 9   | Compose bar has no Liquid Glass treatment: plain `Color(.systemBackground)` background on `HStack`                      | P1       | Apply `.background(.regularMaterial)` or a Liquid Glass surface behind the compose row |
| 10  | Date header has no material backing: it floats over scroll content with no visual separation, unsuitable for sticky use | P2       | Apply a material capsule background behind the date label                              |

## Typography

| #   | Finding                                                                                                          | Severity | Fix hint                                                          |
| --- | ---------------------------------------------------------------------------------------------------------------- | -------- | ----------------------------------------------------------------- |
| 11  | `DateFormatter` with `.dateFormat = "h:mm a"` in `timeText(_:)`: not localized, ignores locale 12/24h preference | P2       | Replace with `date.formatted(date: .omitted, time: .shortened)`   |
| 12  | `DateFormatter` with `.dateStyle = .medium` in `dateHeaderText(for:)`: not using `.formatted()` API              | P2       | Replace with `date.formatted(date: .abbreviated, time: .omitted)` |
| 13  | Timestamps have no `.monospacedDigit()` modifier: digits shift width as time changes                             | P2       | Add `.monospacedDigit()` to all timestamp `Text` views            |
| 14  | `VStack(alignment: .leading, spacing: 2)` used in received bubble rows: 2pt is off the 4pt grid                  | P2       | Change to `spacing: 4`                                            |
| 15  | `VStack(alignment: .leading, spacing: 6)` used in reply thread and link preview: 6pt is off the 4pt grid         | P2       | Change to `spacing: 8`                                            |
| 16  | No `@ScaledMetric` for bubble padding constants (12, 8, 10): values do not scale with Dynamic Type               | P1       | Declare padding and radius constants with `@ScaledMetric`         |

## Accessibility

| #   | Finding                                                                                                                                            | Severity | Fix hint                                                                                     |
| --- | -------------------------------------------------------------------------------------------------------------------------------------------------- | -------- | -------------------------------------------------------------------------------------------- |
| 17  | Send button has no `.accessibilityLabel`: VoiceOver reads the button text "Send" but not its action context; more critically, no label is declared | P0       | Add `.accessibilityLabel("Send message")`                                                    |
| 18  | No `.accessibilityElement(children: .combine)` on composite bubble rows: VoiceOver steps through each sub-view individually                        | P1       | Wrap each bubble case in `.accessibilityElement(children: .combine)`                         |
| 19  | Photo bubble (`case .photo`): no `.accessibilityLabel`, not marked `.accessibilityHidden(true)`                                                    | P1       | Add `.accessibilityLabel(attachment.accessibilityDescription ?? "Photo")` or mark decorative |
| 20  | PDF bubble (`case .pdfAttachment`): no `.accessibilityLabel` on the attachment HStack                                                              | P1       | Add `.accessibilityLabel("PDF: \(attachment.filename)")`                                     |
| 21  | Reply thread bubble (`case .replyThreadRoot`): no `.accessibilityElement` or `.accessibilityLabel` on the bubble container                         | P1       | Combine the element and label with sender name plus reply count                              |

## Interaction

| #   | Finding                                                                                                                                                                  | Severity | Fix hint                                                                                                             |
| --- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | -------- | -------------------------------------------------------------------------------------------------------------------- |
| 22  | Reply thread `Button` only renders in the `else` branch: when expanded, there is no affordance to collapse the thread; user is permanently trapped in the expanded state | P0       | Move the button outside the `if/else` so it toggles both expand and collapse                                         |
| 23  | Send button has no `.frame(minWidth: 44, minHeight: 44)` and no `.contentShape(Rectangle())`: estimated height is ~34pt, below the 44pt minimum tap target               | P0       | Add `.frame(minWidth: 44, minHeight: 44)` and `.contentShape(Rectangle())`                                           |
| 24  | Reply thread `Button("\(thread.replies.count) replies")` has no minimum frame or contentShape: estimated height ~30pt, below 44pt minimum                                | P0       | Add `.frame(minHeight: 44)` and `.contentShape(Rectangle())`                                                         |
| 25  | No `.sensoryFeedback` on send or thread expand actions                                                                                                                   | P1       | Add `.sensoryFeedback(.impact, trigger: ...)` to both interactions                                                   |
| 26  | No `@Environment(\.accessibilityReduceMotion)` check anywhere in the file                                                                                                | P1       | Gate any future animations on `reduceMotion`                                                                         |
| 27  | No animation on thread expand/collapse: content snaps in with no transition                                                                                              | P2       | Add `.animation(.spring(), value: expandedThreads)` and a `.transition(.opacity.combined(with: .move(edge: .top)))`  |
| 28  | No `@FocusState` on the compose `TextField`: keyboard cannot be dismissed programmatically                                                                               | P1       | Add `@FocusState private var isComposeFocused: Bool` and wire it                                                     |
| 29  | `RoundedBorderTextFieldStyle` used in compose bar: legacy style that does not match platform conventions                                                                 | P2       | Replace with a custom styled field using `.background(.ultraThinMaterial)` and a continuous rounded rectangle stroke |
| 30  | No `.submitLabel(.send)` on the compose `TextField`                                                                                                                      | P2       | Add `.submitLabel(.send)`                                                                                            |
| 31  | No `.lineLimit(1...5)` on the compose `TextField`                                                                                                                        | P2       | Add `.lineLimit(1...5)` to allow multi-line expansion                                                                |

## Composition

| #   | Finding                                                                                                                                                                                              | Severity | Fix hint                                                                                  |
| --- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------- | ----------------------------------------------------------------------------------------- |
| 32  | `.cornerRadius(10)` used on all bubbles (sent bubble, received bubble, link card, photo, PDF, reply thread) without `style: .continuous`: produces mismatched corner curves versus system components | P1       | Replace each with `.clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))`    |
| 33  | SF Symbol used in link preview with `.resizable().scaledToFit().frame(width: 200, height: 100)`: SF Symbols should not be resized with `.resizable()`; this produces distorted rendering             | P1       | Use `.font(.system(size: 64))` or `.imageScale(.large)` instead of `.resizable()`         |
| 34  | Photo bubble uses `.resizable().frame(width: 200, height: 150)` hardcoded frame: not adaptive to device width                                                                                        | P2       | Use `.resizable().scaledToFill().frame(maxWidth: .infinity).clipped()` inside a container |

## State Coverage

| #   | Finding                                                                                                      | Severity | Fix hint                                                                                      |
| --- | ------------------------------------------------------------------------------------------------------------ | -------- | --------------------------------------------------------------------------------------------- |
| 35  | No empty state: when `messages` is empty the view shows a blank scroll area with no feedback                 | P2       | Add a centered placeholder view when `messages.isEmpty`                                       |
| 36  | No loading state: data is assumed immediately available via `SampleData` with no provision for async loading | P2       | Add a `@State private var isLoading: Bool` path with a `ProgressView`                         |
| 37  | No error state: no mechanism to show fetch or send failures to the user                                      | P2       | Add an error binding or `@State private var errorMessage: String?` with an alert              |
| 38  | Single `#Preview` with no dark mode or Dynamic Type size variants                                            | P3       | Add `#Preview("Dark") { ... .preferredColorScheme(.dark) }` and an accessibility size variant |
| 39  | PDF bubble shows no file size: user cannot gauge download cost                                               | P3       | Add a file size string beneath the filename in the PDF bubble                                 |

## Summary

| Severity  | Count  |
| --------- | ------ |
| P0        | 6      |
| P1        | 14     |
| P2        | 15     |
| P3        | 4      |
| **Total** | **39** |
