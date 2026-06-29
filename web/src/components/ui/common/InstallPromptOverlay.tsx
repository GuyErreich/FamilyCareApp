import { useEffect, useRef } from "react";
import { AnimatePresence, motion, useReducedMotion } from "framer-motion";
import {
  ENTER_TRANSITION,
  EXIT_TRANSITION,
  REDUCED_ENTER_TRANSITION,
  REDUCED_EXIT_TRANSITION,
} from "../../../lib/motion";
import { useShellUi } from "../../../hooks/useShellUi";
import { InstallPromptCard, useInstallPrompt } from "./InstallPrompt";

interface InstallPromptOverlayProps {
  /** When false (e.g. calendar tab), the banner exits in sync with route motion. */
  showOnRoute: boolean;
}

export function InstallPromptOverlay({ showOnRoute }: InstallPromptOverlayProps) {
  const reduceMotion = useReducedMotion();
  const panelRef = useRef<HTMLDivElement>(null);
  const { setInstallBannerInset } = useShellUi();
  const { visible, deferredPrompt, dismiss, install } = useInstallPrompt();
  const show = showOnRoute && visible;

  const enter = reduceMotion ? REDUCED_ENTER_TRANSITION : ENTER_TRANSITION;
  const exit = reduceMotion ? REDUCED_EXIT_TRANSITION : EXIT_TRANSITION;

  useEffect(() => {
    if (!show) {
      setInstallBannerInset(0);
      return;
    }

    const panel = panelRef.current;
    if (!panel) return;

    const syncInset = () => {
      const height = panel.getBoundingClientRect().height;
      setInstallBannerInset(height > 0 ? Math.ceil(height + 8) : 0);
    };

    syncInset();
    const observer = new ResizeObserver(syncInset);
    observer.observe(panel);
    return () => {
      observer.disconnect();
      setInstallBannerInset(0);
    };
  }, [show, setInstallBannerInset]);

  return (
    <div className="install-prompt-overlay" aria-hidden={!show}>
      <AnimatePresence initial={false}>
        {show ? (
          <motion.div
            ref={panelRef}
            key="install-prompt"
            className="install-prompt-overlay__panel"
            initial={reduceMotion ? { opacity: 0 } : { opacity: 0, y: -10 }}
            animate={{ opacity: 1, y: 0, transition: enter }}
            exit={
              reduceMotion
                ? { opacity: 0, transition: exit }
                : { opacity: 0, y: -10, transition: exit }
            }
          >
            <InstallPromptCard
              deferredPrompt={deferredPrompt}
              onDismiss={dismiss}
              onInstall={() => void install()}
            />
          </motion.div>
        ) : null}
      </AnimatePresence>
    </div>
  );
}
