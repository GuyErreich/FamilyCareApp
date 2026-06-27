# Family Care Scheduler — Agent Guide

## Read First

1. `.cursor/skills/family-care-flutter/SKILL.md` — architecture and conventions
2. `.cursor/skills/family-care-docs/SKILL.md` — documentation workflow
3. `README.md` — setup and Firestore schema

## Structure

- `lib/core/` — theme, router, providers, utilities
- `lib/features/` — feature modules (auth, shifts, dashboard, ...)
- `lib/shared/widgets/` — reusable UI components

## Commands

```bash
task get    # flutter pub get
task gen    # build_runner
task test   # flutter test
task analyze
```

## Phase Order

Setup → models → data layer → auth → dashboard → calendar → shifts → family → notifications → Google Calendar → polish → tests.
