import { useLocation } from "react-router-dom";
import { ROUTES } from "../../../lib/constants";
import { useFamily } from "../../../hooks/family/useFamilyData";
import { useRealtimeSync } from "../../../hooks/useRealtimeSync";
import { ShellUiProvider, useShellUi } from "../../../hooks/useShellUi";
import { InstallPrompt } from "./InstallPrompt";
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
  const { hideFab } = useShellUi();
  const location = useLocation();
  const isCalendar = location.pathname === ROUTES.calendar;
  const isDashboard = location.pathname === ROUTES.dashboard;
  const familyQuery = useFamily();
  const dashboardTitle = familyQuery.data?.grandpa_name ?? "Family care";

  const showFab =
    !hideFab &&
    (location.pathname === ROUTES.dashboard || isCalendar);

  return (
    <div className="app-frame">
      <div className="app-shell">
        <header
          className={[
            "app-topbar",
            isCalendar ? "app-topbar--calendar" : "",
          ]
            .filter(Boolean)
            .join(" ")}
          aria-hidden={isCalendar}
        >
          <TopBarTitle title={shellTitle(location.pathname, dashboardTitle)} />
        </header>
        <main
          className={[
            "app-shell__main",
            isCalendar ? "app-shell__main--calendar" : "",
            isDashboard ? "app-shell__main--dashboard" : "",
          ]
            .filter(Boolean)
            .join(" ")}
        >
          {!isCalendar ? <InstallPrompt /> : null}
          <PageTransition
            className={isCalendar ? "app-outlet app-outlet--calendar" : ""}
          />
          {showFab ? <AddShiftFab /> : null}
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
