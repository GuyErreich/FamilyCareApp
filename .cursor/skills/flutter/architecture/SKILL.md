---
name: flutter-architecture
description: Family Care Scheduler Flutter architecture — feature-first clean layers, repository pattern, routing, and naming. Use when adding features, repositories, use-cases, or reviewing lib/ structure. Extends engineering.
disable-model-invocation: true
---

# Flutter Architecture

## Extends

Load `.cursor/skills/foundations/engineering/SKILL.md` first. This skill adds Family Care Scheduler layout rules.

## Core rules

- Feature-first: `lib/features/<name>/{data,domain,presentation}/`
- Three layers per feature: **presentation** → **domain** ← **data**
- Widgets render state and dispatch intents only — no business rules in `build()`
- Repository interfaces in `domain/`; Firestore implementations in `data/`
- Shared UI in `lib/shared/widgets/`; cross-cutting in `lib/core/`

## Models

- Domain entities: freezed in `domain/entities/`
- Firestore DTOs: freezed + json_serializable in `data/dto/`
- After model changes: `task gen` (`dart run build_runner build --delete-conflicting-outputs`)

## Routing

- Routes: `lib/core/router/app_router.dart`, paths in `app_routes.dart`
- Auth flow: login → onboarding (no family) → shell (dashboard, calendar, family, settings)
- Detail routes use `page_transitions.dart` (`fadeSlidePage`, `sharedAxisPage`) — do not add unstyled `builder:` routes for pushed screens

## State

- See `.cursor/skills/flutter/riverpod/SKILL.md` for provider patterns
- `setState` only for local ephemeral UI (animation controllers, one-off form focus) — not for domain state

## Phase order (greenfield features)

Setup → models → data layer → auth → dashboard → calendar → shifts → family → notifications → Google Calendar → polish → tests.

## When to load references

| Topic | Reference |
|---|---|
| Feature folder layout | `foundations/engineering/references/folder-structure.md` |
| Layer boundaries | `foundations/engineering/references/separation-of-concerns.md` |
