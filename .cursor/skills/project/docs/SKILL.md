---
name: family-care-docs
description: Updates Family Care Scheduler documentation incrementally. Use when completing a phase, adding a feature module, exposing a new hook or utility, or when the user mentions docs, README, or JSDoc.
disable-model-invocation: true
---

# Documentation

## Extends

Load `foundations/engineering` when documenting architecture boundaries.

## Workflow

1. Read `README.md` and relevant `web/src/**/AGENT.md` files.
2. Update only README sections affected by the change.
3. Update `AGENT.md` in the affected folder when structure or conventions change.
4. Add brief JSDoc to **new public** exports only.
5. Never add verbose inline comments — refactor for clarity instead.
6. When project structure or skill layout changes, update `AGENTS.md` and `.cursor/PLUGIN.md`.

## Documentation layers

| Layer | Location | Scope |
|---|---|---|
| Project | `README.md` | Setup, architecture, schema |
| Agent entry | `AGENTS.md` | Commands, skill index, phase order |
| Web client | `web/AGENTS.md` | Layout, commands, env |
| Area guides | `web/src/**/AGENT.md` | Folder-specific conventions |
| Public API | JSDoc on exported functions/types | 1–3 lines max |

## Do not document

- JSX render trees
- Private helpers
- Obvious getters
- Component implementation details

## Skill changes

When adding skills, follow `.cursor/PLUGIN.md` inheritance layout and `meta/improvement-protocol`.
