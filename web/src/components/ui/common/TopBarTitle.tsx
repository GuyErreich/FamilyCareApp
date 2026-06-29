import { AnimatePresence, motion, useReducedMotion } from "framer-motion";
import { ENTER_TRANSITION, EXIT_TRANSITION, REDUCED_ENTER_TRANSITION, REDUCED_EXIT_TRANSITION } from "../../../lib/motion";

interface TopBarTitleProps {
  title: string;
}

/** Crossfades the shell title in sync with tab route transitions. */
export function TopBarTitle({ title }: TopBarTitleProps) {
  const reduceMotion = useReducedMotion();
  const enter = reduceMotion ? REDUCED_ENTER_TRANSITION : ENTER_TRANSITION;
  const exit = reduceMotion ? REDUCED_EXIT_TRANSITION : EXIT_TRANSITION;

  return (
    <AnimatePresence mode="wait" initial={false}>
      <motion.h1
        key={title}
        className="app-topbar__title"
        aria-live="polite"
        initial={reduceMotion ? { opacity: 0 } : { opacity: 0, y: 3 }}
        animate={{ opacity: 1, y: 0, transition: enter }}
        exit={
          reduceMotion
            ? { opacity: 0, transition: exit }
            : { opacity: 0, y: -3, transition: exit }
        }
      >
        {title}
      </motion.h1>
    </AnimatePresence>
  );
}
