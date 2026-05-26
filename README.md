# impeccable-swift

v0.3.0: Swift/SwiftUI port of [impeccable](https://github.com/pbakaus/impeccable) by Paul Bakaus (Apache 2.0). See NOTICE.md for full attribution chain.

Based on impeccable pinned at `4af581e2` (skill-v3.1.1, 2026-05-26).

## Install

```
npx skills add SeanSmithDesign/impeccable-swift
```

## What this is

A Swift/SwiftUI-flavored design-quality skill, scoped to iOS 26+ and macOS 26+ with Liquid Glass as first-class vocabulary. One skill, 23 sub-commands:

```
/impeccable-swift <sub-command>
```

Sub-commands by group:

- **craft:** shape, audit, critique
- **render:** animate, bolder, colorize, delight, layout, overdrive, quieter, typeset
- **fix:** adapt, clarify, distill
- **ship:** harden, onboard, optimize, polish
- **reference:** teach, document, extract, live

Behind the skill is a three-tool detector stack: SwiftLint `custom_rules` for line-local patterns, a `SwiftSyntax` CLI (`impeccable-lint`) for AST-level checks, and an asset-catalog checker for SF Symbol vs PNG resolution.

## Register

Two files at project root are read automatically on every invocation via `load-context.mjs`:

- `PRODUCT.md`: product register: goal, audience, voice
- `DESIGN.md`: token register: palette, type, spacing

Place both files at the root of the host project. If absent, the skill runs without project context.

## Live Mode

Browser-based Live Mode from upstream is stubbed: there is no Apple-native analog. Xcode Previews and SnapshotPreviews serve this purpose on Apple platforms. See `reference/live.md` for details.

## What this isn't

- Not a backport. iOS <26 / macOS <26 are not supported.
- Not a rebrand. Paul's voice, structure, and philosophy are preserved; Swift-specific docs are additive.

## Links

- [NOTICE.md](./NOTICE.md): attribution chain.
- [UPSTREAM.md](./UPSTREAM.md): upstream surveillance log and pinned SHA.
- [CHANGELOG.md](./CHANGELOG.md): release notes.
