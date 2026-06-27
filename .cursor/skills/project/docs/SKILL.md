---
name: family-care-docs
description: Updates Family Care Scheduler documentation incrementally. Use when completing a phase, adding a feature module, exposing a new repository or use-case, or when the user mentions docs, README, or dartdoc.
disable-model-invocation: true
---

# Documentation

## Extends

Load `foundations/engineering` when documenting architecture boundaries.

## Workflow

1. Read `README.md` and `lib/family_care_scheduler.dart`.
2. Update only README sections affected by the change.
3. Revise the library header module index when a new `features/*` folder ships.
4. Add brief `///` dartdoc to **new public** types only.
5. Never add verbose inline comments — refactor for clarity instead.
6. When project structure or skill layout changes, update `AGENTS.md` and `.cursor/PLUGIN.md`.

## Documentation layers

| Layer | Location | Scope |
|---|---|---|
| Project | `README.md` | Setup, architecture, collections |
| Agent entry | `AGENTS.md` | Commands, skill index, phase order |
| Library | `lib/family_care_scheduler.dart` | Package intent, module index |
| Public API | `///` on exported classes | 1–3 lines max |

## Do not document

- `build()` methods
- Private helpers
- Obvious getters
- Widget implementation details

## Skill changes

When adding skills, follow `.cursor/PLUGIN.md` inheritance layout and `meta/improvement-protocol`.
