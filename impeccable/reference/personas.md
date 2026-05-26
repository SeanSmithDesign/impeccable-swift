# Persona-Based Design Testing

Test the interface through the eyes of 5 distinct user archetypes. Each persona exposes failure modes that a single "design director" perspective would miss. On Apple platforms they map onto specific surfaces: a tab bar, a sidebar, a sheet, a Stage Manager window, an Apple Watch glance.

**How to use**: Select 2-3 personas most relevant to the surface being critiqued. Walk through the primary user action as each persona, on the actual device idiom (iPhone in hand, iPad in Stage Manager, Mac at a desk, Watch on a wrist). Report specific red flags, not generic concerns.

Personas with accessibility needs (Sam in particular) frequently overlap with the audit covered in [accessibility.md](accessibility.md). When the persona walk surfaces a VoiceOver, Dynamic Type, Reduce Motion, or contrast failure, cite the specific accessibility rule rather than restating it.

---

## 1. Impatient Power User: "Alex"

**Profile**: Expert with similar apps. Expects efficiency, hates hand-holding. Knows the platform's gestures, shortcuts, and conventions cold. Will find shortcuts or leave.

**Behaviors**:

- Skips all onboarding and instructions
- Reaches for keyboard shortcuts on Mac and iPad with keyboard immediately; long-presses on iPhone
- Tries to bulk-select, batch-edit, swipe-action, and drag-and-drop everything
- Gets frustrated by required steps that feel unnecessary (forced confirmations, unskippable splash screens, mandatory tooltips)
- Abandons if anything feels slow, patronizing, or non-native to the platform

**Test Questions**:

- Can Alex complete the core task in under 60 seconds?
- Does the app honor platform conventions: swipe-to-delete on rows, ⌘W to close on Mac, two-finger swipe back, edit-mode multi-select, drag-and-drop between apps?
- Are there keyboard shortcuts for primary actions (Mac and iPad with keyboard)?
- Can onboarding be skipped entirely? Does the splash dismiss instantly on tap?
- Does long-press reveal contextual menus (`.contextMenu`) where useful?
- On Mac: are menu bar items present and properly grouped under standard menus (File / Edit / View / Window)?

**Red Flags** (report these specifically):

- Forced tutorials or unskippable onboarding, spinning splash screens, mandatory "What's New" sheets on every launch
- No keyboard navigation on Mac or iPad with keyboard for primary actions
- Slow animations that can't be skipped or shortened by Reduce Motion
- One-item-at-a-time workflows where edit-mode multi-select would be natural
- Redundant confirmation alerts for low-risk, undoable actions (use undo / toast instead)
- Custom gestures that conflict with system gestures (edge-swipe back, control-center pull-down, Stage Manager edges)
- Re-implemented controls (custom segmented controls, custom switches) that ignore platform shortcuts and Dynamic Type

---

## 2. Confused First-Timer: "Jordan"

**Profile**: Never used this type of app, possibly new to the platform idiom (e.g., a longtime Android switcher on iOS, or a longtime iPhone user opening an iPad app for the first time). Needs guidance at every step. Will abandon rather than figure it out.

**Behaviors**:

- Reads all visible labels carefully; ignores instructions buried in tutorials
- Hesitates before tapping anything unfamiliar, especially destructive-looking icons
- Looks for help, support, or "Settings" constantly
- Misunderstands jargon, abbreviations, and product-specific terms
- Takes the most literal interpretation of any label ("Library" means "books")
- Doesn't know what a hamburger / kebab / disclosure-chevron means without a label

**Test Questions**:

- Is the first action obviously clear within 5 seconds of the screen appearing?
- Are SF Symbols paired with text labels at primary-navigation sites (tabbar items, toolbar primaries, empty-state CTAs)?
- Is there contextual help at decision points (an inline `Text` explainer, not a buried Help menu)?
- Does terminology assume product-specific jargon? Does it match how Apple's own apps name the same concept (Library / Inbox / Album / Document)?
- Is there a clear "Cancel" or "Back" at every step, including in modals?
- Do destructive actions confirm with a clear `confirmationDialog` that names the consequence?

**Red Flags** (report these specifically):

- Tabbar with icon-only items (no `.tabItem` text labels)
- Toolbar packed with unlabeled SF Symbols where the symbol isn't universally legible (a circle-with-dot is not self-evident)
- Custom terminology that diverges from Apple's vocabulary for the same concept without good reason
- No visible help, support, or "?" affordance on complex screens
- Ambiguous next steps after completing an action (no toast, no nav push, no state change)
- Empty states that say "No items" with no guidance on how to create one
- Modals with no clear way out other than the system swipe-down (which Jordan doesn't know about)

---

## 3. Accessibility-Dependent User: "Sam"

**Profile**: Uses VoiceOver, Switch Control, or Voice Control. May rely on Dynamic Type at XXL or AX sizes, Reduce Motion, Reduce Transparency, Increase Contrast, Differentiate Without Color, or Bold Text. May have low vision, motor impairment, hearing loss, or cognitive differences.

**Behaviors**:

- Swipes through the interface linearly with VoiceOver, expecting a logical reading order
- Uses the rotor to jump by headings, links, form controls, or landmarks
- Cannot see hover states, transient highlights, or visual-only indicators
- Cannot perceive meaning encoded only in color (red error, green success)
- Needs adequate color contrast (minimum 4.5:1 for body text, 3:1 for large text and UI components)
- May have Dynamic Type set to AX5; text wraps and grows, so layouts must reflow
- May have Reduce Motion enabled, so `.animation` and phase animators must degrade gracefully

**Test Questions**:

- Can the entire primary flow be completed with VoiceOver alone? Walk through with the screen curtain on (triple-tap with three fingers).
- Does every interactive element have a meaningful `.accessibilityLabel`? Decorative images marked with `.accessibilityHidden(true)`?
- Does the reading order make sense? Custom layouts may need `.accessibilitySortPriority` or `.accessibilityElement(children: .combine)`.
- Does the layout survive Dynamic Type at AX3 and AX5 without truncation, overlap, or clipped text? Use `@ScaledMetric` for spacing tied to text.
- Does color contrast pass WCAG AA against both Light and Dark Mode backgrounds, including over `.ultraThinMaterial` / Liquid Glass surfaces, where vibrancy can collapse contrast?
- Are state changes (loading, success, error) announced via `.accessibilityAnnouncement` or by moving focus to the new content?
- Are time-sensitive actions (countdown timers, auto-dismiss toasts) extendable, or do they offer an alternative path?
- Does the app respect `accessibilityReduceMotion` (disable parallax, replace cross-dissolves with crossfade, suppress phase animators)?

**Red Flags** (report these specifically):

- Tap-only interactions with no equivalent for Switch Control or Voice Control ("tap and hold to reveal" with no menu alternative)
- Missing or invisible focus indicators in keyboard / Switch Control flows
- Meaning conveyed by color alone (red dot for unread, green pill for active) without an icon, label, or shape backup
- Unlabeled `Button { Image(systemName: ...) }` constructs (VoiceOver reads "Button" with no name)
- Custom controls (custom slider, custom segmented picker) that break VoiceOver; use `.accessibilityRepresentation` or rebuild on system primitives
- Time-limited sheets or auto-dismissing alerts with no way to extend
- Layouts that clip, truncate, or overlap at AX3+ Dynamic Type
- Animations that ignore `accessibilityReduceMotion` (autoplay video, infinite loops, parallax)
- Liquid Glass / `.ultraThinMaterial` over busy backgrounds that drops contrast below 4.5:1

For the full accessibility ruleset, see [accessibility.md](accessibility.md).

---

## 4. Deliberate Stress Tester: "Riley"

**Profile**: Methodical user who pushes interfaces beyond the happy path. Tests edge cases, tries unexpected inputs, and probes for gaps in the experience. The kind of user who finds the bug your team didn't.

**Behaviors**:

- Tests edge cases intentionally: empty list, 1 item, 1,000 items, single-character names, 500-character names
- Submits forms with unexpected data (emoji, RTL text, combining characters, paste from a Numbers cell)
- Tries to break workflows by force-quitting mid-flow, switching apps, locking the device, killing the network, swiping back from a sheet
- On iPad: drags the app into Slide Over, splits with another app, drops into Stage Manager, rotates landscape ↔ portrait
- On Mac: resizes the window to its minimum, then to full screen, then half a Stage Manager strip
- Looks for inconsistencies between what the UI promises and what actually happens
- Documents problems methodically (often with screen recordings)

**Test Questions**:

- What happens at the edges (0 items, 1 item, 1,000 items, very long strings, items containing emoji)?
- Does the layout survive iPad rotation, Slide Over (320pt wide), Split View, and Stage Manager resizing? Does it survive Mac window resize down to the minimum?
- What happens if the network drops mid-fetch? Does the UI recover, retry, or get stuck on a spinner?
- Does state persist across force-quit and relaunch (`@SceneStorage`, `@AppStorage`)? Across iCloud sync?
- Are there `.task` modifiers that re-fire incorrectly on view re-creation, double-firing network calls?
- Are there features that appear to work but produce broken results (saved-but-not-actually-saved, sent-but-not-actually-sent)?
- How does the UI handle paste containing rich text, mixed scripts, or 10,000 characters?

**Red Flags** (report these specifically):

- Features that appear to succeed but silently fail (the toast says "Saved" but the row didn't update)
- Error handling that exposes raw `NSError` strings, stack traces, or technical jargon to the user
- Empty states that show nothing useful (a centered "No items" with no action)
- Layouts that break under iPad rotation, Slide Over, or Stage Manager (clipped buttons, overlapping rows, tabbars under the home indicator)
- Sheets that lose user-entered data on swipe-down dismiss with no "discard?" confirmation
- Workflows that lose state on force-quit because nothing is in `@SceneStorage` or persisted
- Inconsistent behavior between similar interactions (swipe-to-delete works on one list, not on a structurally identical list)
- `Image` views that show a broken-symbol glyph when the asset is missing instead of a graceful placeholder

---

## 5. Distracted Mobile User: "Casey"

**Profile**: Using iPhone one-handed on the go. Frequently interrupted by notifications, calls, walking, talking. Possibly on cellular (LTE or worse), Low Power Mode, or Low Data Mode.

**Behaviors**:

- Uses thumb only; prefers bottom-of-screen actions
- Gets interrupted mid-flow by a call, a notification, or real life; returns minutes or hours later
- Switches apps frequently (Maps, Messages, Music, back to your app)
- Has limited attention span and zero patience for slow loads
- Types as little as possible; prefers taps, selections, autofill, dictation, scan-with-camera

**Test Questions**:

- Are primary actions in the thumb zone (bottom half of an iPhone screen, especially Pro Max sizes)?
- Is state preserved on app backgrounding, force-quit, and relaunch? (`@SceneStorage` for transient UI state, persistence layer for data)
- Does the app degrade gracefully on slow networks (skeleton states, optimistic UI, retry-on-tap rather than infinite spinners)?
- Does the app respect Low Power Mode (`ProcessInfo.processInfo.isLowPowerModeEnabled`) by suppressing autoplay, background polling, and heavy animation?
- Can forms leverage iOS niceties: `.textContentType` for autofill, `.keyboardType` for the right keyboard, `.scannerView` for codes, dictation by default?
- Are touch targets at least 44×44pt? Is there breathing room between adjacent targets?
- Do destinations that need the camera, microphone, or location ask for permission contextually, not on first launch?

**Red Flags** (report these specifically):

- Important actions positioned at the top of the screen (unreachable by thumb on a 6.7" device)
- A back button in the top-left as the only way back (no swipe-back, no bottom-sheet drag)
- No state persistence; typed text or scroll position lost on background or app-switch
- Large free-text inputs required where a Picker, Stepper, or scan would work
- Missing `.textContentType` on email / password / phone / one-time-code fields (no autofill, no SMS-code suggestion)
- Heavy assets loading on every screen entry (no `.task(id:)` deduplication, no caching)
- Touch targets smaller than 44×44pt or packed too close together
- Permissions requested upfront ("Allow notifications" on first launch) rather than at the moment of need

---

## Selecting Personas

Choose personas based on the surface type:

| Surface Type                                | Primary Personas     | Why                                        |
| ------------------------------------------- | -------------------- | ------------------------------------------ |
| Marketing app shell / portfolio             | Jordan, Riley, Casey | First impressions, edge cases, mobile      |
| Dashboard / admin (Mac, iPad)               | Alex, Sam            | Power-user efficiency, accessibility       |
| Onboarding / first-run flow                 | Jordan, Casey        | Confusion, interruption                    |
| Settings / preferences                      | Alex, Sam            | Speed, accessibility, no surprises         |
| Data-heavy list / table (Mail, Files, etc.) | Alex, Sam, Riley     | Bulk ops, VoiceOver order, edge cases      |
| Form-heavy / multi-step wizard              | Jordan, Sam, Casey   | Clarity, accessibility, persistence        |
| Apple Watch complication / glance           | Alex, Sam, Casey     | Sub-second use, VoiceOver, one-handed      |
| iPad app under Stage Manager / Split View   | Alex, Riley          | Power-user multitasking, layout edge cases |
| In-app purchase / subscription paywall      | Jordan, Riley        | Trust, dark-pattern detection              |
| Empty state / first-time empty surface      | Jordan, Casey        | Clarity of next action                     |

---

## Project-Specific Personas

If `PRODUCT.md` contains an audience description (generated by `/impeccable-swift teach`), derive 1-2 additional personas from that audience plus the primary device idiom.

1. Read the "Users" and "Brand" sections of PRODUCT.md.
2. Identify a primary user archetype not already covered by the five above.
3. Anchor the persona to the device they actually use (iPhone-only, iPad-first, Mac power user, Watch glance); that grounds the behaviors in real interactions.
4. Create the persona using this template:

```
### [Role on device]: "[Name]"

**Profile**: [2-3 key characteristics derived from PRODUCT.md, including device idiom]

**Behaviors**: [3-4 specific behaviors grounded in the described audience and device]

**Red Flags**: [3-4 things that would alienate this specific user on this device]
```

Only generate project-specific personas when real PRODUCT.md context exists. Don't invent audience details; use the 5 predefined personas when no context is available.
