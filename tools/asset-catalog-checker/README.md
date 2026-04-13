# asset-catalog-checker

A POC single-file Swift script that walks a Swift project's asset catalogs and flags bundled-PNG `Image("name")` references where an SF Symbol with the same (or semantically equivalent) name exists. Most apps ship more bundled PNGs than they need — SF Symbols render at every size, tint with any color, and weigh nothing.

## Run

```sh
swift tools/asset-catalog-checker/check.swift <path-to-project-or-xcassets>
```

You can point it at an `.xcassets` directory directly, or at a parent directory that contains one or more `.xcassets` plus Swift source.

## What it does

1. Recursively finds every `*.xcassets` directory under the given path.
2. Enumerates `*.imageset/` (PNG-backed assets) and `*.symbolset/` (custom SF Symbols) inside each catalog.
3. Scans every `.swift` file under the given path for `Image("name")` calls (string literal only — see "Known limits" below).
4. For each imageset-backed `Image("name")`, checks a small hardcoded mapping table for a semantically-equivalent Apple SF Symbol. If one exists and the project does not already ship a `name.symbolset`, prints a finding:

   ```
   <swift-file>:<line>: consider SF Symbol "<sf-name>" in place of bundled PNG "<name>"
   ```

5. Exits `0` if there are no findings (or no asset catalog was found), `1` otherwise.

## Why the silent cases

- **Imageset with no SF Symbol match** → silent. Custom illustrations, logos, and brand art are legitimately bundled PNGs.
- **Imageset and symbolset with the same name** → silent. The project ships a custom SF Symbol version of that asset; the user made that choice intentionally.

## SF Symbol mapping (v1)

The checker ships a hardcoded dictionary of about 35 common PNG names → SF Symbol names. The mapping is intentionally conservative — when in doubt, leave an entry out, because false positives are worse than false negatives.

Current entries (one-way lookup, PNG-name → SF Symbol):

`gear` → `gearshape`, `settings` → `gearshape`, `star` → `star`, `heart` → `heart`, `plus` → `plus`, `add` → `plus`, `minus` → `minus`, `close`/`xmark`/`x` → `xmark`, `trash`/`delete` → `trash`, `pencil`/`edit` → `pencil`, `arrow-up` → `arrow.up`, `arrow-down` → `arrow.down`, `chevron-right` → `chevron.right`, `search`/`magnifyingglass` → `magnifyingglass`, `bell`/`notification` → `bell`, `person`/`user`/`profile` → `person`, `house`/`home` → `house`, `folder` → `folder`, `doc`/`document`/`file` → `doc`, `envelope`/`mail` → `envelope`, `phone` → `phone`, `camera` → `camera`, `mic`/`microphone` → `mic`, `speaker`/`volume` → `speaker.wave.2`, `play` → `play`, `pause` → `pause`, `stop` → `stop`, `forward` → `forward`, `backward` → `backward`, `gauge` → `gauge`, `bookmark` → `bookmark`, `cart`/`basket` → `cart`.

To add an entry, edit the `sfSymbolMap` constant at the top of `check.swift`.

## Known limits

- **Regex-based Swift parsing.** The checker uses a regex to find `Image("name")`. It will miss any call where `name` is a variable, a computed string, or an enum case (e.g. `Image(Theme.iconName)`). Proper SwiftSyntax parsing is a separate tool's job; this one just wants to catch the obvious cases.
- **Case-sensitive asset matching.** Imageset names are matched exactly as they appear on disk. The SF-Symbol lookup is case-insensitive, so `Image("Gear")` still flags if a `Gear.imageset` exists.
- **One SF Symbol suggestion per entry.** When a PNG name has several plausible matches, the map picks one — the goal is to nudge the developer to look, not to enumerate every option.

## Fixture

`fixtures/example.xcassets/` contains:

- `gear.imageset/` — should be flagged when referenced from Swift (SF Symbol `gearshape` exists).
- `custom-illustration.imageset/` — should not be flagged (no SF Symbol match — represents a legitimate bundled asset).

`fixtures/example-usage.swift` references both and exercises the checker end-to-end.

Run the fixture check:

```sh
swift tools/asset-catalog-checker/check.swift tools/asset-catalog-checker/fixtures/
```

Expected output: one finding for `Image("gear")`, exit code 1.
