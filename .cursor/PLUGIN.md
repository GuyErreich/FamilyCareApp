# Family Care Scheduler — Agent Plugin

Portable agent instructions for this React + Supabase PWA. Structure mirrors the PersonalWebsite plugin: universal foundations, stack skills, then project-specific overlays.

## Layout

```
.cursor/skills/foundations/**     # language-agnostic engineering (always extends from here)
.cursor/skills/platform/**        # WSL dev environment
.cursor/skills/project/**         # schedule calendar, tactile UI, docs, Supabase
.cursor/skills/meta/**            # skill/rule maintenance
.cursor/rules/foundations/**      # always-applied engineering principles
.cursor/rules/project/**          # glob rules → project skills
AGENTS.md                         # entry point, commands, phase order
web/AGENTS.md                     # web client layout and conventions
```

## Inheritance

```
foundations/engineering
  ├─ code/web/libs/react
  └─ code/web/ui
       ├─ project/ui-interactions
       ├─ project/ux
       └─ project/schedule (first-party calendar + planner)
project/platform/supabase         # extends engineering; no weakening
project/docs
```

Downstream skills add stricter domain rules; they never contradict or loosen `foundations/engineering`.

## Load order for agents

1. `AGENTS.md`
2. `.cursor/skills/foundations/engineering/SKILL.md` (before any code change)
3. Domain skill for the task (`code/web/*`, `project/*`, or `platform/wsl-dev`)
4. `references/` files only when a decision needs deep guidance — do not preload
