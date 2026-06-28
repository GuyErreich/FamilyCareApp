# Planner Grid

## Component stack

1. `ScheduleViews.tsx` — planner layout, hour bands, column structure
2. `PlannerEventBlock.tsx` — positioned event blocks on the timeline
3. CSS in `base.css` — hour lines, gutters, column dividers

## Hour band index

Hour bands alternate by full hour height (4 × 15-minute slots), not individual 15-minute cells. Styling uses CSS classes and variables in `base.css`.

## Day separation

Visual separation comes from column divider styles, not wide gutters.

## Month grid

Month view uses bordered rounded day cells with uniform base fill; today highlight via border + tint. No alternating column colors.

`ScheduleViews.tsx` renders six-week month grid; outside-month days use muted styling.

## Scroll safety

`CalendarPageContent.tsx` handles scroll position during date jumps and drag interactions.

## Constants

```typescript
// web/src/lib/constants.ts
SCHEDULE.snapMinutes      // 15
SCHEDULE.heightPerMinute  // pixels per minute in planner
```

Used by `slotOverlap.ts`, `PlannerEventBlock.tsx`, and pointer gesture hooks.
