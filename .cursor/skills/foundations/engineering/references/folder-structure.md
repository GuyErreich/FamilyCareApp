# Folder Structure (Family Care Scheduler)

## Paths

| Responsibility | Location |
|---|---|
| Feature modules | `lib/features/<name>/{data,domain,presentation}/` |
| Shared widgets | `lib/shared/widgets/` |
| Theme, router, motion | `lib/core/theme/`, `lib/core/router/` |
| App-wide providers | `lib/core/providers/` |
| Firestore collection names | `lib/core/constants/firestore_collections.dart` |

## Rules

- **Shared vs feature-local is obvious from the path.** If two features need it, move to `shared/` or `core/`.
- **Group what changes together.** Shift UI, overlap logic, and shift repository live under `features/shifts/`.
- **Thin pages.** Pages compose widgets and wire providers; extract when `build()` exceeds ~80 lines.

## Anti-patterns

- Business logic in a `*_page.dart` widget.
- A reusable widget buried inside one feature's `presentation/pages/`.
- Duplicating calendar styling outside `schedule_calendar_style.dart` and `planner_slot_painters.dart`.
