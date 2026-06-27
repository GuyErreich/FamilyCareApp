import { SCHEDULE } from "./constants";

export const pad2 = (n: number): string => n.toString().padStart(2, "0");

export const toDateKey = (date: Date): string =>
  `${date.getFullYear()}-${pad2(date.getMonth() + 1)}-${pad2(date.getDate())}`;

export const parseDateKey = (key: string): Date => {
  const [y, m, d] = key.split("-").map(Number);
  return new Date(y, m - 1, d);
};

export const startOfDay = (date: Date): Date =>
  new Date(date.getFullYear(), date.getMonth(), date.getDate());

export const addDays = (date: Date, days: number): Date => {
  const next = new Date(date);
  next.setDate(next.getDate() + days);
  return next;
};

export const formatTime = (hour: number, minute: number): string => {
  const d = new Date();
  d.setHours(hour, minute, 0, 0);
  return d.toLocaleTimeString(undefined, {
    hour: "numeric",
    minute: "2-digit",
  });
};

export const formatShiftRange = (
  dateKey: string,
  startHour: number,
  startMinute: number,
  durationMinutes: number,
): string => {
  const start = parseDateKey(dateKey);
  start.setHours(startHour, startMinute, 0, 0);
  const end = new Date(start.getTime() + durationMinutes * 60_000);
  return `${start.toLocaleDateString(undefined, {
    weekday: "short",
    month: "short",
    day: "numeric",
  })} ${formatTime(startHour, startMinute)} – ${end.toLocaleTimeString(undefined, {
    hour: "numeric",
    minute: "2-digit",
  })}`;
};

export const snapToGrid = (date: Date): Date => {
  const day = startOfDay(date);
  let totalMinutes = date.getHours() * 60 + date.getMinutes();
  totalMinutes =
    Math.round(totalMinutes / SCHEDULE.snapMinutes) * SCHEDULE.snapMinutes;
  totalMinutes = Math.max(
    0,
    Math.min(totalMinutes, 24 * 60 - SCHEDULE.snapMinutes),
  );
  day.setHours(Math.floor(totalMinutes / 60), totalMinutes % 60, 0, 0);
  return day;
};

export const computeEndTime = (
  dateKey: string,
  startHour: number,
  startMinute: number,
  durationMinutes: number,
): string => {
  const start = parseDateKey(dateKey);
  start.setHours(startHour, startMinute, 0, 0);
  return new Date(start.getTime() + durationMinutes * 60_000).toISOString();
};

export const monthGridWeeks = (anchor: Date): Date[][] => {
  const first = new Date(anchor.getFullYear(), anchor.getMonth(), 1);
  const start = addDays(first, -first.getDay());
  const weeks: Date[][] = [];
  let cursor = start;
  for (let w = 0; w < 6; w += 1) {
    const week: Date[] = [];
    for (let d = 0; d < 7; d += 1) {
      week.push(cursor);
      cursor = addDays(cursor, 1);
    }
    weeks.push(week);
  }
  return weeks;
};

export const isSameDay = (a: Date, b: Date): boolean =>
  a.getFullYear() === b.getFullYear() &&
  a.getMonth() === b.getMonth() &&
  a.getDate() === b.getDate();

export const isToday = (date: Date): boolean => isSameDay(date, new Date());
