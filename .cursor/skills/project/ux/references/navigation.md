# Navigation

## Single source of truth

All primary shell tabs live in:

- `web/src/components/ui/common/TabBarNav.tsx` — tab links and icons
- `web/src/lib/constants.ts` → `ROUTES` — route paths
- Wired through `AppShell.tsx`

Adding a fifth tab: update `TabBarNav.tsx`, `ROUTES`, and `App.tsx` routes — nowhere else.

## Bottom bar (`TabBarNav`)

- Floating pill with rounded corners and safe-area inset
- Surface uses theme tokens from `base.css`
- `navigator.vibrate()` haptic when the selected index changes
- Visible labels on each tab (users should not guess icons)

## Do not

- Build a custom tab row in a feature page for main navigation
- Hide labels on phone
- Remount the entire shell on tab change
