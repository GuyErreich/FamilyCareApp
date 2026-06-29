# Sound Feedback Implementation

## Interactive button example

```tsx
import { motion } from "framer-motion";
import { playHoverSound, playClickSound } from "../../../lib/sound/interactionSounds";

export function InteractiveButton({ onPress }: { onPress: () => void }) {
  return (
    <motion.button
      type="button"
      whileHover={{ scale: 1.03, y: -2 }}
      whileTap={{ scale: 0.95 }}
      onMouseEnter={() => {
        if (window.matchMedia("(hover: hover)").matches) playHoverSound();
      }}
      onClick={() => {
        playClickSound();
        onPress();
      }}
      className="btn btn-primary"
    >
      Click me
    </motion.button>
  );
}
```

## Required wiring per element

| Element | Required |
|---|---|
| Button / link / menu item | `whileHover` + `whileTap` via `motion.*` (fine pointer) |
| Button / link / menu item | `playHoverSound` on desktop pointer enter |
| Button / link / menu item | `playClickSound` on tap/click (plus primary handler) |
| Mobile primary control | Long-press hook + `playLongPressSound` + haptic when hold threshold fires |
| Icon-only button | `aria-label` |
| Menu / modal | `playMenuOpenSound` on open |

## FAB (`AddShiftFab.tsx`)

- Wrap with `AnimatePresence` — pass `visible` prop; never mount/unmount without exit.
- Outer `motion.div.fab-wrap`: enter/exit scale + fade + drag offset.
- Inner `motion.button.fab`: hover/tap/hold scale.
- Desktop: `onMouseEnter` → `playHoverSound`.
- Mobile: `useFabPointerGesture` → tap navigates with click sound; hold plays long-press sound.

## Dismiss-path checklist (menus/modals)

Every dismiss path must fire `playMenuCloseSound`:

- [ ] Close button
- [ ] Backdrop / overlay click
- [ ] Navigation link clicks that close the menu
- [ ] Any programmatic close triggered by user action
