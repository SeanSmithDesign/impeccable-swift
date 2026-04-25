# Cognitive Load

Cognitive load is the total mental effort required to use an interface. Overloaded users tap the wrong thing, abandon the flow, and never come back. This reference is a critique-supporting framework: use it to name what's wrong when a screen "feels heavy," and to score how heavy it actually is.

The principles are platform-agnostic (Hick's Law, Miller's Number, decision fatigue, progressive disclosure are universal). The remedies in this doc are SwiftUI-shaped: `Menu`, `Picker`, `DisclosureGroup`, `NavigationSplitView`, sheet stacking, `.controlSize`, and the system controls that already do the right thing if you let them.

For the structural side of cognitive load (how an app is laid out across stacks, splits, and tabs), see [`navigation.md`](navigation.md). For cognitive accessibility: Reduce Motion, VoiceOver verbosity, and the working-memory cost of a screen for users who already have a high baseline load: see [`accessibility.md`](accessibility.md).

## Three Types of Cognitive Load

### Intrinsic Load: The Task Itself

The complexity inherent to what the user is trying to do. Configuring a backup destination is intrinsically harder than toggling a switch. You cannot eliminate intrinsic load. You can only structure it so the user meets it in the right order.

**Manage it by:**

- Breaking the task into discrete steps with their own screens or sections.
- Providing scaffolding: sensible defaults, templates, examples, and pre-filled fields.
- Progressive disclosure: show what's needed now, hide the rest behind a `DisclosureGroup` or a secondary screen.
- Grouping related decisions so the user makes them together, not scattered across the flow.

### Extraneous Load: Bad Design

Mental effort caused by the interface itself, not the task. **Eliminate this ruthlessly.** It is pure waste. Every unit of extraneous load you remove is bandwidth the user can spend on intrinsic load (the actual job) or germane load (learning your app).

**Common sources:**

- Confusing navigation that forces users to build a mental map.
- Unclear labels that force the user to guess what a control does.
- Visual clutter where every element competes for attention.
- Inconsistent patterns: a `Toggle` here, a custom switch there, a `Button` styled like a toggle in a third place.
- Unnecessary steps between intent and result (a confirm dialog on a non-destructive action, a modal that wraps a single field).

### Germane Load: Learning Effort

Mental effort spent building understanding of the app. This is the _good_ kind of cognitive load. It pays off as mastery: the user gets faster every session.

**Support it by:**

- Consistent patterns that reward learning (the same gesture means the same thing across screens).
- Feedback that confirms correct understanding (haptics, animation, status changes).
- Onboarding that teaches through real use, not a wall of slides at first launch.
- Progressive disclosure that reveals depth at the user's pace, not all at once.

## The Working Memory Rule

**Humans hold roughly four items in working memory at once.** This is Miller's "magical number seven" as revised by Cowan (2001). At every decision point, count the distinct options, actions, or pieces of information the user must hold simultaneously.

- **Four or fewer:** within working memory limits. Manageable.
- **Five to seven:** pushing the boundary. Group, chunk, or progressively disclose.
- **Eight or more:** overloaded. Users will skip, misclick, or abandon.

**Practical SwiftUI applications:**

- **Tab bar:** five tabs maximum on iPhone. The system enforces this by collapsing the sixth into a "More" tab: that collapse is a smell, not a feature. If you need six, your IA is wrong.
- **`NavigationSplitView` sidebar:** group items into sections with `Section { } header: { Text("...") }`. A flat list of fifteen sidebar entries is a wall of options.
- **Form sections:** four fields visible per `Section` before a header break. Long forms get sectioned, not scrolled.
- **Toolbar items:** one `.primaryAction`, one or two `.secondaryAction`, the rest behind a `Menu`. Five trailing toolbar buttons on iPhone is a guaranteed misfire: the system will overflow them anyway, badly.
- **Pricing or plan selection:** three options. More causes analysis paralysis. If you have five plans, surface three and let users tap "See all plans."

## Choice Surface: Menu vs. Picker vs. Inline

The number of options is the single biggest cognitive load lever in a SwiftUI form. The right control collapses with the count.

```swift
// 2 options: inline. Make the choice visible.
Toggle("Use Face ID", isOn: $useFaceID)

// 3 to 5 options: segmented Picker. All choices visible, one tap.
Picker("Theme", selection: $theme) {
    Text("Light").tag(Theme.light)
    Text("Dark").tag(Theme.dark)
    Text("System").tag(Theme.system)
}
.pickerStyle(.segmented)

// 5 to ~12 options: menu Picker. One tap to reveal, one to choose.
Picker("Time Zone", selection: $tz) {
    ForEach(TimeZone.commonZones, id: \.self) { zone in
        Text(zone.displayName).tag(zone)
    }
}
.pickerStyle(.menu)

// 12+ options: navigationLink Picker into a searchable list.
Picker("Country", selection: $country) {
    ForEach(Country.all) { Text($0.name).tag($0) }
}
.pickerStyle(.navigationLink)
```

**Rule of thumb:** if the user has to scan more than five labels at once to make a choice, the choice is too wide for the surface. Push it down a level (`Menu`, `.navigationLink`, sheet) so the working memory cost is the _category_ of the choice, not the choice itself.

**`Menu` for actions, `Picker` for state.** A `Menu` groups discrete actions ("Share," "Duplicate," "Delete"). A `Picker` selects one value from a set of options. Mixing them: a `Menu` with checkmarks and a "Done" button: is a custom control and a load violation.

## Progressive Disclosure With DisclosureGroup

`DisclosureGroup` is the SwiftUI primitive for "show what matters now; the rest is one tap away." Use it whenever the screen has a primary task and a tail of advanced or rarely-used options.

```swift
Form {
    Section("Connection") {
        TextField("Server", text: $server)
        TextField("Port", text: $port)
    }

    DisclosureGroup("Advanced") {
        Toggle("Use SSL", isOn: $useSSL)
        Toggle("Verify certificate", isOn: $verifyCert)
        Picker("Timeout", selection: $timeout) {
            ForEach(timeoutOptions, id: \.self) { Text("\($0)s") }
        }
    }
}
```

**Rule:** if a control is used by less than 20% of users in the typical flow, it belongs inside a `DisclosureGroup` collapsed by default. If it's used by less than 5%, it belongs on a separate screen entirely.

**Anti-pattern: "The Permanent Reveal."** A `DisclosureGroup` that's expanded by default and contains every option the developer could think of. This is a flat list with extra chrome. The point of disclosure is that it's _closed_ until needed.

## Sheet Stacking And Modal Depth

Modals add cognitive load because they suspend the user's current context and demand a separate one. **One sheet is fine. A sheet that opens a sheet is a smell. Three deep is a violation.**

```swift
// Bad: editing a contact opens a sheet, which opens a sheet to pick a label,
// which opens a sheet to add a custom label.
.sheet(isPresented: $editing) {
    ContactEditor()
        .sheet(isPresented: $pickingLabel) {
            LabelPicker()
                .sheet(isPresented: $addingCustom) {
                    CustomLabelEditor()
                }
        }
}
```

The user is now three context-switches deep. They've forgotten what they were editing. Each dismissal costs another decision: "Am I done with this layer or all of it?"

**Fix:** push deeper choices onto a `NavigationStack` _inside_ the sheet. The user stays in one modal context with a clear back path.

```swift
.sheet(isPresented: $editing) {
    NavigationStack {
        ContactEditor()
            .navigationDestination(for: EditorRoute.self) { ... }
    }
}
```

**Rule:** modal depth on iPhone is one. On iPad, never more than two (and the second should be a `popover` or `formSheet`, not a full sheet).

## Control Density And `.controlSize`

`.controlSize` lets the same control fit into different information densities. **Density is a cognitive load lever.** Big controls in a sparse layout signal "few important choices." Small controls in a dense layout signal "lots of options for power users." Mixing densities on the same screen forces the user to re-anchor on every block.

```swift
// A toolbar of editing tools: dense, .small or .mini. Power users.
HStack {
    Button("B") { ... }.controlSize(.small)
    Button("I") { ... }.controlSize(.small)
    Button("U") { ... }.controlSize(.small)
}

// A primary CTA at the bottom of an onboarding screen: .large.
Button("Continue") { ... }
    .buttonStyle(.borderedProminent)
    .controlSize(.large)
```

**Rule:** pick one `.controlSize` per visual region and stick to it. Mixed sizes inside the same `HStack` look like a draft.

## Cognitive Load Checklist

Score the interface against these eight items. Each failure is a finding for [`audit.md`](audit.md) and [`critique.md`](critique.md).

- [ ] **Single focus:** Can the user complete the primary task without competing elements stealing attention?
- [ ] **Chunking:** Is information presented in groups of four or fewer items per group?
- [ ] **Grouping:** Are related items visually grouped (proximity, `Section`, shared background, `GroupBox`)?
- [ ] **Visual hierarchy:** Is the most important element on screen unambiguously the most prominent?
- [ ] **One thing at a time:** Can the user focus on a single decision before the next appears?
- [ ] **Minimal choices:** Are decision points capped at four visible options, with the rest behind a `Menu`, `Picker`, or `DisclosureGroup`?
- [ ] **Working memory:** Can the user act on the current screen without remembering data from a previous one?
- [ ] **Progressive disclosure:** Is complexity revealed only when it's actually needed?

**Scoring:**

- 0 to 1 failures: low cognitive load. Good.
- 2 to 3 failures: moderate. Address before ship.
- 4 or more failures: high cognitive load. Critical fix. The screen is doing too much.

## Common Cognitive Load Violations

### 1. The Wall of Options

**Problem:** Ten or more choices with no hierarchy: a settings screen that's one flat `Form`, a `Picker` with thirty entries and no search.
**Fix:** Group into `Section`s. Use `.pickerStyle(.navigationLink)` with a `searchable` destination for long lists. Highlight a recommended default.

### 2. The Memory Bridge

**Problem:** The user must remember a value from screen 1 to act on screen 3 (an order ID, a confirmation code, a name they entered earlier).
**Fix:** Carry the context visibly forward. Use a header, a summary card, or `.navigationSubtitle` to keep the relevant value on screen.

### 3. The Hidden Navigation

**Problem:** The user has to build a mental map of where things live. No active tab indication. No `.navigationTitle`. No breadcrumb on Mac.
**Fix:** Always show location. Use `.navigationTitle`, give `TabView` items clear icons and labels, light up the active sidebar row in `NavigationSplitView`.

### 4. The Jargon Barrier

**Problem:** Labels use system or domain terms ("ICCID," "SSID," "MFA token") that force a translation step.
**Fix:** Plain language by default. If a domain term is unavoidable, define it inline with a `Text` footnote or a `Label` with a "Learn more" `Menu` item. See [`ux-writing.md`](ux-writing.md).

### 5. The Visual Noise Floor

**Problem:** Every element is bold, every button is `.borderedProminent`, every card has a shadow. Nothing reads as primary because everything is shouting.
**Fix:** One primary action per screen. Two or three secondary. Everything else `.bordered` or `.borderless`. Reserve `.borderedProminent` for the single most important action.

### 6. The Inconsistent Pattern

**Problem:** "Add" is a `+` in the toolbar on one screen, a button labeled "New" on another, and a swipe gesture on a third.
**Fix:** Standardize. Same kind of action, same kind of UI. The system adds an `Image(systemName: "plus")` `ToolbarItem(placement: .primaryAction)` for free: use it everywhere "add" appears.

### 7. The Multi-Task Demand

**Problem:** A single screen requires reading, deciding, _and_ navigating at once: a payment flow that asks for card details while also showing a promotional carousel and a chat support widget.
**Fix:** Sequence. One job per screen. Defer secondary surfaces until the primary task completes.

### 8. The Context Switch

**Problem:** The user has to flip between sheets, tabs, or apps to gather what they need for one decision (checking a code in Mail to paste in your sign-in screen).
**Fix:** Co-locate. Use `TextField(... )` with `.textContentType(.oneTimeCode)` so the system surfaces the code in QuickType. Reduce trips. Every back-and-forth is decision fatigue accumulating.

## When To Cite This Doc

- During [`critique.md`](critique.md) runs: cite specific checklist items the screen fails, score 0 to 8, name the violation by number.
- During [`audit.md`](audit.md): the working memory rule and modal depth rule are P1 findings when violated.
- During [`shape.md`](shape.md) and pre-build planning: use the checklist as a self-test before any code is written. The cheapest cognitive load fix is the one made before the screen exists.
