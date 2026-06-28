import type { Transition } from "framer-motion";

export const EASE_SMOOTH = [0.32, 0.72, 0, 1] as const;

export const NAV_TRANSITION: Transition = {
  duration: 0.28,
  ease: EASE_SMOOTH,
};

export const PANEL_TRANSITION: Transition = {
  duration: 0.38,
  ease: EASE_SMOOTH,
};

export const FADE_TRANSITION: Transition = {
  duration: 0.18,
  ease: EASE_SMOOTH,
};

export function navDirectionMultiplier(): number {
  return document.documentElement.dataset.navDirection === "back" ? -1 : 1;
}
