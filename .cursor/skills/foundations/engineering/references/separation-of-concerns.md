# Separation of Concerns

One module, one reason to change.

## Four concerns to keep apart

- **Data** — Firestore queries, DTOs, repository implementations.
- **Orchestration** — use-cases, notifiers, business rules, overlap validation.
- **Presentation** — widgets, pages, layout; dispatch intents only.
- **I/O and side effects** — Firebase, FCM, local notifications, Google Calendar API.

Widgets must not embed business rules. Use-cases and repositories must not import `material.dart`.

## This project's layer mapping

```
lib/features/<name>/
  data/           # repositories impl, DTOs
  domain/         # entities, repository interfaces, use-cases
  presentation/   # pages, widgets, providers (Riverpod wiring)
```

Cross-cutting: `lib/core/` (router, theme, utils). Reusable UI: `lib/shared/widgets/`.

## Smell

If you cannot describe a module's job in one sentence without "and", it has more than one concern.
