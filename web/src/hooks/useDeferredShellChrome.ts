import { useEffect, useState } from "react";
import { EXIT_DURATION_S, REDUCED_EXIT_TRANSITION } from "../lib/motion";

/**
 * Delays shell chrome (top bar, main padding) until the outgoing page finishes exiting.
 * Keeps the viewport geometry stable while tab content animates.
 */
export function useDeferredShellChrome(active: boolean, reduceMotion: boolean | null): boolean {
  const [chromeActive, setChromeActive] = useState(active);

  useEffect(() => {
    if (active === chromeActive) return;

    const delayMs = reduceMotion
      ? (REDUCED_EXIT_TRANSITION.duration ?? 0.16) * 1000
      : EXIT_DURATION_S * 1000;

    const id = window.setTimeout(() => setChromeActive(active), delayMs);
    return () => window.clearTimeout(id);
  }, [active, chromeActive, reduceMotion]);

  return chromeActive;
}
