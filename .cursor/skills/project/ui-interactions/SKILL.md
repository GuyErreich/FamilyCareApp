---
name: ui-interactions
description: Family Care tactile UI contract — AppMotion transitions, press feedback, rounded surfaces, and slide-up confirm bars. Use when adding buttons, cards, navigation, dialogs, or interactive schedule chrome. Extends flutter-ui.
disable-model-invocation: true
---

# UI Interactions (project)

Everything interactive should feel responsive: rounded surfaces, deliberate motion, and clear affordances. This is the project overlay on generic Flutter UI rules.

## Extends

Load `foundations/engineering` and `flutter/ui` first. For UX review checklist, load `project/ux`. For schedule-specific grid rules, also load `project/schedule`.

## Motion tokens

Use `lib/core/theme/app_motion.dart` — never invent ad-hoc `Duration(milliseconds: 250)` in feature code.

| Token | Use |
|---|---|
| `AppMotion.fast` | Press feedback, reverse transitions |
| `AppMotion.medium` | Page push, confirm bar enter |
| `AppMotion.slow` | Hero / login entrance |
| `AppMotion.spring` | Bottom sheet / confirm bar slide |
| `AppMotion.pressScale` | `AppCard` scale |

## Route transitions

- Pushed detail/form routes: `fadeSlidePage` or `sharedAxisPage` in `app_router.dart`
- Do not add bare `GoRoute(builder:)` for flows that should feel modal

## Interactive widgets

| Element | Contract |
|---|---|
| `AppCard` | Rounded card; optional `onTap` with scale feedback |
| `PrimaryButton` | Min height 48; uses theme `FilledButton` shape |
| `ScheduleSlotConfirmBar` | Slides up; rounded top radius 22; `SafeArea` bottom |
| `AppNavigationBar` / `AppNavigationRail` | Shell menu; haptic on change; floating pill on phone |

## Layout

- Prefer **fill** over **box** — schedules and lists use available height
- Cards and chips for metadata (legend, warnings) — not for constraining primary content
- Border radius: cards 18, buttons 14, dialogs 20 — extend theme, don't one-off

## Accessibility

- `tooltip` on `IconButton` actions
- Semantic labels on icon-only controls
- Sufficient contrast on hour lines and cell borders (`outlineVariant` alphas in `schedule_calendar_style`)

## Anti-patterns

- `AnimatedSwitcher` on `StatefulNavigationShell` (breaks tab state)
- Checkerboard backgrounds for "readability"
- External animation durations per screen

## When to load references

| Topic | Reference |
|---|---|
| Theme wiring | `flutter/ui/references/theme-and-motion.md` |
