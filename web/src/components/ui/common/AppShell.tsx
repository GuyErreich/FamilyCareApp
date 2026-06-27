import { NavLink, Outlet } from "react-router-dom";
import { ROUTES } from "../../../lib/constants";
import { useRealtimeSync } from "../../../hooks/useRealtimeSync";
import { InstallPrompt } from "./InstallPrompt";

const links = [
  { to: ROUTES.dashboard, label: "Home" },
  { to: ROUTES.calendar, label: "Calendar" },
  { to: ROUTES.family, label: "Family" },
  { to: ROUTES.settings, label: "Settings" },
];

export function AppShell() {
  useRealtimeSync();

  return (
    <div className="app-shell">
      <nav className="bottom-nav" aria-label="Main">
        {links.map((link) => (
          <NavLink
            key={link.to}
            to={link.to}
            end={link.to === ROUTES.dashboard}
            className={({ isActive }) => (isActive ? "active" : undefined)}
          >
            {link.label}
          </NavLink>
        ))}
      </nav>
      <main className="app-shell__main">
        <InstallPrompt />
        <Outlet />
      </main>
    </div>
  );
}
