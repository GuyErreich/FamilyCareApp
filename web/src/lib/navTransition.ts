import { ROUTES } from "./constants";
import { NAV_DIRECTION_CLEAR_MS } from "./motion";

export type SheetNavDirection = "up" | "down";

export function isShiftFormPath(pathname: string): boolean {
  return pathname === ROUTES.shiftNew || /^\/shifts\/[^/]+$/.test(pathname);
}

/** Mark the next route change as a vertical form sheet (call before navigate). */
export function beginSheetNav(direction: SheetNavDirection): void {
  document.documentElement.dataset.navTransition =
    direction === "up" ? "sheet-up" : "sheet-down";
  window.setTimeout(clearSheetNav, NAV_DIRECTION_CLEAR_MS);
}

export function clearSheetNav(): void {
  document.documentElement.removeAttribute("data-nav-transition");
}

export function sheetNavMode(): "sheet-up" | "sheet-down" | null {
  const value = document.documentElement.dataset.navTransition;
  if (value === "sheet-up" || value === "sheet-down") return value;
  return null;
}
