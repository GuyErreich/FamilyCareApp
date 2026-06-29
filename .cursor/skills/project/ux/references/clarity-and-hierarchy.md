# Clarity & Hierarchy

## Page structure

1. **Where am I?** — `AppBar` title or prominent date/header
2. **What matters?** — primary content gets `Expanded` / full width
3. **What can I do?** — FAB, confirm bar, or inline CTA at natural end of flow

## Typography

- One `headline*` or `titleLarge` per screen for the main subject
- Supporting copy: `bodyMedium` + `onSurfaceVariant`
- Do not stack more than two title-weight lines before content

## Visual weight

- Primary actions: `FilledButton` / `PrimaryButton`
- Secondary: `OutlinedButton` or `TextButton`
- Destructive: `error` color, confirm first

## Schedule-specific

- Legend and warnings above planner — compact chips/cards, not full-width boxes
- Planner consumes remaining height
- Calendar header (`_CalendarHeader`) is navigation chrome — keep one per calendar screen

## Density

- Care scheduling is information-dense — prefer clear grid lines and hour bands over decorative containers
- Padding: 16px screen edges for text; 0 for full-bleed grids
- **Motion clip boundary:** horizontal inset belongs on inner content (`.page-viewport__content`), not on the clipping ancestor — see `project/ui-interactions/references/shell-viewport-motion.md`
