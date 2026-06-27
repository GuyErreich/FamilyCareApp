# Planner Grid

## Painter stack

1. `PlannerDaySlotBackgroundPainter` — column base color, hour bands, right-edge divider
2. `PlannerSlotGridPainter` — horizontal lines (hour / half / quarter)
3. `PlannerTimeGutterPainter` — gutter bands + labels aligned to hour lines

## Hour band index

```dart
// hourIndex = slot * snapMinutes ~/ 60
ScheduleCalendarStyle.plannerHourBandColor(scheme, hourIndex, isToday: isToday)
```

Bands span full hour height (4 × 15-minute slots), not individual 15-minute cells.

## Day separation

`ScheduleConstants.daySeparationWidth` — keep minimal (1px); visual separation comes from column divider paint, not wide gutters.

## Month grid

`ScheduleMonthWeek` — bordered rounded day cells (`monthDayCellBorder`), uniform base fill, today highlight via border + tint. No alternating column colors.

## Scroll safety

`calendar_page` uses double `addPostFrameCallback` before `jumpToDate` — preserve when changing navigation to avoid scroll controller assertions.
