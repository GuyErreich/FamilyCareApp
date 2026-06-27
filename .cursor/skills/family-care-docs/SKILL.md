---
name: family-care-docs
description: Updates Family Care Scheduler documentation incrementally. Use when completing a phase, adding a feature module, exposing a new repository or use-case, or when the user mentions docs, README, or dartdoc.
---

# Family Care Docs

## Workflow

1. Read `README.md` and `lib/family_care_scheduler.dart`.
2. Update only README sections affected by the change.
3. Revise the library header module index when a new `features/*` folder ships.
4. Add brief `///` dartdoc to **new public** types only.
5. Never add verbose inline comments — refactor for clarity instead.

## Documentation Layers

| Layer | Location | Scope |
|-------|----------|-------|
| Project | `README.md` | Setup, architecture, collections |
| Library | `lib/family_care_scheduler.dart` | Package intent, module index |
| Public API | `///` on exported classes | 1–3 lines max |

## Do Not Document

- `build()` methods
- Private helpers
- Obvious getters
- Widget implementation details
