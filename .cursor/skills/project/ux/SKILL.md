---
name: ux-standards
description: Family Care Scheduler UI/UX quality bar — navigation, feedback, clarity, accessibility, and pre-ship checklist. Use when designing screens, menus, forms, empty states, or reviewing UI polish. Extends flutter-ui and ui-interactions.
disable-model-invocation: true
---

# UX Standards (project)

Minimum bar for every user-facing surface. If a change fails a **must** rule, fix it in the same change.

## Extends

Load `foundations/engineering`, `flutter/ui`, and `project/ui-interactions` first. Schedule views also need `project/schedule`.

## Principles

| Principle | Must | Deep detail |
|---|---|---|
| Clarity | User knows where they are and what to do next | `references/clarity-and-hierarchy.md` |
| Feedback | Every tap produces visible + haptic response | `references/feedback-and-states.md` |
| Consistency | Theme tokens, shared widgets, one nav definition | `references/navigation.md` |
| Accessibility | Tooltips, contrast, 48dp targets, semantic structure | `references/accessibility.md` |
| Space | Primary content fills the screen; chrome stays thin | `flutter/ui` fill rule |
| Recovery | Loading, error, and empty states are designed — not blank | `references/feedback-and-states.md` |

## Navigation contract

- Shell tabs defined only in `AppNavigationDestinations` / `app_navigation.dart`
- Bottom bar: floating pill (`AppNavigationBar`), haptic on tab change, tooltips on icons
- Tablet: `AppNavigationRail` with branded leading avatar
- Do not duplicate tab labels/icons in feature pages
- Pushed routes use `fadeSlidePage` / `sharedAxisPage` — not instant cuts

## Shared widgets (use before inventing)

| Need | Widget |
|---|---|
| Page chrome | `AppScaffold` |
| Shell menu | `AppNavigationBar`, `AppNavigationRail` |
| Tappable card | `AppCard` |
| Primary action | `PrimaryButton` |
| Async content | `AsyncValueWidget` |

## Pre-ship UI checklist

Copy and verify before marking UI work done:

```
- [ ] Uses theme colors/text — no stray hex except member shift colors
- [ ] Interactive targets ≥ 48dp; icon buttons have tooltip
- [ ] Loading / error / empty handled (AsyncValue or explicit widget)
- [ ] Motion from AppMotion; routes use page_transitions
- [ ] Primary content fills space — no unnecessary nested boxes
- [ ] New nav items added to AppNavigationDestinations only
- [ ] task analyze passes
```

## Anti-patterns (reject in review)

- Raw `NavigationBar` / `NavigationRail` in feature code
- Silent failures (empty `SizedBox.shrink()` without intentional design)
- Checkerboard or harsh alternating fills for structure
- `setState` for data that should be in Riverpod
- Ad-hoc `Duration` / `Curves` per screen

## When to load references

Load only when the matching decision arises — do not preload.
