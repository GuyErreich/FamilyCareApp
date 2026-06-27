# Navigation

## Single source of truth

All primary shell tabs live in:

- `lib/shared/widgets/app_navigation.dart` → `AppNavigationDestinations`
- Wired through `AppShell` in `app_scaffold.dart`

Adding a fifth tab: update destinations, `app_router.dart` branches, and `AppRoutes` — nowhere else.

## Bottom bar (`AppNavigationBar`)

- Floating pill: 16px horizontal inset, 12px bottom safe area, 26px corner radius
- Surface: `surfaceContainerLowest` + outline border + soft shadow
- Inner `NavigationBar`: transparent background, theme indicator pill
- `HapticFeedback.lightImpact()` when the selected index changes
- `Tooltip` on each icon (not label-only hints)

## Rail (`AppNavigationRail`)

- Used when `context.isTablet` (width ≥ 600)
- Branded `CircleAvatar` leading with care icon
- Same destinations and haptics as bottom bar
- Theme: rounded indicator, `primaryContainer` fill

## Do not

- Build a custom tab row in a feature page for main navigation
- Hide labels on phone (`alwaysShow` — users should not guess icons)
- Animate the entire `StatefulNavigationShell` with `AnimatedSwitcher`
