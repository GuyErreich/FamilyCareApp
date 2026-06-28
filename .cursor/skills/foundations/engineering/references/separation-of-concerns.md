# Separation of Concerns

One module, one reason to change.

## Four concerns to keep apart

- **Data** — Supabase queries, typed row mapping, client configuration.
- **Orchestration** — hooks, business rules, overlap validation, mutation logic.
- **Presentation** — React components, layout; dispatch intents only.
- **I/O and side effects** — Supabase Realtime, Web Push, Google Calendar API.

Components must not embed business rules. Hooks and `lib/` utilities must not import presentation-only concerns.

## This project's layer mapping

```
web/src/
  pages/              # route screens — compose hooks + components
  components/ui/      # presentation
  hooks/              # data fetching, mutations, feature state
  lib/                # supabase client, types, pure utilities
  styles/             # global CSS and design tokens
```

## Smell

If you cannot describe a module's job in one sentence without "and", it has more than one concern.
