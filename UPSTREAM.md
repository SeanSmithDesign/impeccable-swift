# Upstream Surveillance

**Pinned SHA:** `00d485659af82982aef0328d0419c49a2716d123`
**Pinned on:** 2026-04-12
**Upstream:** https://github.com/pbakaus/impeccable

## Review Cadence

Monthly during active upstream dev; quarterly if upstream slows.

## Notable Upstream Events

- **2026-04-24 — Impeccable 3.0 merged upstream** (PR #109, merge commit `6816558`, HEAD `f5e82162`). Major re-architecture: 18 standalone skills consolidated into one `/impeccable` skill with 23 sub-commands via a router pattern; new `brand` / `product` register system; mandatory `load-context.mjs` for PRODUCT.md + DESIGN.md; browser-based Live Mode (~2,500 lines across 7 `.mjs` scripts); `pin.mjs` shortcut shims; `command-metadata.json` single source of truth; a11y moved into `audit.md`. Typography (+45 lines) and craft (+70 lines) are the only ported reference docs with substantive text changes; the other six are unchanged. See `docs/3.0-upgrade-plan.md` for the port scope and locked decisions.

## Reviewed Upstream Commits

| Date       | SHA Range               | Reviewed By       | Incorporated | Rejected (with rationale) | Already Covered                                                                                    |
| ---------- | ----------------------- | ----------------- | ------------ | ------------------------- | -------------------------------------------------------------------------------------------------- |
| 2026-04-12 | pinned at `00d485659`   | initial pin       | —            | —                         | —                                                                                                  |
| 2026-04-16 | `00d485659` (no change) | pre-launch review | —            | —                         | upstream main unchanged since pin; PR #56 (Chrome extension / v2.0) was already merged at pin time |
| 2026-04-24 | `00d485659`..`f5e82162` (127 commits) | 3.0 review | port in progress on `claude/impeccable-3-0-upgrade-4MsLs`; pin to move to `f5e82162` at merge | Live Mode browser picker (no Apple-native analog; replaced with Xcode Previews + SnapshotPreviews stub under `reference/live.md`) | — |
