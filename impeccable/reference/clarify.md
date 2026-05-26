> **Additional context needed**: audience technical level and users' mental state in context.

Find the unclear, confusing, or poorly written interface text and rewrite it. Vague copy creates support tickets and abandonment; specific copy gets users through the task.

---

## Assess Current Copy

Identify what makes the text unclear or ineffective:

1. **Find clarity problems**:
   - **Jargon**: Technical terms users won't understand
   - **Ambiguity**: Multiple interpretations possible
   - **Passive voice**: "Your file has been uploaded" vs "We uploaded your file"
   - **Length**: Too wordy or too terse
   - **Assumptions**: Assuming user knowledge they don't have
   - **Missing context**: Users don't know what to do or why
   - **Tone mismatch**: Too formal, too casual, or inappropriate for situation

2. **Understand the context**:
   - Who's the audience? (Technical? General? First-time users?)
   - What's the user's mental state? (Stressed during error? Confident during success?)
   - What's the action? (What do we want users to do?)
   - What's the constraint? (Character limits? Space limitations?)

**CRITICAL**: Clear copy helps users succeed. Unclear copy creates frustration, errors, and support tickets.

## Plan Copy Improvements

Create a strategy for clearer communication:

- **Primary message**: What's the ONE thing users need to know?
- **Action needed**: What should users do next (if anything)?
- **Tone**: How should this feel? (Helpful? Apologetic? Encouraging?)
- **Constraints**: Length limits, brand voice, localization considerations

**IMPORTANT**: Good UX writing is invisible. Users should understand immediately without noticing the words.

## Improve Copy Systematically

Refine text across these common areas:

### Error Messages

**Bad**: "Error 403: Forbidden"
**Good**: "You don't have permission to view this page. Contact your admin for access."

**Bad**: "Invalid input"
**Good**: "Email addresses need an @ symbol. Try: name@example.com"

**Principles**:

- Explain what went wrong in plain language
- Suggest how to fix it
- Don't blame the user
- Include examples when helpful
- Link to help/support if applicable

In SwiftUI, pair every user-visible error string with a specific `.accessibilityLabel` so VoiceOver announces it with the same clarity as the sighted copy. See [`accessibility.md`](accessibility.md) for label vs. hint guidance.

### Form Labels & Instructions

**Bad**: "DOB (MM/DD/YYYY)"
**Good**: "Date of birth" (with placeholder showing format)

**Bad**: "Enter value here"
**Good**: "Your email address" or "Company name"

**Principles**:

- Use clear, specific labels (not generic placeholders)
- Show format expectations with examples
- Explain why you're asking (when not obvious)
- Put instructions before the field, not after
- Keep required field indicators clear

### Button & CTA Text

**Bad**: "Click here" | "Submit" | "OK"
**Good**: "Create account" | "Save changes" | "Got it, thanks"

**Principles**:

- Describe the action specifically
- Use active voice (verb + noun)
- Match user's mental model
- Be specific ("Save" is better than "OK")

See [`ux-writing.md`](ux-writing.md) for the full button-label taxonomy and destructive-action patterns.

### Help Text & Tooltips

**Bad**: "This is the username field"
**Good**: "Choose a username. You can change this later in Settings."

**Principles**:

- Add value (don't just repeat the label)
- Answer the implicit question ("What is this?" or "Why do you need this?")
- Keep it brief but complete
- Link to detailed docs if needed

### Empty States

**Bad**: "No items"
**Good**: "No projects yet. Create your first project to get started."

**Principles**:

- Explain why it's empty (if not obvious)
- Show next action clearly
- Make it welcoming, not dead-end

### Success Messages

**Bad**: "Success"
**Good**: "Settings saved! Your changes will take effect immediately."

**Principles**:

- Confirm what happened
- Explain what happens next (if relevant)
- Be brief but complete
- Match the user's emotional moment (celebrate big wins)

### Loading States

**Bad**: "Loading..." (for 30+ seconds)
**Good**: "Analyzing your data... this usually takes 30-60 seconds"

**Principles**:

- Set expectations (how long?)
- Explain what's happening (when it's not obvious)
- Show progress when possible
- Offer escape hatch if appropriate ("Cancel")

### Confirmation Dialogs

**Bad**: "Are you sure?"
**Good**: "Delete 'Project Alpha'? This can't be undone."

**Principles**:

- State the specific action
- Explain consequences (especially for destructive actions)
- Use clear button labels ("Delete project" not "Yes")
- Don't overuse confirmations (only for risky actions)

### Navigation & Wayfinding

**Bad**: Generic labels like "Items" | "Things" | "Stuff"
**Good**: Specific labels like "Your projects" | "Team members" | "Settings"

**Principles**:

- Be specific and descriptive
- Use language users understand (not internal jargon)
- Make hierarchy clear
- Consider information scent (breadcrumbs, current location)

## Localization with StringCatalog

Every user-visible string in SwiftUI should live in a StringCatalog (`.xcstrings` file): Apple's modern localization format introduced in Xcode 15. Strings declared as `Text("Hello")` or `LocalizedStringKey` are extracted automatically.

### Basic localized string

```swift
// SwiftUI picks this up automatically from the StringCatalog
Text("Welcome back")

// Explicit key with default value for strings outside of a View
let message = String(localized: "welcome.back",
                     defaultValue: "Welcome back",
                     comment: "Shown on the home screen after sign-in")
```

### Interpolation with positional placeholders

StringCatalog handles interpolated strings with ordered placeholders so translators can reorder arguments as their language demands:

```swift
// Declared in SwiftUI
Text("Hello \(name), you have \(count) notifications")

// In the .xcstrings file, the translation entry uses positional placeholders:
// "Hello %1$@, you have %2$lld notifications"
// A French translator might write: "Vous avez %2$lld notifications, %1$@"
```

### Plural rules

Use `String(localized:)` with `.init(format:)` for simple plurals, or declare plural variants directly in the `.xcstrings` file:

```swift
// The .xcstrings file holds "one" and "other" variants; SwiftUI resolves automatically
Text("\(count) items selected")
```

Avoid hardcoding "1 item / 2 items" logic in Swift. StringCatalog supports CLDR plural categories (zero, one, two, few, many, other) so the right form is served per locale without code changes.

### AccessibilityLabel parity

Every visible label with a matching `accessibilityLabel` keeps VoiceOver in sync with the sighted copy. When you update a localized string, update its `accessibilityLabel` too:

```swift
Button(action: submit) {
    Text("Save changes")
}
.accessibilityLabel(Text("Save changes"))
// LocalizedStringKey: picked up by StringCatalog just like Text()
```

See [`accessibility.md`](accessibility.md) for full guidance on `.accessibilityLabel` vs `.accessibilityHint`.

## Apply Clarity Principles

Every piece of copy should follow these rules:

1. **Be specific**: "Enter email" not "Enter value"
2. **Be concise**: Cut unnecessary words (but don't sacrifice clarity)
3. **Be active**: "Save changes" not "Changes will be saved"
4. **Be human**: "Oops, something went wrong" not "System error encountered"
5. **Be helpful**: Tell users what to do, not just what happened
6. **Be consistent**: Use same terms throughout (don't vary for variety)

**NEVER**:

- Use jargon without explanation
- Blame users ("You made an error" is wrong; "This field is required" is right)
- Be vague ("Something went wrong" without explanation)
- Use passive voice unnecessarily
- Write overly long explanations (be concise)
- Use humor for errors (be empathetic instead)
- Assume technical knowledge
- Vary terminology (pick one term and stick with it)
- Repeat information (headers restating intros, redundant explanations)
- Use placeholders as the only labels (they disappear when users type)
- Ship raw system error codes ("Error 0x80070005") without translating them into plain-language copy

## Verify Improvements

Test that copy improvements work:

- **Comprehension**: Can users understand without context?
- **Actionability**: Do users know what to do next?
- **Brevity**: Is it as short as possible while remaining clear?
- **Consistency**: Does it match terminology elsewhere?
- **Tone**: Is it appropriate for the situation?
- **Localization readiness**: Are all strings in the StringCatalog (`.xcstrings`)? Do interpolated strings use positional placeholders? Do plural strings declare all necessary CLDR variants?
- **VoiceOver parity**: Does every visible label have a matching `accessibilityLabel`? Run the Accessibility Inspector or enable VoiceOver and tab through the updated views.

When the copy reads cleanly, hand off to `/impeccable polish` for the final pass.
