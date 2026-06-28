---
name: ux-standards
description: Family Care Scheduler UI/UX quality bar — navigation, feedback, clarity, accessibility, and pre-ship checklist. Use when designing screens, menus, forms, empty states, or reviewing UI polish. Extends code/web/ui and ui-interactions.
disable-model-invocation: true
---

# UX Standards (project)

Minimum bar for every user-facing surface. If a change fails a **must** rule, fix it in the same change.

## Extends

Load `foundations/engineering`, `code/web/ui`, and `project/ui-interactions` first. Schedule views also need `project/schedule`.

## Principles

| Principle | Must | Deep detail |
|---|---|---|
| Clarity | User knows where they are and what to do next | `references/clarity-and-hierarchy.md` |
| Feedback | Every tap produces visible + haptic response | `references/feedback-and-states.md` |
| Consistency | Theme tokens, shared widgets, one nav definition | `references/navigation.md` |
| Accessibility | Labels, contrast, 48px targets, semantic structure | `references/accessibility.md` |
| Space | Primary content fills the screen; chrome stays thin | `code/web/ui` fill rule |
| Recovery | Loading, error, and empty states are designed — not blank | `references/feedback-and-states.md` |

## Navigation contract

- Shell tabs defined only in `TabBarNav.tsx` with routes from `ROUTES` in `lib/constants.ts`
- Bottom bar: floating pill, haptic on tab change, labels on icons
- Do not duplicate tab labels/icons in feature pages
- Form and detail routes should feel intentional — not instant cuts

## Shared widgets (use before inventing)

| Need | Widget |
|---|---|
| Page chrome | `AppShell.tsx` |
| Shell menu | `TabBarNav.tsx` |
| Tappable card | `Card.tsx` |
| Primary action | `PrimaryButton.tsx` |
| Async content | `AsyncStates.tsx` |
| Bottom sheet | `BottomSheet.tsx` |

## Pre-ship UI checklist

Copy and verify before marking UI work done:

```
- [ ] Uses theme colors/text — no stray hex except member shift colors
- [ ] Interactive targets ≥ 48px; icon buttons have aria-label
- [ ] Loading / error / empty handled (AsyncStates or explicit component)
- [ ] Motion from CSS tokens in base.css
- [ ] Primary content fills space — no unnecessary nested boxes
- [ ] New nav items added to TabBarNav + ROUTES only
- [ ] task web:lint passes
```

## Anti-patterns (reject in review)

- Custom tab row in a feature page for main navigation
- Silent failures (empty fragment without intentional design)
- Checkerboard or harsh alternating fills for structure
- Duplicated fetch logic in components that should use hooks
- Ad-hoc transition durations per screen

## When to load references

Load only when the matching decision arises — do not preload.
