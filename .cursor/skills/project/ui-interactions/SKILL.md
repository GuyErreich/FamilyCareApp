---
name: ui-interactions
description: Family Care tactile UI contract — CSS motion tokens, press feedback, rounded surfaces, and slide-up confirm bars. Use when adding buttons, cards, navigation, dialogs, or interactive schedule chrome. Extends code/web/ui.
disable-model-invocation: true
---

# UI Interactions (project)

Everything interactive should feel responsive: rounded surfaces, deliberate motion, and clear affordances. This is the project overlay on generic web UI rules.

## Extends

Load `foundations/engineering` and `code/web/ui` first. For UX review checklist, load `project/ux`. For schedule-specific grid rules, also load `project/schedule`.

## Motion tokens

Use CSS variables in `web/src/styles/base.css` — never invent ad-hoc `transition: 250ms` in feature code.

| Token | Use |
|---|---|
| `--motion-fast` | Press feedback, reverse transitions |
| `--motion-medium` | Page transitions, confirm bar enter |
| `--motion-spring` | Bottom sheet / confirm bar slide |

## Route transitions

- Page content uses CSS transitions on enter; avoid instant cuts for modal flows
- Sheets and confirm bars use `BottomSheet.tsx` or slide-up patterns

## Interactive widgets

| Element | Contract |
|---|---|
| `Card.tsx` | Rounded card; optional click with press feedback |
| `PrimaryButton.tsx` / `Button.tsx` | Min height 48px; theme button radius |
| `PlannerSelectionBar.tsx` | Slides up; rounded top; safe-area bottom |
| `TabBarNav.tsx` | Shell menu; haptic on change; floating pill on phone |

## Layout

- Prefer **fill** over **box** — schedules and lists use available height
- Cards and chips for metadata (legend, warnings) — not for constraining primary content
- Border radius: cards 18px, buttons 14px — use `--radius-card`, `--radius-button`

## Accessibility

- `aria-label` on icon-only buttons
- Sufficient contrast on hour lines and cell borders
- Respect `prefers-reduced-motion` when adding custom animations

## Anti-patterns

- Remounting the entire shell on tab change (breaks tab state)
- Checkerboard backgrounds for "readability"
- External animation durations per screen
