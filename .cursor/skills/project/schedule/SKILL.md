---
name: schedule-calendar
description: Family Care schedule and calendar UI — first-party planner and month grid, hour bands, slot selection. Use when editing calendar, schedule, planner, or day timeline views. Extends code/web/ui.
disable-model-invocation: true
---

# Schedule & Calendar (project)

## Extends

Load `foundations/engineering` and `code/web/ui` first.

## Component boundary

| Component | Role |
|---|---|
| `CalendarPage.tsx` | Route entry for calendar view |
| `CalendarPageContent.tsx` | Calendar chrome, view mode, selection orchestration |
| `ScheduleViews.tsx` | Planner and month view switcher |
| `PlannerEventBlock.tsx` | Event blocks in day/week timeline |
| `MonthEventChip.tsx` | Event chips in month grid |

Feature pages use these components — do not duplicate planner/month logic in pages.

## Visual contract

All planner/month styling flows through:

- `web/src/styles/base.css` — grid tokens, hour bands, borders, radii
- `web/src/components/ui/schedule/common/` — planner and month components

### Do

- **Hour-band zebra** — alternate by hour row, not per 15-minute slot or day-column checkerboard
- **Strong hour lines**, lighter half- and quarter-hour lines
- **Vertical column dividers** between days
- **Full-bleed** planner — avoid extra nested frames that shrink the grid
- **Today** — subtle highlight on column + header, not loud checkerboard

### Do not

- Checkerboard `(row + col) % 2` fills across day columns
- Heavy outer padding + rounded boxes around the planner
- Duplicate grid styling outside `base.css` and schedule components

## Interaction

- Slot snap: `SCHEDULE.snapMinutes` (15) in `lib/constants.ts`
- Selection UI: `PlannerSelectionBar.tsx` + pointer gestures via `usePlannerPointerGesture.ts`
- Overlap layout: `lib/slotOverlap.ts`
- Scroll during drag: handled in `CalendarPageContent.tsx`

## Constants

`web/src/lib/constants.ts` — `SCHEDULE.snapMinutes`, `SCHEDULE.heightPerMinute`, and related schedule constants.

## When to load references

| Topic | Reference |
|---|---|
| Grid structure | `references/planner-grid.md` |
