# Accessibility (Flutter)

## Touch targets

- Minimum 48×48 logical pixels for tappable controls
- `IconButton` and nav destinations rely on theme padding — do not shrink below M3 defaults

## Labels

- `tooltip` on icon-only `IconButton` and nav icons
- `Semantics(label: …)` when icon + visible text is not enough
- Form fields: `labelText` / `decoration` — not placeholder-only

## Color & contrast

- Text on surfaces: `onSurface` / `onSurfaceVariant` from theme
- Do not convey state by color alone — add icon, weight, or label (e.g. conflict vs available slot)
- Grid lines: use `outlineVariant` with documented alpha in style modules

## Motion

- Respect platform reduced-motion when adding custom animations (prefer theme defaults)
- Avoid motion as the only indicator of selection — pair with color/weight

## Screen readers

- Buttons and links for actions — not `GestureDetector` on static text without semantics
- List tiles: meaningful `title` and `subtitle`

Project motion contract: `project/ui-interactions`. Project nav tooltips: `references/navigation.md`.
