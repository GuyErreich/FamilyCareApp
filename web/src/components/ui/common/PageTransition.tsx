import { AnimatePresence, motion, useReducedMotion } from "framer-motion";
import { useLocation, useOutlet } from "react-router-dom";
import { ROUTES } from "../../../lib/constants";
import { NAV_TRANSITION, navDirectionMultiplier } from "../../../lib/motion";

function outletKey(pathname: string): string {
  return pathname === ROUTES.calendar ? "calendar" : pathname;
}

export function PageTransition({ className }: { className?: string }) {
  const location = useLocation();
  const outlet = useOutlet();
  const reduceMotion = useReducedMotion();
  const key = outletKey(location.pathname);
  const direction = navDirectionMultiplier();
  const slide = reduceMotion ? 0 : 12;

  return (
    <div className={["page-viewport", className].filter(Boolean).join(" ")}>
      <AnimatePresence mode="wait" initial={false}>
        {outlet ? (
          <motion.div
            key={key}
            className="page-viewport__content"
            initial={{ opacity: 0, x: direction * slide }}
            animate={{ opacity: 1, x: 0 }}
            exit={{ opacity: 0, x: direction * -slide }}
            transition={NAV_TRANSITION}
          >
            {outlet}
          </motion.div>
        ) : null}
      </AnimatePresence>
    </div>
  );
}
