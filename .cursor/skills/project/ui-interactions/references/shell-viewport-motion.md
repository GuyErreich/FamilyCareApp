# Shell Viewport Motion (PWA)

Family Care is **mobile-first PWA**: a max-width shell with tab bar, not a separate `mobile/` code tree. Shell motion contracts apply to `AppShell`, `PageTransition`, `TabBarNav`, `web/src/pages/*`, and `web/src/styles/base.css` even when paths lack `mobile/`.

Portable pattern (clip boundary, edge entrance math): `~/.cursor/skills/code/web/ux/references/mobile/navigation-motion.md`.

## Default viewport

| Concept | Location |
|---|---|
| Shell frame | `AppShell`, `--app-max-width` |
| Route outlet | `PageTransition` → `.page-viewport` |
| Tab navigation | `TabBarNav` |
| List edge stagger | `Stack` + page CSS |

Load this reference for shell/motion token work. Load `mobile/navigation-motion.md` for generic rules without project tokens.

## DOM contract

```text
.app-shell__main          padding-inline: 0  (no horizontal pad on main)
  .page-viewport          overflow-x: clip; full shell width
    .page-viewport__content   padding-inline: var(--shell-inline-inset)
      .stack--stagger-from-edge   negative margin breakout + inner pad
```

**Wrong:** padding on `main` while `.page-viewport` clips inside that inset — animations stop at an inner “wall.”

**Right:** clip at full-width `.page-viewport`; horizontal inset on `.page-viewport__content` only.

Calendar routes (`.app-shell__main--calendar`) use `overflow: hidden` on viewport for full-bleed planner — different motion contract (no edge stagger).

## Tokens

| Token | Role |
|---|---|
| `--shell-inline-inset` | Horizontal content inset (`--space-lg`; `--space-xl` at wide breakpoint) |
| `--motion-nav` | Edge stagger and route handoff duration |
| `--ease-out-soft` | Edge stagger easing |

Form routes use `.page-viewport__content--form` with padding on `.form-sheet__body` instead of the default content rule.

## Stack edge stagger API

`web/src/components/ui/common/Stack.tsx`:

| Prop | Effect |
|---|---|
| `staggerFromEdge="start"` | Leading edge (LTR: left) — `stack--stagger-from-edge` |
| `staggerFromEdge="end"` | Trailing edge (LTR: right) — adds `stack--stagger-from-edge--end` |
| `staggerFromEdge={true}` | Same as `"start"` |
| `stagger` (no edge) | Subtle fade-up — non-edge chrome |

CSS (`base.css`):

- `.stack--stagger-from-edge`: `margin-inline: calc(-1 * var(--shell-inline-inset))` + matching `padding-inline` — aligns list bleed without inner `overflow: hidden`.
- Keyframes: `translateX(calc(±100% ± var(--shell-inline-inset)))` so items start fully off the frame edge.
- Do **not** add `overflow: hidden` on the stagger container — clip once at `.page-viewport`.

## Tab position → entrance direction

| Tab / page | `staggerFromEdge` | Notes |
|---|---|---|
| Home (`DashboardPage`) | `"start"` | Leading tab |
| Family (`FamilyPage`) | `"end"` | Trailing tab |
| Settings (`SettingsPage`) | `"end"` | Trailing tab |
| Calendar | none | Full-bleed planner; no edge list stagger |

## PageTransition

`PageTransition.tsx` wraps outlet in `.page-viewport` / `.page-viewport__content` with Framer route variants from `web/src/lib/motion.ts`. Edge stagger is **list-level** (`Stack`), not the page crossfade — both may run on tab change.

## Checklist

```
- [ ] main has padding-inline: 0; inset on page-viewport__content
- [ ] page-viewport clips at shell width (overflow-x: clip)
- [ ] Edge stagger includes --shell-inline-inset in transform
- [ ] No overflow: hidden on stack--stagger-from-edge
- [ ] Tab/page mapping matches table above
- [ ] prefers-reduced-motion shortens or disables slide
```

Padding vs full-bleed: see `project/ux/references/clarity-and-hierarchy.md`.
