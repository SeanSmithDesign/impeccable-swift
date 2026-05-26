# Codex: Visual Direction and Asset Production

This file loads when a harness has native image generation attached to the session. It covers the craft steps that depend on real image generation: landing visual direction and producing raster assets that the SwiftUI implementation will compose. Harnesses without image generation skip this file.

Read this before generating any images. The order matters, and the per-step user pauses are what keep generated imagery from drifting away from the brief.

## Four Stop Points Before Code

Steps A through D each end with the user. Do not advance past any of them on your own read of the situation.

1. **STOP after Step A questions.** Wait for answers.
2. **STOP after Step B palette generation.** Wait for "confirm palette."
3. **STOP after Step C mocks.** Wait for direction approval or delegation.
4. **Only after Step D approves a direction** do you return to craft.md Step 4 and write SwiftUI code.

Prior shape approval does not satisfy any of these. Shape's "confirm or override" advances you into Step A; it is not a substitute for it.

## Step A: Explore Directions with the User

Before generating anything, run a brief direction conversation grounded in the shape brief.

**Step A is required even when shape just produced a confirmed brief.** Shape pins purpose, content, and scope. Step A pins palette, atmosphere, and named visual references for the comps you are about to generate. The only time you can skip Step A is when the user has already answered these exact palette and atmosphere questions in the same session.

Ask **2-3 targeted questions** about visual lane, color strategy, atmosphere, and named anchor references. Tie each question to the shape brief's answers:

- "Brief says 'editorial restraint.' Are we closer to a quiet specimen-page feel or a magazine-spread with hero imagery?"
- "Palette strategy from shape was 'Committed.' Want it warm-grounded (deep oxblood + cream) or cool-grounded (slate + paper white)?"
- "The app surfaces over Liquid Glass. Should imagery feel translucent and recessive, or should it anchor the composition with full opacity?"

**STOP and wait for answers.** These pin the palette before any pixel gets generated. Do not proceed to Step B until the user has responded.

## Step B: Generate the Brand Palette First

Generate **one** palette artifact before any mocks. A small, focused image: typography pairing on the chosen background, primary and accent color swatches, one signature motif. Single image, single pass.

Why palette first: mocks generated against a vague color sense produce noise that drowns out the structural decisions. A confirmed palette is the first concrete contract for everything downstream, including the `Color` entries that will go into the asset catalog.

Show the palette to the user. Ask one question: "This is the palette I am locking in for the mocks. Confirm, or call out what to shift?"

**STOP and wait for confirmation.** Do not generate mocks against an unconfirmed palette. The palette is the contract for everything downstream: asset catalog color sets, `.tint`, and SwiftUI `Color` values all trace back to it.

## Step C: Generate 1-3 Visual Mocks Against the Palette

Once the palette is confirmed, generate **1 to 3** high-fidelity north-star comps. Each mock must use the confirmed palette and type pairing. Mocks differ in structural direction (hierarchy, density, composition), not in color or motif.

- **Brand work:** push visual identity, composition, mood, and signature motifs.
- **Product work:** push hierarchy, topology, density, and tone, grounded in realistic product structure.
- **App surfaces meant to layer on Liquid Glass:** show enough of the underlying material to establish how the imagery recedes, anchors, or contrasts with the glass layer. Do not generate opaque backgrounds where the design calls for `.ultraThinMaterial` or `.thickMaterial`.

Use the `image_gen` tool directly (or via the imagegen skill when available). Do not ask the user to install anything.

## Step D: Approval Loop

Show the comps. Ask what carries forward. Iterate until **one direction is approved** or the user explicitly delegates.

**STOP and wait for the approval or the delegation.** Do not begin Step E or return to craft.md Step 4 until a single direction is named. If the user delegates, pick the strongest direction and explain it from the brief, not from personal taste.

Before moving to assets, summarize what to carry into code and what not to literalize from the mock. This is the handoff between visual exploration and semantic SwiftUI implementation.

## Step E: Mock Fidelity Inventory

Inventory the approved mock's major visible ingredients. For each, decide implementation: SwiftUI native, SF Symbol, generated raster in the asset catalog, sourced photography, or accepted omission.

Common ingredients to inventory:

- Hero silhouette and dominant composition
- Signature motifs (device frames, route lines, charts, badges, portraits, insets)
- Navigation and primary CTA treatment
- Section sequence, including content below the first fold
- Image-native content the concept depends on (photography, illustration, product shots)
- Typography pairing, density, color and material treatment, motion cues

For each ingredient, answer the question: can SwiftUI produce this credibly without a raster asset?

| Ingredient type | Preferred implementation |
| --- | --- |
| Icon or pictogram | `Image(systemName:)` + SF Symbols 7+ |
| Brand symbol with no SF Symbols match | Custom `.symbolset` in asset catalog |
| Color swatch or gradient | `Color` + asset catalog color set |
| Photography, illustration, product shot | `.imageset` in asset catalog, PDF or PNG |
| Decorative shape or ornament | `Shape`, `Canvas`, or SwiftUI path |
| Animated motif | SwiftUI animation or Lottie if complex |
| Full-bleed background image | `Image("name").resizable()` + `.scaledToFill()` |

Do not rasterize core UI text. A generated mock where the body copy is pixel-baked into a PNG cannot scale with Dynamic Type and will fail at any accessibility size. Text stays in `Text` views; images carry the visual content that text cannot.

**If the live implementation lacks the mock's major ingredients, the implementation is wrong.** Treat the mock as a north star, not a tracing. Do not substitute a different hero composition post-approval without user sign-off.

## Step F: Asset Production

Raster ingredients identified in Step E need clean production assets placed into the app's `.xcassets` bundle. Follow this workflow:

### Asset catalog structure

Every raster asset lives in an `.imageset` folder inside `Assets.xcassets`. The folder name becomes the string you pass to `Image("name")`.

```
Assets.xcassets/
  HeroBackground.imageset/
    Contents.json
    HeroBackground@1x.pdf     ← vector preferred
    HeroBackground@2x.png     ← fallback for PNGs without vector source
    HeroBackground@3x.png
  BrandMark.imageset/
    Contents.json
    BrandMark.pdf             ← universal, single file, vector
```

**Vector first.** A single PDF in the `.imageset` with "Scales" set to "Single Scale" in the asset catalog covers all display densities without managing three PNG files. Use PDF for any asset that can be drawn as a vector (logo marks, illustrations, diagrams, ornaments). Reserve `@1x/@2x/@3x` PNGs for photographic content, pixel-art, or any raster asset where a PDF rendering artifact would be visible.

### Appearance variants

Every asset that appears on both light and dark surfaces needs an appearance variant. In Xcode, set the Appearances attribute on the `.imageset` to "Any, Dark." Place the light-mode asset under "Any Appearance" and the dark-mode asset under "Dark." The asset catalog `Contents.json` records this:

```json
{
  "images": [
    { "idiom": "universal", "filename": "HeroBackground-Light.pdf", "appearances": [] },
    { "idiom": "universal", "filename": "HeroBackground-Dark.pdf",
      "appearances": [{ "appearance": "luminosity", "value": "dark" }] }
  ]
}
```

In SwiftUI, `Image("HeroBackground")` picks the correct variant automatically based on `colorScheme`. You do not need `.environment(\.colorScheme, .dark)` at the call site.

To preview both appearances without launching a simulator, add a `#Preview` pair:

```swift
#Preview("Light") {
    HeroView()
        .environment(\.colorScheme, .light)
}

#Preview("Dark") {
    HeroView()
        .environment(\.colorScheme, .dark)
}
```

### SF Symbols vs. custom assets: the decision tree

Before producing a raster asset for a pictographic ingredient, run this check:

1. **Does SF Symbols 7+ have a match?** Check the SF Symbols app (available from developer.apple.com). If yes, use `Image(systemName:)`. No asset file needed.
2. **Does the form exist but at the wrong weight, style, or variant?** Author a custom `.symbolset` override in the asset catalog, or annotate an exported SVG using the SF Symbols template. Still no PNG.
3. **Is the ingredient photographic or genuinely illustrative?** Generate the asset and drop it into an `.imageset`. Use PDF if the source is vector; PNG if it is raster.
4. **Is the ingredient a logotype or wordmark?** PDF in an `.imageset`. Never rasterize a wordmark into a PNG.

SF Symbols 7 shipped with iOS 26 and macOS 26 (the baseline for this toolkit). The full catalog at that version includes over 6,000 symbols across all weight and scale variants. The correct first answer for any pictographic need is "check SF Symbols," not "generate an image."

### Downstream validation

After dropping assets into the catalog, run the asset-catalog-checker to confirm coverage:

```bash
swift tools/asset-catalog-checker/check.swift path/to/App.xcassets
```

The checker reports: unresolved `Image(systemName:)` calls that could use an SF Symbol, PNG-only imagesets missing vector sources, and imagesets lacking dark appearance variants. Resolve every finding before moving to Step G.

See `tools/asset-catalog-checker/README.md` for the full rule set.

### Assets on Liquid Glass surfaces

When generated imagery is meant to sit beneath or beside a Liquid Glass layer (`.ultraThinMaterial`, `.regularMaterial`, `.thickMaterial`), treat opacity as a design variable, not a rendering accident.

- Images composited under a material layer should lean lower-contrast: the material's blur and vibrancy will shift perceived saturation. Generate source art at full contrast; reduce opacity or saturation at the SwiftUI call site so the result reads correctly over the material.
- Do not generate assets with fake blur, fake vibrancy, or simulated glass edges baked in. Those are the material's job. Baked-in effects conflict with the real material and produce visual doubling.
- Use `.resizable().scaledToFill().opacity(0.6)` (or similar) rather than pre-baking the reduced opacity into the source PNG. The opacity value should live in SwiftUI code so it can be tuned without re-exporting assets.

## After This File

Once Steps A through F are complete, return to `craft.md` Step 5 (Build to Production Quality). The SwiftUI implementation builds against the confirmed palette, the approved mock, and the assets committed to the `.xcassets` bundle. Every `Color` comes from the asset catalog or a semantic SwiftUI color. Every pictographic element is either a system symbol or a catalogued asset. Text stays in `Text` views and scales with Dynamic Type.

---

## When Image Generation Is Not Available

If the harness has no image generation capability, skip Steps A through F entirely.

Substitute the following for generated palette and mocks:

- **Palette:** Define `Color` values directly in the asset catalog as color sets. Use the Xcode color picker to land hues. Reference the confirmed palette in prose so the rest of the team can apply it.
- **Mocks:** Use Xcode Previews with placeholder shapes (`RoundedRectangle`, `Color.gray.opacity(0.15)`) to sketch composition before implementing content. This is lower fidelity than a generated comp but keeps the review loop inside Xcode.
- **Photography:** Use SF Symbols' multicolor glyphs as structural placeholders, or `AsyncImage` pointed at a temporary URL (Unsplash, Picsum Photos) during development. Remove placeholder URLs before shipping.
- **Illustrations:** Scope them as a deferred deliverable. Mark the call site with `// TODO: illustration asset, pending art production` and ship a placeholder `RoundedRectangle` with the correct aspect ratio and background color.

The four stop points still apply to the parts of the workflow that do not require image generation: Step A questions (direction conversation), Step E inventory (deciding what is raster vs. native), and the downstream validation run.

---

**Avoid:** Baking UI text into PNG assets. Generating assets with fake blur or vibrancy that conflicts with a real material layer. PNG-only imagesets where a single PDF would cover all display densities. Skipping dark appearance variants for any asset that appears on a themed surface. Mixing `Image(systemName:)` and `Image("custom")` on the same surface without the SF Symbols decision tree. Pre-baking opacity or saturation adjustments into the source file instead of applying them in SwiftUI.
