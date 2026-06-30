import { useReducedMotion } from "framer-motion";
import { useCallback, useMemo } from "react";
import type { MouseEvent, MouseEventHandler } from "react";
import { MICRO_TRANSITION } from "../../lib/motion";
import { playClickSound, playHoverSound } from "../../lib/sound/interactionSounds";
import { useCoarsePointer } from "./useCoarsePointer";

type TapScale = "button" | "icon" | "chip" | "card";

const TAP_SCALE: Record<TapScale, number> = {
  button: 0.96,
  icon: 0.92,
  chip: 0.96,
  card: 0.97,
};

type HoverStyle = "lift" | "card" | "none";

interface UseInteractiveMotionOptions {
  disabled?: boolean;
  tapScale?: TapScale;
  hover?: HoverStyle;
}

/** Framer press/hover + generative sound for shell interactive controls. */
export function useInteractiveMotion({
  disabled = false,
  tapScale = "button",
  hover = "lift",
}: UseInteractiveMotionOptions = {}) {
  const reduceMotion = useReducedMotion();
  const coarsePointer = useCoarsePointer();

  const whileHover = useMemo(() => {
    if (reduceMotion || disabled || coarsePointer || hover === "none") return undefined;
    if (hover === "card") {
      return { y: -2, transition: MICRO_TRANSITION };
    }
    return { scale: 1.03, y: -1, transition: MICRO_TRANSITION };
  }, [coarsePointer, disabled, hover, reduceMotion]);

  const whileTap = useMemo(() => {
    if (reduceMotion || disabled) return undefined;
    return {
      scale: TAP_SCALE[tapScale],
      transition: { type: "tween" as const, duration: 0.1 },
    };
  }, [disabled, reduceMotion, tapScale]);

  const onMouseEnter = useCallback(() => {
    if (disabled) return;
    if (window.matchMedia("(hover: hover)").matches) {
      playHoverSound();
    }
  }, [disabled]);

  const wrapClick = useCallback(
    (handler?: MouseEventHandler) => (event: MouseEvent) => {
      if (!disabled) {
        playClickSound();
        navigator.vibrate?.(10);
      }
      handler?.(event);
    },
    [disabled],
  );

  return {
    motionProps: {
      whileHover,
      whileTap,
      onMouseEnter,
    },
    wrapClick,
  };
}
