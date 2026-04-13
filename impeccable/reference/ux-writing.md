# UX Writing

Every string that reaches the screen is a design decision. Copy is part of the interface, not an afterthought tacked onto it.

## The Button Label Problem

**Never use "OK", "Submit", "Yes", or "No" as button labels.** Generic verbs make the user translate the label back into an action in their head. Use specific verb + object patterns — the button should read like the thing that will happen when tapped.

| Bad        | Good           | Why                           |
| ---------- | -------------- | ----------------------------- |
| OK         | Save changes   | Says what will happen         |
| Submit     | Create account | Outcome-focused               |
| Yes        | Delete message | Confirms the action           |
| Cancel     | Keep editing   | Clarifies what "cancel" means |
| Learn more | View pricing   | Describes the destination     |

**For destructive actions, name the destruction and show the count.** "Delete" beats "Remove" because permanence is the point. "Delete 5 items" beats "Delete selected" because the number forces confirmation before the finger moves.

```swift
// Anti-pattern
Button("OK") { save() }
Button("Yes", role: .destructive) { deleteItem() }

// Rule
Button("Save changes") { save() }
Button("Delete \(selection.count) items", role: .destructive) { deleteSelected() }
```

**Anti-pattern — "The OK Button."** A dialog ends with "OK" / "Cancel." OK of what? The user has to re-read the body copy to know what tapping OK commits them to. Named buttons are self-describing.

## Error Messages: Three Jobs, No Exceptions

**Stop shipping "An error occurred."** That string is an Apple HIG violation and the most common error message on the platform. Every error message must answer three questions: (1) What happened? (2) Why? (3) How to fix it?

```swift
// Anti-pattern
Alert("Error", message: Text("An error occurred."))

// Rule
Alert(
    "Couldn't save note",
    message: Text("You're offline. Your changes will sync when you reconnect.")
)
```

### Error Message Templates

| Situation         | Template                                                       |
| ----------------- | -------------------------------------------------------------- |
| Format error      | "[Field] needs to be [format]. Example: [example]"             |
| Missing required  | "Enter [what's missing] to continue"                           |
| Permission denied | "You don't have access to [thing]. [What to do instead]"       |
| Network error     | "Couldn't reach [thing]. Check your connection and try again." |
| Server error      | "Something went wrong on our end. We're looking into it."      |

**Never blame the user.** Reframe errors as conditions of the system, not faults of the person. "Email needs an @ symbol" — not "You entered an invalid email."

**Anti-pattern — "An error occurred."** Generic, blame-shifting, useless. It tells the user something is wrong but gives them no next move. If you can't say what happened, you shouldn't be showing a dialog.

## Apple Platform Conventions

**Follow Apple's copy conventions on Apple platforms.** On iOS/macOS 26+, errors use sentence case ("Couldn't save note"), not title case. Never start a user-facing string with "Please" — it reads as apologetic and inflates word count. Don't stack exclamation marks; system chrome is already loud enough.

```swift
// Anti-pattern
Alert("Please Try Again!", message: Text("An Error Has Occurred!"))

// Rule
Alert("Couldn't connect", message: Text("Check your internet and try again."))
```

**Anti-pattern — "Exclamation Overload."** Success! Saved! Done! Every toast and alert firing with an exclamation point flattens emotional range. Reserve `!` for rare, genuinely celebratory moments. Default to a period.

## Empty States Are Onboarding

**Treat every empty state as a first-run moment.** Use `ContentUnavailableView` (iOS 26+) — it gives you a title, message, and action slot, which is exactly the three-part structure empty states need: acknowledge → explain the value → offer the next step.

```swift
// Rule
ContentUnavailableView {
    Label("No notes yet", systemImage: "note.text")
} description: {
    Text("Capture an idea, a link, or a sketch. Everything syncs across your devices.")
} actions: {
    Button("Create your first note") { createNote() }
}

// Anti-pattern
ContentUnavailableView("No items", systemImage: "tray")
```

**Anti-pattern — "The Dead Tray."** A gray tray icon and the words "No items." No explanation of why the user would want items, no action to create one. Empty states are opportunities, not placeholders.

## Voice vs Tone

**Voice is constant. Tone shifts with the moment.** Your voice is the product's personality — it should sound the same whether the user is succeeding or stuck. Tone adjusts for what's happening on screen right now.

| Moment              | Tone                                                              |
| ------------------- | ----------------------------------------------------------------- |
| Success             | Brief, clear: "Saved" (not "Saved!!!")                            |
| Error               | Empathetic, actionable: "That didn't work. Here's what to try..." |
| Loading             | Reassuring, specific: "Saving your draft..."                      |
| Destructive confirm | Serious, plain: "Delete this project? This can't be undone."      |

**Never use humor in error messages.** A stuck user is already frustrated. Jokes read as flippant and widen the gap between user and product. Save personality for onboarding, empty states, and success moments.

## Writing for Accessibility

**Every interactive element needs a standalone label.** VoiceOver reads labels out of context — "Click here" becomes useless when surfaced in the rotor. Use `.accessibilityLabel(_:)` on icon-only controls and make link-equivalent text describe the destination.

```swift
// Anti-pattern
Button { showPricing() } label: {
    Image(systemName: "info.circle")
}

// Rule
Button { showPricing() } label: {
    Image(systemName: "info.circle")
}
.accessibilityLabel("View pricing plans")
```

**Decorative images must be marked decorative.** `Image(decorative:)` or `.accessibilityHidden(true)` keeps VoiceOver from announcing ornamental glyphs. Announcing decoration makes the rotor a landfill.

## Confirmation Dialogs: Use Sparingly

**Prefer undo over confirmation.** Most confirmation dialogs are design failures — they shift the cost of reversibility onto the user on every single action. If an action is reversible within a few seconds, use `ToolbarItem` + a transient undo banner instead of a `.confirmationDialog`.

When you must confirm: name the action in the button, name the consequence in the body, never use "Yes"/"No."

```swift
// Rule
.confirmationDialog(
    "Delete this project?",
    isPresented: $showConfirm,
    titleVisibility: .visible
) {
    Button("Delete project", role: .destructive) { delete() }
    Button("Keep project", role: .cancel) { }
} message: {
    Text("This removes all associated notes and can't be undone.")
}
```

## Form Copy

**Show format with placeholders or footers, never with inline instructions above the field.** If a field is non-obvious, explain _why_ you're asking in a `.footer`, not what to type — the label and placeholder already handle the what.

```swift
// Rule
TextField("Email", text: $email)
    .textContentType(.emailAddress)
    .keyboardType(.emailAddress)

Section {
    TextField("Phone", text: $phone)
        .textContentType(.telephoneNumber)
} footer: {
    Text("We'll text you when your order ships. We never share your number.")
}
```

## Consistency: Pick One Term

**Terminology variety reads as inconsistency.** If the same concept appears in three places with three different labels, the user assumes they're three different things. Build a glossary for the project and enforce it.

| Inconsistent                     | Consistent |
| -------------------------------- | ---------- |
| Delete / Remove / Trash          | Delete     |
| Settings / Preferences / Options | Settings   |
| Sign in / Log in / Enter         | Sign in    |
| Create / Add / New               | Create     |

**Anti-pattern — "The Thesaurus Trap."** Writers are taught to vary word choice for style. Interfaces are the opposite — users scan for labels as landmarks. Repetition is clarity.

## Loading States Are Copy Moments

**Say what you're loading, not that you're loading.** "Loading..." is less informative than the spinner above it. "Saving your draft..." tells the user their work is being handled. For anything over ~2 seconds, set expectations or show progress.

```swift
// Anti-pattern
ProgressView("Loading...")

// Rule
ProgressView("Syncing your library (this usually takes a few seconds)")
```

## Avoid Redundant Copy

If the heading explains it, the body is redundant. If the button label is clear, don't add a helper sentence under it. Say it once, say it well. The most impeccable copy is the copy that got cut.

---

**Avoid:** Jargon without explanation. Blaming the user ("You entered an invalid date" → "Date needs to be MM/DD/YYYY"). Vague errors ("Something went wrong"). Humor in error states. Varying terminology for style. Starting strings with "Please." Stacking exclamation marks. Generic "OK" buttons.
