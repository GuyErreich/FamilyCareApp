import { motion, useReducedMotion } from "framer-motion";
import type { CSSProperties } from "react";
import { useLocation } from "react-router-dom";
import { ROUTES } from "../../../lib/constants";
import { useFamily } from "../../../hooks/family/useFamilyData";
import { useDeferredShellChrome } from "../../../hooks/useDeferredShellChrome";
import { useRealtimeSync } from "../../../hooks/useRealtimeSync";
import { ShellUiProvider, useShellUi } from "../../../hooks/useShellUi";
import { shellTopbarVariants } from "../../../lib/motion";
import { InstallPromptOverlay } from "./InstallPromptOverlay";
import { AddShiftFab } from "./AddShiftFab";
import { PageTransition } from "./PageTransition";
import { TabBarNav } from "./TabBarNav";
import { TopBarTitle } from "./TopBarTitle";

const routeTitles: Record<string, string> = {
  [ROUTES.calendar]: "Calendar",
  [ROUTES.family]: "Family",
  [ROUTES.settings]: "Settings",
  [ROUTES.shiftNew]: "New shift",
};

function shellTitle(pathname: string, dashboardTitle: string): string {
  if (pathname === ROUTES.dashboard) return dashboardTitle;
  if (pathname.startsWith("/shifts/") && pathname !== ROUTES.shiftNew) return "Edit shift";
  return routeTitles[pathname] ?? "Family Care";
}

function AppShellContent() {
  useRealtimeSync();
  const { hideFab, installBannerInset } = useShellUi();
  const location = useLocation();
  const reduceMotion = useReducedMotion();
  const isCalendar = location.pathname === ROUTES.calendar;
  const chromeCalendar = useDeferredShellChrome(isCalendar, reduceMotion);
  const isDashboard = location.pathname === ROUTES.dashboard;
  const familyQuery = useFamily();
  const dashboardTitle = familyQuery.data?.grandpa_name ?? "Family care";

  const showFab =
    !hideFab &&
    (location.pathname === ROUTES.dashboard || isCalendar);

  const mainStyle = {
    "--shell-content-inset-top":
      !chromeCalendar && installBannerInset > 0 ? `${installBannerInset}px` : "0px",
  } as CSSProperties;

  return (
    <div className="app-frame">
      <div className="app-shell">
        <motion.header
          className="app-topbar"
          initial={false}
          animate={chromeCalendar ? "hidden" : "visible"}
          variants={shellTopbarVariants(reduceMotion)}
          aria-hidden={chromeCalendar}
        >
          <TopBarTitle title={shellTitle(location.pathname, dashboardTitle)} />
        </motion.header>
        <main
          className={[
            "app-shell__main",
            chromeCalendar ? "app-shell__main--calendar" : "",
            isDashboard ? "app-shell__main--dashboard" : "",
          ]
            .filter(Boolean)
            .join(" ")}
          style={mainStyle}
        >
          <PageTransition
            className={chromeCalendar ? "app-outlet app-outlet--calendar" : "app-outlet"}
          />
          <InstallPromptOverlay showOnRoute={!chromeCalendar} />
          <AddShiftFab visible={showFab} />
        </main>
        <TabBarNav />
      </div>
    </div>
  );
}

export function AppShell() {
  return (
    <ShellUiProvider>
      <AppShellContent />
    </ShellUiProvider>
  );
}
