import type { Transition, Variants } from "framer-motion";
import { isShiftFormPath, sheetNavMode } from "./navTransition";

/** Soft deceleration — no sharp snap at rest. */
export const EASE_OUT = [0.33, 1, 0.68, 1] as const;

/** Gentle acceleration away — pairs with EASE_OUT for connected handoffs. */
export const EASE_IN = [0.32, 0, 0.67, 0] as const;

/** @deprecated Use EASE_OUT */
export const EASE_SMOOTH = EASE_OUT;

export const NAV_SLIDE_PX = 14;
export const PANEL_SLIDE_PX = 14;

export const EXIT_DURATION_S = 0.36;
export const ENTER_DURATION_S = 0.42;
export const ENTER_DELAY_S = 0.1;

export const EXIT_TRANSITION: Transition = {
  duration: EXIT_DURATION_S,
  ease: EASE_IN,
};

export const ENTER_TRANSITION: Transition = {
  duration: ENTER_DURATION_S,
  ease: EASE_OUT,
  delay: ENTER_DELAY_S,
};

export const REDUCED_EXIT_TRANSITION: Transition = {
  duration: 0.16,
  ease: EASE_OUT,
};

export const REDUCED_ENTER_TRANSITION: Transition = {
  duration: 0.2,
  ease: EASE_OUT,
  delay: 0.04,
};

/** Keep direction attribute until the full exit → pause → enter sequence finishes. */
export const NAV_DIRECTION_CLEAR_MS = Math.ceil(
  (EXIT_DURATION_S + ENTER_DELAY_S + ENTER_DURATION_S) * 1000 + 80,
);

export const MICRO_TRANSITION: Transition = {
  duration: 0.14,
  ease: EASE_OUT,
};

/** Slight bounce when a full-height form sheet settles. */
export const FORM_SHEET_ENTER_SPRING: Transition = {
  type: "spring",
  stiffness: 380,
  damping: 30,
  mass: 0.92,
};

export const FORM_SHEET_EXIT_TRANSITION: Transition = {
  duration: 0.34,
  ease: EASE_IN,
};

export const FORM_DRAG_DISMISS_PX = 96;
export const FORM_DRAG_DISMISS_VELOCITY = 520;

/** Selection mark on planner events — quick zoom-out bounce. */
export const MARK_BOUNCE_SPRING: Transition = {
  type: "spring",
  stiffness: 520,
  damping: 22,
  mass: 0.75,
};

/** Lift planner block while dragging. */
export const PLANNER_DRAG_SPRING: Transition = {
  type: "spring",
  stiffness: 420,
  damping: 28,
  mass: 0.85,
};

/** Bottom sheet enter — soft overshoot. */
export const SHEET_ENTER_SPRING: Transition = {
  type: "spring",
  stiffness: 360,
  damping: 30,
  mass: 0.95,
};

export const SHEET_EXIT_TRANSITION: Transition = {
  duration: 0.32,
  ease: EASE_IN,
};

/** Keep bottom-sheet content mounted through Vaul exit animation. */
export const SHEET_EXIT_CLEAR_MS = 380;

/** @deprecated Use EXIT_TRANSITION / ENTER_TRANSITION */
export const NAV_EXIT_TRANSITION = EXIT_TRANSITION;
/** @deprecated Use ENTER_TRANSITION */
export const NAV_ENTER_TRANSITION = ENTER_TRANSITION;
/** @deprecated */
export const NAV_REDUCED_EXIT_TRANSITION = REDUCED_EXIT_TRANSITION;
/** @deprecated */
export const NAV_REDUCED_ENTER_TRANSITION = REDUCED_ENTER_TRANSITION;
/** @deprecated */
export const NAV_TRANSITION: Transition = ENTER_TRANSITION;
/** @deprecated */
export const PANEL_TRANSITION: Transition = ENTER_TRANSITION;
/** @deprecated */
export const FADE_TRANSITION: Transition = {
  duration: 0.2,
  ease: EASE_OUT,
};

export function navDirectionMultiplier(): number {
  return document.documentElement.dataset.navDirection === "back" ? -1 : 1;
}

/** Shared slide + fade for tabs, stacked panels, and chrome. */
export function slideFadeVariants(
  slidePx: number,
  reduceMotion: boolean | null,
): Variants {
  const slide = reduceMotion ? 0 : slidePx;
  const exitTransition = reduceMotion ? REDUCED_EXIT_TRANSITION : EXIT_TRANSITION;
  const enterTransition = reduceMotion ? REDUCED_ENTER_TRANSITION : ENTER_TRANSITION;

  return {
    initial: (direction: number) => ({
      opacity: reduceMotion ? 0.92 : 0,
      x: direction * slide,
    }),
    animate: {
      opacity: 1,
      x: 0,
      transition: enterTransition,
    },
    exit: (direction: number) => ({
      opacity: reduceMotion ? 0.92 : 0,
      x: direction * -slide,
      transition: exitTransition,
    }),
  };
}

export function navPageVariants(reduceMotion: boolean | null): Variants {
  return slideFadeVariants(NAV_SLIDE_PX, reduceMotion);
}

/** Full-viewport shift form — slides up/down with a soft spring on enter. */
export function formSheetVariants(reduceMotion: boolean | null): Variants {
  const enterTransition = reduceMotion
    ? REDUCED_ENTER_TRANSITION
    : FORM_SHEET_ENTER_SPRING;
  const exitTransition = reduceMotion ? REDUCED_EXIT_TRANSITION : FORM_SHEET_EXIT_TRANSITION;

  return {
    initial: {
      y: reduceMotion ? 0 : "100%",
      opacity: reduceMotion ? 0 : 1,
    },
    animate: {
      y: 0,
      opacity: 1,
      transition: enterTransition,
    },
    exit: {
      y: reduceMotion ? 0 : "100%",
      opacity: reduceMotion ? 0 : 1,
      transition: exitTransition,
    },
  };
}

/** Tab page under a form sheet — dims slightly instead of sliding horizontally. */
export function tabUnderlayVariants(reduceMotion: boolean | null): Variants {
  const restoreSpring: Transition = reduceMotion
    ? REDUCED_ENTER_TRANSITION
    : { type: "spring", stiffness: 400, damping: 34, mass: 0.9 };

  return {
    initial: {
      opacity: reduceMotion ? 0.94 : 0.96,
      scale: reduceMotion ? 1 : 0.98,
    },
    animate: {
      opacity: 1,
      scale: 1,
      transition: restoreSpring,
    },
    exit: {
      opacity: reduceMotion ? 0.94 : 0.96,
      scale: reduceMotion ? 1 : 0.98,
      transition: reduceMotion ? REDUCED_EXIT_TRANSITION : { duration: 0.3, ease: EASE_IN },
    },
  };
}

export function pageTransitionVariants(
  routeKey: string,
  reduceMotion: boolean | null,
): Variants {
  const sheetMode = sheetNavMode();

  if (isShiftFormPath(routeKey)) {
    return formSheetVariants(reduceMotion);
  }

  if (sheetMode === "sheet-up" || sheetMode === "sheet-down") {
    return tabUnderlayVariants(reduceMotion);
  }

  return slideFadeVariants(NAV_SLIDE_PX, reduceMotion);
}

/** Shell top bar — transform only so main viewport height stays fixed. */
export const shellTopbarVariants = (reduceMotion: boolean | null): Variants => ({
  visible: {
    opacity: 1,
    y: 0,
    pointerEvents: "auto",
    transition: reduceMotion ? REDUCED_ENTER_TRANSITION : ENTER_TRANSITION,
  },
  hidden: {
    opacity: 0,
    y: reduceMotion ? 0 : "-100%",
    pointerEvents: "none",
    transition: reduceMotion ? REDUCED_EXIT_TRANSITION : EXIT_TRANSITION,
  },
});
