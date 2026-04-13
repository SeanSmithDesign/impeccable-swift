# Brief 02 — List with Empty State

**Prompt:**

> Build a SwiftUI list view of recent documents with a title, last-edited date, and filetype icon. Include an empty-state view for when there are no documents. Target iOS 26+.

**Exercises:**

- `navigation` (`NavigationStack` + `.navigationTitle`, large title behavior)
- `typography` (title/subtitle hierarchy, date formatting with Dynamic Type)
- `ux-writing` (empty-state copy — clear, no "Oops!" or "Uh-oh")
- `interaction-design` (`ContentUnavailableView` API, swipe actions on rows)
- `sf-symbols` (filetype glyphs with a single rendering mode)
- `materials` (list row background, separators)

**Expected signals in the "with" output:**

- `NavigationStack` at the root with `.navigationTitle("Recent")` (or similar) and default large-title behavior
- Empty state rendered via `ContentUnavailableView` (iOS 17+) — **not** a custom `VStack` with a centered "No documents" Text
- Empty-state copy is declarative and helpful ("No recent documents" + a short description), not apologetic
- Row layout uses `Label` or `HStack` with an SF Symbol filetype icon; symbol uses a single rendering mode (monochrome / hierarchical / palette), not a mix
- Date formatted with `Text(date, format: .relative(presentation: .named))` or `.dateTime` — not a hardcoded `DateFormatter` with a magic string
- `List` style is `.plain` or `.insetGrouped` appropriate to the content; row background uses a `Material` or semantic surface where a background is needed
- Swipe actions on rows (delete, archive) using `.swipeActions` with appropriate role/tint
- `#Preview` shows both populated and empty states

**Known failure modes in the "without" output:**

- Empty state as a bespoke `VStack` with `Spacer()`s and a gray `Text` — no `ContentUnavailableView`
- Empty-state copy is either too chirpy ("Oops! Nothing here yet!") or too terse ("Empty")
- Date formatted via `DateFormatter()` with a literal format string
- Filetype icon as a PNG `Image("pdf-icon")` instead of an SF Symbol
- Row uses fixed `.frame(height: 60)` instead of letting content and Dynamic Type drive height
- Only one `#Preview`, always showing data — no empty-state preview
