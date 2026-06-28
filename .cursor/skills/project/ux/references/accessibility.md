# Accessibility (Web)

## Touch targets

- Minimum 48×48 CSS pixels for tappable controls
- Icon buttons rely on padding — do not shrink below accessible defaults

## Labels

- `aria-label` on icon-only buttons and nav icons
- Form fields: visible labels — not placeholder-only
- Meaningful button text for screen readers

## Color & contrast

- Text on surfaces: theme tokens from `base.css`
- Do not convey state by color alone — add icon, weight, or label (e.g. conflict vs available slot)
- Grid lines: use theme border colors with documented opacity

## Motion

- Respect `prefers-reduced-motion` when adding custom animations
- Avoid motion as the only indicator of selection — pair with color/weight

## Screen readers

- Use semantic HTML (`button`, `nav`, `main`) for actions and landmarks
- List rows: meaningful visible text content

Project motion contract: `project/ui-interactions`. Project nav labels: `references/navigation.md`.
