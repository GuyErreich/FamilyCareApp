# Family Care Scheduler — Agent Guide

## Read first

1. `.cursor/PLUGIN.md` — skill inheritance and layout
2. `.cursor/skills/foundations/engineering/SKILL.md` — universal principles (always)
3. `README.md` — Supabase schema and setup; `docs/google-oauth.md` — Google OAuth Testing vs Production and verification
4. `web/AGENTS.md` — Vite client layout and conventions

## Skill index

| When | Skill |
|---|---|
| Any code change | `foundations/engineering` |
| React client, routes, hooks | `code/web/libs/react` + `code/web/ui` |
| Postgres, RLS, Edge Functions | `project/platform/supabase` |
| UX quality bar, menus, states | `project/ux` |
| Planner / month calendar | `project/schedule` |
| README, public API docs | `project/docs` |
| Update skills/rules | `~/.cursor/skills/meta/improvement-protocol` |

## Structure

- `web/` — Vite + React PWA (primary client)
- `supabase/` — Postgres migrations, RLS, Edge Functions

## Commands

```bash
task web:install
task web:dev
task web:build
task web:test
task web:lint
task supabase:start
task deploy:pages
```

## Delivery phases

Supabase backend → web scaffold → auth → core features → calendar → planner → PWA + deploy.
