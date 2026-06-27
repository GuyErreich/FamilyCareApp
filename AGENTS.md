# Family Care Scheduler — Agent Guide

## Read first

1. `.cursor/PLUGIN.md` — skill inheritance and layout
2. `.cursor/skills/foundations/engineering/SKILL.md` — universal principles (always)
3. `.cursor/skills/flutter/architecture/SKILL.md` — feature layers and routing
4. `README.md` — setup and Firestore schema

## Skill index

| When | Skill |
|---|---|
| Any code change | `foundations/engineering` |
| Features, repos, routes | `flutter/architecture` |
| Providers, AsyncValue | `flutter/riverpod` |
| Widgets, theme, layout | `flutter/ui` |
| Motion, cards, transitions | `project/ui-interactions` |
| UX quality bar, menus, states | `project/ux` |
| Planner / month calendar | `project/schedule` |
| Firestore, rules, functions | `platform/firebase` |
| FCM, local notifications | `platform/notifications` |
| WSL, adb, flutter doctor | `platform/wsl-dev` |
| README, dartdoc | `project/docs` |
| Update skills/rules | `meta/improvement-protocol` |

Load `references/` only when a skill's table points you there — do not preload.

## Structure

- `lib/core/` — theme, router, providers, utilities
- `lib/features/` — feature modules (auth, shifts, dashboard, …)
- `lib/shared/widgets/` — reusable UI components

## Commands

```bash
task get      # flutter pub get
task gen      # build_runner
task test     # flutter test
task analyze
```

## Phase order

Setup → models → data layer → auth → dashboard → calendar → shifts → family → notifications → Google Calendar → polish → tests.
