# Folder Structure (Family Care Scheduler)

## Paths

| Responsibility | Location |
|---|---|
| Route screens | `web/src/pages/` |
| Reusable UI | `web/src/components/ui/common/` and `web/src/components/ui/<domain>/` |
| Data hooks | `web/src/hooks/` (by domain: `auth/`, `family/`, `shifts/`, `schedule/`) |
| Supabase client, types, utilities | `web/src/lib/` |
| Global styles and tokens | `web/src/styles/` |
| Agent docs per area | `web/src/**/AGENT.md` |

## Rules

- **Shared vs feature-local is obvious from the path.** If two features need it, move to `components/ui/common/` or `lib/`.
- **Group what changes together.** Shift UI, overlap logic, and shift hooks live under shifts-related paths.
- **Thin pages.** Pages compose components and hooks; extract when a page exceeds ~80 lines.

## Anti-patterns

- Business logic embedded in page JSX.
- A reusable component buried inside one page file.
- Duplicating schedule styling outside `base.css` and `components/ui/schedule/common/`.
