---
name: ui-interactions
description: Family Care tactile UI contract — Framer Motion, generative sound, press/hold/drag feedback, and slide-up confirm bars. Use when adding buttons, cards, navigation, dialogs, or interactive schedule chrome. Extends code/web/ui and code/web/ux.
disable-model-invocation: true
---

# UI Interactions (project)

Everything interactive must feel responsive: deliberate **enter/exit** motion, press feedback, generative sound, and clear affordances. This is the project overlay on generic web UI and UX rules.

## Extends

Load `foundations/engineering`, `code/web/ui`, and **`code/web/ux` first** (press feedback, overlay dismiss, motion feel, library discipline). For schedule grid rules, also load `project/schedule`.

Generic CSS or Motion patterns without sound: `code/web/ux` → `references/shared/press-feedback.md` and `references/shared/motion-libraries.md`.

## Default viewport (PWA)

This app is **mobile-first PWA** — shell, tab bar, and edge stagger apply to `pages/`, `AppShell`, and `base.css` even without a `mobile/` folder in the path. Load `references/shell-viewport-motion.md` for viewport clip, tokens, and tab-to-edge mapping.

## Stack edge stagger

`Stack` (`web/src/components/ui/common/Stack.tsx`) supports list entrance from the **app frame edge**:

| Prop | Use |
|---|---|
| `staggerFromEdge="start"` | Home — leading edge |
| `staggerFromEdge="end"` | Family, Settings — trailing edge |
| `stagger` (default) | Subtle fade-up for non-edge lists |

Do not use edge stagger on full-bleed Calendar planner content. See `references/shell-viewport-motion.md` for DOM, CSS, and anti-patterns (double clip, padding on wrong ancestor).

## Non‑negotiable contract

| Surface | Enter / exit | Desktop (`hover: hover`) | Mobile (`pointer: coarse`) | Sound |
|---|---|---|---|---|
| Primary buttons, links, chips | Animate mount/unmount or route handoff — **no instant snap** | `whileHover` scale/lift + `playHoverSound` on `mouseenter` | `whileTap` scale + `playClickSound` on tap; **press‑and‑hold** affordance where applicable | Generative Web Audio — no `.mp3` assets |
| Icon-only controls | Same | Same + `aria-label` | Same + haptic (`navigator.vibrate`) on tap | Same |
| Menus / sheets | Slide/fade via shared motion tokens | — | — | `playMenuOpenSound` / **`playMenuCloseSound` on every dismiss path** |
| Shell FAB (`AddShiftFab`) | `AnimatePresence` enter/exit; opens form via `useSheetNavigation().openSheet` | Hover lift + hover sound | Long-press + drag offset while held | Click + menu open on navigate |
| Shift form routes (`/shifts/*`) | Slide up with spring bounce; slide down on dismiss | — | Drag handle / pull down to dismiss | Menu open/close sounds |

A control that appears, disappears, or activates **without** paired motion and sound (when this repo adopts the contract) is a defect.

## Motion

- Shared timing lives in `web/src/lib/motion.ts` and CSS tokens in `web/src/styles/base.css` — do not invent per-screen durations.
- Use Framer Motion (`motion.*`, `AnimatePresence`) for enter/exit and press/hover on shell controls.
- Honor `prefers-reduced-motion` (`useReducedMotion`) — shorten or fade-only; generative sounds are also skipped when reduced motion is on.
- Spring press: `whileTap={{ scale: 0.92–0.97 }}`; hover lift: `whileHover={{ scale: 1.03, y: -2 }}` on fine pointers only.

## Generative sound

Helpers: `web/src/lib/sound/interactionSounds.ts`

| Helper | When |
|---|---|
| `playHoverSound` | Desktop pointer enter on interactive control |
| `playClickSound` | Primary tap / click (in addition to handler) |
| `playLongPressSound` | Mobile press-and-hold threshold reached |
| `playMenuOpenSound` | Menu/sheet opened |
| `playMenuCloseSound` | **Every** user dismiss path (close btn, backdrop, nav link, programmatic close) |

Wire sounds on user gesture so `AudioContext` can resume. See `references/sound-feedback.md`.

## Mobile press-and-hold / drag

- Use `useFabPointerGesture` (FAB) or `usePlannerPointerGesture` (schedule) for coarse pointers.
- Long-press: ~450 ms → haptic + long-press sound + held visual state.
- Drag while held: clamped offset, snap back on release; do not navigate unless the gesture was a tap.

## Layout & tokens

| Token | Use |
|---|---|
| `--motion-fast` | Press feedback, reverse transitions |
| `--motion-medium` | Page transitions, confirm bar enter |
| `--motion-spring` | Bottom sheet / confirm bar slide |

Prefer **fill** over **box** for schedules and lists. Border radius: `--radius-card`, `--radius-button`.

## Shared widgets

| Element | Contract |
|---|---|
| `AddShiftFab.tsx` | AnimatePresence in/out; desktop hover sound; mobile hold + drag |
| `Button.tsx` / `Card.tsx` | Min 48px targets; press feedback (sound wiring in progress) |
| `TabBarNav.tsx` | Haptic on tab change |
| `BottomSheet.tsx` | Vaul drawer; exit before unmount |

## Anti-patterns

- Conditional mount without exit animation (`{show && <Fab />}` without `AnimatePresence`)
- CSS-only `:hover` transform **without** Framer/sound on primary shell controls
- External audio files for micro feedback
- Remounting the entire shell on tab change
- Ad-hoc transition durations per screen
- Horizontal padding on `main` while `.page-viewport` clips inside it — edge animations clip at inner wall (see `references/shell-viewport-motion.md`)
- `overflow: hidden` on `.stack--stagger-from-edge` — clip at viewport only

## References

Load `references/sound-feedback.md` when wiring sound or reviewing dismiss paths.

Load `references/shell-viewport-motion.md` when changing shell layout, page viewport clip, `Stack` edge stagger, or `--shell-inline-inset`.
