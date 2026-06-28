import { AnimatePresence, motion, useReducedMotion } from "framer-motion";
import { FADE_TRANSITION } from "../../../lib/motion";

interface TopBarTitleProps {
  title: string;
}

/** Crossfades the shell title instead of remounting the heading on every route. */
export function TopBarTitle({ title }: TopBarTitleProps) {
  const reduceMotion = useReducedMotion();

  return (
    <AnimatePresence mode="wait" initial={false}>
      <motion.h1
        key={title}
        className="app-topbar__title"
        aria-live="polite"
        initial={reduceMotion ? { opacity: 0 } : { opacity: 0, y: 4 }}
        animate={{ opacity: 1, y: 0 }}
        exit={reduceMotion ? { opacity: 0 } : { opacity: 0, y: -4 }}
        transition={FADE_TRANSITION}
      >
        {title}
      </motion.h1>
    </AnimatePresence>
  );
}
