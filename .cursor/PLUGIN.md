# Family Care Scheduler — Agent Plugin

Portable agent instructions for this Flutter + Firebase app. Structure mirrors the PersonalWebsite plugin: universal foundations, stack skills, then project-specific overlays.

## Layout

```
.cursor/skills/foundations/**     # language-agnostic engineering (always extends from here)
.cursor/skills/flutter/**         # Dart/Flutter architecture, Riverpod, UI
.cursor/skills/platform/**        # Firebase, notifications, WSL dev environment
.cursor/skills/project/**         # schedule calendar, tactile UI, docs
.cursor/skills/meta/**            # skill/rule maintenance
.cursor/rules/foundations/**      # always-applied engineering principles
.cursor/rules/flutter/**          # glob rules → flutter skills
.cursor/rules/project/**          # glob rules → project skills
AGENTS.md                         # entry point, commands, phase order
```

## Inheritance

```
foundations/engineering
  └─ flutter/architecture
       ├─ flutter/riverpod
       └─ flutter/ui
            └─ project/ui-interactions
            └─ project/ux
            └─ project/schedule (first-party calendar + planner)
platform/{firebase,notifications,wsl-dev}  # extends engineering; no weakening
project/docs
```

Downstream skills add stricter domain rules; they never contradict or loosen `foundations/engineering`.

## Load order for agents

1. `AGENTS.md`
2. `.cursor/skills/foundations/engineering/SKILL.md` (before any code change)
3. Domain skill for the task (`flutter/*`, `platform/*`, or `project/*`)
4. `references/` files only when a decision needs deep guidance — do not preload
