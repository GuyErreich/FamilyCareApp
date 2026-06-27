---
name: schedule-calendar
description: Family Care schedule and calendar UI — infinite_calendar_view wrappers, planner grid, hour bands, slot selection, and month grid. Use when editing calendar, schedule, planner, or day timeline views. Extends flutter-ui.
disable-model-invocation: true
---

# Schedule & Calendar (project)

## Extends

Load `foundations/engineering`, `flutter/architecture`, and `flutter/ui` first.

## Package boundary

`infinite_calendar_view` is wrapped by:

| Widget | Role |
|---|---|
| `FamilySchedulePlanner` | Day/week planner, slot selection, events |
| `FamilyScheduleMonth` | Month grid with shift chips |

Feature pages (`calendar_page`, `dashboard_page`, `day_schedule_page`) use these wrappers — **do not** import `infinite_calendar_view` directly in feature pages.

## Visual contract

All planner/month styling flows through:

- `schedule_calendar_style.dart` — tokens, frame, colors
- `planner_slot_painters.dart` — hour bands, grid lines, gutters, column dividers

### Do

- **Hour-band zebra** — alternate by hour row (`plannerHourBandColor`), not per 15-minute slot or day-column checkerboard
- **Strong hour lines**, lighter :30 and :15/:45 lines
- **Vertical column dividers** between days
- **Full-bleed** planner — `calendarFramePadding` is zero; avoid extra nested frames that shrink the grid
- **Today** — subtle `primaryContainer` blend on column + header, not loud checkerboard

### Do not

- Checkerboard `(row + col).isOdd` fills across day columns
- Heavy outer `Padding` + rounded `ClipRRect` boxes around the planner
- Duplicate painter logic outside `planner_slot_painters.dart`

## Interaction

- Slot snap: `ScheduleConstants.snapMinutes` (15)
- Selection UI: `FamilyInteractiveSlot` + `ScheduleSlotConfirmBar`
- Overlap: `SlotOverlapResolver` (client UX); conflicts clear selection when not dragging

## Constants

`lib/features/schedule/domain/schedule_constants.dart` — `heightPerMinute`, `daySeparationWidth`, `daysShowed`, scroll offsets.

## When to load references

| Topic | Reference |
|---|---|
| Grid painter structure | `references/planner-grid.md` |
