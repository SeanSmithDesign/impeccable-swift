# impeccable-swift

v0.1.0-poc — proof of concept, not production-grade. Faithful Swift/SwiftUI port.

impeccable-swift builds on [impeccable](https://github.com/pbakaus/impeccable) by Paul Bakaus (Apache 2.0). See NOTICE.md for full attribution chain.

Based on impeccable pinned at `00d485659` (2026-04-12).

## Install

```
npx skills add SeanSmithDesign/impeccable-swift
```

Note: this repo is private during the build phase. The `npx skills` install path becomes usable once the repo is flipped public at POC launch.

## What this is

A Swift/SwiftUI-flavored design-quality skill family, scoped to iOS 26+ and macOS 26+ with Liquid Glass as first-class vocabulary. Three skills ship in v1:

- **impeccable-swift** — umbrella skill carrying the 12 reference docs (8 ported from upstream + 4 Swift-native).
- **critique** — evaluate a SwiftUI file or view against the reference docs and the project's `DESIGN.md` tokens.
- **polish** — tighten generated SwiftUI code against the same rules.

Behind the skills is a three-tool detector stack: SwiftLint `custom_rules` for line-local patterns, a `SwiftSyntax` CLI (`impeccable-lint`) for AST-level checks, and an asset-catalog checker for SF Symbol vs PNG resolution.

## What this isn't

- Not a production-grade release — explicitly a proof of concept.
- Not a backport. iOS <26 / macOS <26 are not supported in v1.
- Not a rebrand. Paul's voice, structure, and philosophy are preserved; Swift-specific docs are additive.

## Links

- [NOTICE.md](./NOTICE.md) — attribution chain.
- [UPSTREAM.md](./UPSTREAM.md) — upstream surveillance log and pinned SHA.
- [CHANGELOG.md](./CHANGELOG.md) — release notes.
