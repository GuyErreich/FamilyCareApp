# Theme & Motion

## Modules

| Module | Responsibility |
|---|---|
| `lib/core/theme/app_theme.dart` | `ColorScheme`, component themes (cards 18px, buttons 14px, nav bar) |
| `lib/core/theme/app_motion.dart` | Durations (`fast`, `medium`, `slow`) and curves (`emphasized`, `enter`, `exit`, `spring`) |
| `lib/core/router/page_transitions.dart` | `fadeSlidePage`, `sharedAxisPage` for GoRouter |

## Motion defaults

- Page push: `AppMotion.medium` slide + fade
- Bottom sheets / confirm bars: slide from bottom with `AppMotion.spring`
- Login / hero content: `TweenAnimationBuilder` with `AppMotion.slow` + `AppMotion.enter`
- Press feedback: `AppMotion.fast` scale to `AppMotion.pressScale` (see `AppCard`)

## Adding new routes

Use `pageBuilder:` + `fadeSlidePage` or `sharedAxisPage` — not bare `builder:` for modal/detail flows.

## Do not

- Wrap `StatefulNavigationShell` in `AnimatedSwitcher` keyed by tab index — breaks branch state
- Hardcode border radius per screen — extend `CardTheme`, `FilledButtonTheme`, or shared widget
- Use checkerboard cell fills for schedule readability — use hour bands (see `project/schedule`)
