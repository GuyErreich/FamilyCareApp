import { AnimatePresence, motion, useReducedMotion } from "framer-motion";
import type { PointerEvent as ReactPointerEvent } from "react";
import { useLocation, useNavigate, useOutlet } from "react-router-dom";
import {
  FORM_DRAG_DISMISS_PX,
  FORM_DRAG_DISMISS_VELOCITY,
  navDirectionMultiplier,
  pageTransitionVariants,
} from "../../../lib/motion";
import { beginSheetNav, isShiftFormPath } from "../../../lib/navTransition";
import { playMenuCloseSound } from "../../../lib/sound/interactionSounds";

function outletKey(pathname: string): string {
  if (pathname.startsWith("/shifts")) return pathname;
  return pathname === "/calendar" ? "calendar" : pathname;
}

export function PageTransition({ className }: { className?: string }) {
  const location = useLocation();
  const navigate = useNavigate();
  const outlet = useOutlet();
  const reduceMotion = useReducedMotion();
  const routeKey = outletKey(location.pathname);
  const isFormRoute = isShiftFormPath(location.pathname);
  const direction = navDirectionMultiplier();
  const variants = pageTransitionVariants(routeKey, reduceMotion);

  const dismissFormSheet = () => {
    beginSheetNav("down");
    playMenuCloseSound();
    navigate(-1);
  };

  const onDragEnd = (
    _event: MouseEvent | TouchEvent | PointerEvent,
    info: { offset: { y: number }; velocity: { y: number } },
  ) => {
    if (!isFormRoute || reduceMotion) return;
    if (info.offset.y > FORM_DRAG_DISMISS_PX || info.velocity.y > FORM_DRAG_DISMISS_VELOCITY) {
      dismissFormSheet();
    }
  };

  const stopDragPropagation = (event: ReactPointerEvent) => {
    event.stopPropagation();
  };

  return (
    <div
      className={[
        "page-viewport",
        isFormRoute ? "page-viewport--sheet-host" : "",
        className,
      ]
        .filter(Boolean)
        .join(" ")}
    >
      <AnimatePresence mode="wait" initial={false} custom={direction}>
        {outlet ? (
          <motion.div
            key={routeKey}
            custom={direction}
            className={[
              "page-viewport__content",
              isFormRoute ? "page-viewport__content--form" : "",
            ]
              .filter(Boolean)
              .join(" ")}
            variants={variants}
            initial="initial"
            animate="animate"
            exit="exit"
            drag={isFormRoute && !reduceMotion ? "y" : false}
            dragConstraints={{ top: 0, bottom: 0 }}
            dragElastic={{ top: 0, bottom: 0.42 }}
            onDragEnd={onDragEnd}
          >
            {isFormRoute ? (
              <>
                <div className="form-sheet__handle" aria-hidden />
                <div
                  className="form-sheet__body"
                  onPointerDown={stopDragPropagation}
                  onPointerMove={stopDragPropagation}
                >
                  {outlet}
                </div>
              </>
            ) : (
              outlet
            )}
          </motion.div>
        ) : null}
      </AnimatePresence>
    </div>
  );
}
