# Brand register

When design IS the product: SwiftUI marketing apps, landing surfaces, conference shells, portfolio apps, App Store screenshot tooling, splash and onboarding hero surfaces, campaign experiences, long-form content readers, about screens. The deliverable is the design itself, a visitor's impression is the thing being made.

The register spans every genre. A tech brand (Stripe, Linear, Vercel, Arc). A luxury brand (a hotel, a fashion house). A consumer product (a restaurant, a travel app, a CPG packaging story). A creative studio, a designer's portfolio, a band's album release shell. They all share the stance, _communicate, not transact_, and diverge wildly in aesthetic. Don't collapse them into a single look.

**Apple platform doesn't mean product register.** A SwiftUI app can be brand register. A marketing shell shipped through the App Store, a portfolio app, a conference companion, a campaign mini-app, a hero onboarding surface that runs once, all of these live in the brand register even though they happen to be SwiftUI. The mistake the model makes is assuming "SwiftUI = product UI = restrained tinted neutrals + system semantic colors + plain `List`." Reject that reflex. If the brief is a marketing surface, treat it as one.

## The brand slop test

If someone could look at this and say "AI made that" without hesitation, it's failed. The bar is distinctiveness, a visitor should ask "how was this made in SwiftUI?", not "which AI made this?"

Brand isn't a neutral register. AI-generated landing pages and template SwiftUI shells have flooded the App Store, and average is no longer findable. Restraint without intent now reads as mediocre, not refined. Brand surfaces need a POV, a specific audience, a willingness to risk strangeness. Go big or go home.

**The second slop test: aesthetic lane.** Before committing to moves, name the reference. A Klim-style specimen page is one lane; Stripe-minimal is another; Liquid-Death-acid-maximalism is another; Apple's own product pages are yet another. Don't drift into editorial-magazine aesthetics on a brief that isn't editorial. A hiking brand with Cormorant italic drop caps has the wrong register within the register.

Then the inverse test: in one sentence, describe what you're about to build the way a competitor would describe theirs. If that sentence fits the modal app in the category, restart.

**The third slop test: SwiftUI tutorial smell.** If the hero surface looks like a SwiftUI tutorial screenshot, even a polished one, it's failed. A `VStack` of icon-title-subtitle cards with `cornerRadius(16)` and `.shadow(radius: 8)` is the brand-register equivalent of "AI made that." Rework the layout, not the polish.

## Typography

### Font selection procedure

Every project. Never skip.

1. Read the brief. Write three concrete brand-voice words, not "modern" or "elegant," but "warm and mechanical and opinionated" or "calm and clinical and careful." Physical-object words.
2. List the three fonts you'd reach for by reflex. If any appear in the reflex-reject list below, reject them, they are training-data defaults and they create monoculture.
3. Browse a real catalog (Google Fonts, Pangram Pangram, Future Fonts, Adobe Fonts, ABC Dinamo, Klim, Velvetyne) with the three words in mind. Find the font for the brand as a _physical object_, a museum caption, a 1970s terminal manual, a fabric label, a cheap-newsprint children's book, a concert poster, a receipt from a mid-century diner. Reject the first thing that "looks designy."
4. Cross-check. "Elegant" is not necessarily serif. "Technical" is not necessarily sans. "Warm" is not Fraunces. If the final pick lines up with the original reflex, start over.

SF Pro is not the brand-register answer by default. SF Pro is the product-register baseline (and a perfectly good one). For brand surfaces, the question is whether the voice calls for SF Pro's neutrality or for something with more specific character. A portfolio app for an industrial designer might commit to SF Pro Display at extreme weight contrast, treating Apple's own type as the voice. A hotel brand probably should not.

### Reflex-reject list

Training-data defaults. Ban list, look further:

Fraunces, Newsreader, Lora, Crimson, Crimson Pro, Crimson Text, Playfair Display, Cormorant, Cormorant Garamond, Syne, IBM Plex Mono, IBM Plex Sans, IBM Plex Serif, Space Mono, Space Grotesk, Inter, DM Sans, DM Serif Display, DM Serif Text, Outfit, Plus Jakarta Sans, Instrument Sans, Instrument Serif.

### Reflex-reject aesthetic lanes

Parallel to the font list. Currently saturated aesthetic families that have flooded SwiftUI brand surfaces. If a brief lands in one of these lanes without a register reason that _requires_ it (a literal magazine, a literal terminal, a literal industrial signage system), it's the second-order training reflex: the trap one tier deeper than picking a Fraunces font. Look further.

- **Editorial-typographic.** Display serif (often italic) + small mono labels + ruled separators + monochromatic restraint. Klim-influenced, magazine-cover affectation. The fingerprint in SwiftUI: three `VStack`-separated sections, an italic serif headline via `Font.custom`, lowercase tracked metadata, no imagery.

The reflex-reject lists apply to **new design choices**. When the existing brand has already committed to a font or a lane as part of its identity, identity-preservation wins; variants on an existing surface don't second-guess what's already shipping. The reflex-reject lists are for greenfield decisions.

### Pairing and voice

Distinctive + refined is the goal, the specific shape depends on the brand:

- **Editorial / long-form / luxury**: display serif + sans body (a magazine shape). In SwiftUI, ship a custom variable font as a `.ttf` / `.otf` in the bundle, register it via `UIAppFonts`, and call it through `Font.custom("FamilyName-PostScriptName", size:)`. Use `.fontDesign(.serif)` only as a last-resort fallback, not as the voice itself.
- **Tech / dev tools / fintech**: one committed sans, usually, custom-tight tracking via `.tracking()`, strong weight contrast inside a single family. SF Pro at `.heavy` against `.regular` can carry an entire surface if the scale ratio is committed.
- **Consumer / food / travel**: warmer pairings, often a humanist sans plus a script or display serif. Custom fonts via the bundle, same registration path.
- **Creative studios / agencies**: rule-breaking welcome, mono-only (`.monospaced()` or a custom mono family), or display-only, or custom-drawn type as voice.

Two families minimum is the rule _only_ when the voice needs it. A single well-chosen family with committed weight/size contrast is stronger than a timid display+body pair.

Vary across projects. If the last brief was a serif-display landing app, this one isn't.

See [typography](typography.md) for the full SwiftUI typography stack (Dynamic Type, `@ScaledMetric`, custom font registration, numeric styles).

### Scale

Modular scale, ≥1.25 ratio between steps. Flat scales (1.1× apart) read as uncommitted. SwiftUI's text style ladder (`.largeTitle` through `.caption2`) already encodes this, but on brand-register surfaces you'll often go bigger than `.largeTitle` allows. Reach for `.system(size:weight:design:)` or `Font.custom(_, size:)` with explicit sizes for hero type. Hero type at 96, 120, 160 points is brand-register territory and SwiftUI handles it fine.

Keep Dynamic Type respect even at hero scale. Wrap explicit hero sizes in `@ScaledMetric` so accessibility sizes scale them proportionally, don't lock hero type at a fixed point size.

Light text on dark backgrounds: nudge `lineSpacing` up by 2–4 points. Light type reads as lighter weight and needs more breathing room.

## Color

Brand surfaces have permission for Committed, Full palette, and Drenched strategies. Use them. A single saturated color spread across a hero surface is not excess, it's voice. A beige-and-muted-slate marketing app ignores the register.

- Name a real reference before picking a strategy. "Klim Type Foundry #ff4500 orange drench", "Stripe purple-on-white restraint", "Liquid Death acid-green full palette", "Mailchimp yellow full palette", "Condé Nast Traveler muted navy restraint", "Vercel pure black monochrome", "Apple Store hero gradient pure-black drench". Unnamed ambition becomes beige.
- Palette IS voice. A calm brand and a restless brand should not share palette mechanics.
- When the strategy is Committed or Drenched, the color is load-bearing. Don't hedge with system semantic colors around the edges, commit. `.primary` and `Color(.systemBackground)` are product-register defaults, not brand-register defaults.
- Don't converge across projects. If the last brand surface was restrained-on-cream, this one is not.
- When a cultural-symbol palette is the obvious pull, reach past it. Let the cultural reading come from typography, imagery, and copy, not the palette.
- Color Sets in the asset catalog still earn their place on brand surfaces, they give you free Dark Mode variants and OKLCH-tuned hex. But for hero color, hardcoded `Color(red:green:blue:)` from a deliberate OKLCH derivation is also acceptable, especially in Drenched strategies where the color itself is the brand mark.

See [color and contrast](color-and-contrast.md) for OKLCH reasoning and Color Set wiring.

## Layout

Brand-register layout is where the SwiftUI reflex hurts most. The model's instinct is `VStack { hero; features; cta }` with uniform padding. Reject it.

- **Asymmetric compositions are one option.** Break the grid intentionally for emphasis. SwiftUI's `Grid` (iOS 16+) and `GridRow` give you real grid control, use them. `.alignmentGuide()` lets you offset elements deliberately off the implicit grid.
- **Full-bleed hero layouts.** On iPad and Mac, brand heroes should run edge-to-edge. Use `.ignoresSafeArea()` deliberately, push imagery and color out to the screen edges, then bring type back inside a constrained reading column via `.frame(maxWidth: 720)` or `ViewThatFits`. The default `.padding()` shell is a product-register move.
- **Vary spacing for rhythm.** Generous separations, tight groupings. Build hierarchy by varying the 4 / 8 / 16 / 24 / 48 / 96 scale across regions, not by setting `.padding()` everywhere with the same default.
- **Alternative: a strict, visible grid as the voice** (brutalist / Swiss / tech-spec aesthetics). Either asymmetric or rigorously-gridded can be "designed", the failure mode is splitting the difference into a generic centered `VStack`.
- **Don't default to centering everything.** Left-aligned with asymmetric layouts feels more designed, a strict grid reads as confident structure. A centered `VStack` hero with `Image(systemName:)` + `.title` + `.body` cards reads as template.
- **When cards ARE the right affordance**, use `LazyVGrid(columns: [GridItem(.adaptive(minimum: 280))])` for breakpoint-free responsiveness, but vary the cards themselves, different sizes, different content shapes, not five identical tiles.
- **`ScrollView` is your friend.** Long scroll with deliberate pacing is a brand-register move. Don't collapse a marketing surface into a single non-scrolling screen because "iOS apps don't scroll." Apple's own marketing surfaces scroll for days.

See [responsive design](responsive-design.md) for size-class adaptation across iPhone, iPad, and Mac.

## Imagery

Brand surfaces lean on imagery. A restaurant app, hotel shell, magazine reader, or product launch screen without any imagery reads as incomplete, not as restrained. A solid-color rectangle where a hero image should go is worse than a representative stock photo.

**When the brief implies imagery (restaurants, hotels, magazines, photography, hobbyist communities, food, travel, fashion, product), you must ship imagery.** Zero images is a bug, not a design choice. "Restraint" is not an excuse.

- **For greenfield work without local assets, use stock imagery.** Add the photos to the asset catalog (Image Set with `@1x`/`@2x`/`@3x` if local, or a single high-res asset if not). Pick real Unsplash photos you've verified exist, download them into the bundle, give them descriptive names. If you can't ship real assets, at minimum render a representative `LinearGradient` or `Material`-backed surface with a short caption explaining what should go there, never a flat `Color.gray` block.
- **Search for the brand's physical object**, not the generic category: "handmade pasta on a scratched wooden table" beats "Italian food", "cypress trees above a limestone hotel facade at dusk" beats "luxury hotel".
- **One decisive photo beats five mediocre ones.** Hero imagery should commit to a mood, padding with more stock doesn't rescue an indecisive one. A single full-bleed `Image` with `.resizable().scaledToFill().frame(height: 600).clipped()` carries more weight than a `LazyVGrid` of three.
- **Alt text is part of the voice.** SwiftUI's `accessibilityLabel(_:)` on `Image` is the alt-text equivalent. "Coastal fettuccine, hand-cut, served on the terrace" beats "pasta dish".
- **SF Symbols are brand iconography only when chosen deliberately.** A hotel app with `Image(systemName: "bed.double.fill")` is product-register thinking leaking in. Custom SVG iconography (rendered as `Image` from the asset catalog with `.renderingMode(.template)`) is often the brand-register answer. When you do use SF Symbols on a brand surface, commit to a single weight and scale across the entire surface, see [SF Symbols](sf-symbols.md).

Tech / dev-tool brands are the exception where zero imagery can be correct, a developer-tool marketing app often carries its voice through typography, code samples, diagrams. Know which kind of brand you're working on.

## Materials and surface

Brand register is where Liquid Glass earns its keep. Product surfaces use materials sparingly (toolbars, controls, overlays). Brand surfaces can use them as expressive vocabulary.

- **Floating type over imagery.** A hero photo with a `Text` block on `.regularMaterial` or `.thinMaterial` reads as Apple-native and gives you free legibility. This is a brand-register move, on a product screen it usually is not.
- **`GlassEffectContainer` for related floating UI** (iOS 26+). On a brand surface this can be a stack of three CTAs floating over a video background, the container handles the unified rim and refraction.
- **Drenched color + Material.** A saturated background with a `.ultraThinMaterial` card sitting on top picks up the color through the blur, this is voice, not decoration.
- **Don't slap material on everything.** Glassmorphism-as-default is in the absolute bans for a reason. The brand permission is to use materials with intent, not to use them everywhere.

See [materials](materials.md) for the full Liquid Glass material ladder and `GlassEffectContainer` rules.

## Motion

- One well-orchestrated launch with staggered reveals beats scattered micro-interactions, when the brand invites it. Tech-minimal brands often skip entrance motion entirely, the restraint is the voice.
- Brand-register motion is where `.phaseAnimator(_:content:)` and `.keyframeAnimator(_:content:)` (iOS 17+) earn their place. Choreographed multi-stage entrances, type that draws on with a delayed cascade, an SF Symbol that morphs through `.symbolEffect(.bounce, options:, value:)` on first appear.
- Spring physics, `.smooth`, `.snappy`, `.bouncy` (iOS 17+). No bounce-on-arrival on product, but on a brand hero, a tuned `.bouncy(duration:extraBounce:)` arrival is sometimes exactly the move.
- Scroll-driven choreography via `.scrollTransition` and `ScrollView`'s `.containerRelativeFrame()`. This is a brand-register tool, not a product one.
- **Always respect `@Environment(\.accessibilityReduceMotion)`.** Even on hero surfaces. Provide a static fallback for every animated entrance.

See [motion design](motion-design.md) for the full SwiftUI animation stack.

## Brand bans (on top of the shared absolute bans)

- `.monospaced()` or a mono custom font as lazy shorthand for "technical / developer." If the brand isn't technical, mono reads as costume.
- Large `Image(systemName:)` with `.font(.largeTitle)` above every section heading. Screams template. SF Symbols-as-section-icons is one of the most reliable AI-SwiftUI tells.
- Single-family pages that picked the family by reflex, not voice. (A single family chosen deliberately is fine. SF Pro chosen by default is not.)
- All-caps body copy. Reserve `.textCase(.uppercase)` for short labels and headings.
- Timid palettes and average layouts. Safe = invisible.
- Zero imagery on a brief that implies imagery (restaurant, hotel, food, travel, fashion, photography, hobbyist). Flat `Color.gray` blocks where a hero photo belongs.
- Defaulting to editorial-magazine aesthetics (display serif + italic + drop caps + broadsheet grid) on briefs that aren't magazine-shaped. Editorial is ONE aesthetic lane, not the default brand aesthetic.
- Repeated tiny uppercase tracked labels above every section heading. A single strong kicker can be voice; repeating it as section grammar via `.textCase(.uppercase)` with `.tracking(2)` everywhere is AI scaffolding unless it's a deliberate, named brand system.
- Defaulting to the SwiftUI product baseline (tinted neutrals, `.systemBackground`, `List`, system semantic colors, SF Symbols at default weight) on a brand-register brief. The baseline is for product. Brand earns deviation.
- `NavigationStack` + `List` as the brand-register shell. A marketing app is not a Settings screen.

## Brand permissions

Brand can afford things product can't. Take them.

- **Ambitious launch motion.** `.phaseAnimator` reveals, scroll-triggered transitions via `.scrollTransition`, typographic choreography via `.transition(.text)` or per-character `Text` animation.
- **Single-purpose viewports.** One dominant idea per scroll fold, long scroll, deliberate pacing. `ScrollView` with `.containerRelativeFrame(.vertical)` per section is a brand-register pattern.
- **Typographic risk.** Enormous display type via `Font.custom(_, size: 160)`, unexpected italic cuts, mixed cases via per-character styling, hand-drawn headlines as `Image` assets, a single oversize word as a hero. Wrap in `@ScaledMetric` so Dynamic Type still respects it.
- **Unexpected color strategies.** Drenched OKLCH-derived hex, full-palette campaigns where each section has a different dominant color, Color Sets that swap dramatically between Light and Dark Mode rather than minimally.
- **Art direction per section.** Different sections can have different visual worlds if the narrative demands it. Consistency of voice beats consistency of treatment. A `ScrollView` of sections, each with its own color and type treatment, can be the right answer on a portfolio app.
- **Material as expressive surface.** Liquid Glass over video, drenched color through `.thinMaterial`, `GlassEffectContainer` carrying floating CTAs over a hero. This is brand vocabulary on Apple platforms, see [materials](materials.md).
- **Custom `ButtonStyle` and `LabelStyle`.** A brand-register CTA shouldn't use the default `.borderedProminent`. Build a custom `ButtonStyle` with the brand's type, color, and motion. This is one of the highest-leverage moves on a marketing surface.
- **Full-bleed hero layouts.** `.ignoresSafeArea()` with intent. Edge-to-edge imagery, color, video. Type pulled back into a constrained reading frame. This is brand-register Apple-platform work.
