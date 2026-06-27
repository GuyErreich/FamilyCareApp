---
name: flutter-ui
description: Flutter UI architecture for Family Care Scheduler — reuse-first widgets, theme tokens, layout fill, and extraction triggers. Use when designing or refactoring presentation code. Extends flutter-architecture.
disable-model-invocation: true
---

# Flutter UI Architecture

## Extends

Load `foundations/engineering` then `flutter/architecture` first. For motion and route polish, also load `project/ui-interactions`.

## Core rules

- **Reuse-first.** Search `lib/shared/widgets/` and feature `presentation/` before creating widgets.
- **Theme tokens.** Colors from `Theme.of(context).colorScheme`; motion from `AppMotion`; shapes from `AppTheme` — no magic hex in feature widgets.
- **Fill available space.** Prefer `Expanded`, `Flexible`, and edge-to-edge content over nested `Padding` + boxed frames unless deliberate chrome is needed.
- **Composition.** Pages compose; extract when `build()` exceeds ~80 lines.
- **const** constructors where possible.

## Shared building blocks

| Widget / module | Use for |
|---|---|
| `AppScaffold` | Standard page chrome + shell nav |
| `AppNavigationBar` / `AppNavigationRail` | Primary shell menu — do not duplicate |
| `AppCard` | Tappable rounded cards with press feedback |
| `PrimaryButton` | Primary CTA (filled, min height 48) |
| `AsyncValueWidget` | Loading / error / data states |
| `MemberAvatar` | Family member identity |

## Layout smells

- Calendar or planner wrapped in extra `Padding` + `DecoratedBox` that shrinks usable area
- Duplicate `BoxDecoration` blocks — extract to style module or theme
- Checkerboard or high-contrast alternating fills for readability — prefer hour bands + borders (see `project/schedule`)

## When to load references

| Topic | Reference |
|---|---|
| Extraction triggers | `references/reuse-extraction.md` |
| Theme, motion, transitions | `references/theme-and-motion.md` |

Load references only when the matching decision arises.
