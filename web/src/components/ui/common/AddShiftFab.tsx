import { AnimatePresence, motion, useReducedMotion } from "framer-motion";
import { Plus } from "lucide-react";
import { useCallback, type KeyboardEvent } from "react";
import { useCoarsePointer } from "../../../hooks/ui/useCoarsePointer";
import { useFabPointerGesture } from "../../../hooks/ui/useFabPointerGesture";
import { useSheetNavigation } from "../../../hooks/ui/useSheetNavigation";
import { ROUTES } from "../../../lib/constants";
import {
  ENTER_TRANSITION,
  EXIT_TRANSITION,
  REDUCED_ENTER_TRANSITION,
  REDUCED_EXIT_TRANSITION,
} from "../../../lib/motion";
import { playClickSound, playHoverSound } from "../../../lib/sound/interactionSounds";

interface AddShiftFabProps {
  visible: boolean;
}

export function AddShiftFab({ visible }: AddShiftFabProps) {
  const reduceMotion = useReducedMotion();
  const coarsePointer = useCoarsePointer();
  const { openSheet } = useSheetNavigation();

  const activate = useCallback(() => {
    playClickSound();
    navigator.vibrate?.(10);
    openSheet(ROUTES.shiftNew);
  }, [openSheet]);

  const { holdActive, dragOffset, handlers } = useFabPointerGesture({
    onTap: activate,
    disabled: !visible,
  });

  const enter = reduceMotion ? REDUCED_ENTER_TRANSITION : ENTER_TRANSITION;
  const exit = reduceMotion ? REDUCED_EXIT_TRANSITION : EXIT_TRANSITION;

  const onMouseEnter = () => {
    if (window.matchMedia("(hover: hover)").matches) {
      playHoverSound();
    }
  };

  const onClick = coarsePointer
    ? undefined
    : () => {
        activate();
      };

  const onKeyDown = (event: KeyboardEvent<HTMLButtonElement>) => {
    if (event.key === "Enter" || event.key === " ") {
      event.preventDefault();
      activate();
    }
  };

  return (
    <AnimatePresence initial={false}>
      {visible ? (
        <motion.div
          key="add-shift-fab"
          className="fab-wrap"
          initial={reduceMotion ? { opacity: 0 } : { opacity: 0, scale: 0.6, y: 12 }}
          animate={{ opacity: 1, scale: 1, y: 0 }}
          exit={
            reduceMotion
              ? { opacity: 0, transition: exit }
              : { opacity: 0, scale: 0.6, y: 12, transition: exit }
          }
          transition={enter}
        >
          <motion.div
            className="fab-drag"
            animate={{ x: dragOffset.x, y: dragOffset.y }}
            transition={{ type: "tween", duration: 0.06 }}
          >
            <motion.button
            type="button"
            className={["fab", holdActive ? "fab--holding" : ""].filter(Boolean).join(" ")}
            aria-label="Add shift"
            animate={{
              scale: holdActive && !reduceMotion ? 1.06 : 1,
              transition: { type: "tween", duration: 0.12 },
            }}
            whileHover={
              reduceMotion || coarsePointer
                ? undefined
                : {
                    scale: 1.03,
                    y: -2,
                    transition: { type: "tween", duration: 0.12 },
                  }
            }
            whileTap={
              reduceMotion
                ? undefined
                : {
                    scale: 0.92,
                    transition: { type: "tween", duration: 0.1 },
                  }
            }
            onMouseEnter={onMouseEnter}
            onClick={onClick}
            onKeyDown={onKeyDown}
            {...(coarsePointer ? handlers : {})}
          >
            <Plus size={26} strokeWidth={2.5} aria-hidden />
          </motion.button>
          </motion.div>
        </motion.div>
      ) : null}
    </AnimatePresence>
  );
}
