# Interaction Design

Every interactive view in a SwiftUI app must communicate its state back to the user — the state surface shifts by platform, but the contract is non-negotiable.

## The State Surface Shifts Per Platform

**Declare: design the state surface per input context, not per device.** iPhone touch has no hover and no focus ring until a hardware keyboard or AssistiveTouch attaches. iPad and Mac with a pointer have real hover. Any platform with keyboard navigation has real focus.

**Why:** A single "button style" that ignores this matrix will silently break for pointer users on iPad, keyboard users on iPhone, and Voice Control users everywhere. Each input method is a first-class customer.

**Rule:** every interactive view must cover `default`, `pressed`, `disabled`, and (where applicable) `hover`, `focus`, `loading`, `error`, and `empty`. Don't skip `pressed` because "the system handles it" — the default `Button` label styling barely registers as a tap confirmation in custom designs.

**Anti-pattern — "The Silent Button":** a tap with no visible pressed change, no haptic, no label transition on submit. The user taps twice because they don't trust the first tap landed.

## Pressed State Is Mandatory, Not Optional

**Declare: every custom button ships its own `ButtonStyle` with a visible pressed treatment.** The default system styling is for system-tinted buttons only; the moment you add a background or border, you own the pressed state.

**Why:** `configuration.isPressed` is the only reliable signal that a finger or pointer is currently committing to the action. Without a visible response, users don't know the UI received their touch — latency on the network or a slow view update becomes indistinguishable from a dead button.

```swift
struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.body.weight(.semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.accentColor)
                    .opacity(configuration.isPressed ? 0.7 : 1.0)
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}
```

**Rule:** the pressed treatment must change at least two of: opacity, scale, background fill, or elevation. A 3% opacity shift alone is not visible.

## Hover Belongs to Pointer Contexts Only

**Declare: wire `.onHover` on any control that appears on macOS, iPad with pointer, or Vision Pro.** Never rely on hover to _reveal_ functionality — hover is for affordance, not for discovery.

**Why:** iPhone users can't hover. If a delete button only appears on hover, it does not exist on iPhone. Hover is an enhancement for pointer users, never a gate for core actions.

```swift
struct HoverableCard: View {
    @State private var isHovered = false

    var body: some View {
        content
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.secondarySystemBackground))
                    .shadow(
                        color: .black.opacity(isHovered ? 0.12 : 0.04),
                        radius: isHovered ? 12 : 4,
                        y: isHovered ? 4 : 1
                    )
            )
            .onHover { hovering in
                withAnimation(.easeOut(duration: 0.15)) {
                    isHovered = hovering
                }
            }
    }
}
```

## Focus Is Required for Keyboard and Assistive Tech

**Declare: every destination in a form or list has an explicit `@FocusState` binding.** The system draws a default focus effect automatically — never strip it without providing an equivalent custom one.

**Why:** Keyboard users on iPad and Mac tab through your UI. Full Keyboard Access users on iPhone do the same. A missing focus ring is an accessibility violation and a Review rejection risk.

```swift
struct SignInForm: View {
    enum Field { case email, password }
    @FocusState private var focus: Field?
    @State private var email = ""
    @State private var password = ""

    var body: some View {
        Form {
            TextField("Email", text: $email)
                .textContentType(.emailAddress)
                .focused($focus, equals: .email)
                .submitLabel(.next)
                .onSubmit { focus = .password }

            SecureField("Password", text: $password)
                .textContentType(.password)
                .focused($focus, equals: .password)
                .submitLabel(.go)
                .onSubmit { submit() }
        }
    }
}
```

**Rule:** if you write a custom `ButtonStyle`, preserve focus feedback with `.focusEffect` or draw your own ring via `configuration.isFocused` (on controls that expose it). A filled `Color.accentColor` outline at 2pt is the baseline.

**Anti-pattern — "The Forgotten Focus Ring":** a custom `ButtonStyle` that looks beautiful on iPhone touch and completely disappears for a keyboard user tabbing through a form. The button still works, but the user has no idea which control will fire on Return.

## Disabled Must Stay Legible

**Declare: use `.disabled(true)` and let SwiftUI reduce the control automatically.** Don't hand-roll 40% opacity on top — you'll stack it with the system's own reduction and the text will fall below WCAG contrast.

**Why:** SwiftUI already dims disabled controls. Manual dimming double-applies, hurts legibility, and often paints over Dynamic Type adjustments.

```swift
Button("Continue", action: submit)
    .buttonStyle(PrimaryButtonStyle())
    .disabled(email.isEmpty || password.isEmpty)
```

**Rule:** if disabled state needs more emphasis (e.g. "Subscribe" when already subscribed), swap the label and the style — don't just gray out the original.

## Loading Has a Timeout and a Cancel Path

**Declare: any loading state longer than 300ms shows a `ProgressView`; any longer than 10 seconds offers a cancel affordance.** Replace the button's label with the spinner in place — don't stack the spinner beside the label.

**Why:** An indefinite spinner with no escape is the classic "perpetual spinner" bug. The user either force-quits or assumes the app is broken. Loading is a contract; a contract has a timeout.

```swift
struct SubmitButton: View {
    @State private var isSubmitting = false
    let action: () async throws -> Void

    var body: some View {
        Button {
            Task {
                isSubmitting = true
                defer { isSubmitting = false }
                try await action()
            }
        } label: {
            ZStack {
                Text("Submit").opacity(isSubmitting ? 0 : 1)
                if isSubmitting {
                    ProgressView().controlSize(.small).tint(.white)
                }
            }
            .frame(minWidth: 88)
        }
        .buttonStyle(PrimaryButtonStyle())
        .disabled(isSubmitting)
    }
}
```

**Anti-pattern — "The Perpetual Spinner":** a loading state with no timeout, no cancel button, and no error transition. The network silently failed and the UI will spin until the app is killed.

## Empty States Are a Required View

**Declare: every list, grid, and search result view must render `ContentUnavailableView` when the collection is empty.** Empty is a state, not a gap.

**Why:** An empty scroll view looks like a broken screen. `ContentUnavailableView` gives users an explanation, an illustration, and an action — the three things a user needs to either understand or recover.

```swift
struct InboxView: View {
    let messages: [Message]
    let query: String

    var body: some View {
        Group {
            if messages.isEmpty && query.isEmpty {
                ContentUnavailableView(
                    "Inbox Zero",
                    systemImage: "tray",
                    description: Text("New messages will appear here.")
                )
            } else if messages.isEmpty {
                ContentUnavailableView.search(text: query)
            } else {
                List(messages) { MessageRow(message: $0) }
            }
        }
    }
}
```

## Errors Deserve a Dedicated Treatment

**Declare: pair every error with a human sentence, a recovery action, and semantic color from the Asset Catalog.** Never surface raw `NSError` descriptions to the user.

**Why:** "The operation couldn't be completed. (NSURLErrorDomain error -1009.)" teaches the user nothing. An error is an opportunity to tell the user what happened and what to do next.

```swift
struct FormField: View {
    let title: String
    @Binding var text: String
    let error: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            TextField(title, text: $text)
                .textFieldStyle(.roundedBorder)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(error == nil ? .clear : Color("ErrorBorder"), lineWidth: 1.5)
                )
            if let error {
                Label(error, systemImage: "exclamationmark.triangle.fill")
                    .font(.footnote)
                    .foregroundStyle(Color("ErrorText"))
            }
        }
    }
}
```

**Rule:** validate on field commit (`.onSubmit` or focus loss), not on every keystroke. Password strength meters are the exception.

## Haptics Are a State Signal, Not Decoration

**Declare: map haptic type to semantic outcome — not to "this interaction feels important."** A haptic on every button tap trains users to ignore haptics.

**Why:** The haptic vocabulary is narrow and intentional. Spending `.success` on a tap that doesn't complete anything meaningful depletes the signal. Once users learn to ignore haptics, you've lost the channel entirely.

The three semantic clusters of `SensoryFeedback` (iOS 17+):

**Outcome** — use when an async operation completes with a result:

- `.success` — task completed successfully
- `.warning` — task completed with a caveat
- `.error` — task failed

**Selection / change** — use when a discrete value moves:

- `.selection` — picker, slider, drag-to-reorder (plays on iOS and watchOS)
- `.alignment` — snap-to-grid, object alignment in a canvas

**Physical impact** — use when two visual objects collide:

- `.impact(weight:intensity:)` — card snap, drag-to-slot, pull-to-refresh threshold
- `.impact(flexibility:intensity:)` — when the quality of the collision matters more than mass

**Critical platform note:** `.increase` and `.decrease` play only on watchOS/visionOS — not on iOS. Attaching them to a slider on iPhone fires no feedback. `.levelChange` plays only on macOS.

```swift
// Outcome — async operation completes
.sensoryFeedback(.success, trigger: uploadComplete) { _, new in new == true }
.sensoryFeedback(.error, trigger: uploadError) { _, new in new != nil }

// Selection change — discrete value snap
.sensoryFeedback(.selection, trigger: selectedIndex)

// Physical impact — card drops into a slot
.sensoryFeedback(.impact(weight: .medium), trigger: cardDropped)

// Toggle — fires only when toggling ON, not off
.sensoryFeedback(.impact(weight: .light), trigger: isFavorite) { _, new in new }
```

**Anti-pattern — "The Semantic Mismatch":**

```swift
// WRONG — .impact on a simple form submission with no physical metaphor
Button("Save") { save() }
    .sensoryFeedback(.impact, trigger: saveCount)
// Correct: .success fires when the save operation confirms completion

// WRONG — .success on every state toggle regardless of outcome
.sensoryFeedback(.success, trigger: isExpanded)
// Correct: .selection for a value that cycles through states
```

**Make haptics optional.** The app must remain fully functional without haptics — don't use a haptic as the only signal that an action completed. Some users turn haptics off entirely; others use devices that don't support them. A haptic is an enhancement, not a dependency.

## Destructive Actions: Undo Over Confirm

**Declare: remove the item from the UI immediately, surface an undo affordance for ~5 seconds, then commit the delete.** Reserve `.alert` confirmation dialogs for genuinely irreversible actions (account deletion, paid purchase, data export).

**Why:** Confirmation dialogs become muscle memory. Users tap "Delete" on the alert without reading, because 98% of the time they meant it. Undo respects their attention — they notice the mistake in the 2% case and recover.

```swift
.swipeActions(edge: .trailing) {
    Button(role: .destructive) { stage(forDeletion: message) } label: {
        Label("Delete", systemImage: "trash")
    }
}
```

## Touch Targets Are 44pt Minimum

**Declare: every tappable element is at least 44pt × 44pt on touch surfaces.** Small glyphs are fine; small hit regions are not. Use `.contentShape(Rectangle())` to expand the hit area beyond the visible label.

**Why:** Apple's HIG minimum is 44pt — below that, users miss taps on moving vehicles, with gloves, or when their finger isn't perfectly centered. The visible icon can stay small; the hit region cannot.

```swift
Button(action: close) {
    Image(systemName: "xmark")
        .font(.body.weight(.semibold))
}
.frame(width: 44, height: 44)
.contentShape(Rectangle())
```

---

**Avoid:** stripping focus feedback on custom styles. Loading states without timeouts. Empty views without `ContentUnavailableView`. Hover-gated functionality on views that ship to iPhone. Haptics on every tap. Hit regions smaller than 44pt.
