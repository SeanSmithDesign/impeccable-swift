# SF Symbols

This doc covers iconography on Apple platforms: choosing a symbol set, picking a rendering mode, matching weight to surrounding type, sizing without distortion, and keeping variants consistent. It does not cover illustration, empty-state art, or brand marks — those are not icons.

## One Symbol Set Per Surface

**Stop mixing icon libraries.** A surface ships with SF Symbols, or it ships with a custom glyph set drawn to match SF Symbols' optical rules. Never both. The moment a PNG lands next to `Image(systemName:)`, the grid breaks — strokes disagree, optical sizing disagrees, alignment disagrees, and the UI reads as cobbled together. SF Symbols are a system, not a clip-art library; the whole point is that every glyph shares the same weight axis, the same bounding box math, and the same baseline alignment. A foreign icon cannot join that system by accident.

**Rule:** Pick SF Symbols or a custom set drawn as an SF Symbols variable font (`.symbolset` in the asset catalog). Commit to that choice for the whole surface.

**Anti-pattern — "The PNG-in-the-symbols-row."** A toolbar with five `Image(systemName:)` glyphs and one PNG logo dropped in because "SF Symbols doesn't have it." The PNG is 2px heavier, sits 1px lower, and turns the row into visual noise. Either draw the missing glyph into a custom `.symbolset`, or drop SF Symbols entirely for this surface. Do not mix.

## One Rendering Mode Per Surface

**Pick `.monochrome`, `.hierarchical`, `.palette`, or `.multicolor` — then hold it.** Rendering modes are a statement about how color participates in the icon system. `.monochrome` says icons inherit `.foregroundStyle`. `.hierarchical` says icons have internal depth from a single tint. `.palette` says two or three explicit colors per glyph. `.multicolor` says the glyph is a semantic illustration (the red of the stop-sign symbol, the yellow of the warning). Each has a different voice. Mixing them on one screen reads as incoherent.

```swift
Image(systemName: "bell.badge.fill")
    .symbolRenderingMode(.hierarchical)
    .foregroundStyle(.tint)
```

**Rule:** One rendering mode per surface. If a glyph needs a different mode to read correctly, the surface probably needs rethinking — not a second mode.

**Anti-pattern — "The icon gallery."** A settings screen with a monochrome gear, a multicolor heart, a hierarchical cloud, and a palette-mode battery. Every row screams for attention differently. The user can't tell which icons are actionable, which are decorative, and which are status. Pick one mode. Let the icons recede into rhythm.

## Symbol Weight Matches Text Weight

**Never let an icon float at a different weight than the text it sits with.** SF Symbols ship on the same weight axis as San Francisco (ultralight → black). A `.semibold` headline paired with a default-weight symbol looks broken; the eye reads the weight mismatch before it reads the label. `Image(systemName:)` inherits `.font` automatically — use that, not `.fontWeight` on the image in isolation.

```swift
HStack(spacing: 8) {
    Image(systemName: "sparkles")
    Text("Generate")
}
.font(.headline)             // both inherit .headline weight and size
.foregroundStyle(.primary)
```

**Rule:** Use `.font(_:)` on the `HStack` (or the nearest shared parent) so the symbol inherits the exact text style. Reach for `.fontWeight(_:)` only when the symbol stands alone.

**Why:** SF Symbols' entire value is optical alignment with San Francisco. Breaking the weight contract forfeits that and makes the system look like a worse icon font.

## Size With Type, Not With Frames

**Never wrap a symbol in `.frame(width:height:)` to size it.** A frame clips the bounding box but does not scale the glyph — you either crush the padding or letterbox the icon inside a too-large rectangle. Size symbols through the type system: `.font(.system(size: 17))`, `.imageScale(.large)`, or by inheriting `.font(.headline)` from context. The glyph then scales cleanly, keeps its optical padding, and respects Dynamic Type.

```swift
// Correct
Image(systemName: "pencil")
    .font(.system(size: 20, weight: .medium))
    .imageScale(.medium)
```

**Anti-pattern — "The framed symbol."** `Image(systemName: "star").frame(width: 20, height: 20)`. The glyph now sits inside a fixed 20×20 box regardless of Dynamic Type, regardless of weight, regardless of context. The symbol ignores the type ramp and breaks at accessibility sizes. Delete the frame. Use `.font` or `.imageScale`.

## Variants Are A Surface-Wide Commitment

**`.fill`, `.circle`, `.square`, `.slash` — pick once, apply everywhere on the surface.** `.symbolVariant(.fill)` is a container-level decision, not a per-icon flourish. A navigation bar where three tabs are filled and two are outlined reads as half-finished. Apply the variant at the container (`TabView`, `List`, `.toolbar`) and let every symbol inside follow.

```swift
TabView {
    LibraryView()
        .tabItem { Label("Library", systemImage: "books.vertical") }
    SearchView()
        .tabItem { Label("Search", systemImage: "magnifyingglass") }
}
.symbolVariant(.fill)   // applied once, enforced across tabs
```

**Rule:** `.symbolVariant(_:)` goes on the container. Only override on a single symbol when the variant carries semantic meaning (e.g. `.slash` for "muted").

---

**Avoid:** Mixing SF Symbols with custom PNGs on one surface. Mixing rendering modes in the same view. Sizing with `.frame` instead of `.font` or `.imageScale`. Applying `.fill` per-icon instead of per-container. Letting symbol weight drift away from text weight.
