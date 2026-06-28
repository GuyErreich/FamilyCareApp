import { startOfDay } from "./dates";

const VIEW_KEY = "familycare-calendar-view";
const MONTH_KEY = "familycare-calendar-month";
const SELECTED_KEY = "familycare-calendar-selected";

export type CalendarView = "month" | "day";

function readDate(key: string, fallback: Date): Date {
  const stored = sessionStorage.getItem(key);
  if (!stored) return fallback;
  const parsed = new Date(stored);
  return Number.isNaN(parsed.getTime()) ? fallback : startOfDay(parsed);
}

export function readCalendarView(): CalendarView {
  const stored = sessionStorage.getItem(VIEW_KEY);
  return stored === "day" ? "day" : "month";
}

export function writeCalendarView(view: CalendarView): void {
  sessionStorage.setItem(VIEW_KEY, view);
}

export function readCalendarMonth(): Date {
  return readDate(MONTH_KEY, startOfDay(new Date()));
}

export function writeCalendarMonth(month: Date): void {
  sessionStorage.setItem(MONTH_KEY, month.toISOString());
}

export function readCalendarSelectedDate(): Date {
  return readDate(SELECTED_KEY, startOfDay(new Date()));
}

export function writeCalendarSelectedDate(date: Date): void {
  sessionStorage.setItem(SELECTED_KEY, date.toISOString());
}
