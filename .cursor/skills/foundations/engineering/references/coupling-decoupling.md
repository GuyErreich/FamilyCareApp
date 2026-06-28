# Coupling & Decoupling

- **Couple** modules that always change together (e.g. shift type + database row mapping).
- **Decouple** modules that change for different reasons (e.g. planner grid CSS vs shift mutations).
- **Avoid** both duplication and premature abstraction.

## Web-specific

- Pages and components depend on hooks and `lib/` utilities — not on raw Supabase client calls scattered in JSX.
- Schedule UI stays behind `ScheduleViews.tsx` / `CalendarPageContent.tsx` — pages do not import planner internals directly.
- Theme tokens live in CSS variables — components use classes and tokens, not hardcoded colors.

When two features need the same data, share a hook in `web/src/hooks/`, not a cross-feature component import.
