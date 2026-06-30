import { useLayoutEffect, useRef, useState } from "react";
import { NavLink, useLocation } from "react-router-dom";
import { CalendarDays, Home, Settings, Users } from "lucide-react";
import type { LucideIcon } from "lucide-react";
import { ROUTES } from "../../../lib/constants";
import { NAV_DIRECTION_CLEAR_MS } from "../../../lib/motion";
import { beginSheetNav, isShiftFormPath } from "../../../lib/navTransition";
import { playClickSound, playMenuCloseSound } from "../../../lib/sound/interactionSounds";

const links: { to: string; label: string; icon: LucideIcon; end?: boolean }[] = [
  { to: ROUTES.dashboard, label: "Home", icon: Home, end: true },
  { to: ROUTES.calendar, label: "Calendar", icon: CalendarDays },
  { to: ROUTES.family, label: "Family", icon: Users },
  { to: ROUTES.settings, label: "Settings", icon: Settings },
];

function hapticTap() {
  navigator.vibrate?.(10);
}

function tabIndexForPath(pathname: string): number {
  if (pathname.startsWith("/shifts")) {
    return links.findIndex((link) => link.to === ROUTES.calendar);
  }
  const index = links.findIndex((link) =>
    link.end
      ? pathname === link.to
      : pathname === link.to || pathname.startsWith(`${link.to}/`),
  );
  return index >= 0 ? index : 0;
}

function setNavDirection(fromIndex: number, toIndex: number) {
  const root = document.documentElement;
  if (fromIndex === toIndex) {
    root.removeAttribute("data-nav-direction");
    return;
  }
  root.dataset.navDirection = toIndex > fromIndex ? "forward" : "back";
}

function clearNavDirection() {
  document.documentElement.removeAttribute("data-nav-direction");
}

export function TabBarNav() {
  const location = useLocation();
  const navRef = useRef<HTMLElement>(null);
  const linkRefs = useRef<(HTMLAnchorElement | null)[]>([]);
  const [indicator, setIndicator] = useState({ left: 0, width: 0 });
  const [indicatorReady, setIndicatorReady] = useState(false);

  const activeIndex = tabIndexForPath(location.pathname);
  const indicatorIndex = activeIndex >= 0 ? activeIndex : 0;

  useLayoutEffect(() => {
    const nav = navRef.current;
    const link = linkRefs.current[indicatorIndex];
    if (!nav || !link) return;

    const update = () => {
      setIndicator({ left: link.offsetLeft, width: link.offsetWidth });
      setIndicatorReady(true);
    };

    update();
    const observer = new ResizeObserver(update);
    observer.observe(nav);
    return () => observer.disconnect();
  }, [indicatorIndex, location.pathname]);

  return (
    <nav className="tab-bar" ref={navRef} aria-label="Main">
      <span
        className={[
          "tab-bar__indicator",
          indicatorReady ? "tab-bar__indicator--ready" : "",
        ]
          .filter(Boolean)
          .join(" ")}
        style={{
          width: indicator.width,
          transform: `translateX(${indicator.left}px)`,
        }}
        aria-hidden
      />
      {links.map((link, index) => {
        const Icon = link.icon;
        return (
          <NavLink
            key={link.to}
            ref={(el) => {
              linkRefs.current[index] = el;
            }}
            to={link.to}
            end={link.end}
            className={({ isActive }) => {
              const shiftRoute = location.pathname.startsWith("/shifts");
              const calendarActive = shiftRoute && link.to === ROUTES.calendar;
              return isActive || calendarActive ? "active" : undefined;
            }}
            onClick={() => {
              if (isShiftFormPath(location.pathname)) {
                beginSheetNav("down");
                playMenuCloseSound();
              }
              hapticTap();
              playClickSound();
              setNavDirection(activeIndex, index);
              window.setTimeout(clearNavDirection, NAV_DIRECTION_CLEAR_MS);
            }}
          >
            <Icon className="tab-bar__icon" aria-hidden />
            {link.label}
          </NavLink>
        );
      })}
    </nav>
  );
}
