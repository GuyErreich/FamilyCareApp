import { SCHEDULE } from "./constants";
import type { Shift, Unavailability } from "./database.types";
import { parseDateKey, snapToGrid, toDateKey } from "./dates";

export interface TimeBlock {
  id: string;
  kind: "shift" | "unavail";
  dateKey: string;
  startHour: number;
  startMinute: number;
  durationMinutes: number;
}

export interface SlotPlacement {
  startHour: number;
  startMinute: number;
  durationMinutes: number;
  hasConflict: boolean;
}

function blockStartMinutes(hour: number, minute: number): number {
  return hour * 60 + minute;
}

function rangesOverlap(
  aStart: number,
  aDuration: number,
  bStart: number,
  bDuration: number,
): boolean {
  const aEnd = aStart + aDuration;
  const bEnd = bStart + bDuration;
  return aStart < bEnd && aEnd > bStart;
}

export function shiftToBlock(shift: Shift): TimeBlock {
  return {
    id: shift.id,
    kind: "shift",
    dateKey: shift.shift_date,
    startHour: shift.start_hour,
    startMinute: shift.start_minute,
    durationMinutes: shift.duration_minutes,
  };
}

export function unavailToBlock(block: Unavailability): TimeBlock {
  return {
    id: block.id,
    kind: "unavail",
    dateKey: block.block_date,
    startHour: block.start_hour,
    startMinute: block.start_minute,
    durationMinutes: block.duration_minutes,
  };
}

export function blocksForDay(
  dateKey: string,
  shifts: Shift[],
  unavailabilities: Unavailability[],
): TimeBlock[] {
  return [
    ...shifts.filter((s) => s.shift_date === dateKey).map(shiftToBlock),
    ...unavailabilities.filter((u) => u.block_date === dateKey).map(unavailToBlock),
  ];
}

export function overlapsBlock(
  dateKey: string,
  startHour: number,
  startMinute: number,
  durationMinutes: number,
  shifts: Shift[],
  unavailabilities: Unavailability[],
  exclude?: { id: string; kind: "shift" | "unavail" },
): boolean {
  const start = blockStartMinutes(startHour, startMinute);
  const blocks = blocksForDay(dateKey, shifts, unavailabilities);

  for (const block of blocks) {
    if (exclude && block.id === exclude.id && block.kind === exclude.kind) continue;
    if (
      rangesOverlap(
        start,
        durationMinutes,
        blockStartMinutes(block.startHour, block.startMinute),
        block.durationMinutes,
      )
    ) {
      return true;
    }
  }
  return false;
}

export function clampStartMinutes(
  startHour: number,
  startMinute: number,
  durationMinutes: number,
): { startHour: number; startMinute: number } {
  const maxStart = 24 * 60 - durationMinutes;
  const total = Math.max(0, Math.min(blockStartMinutes(startHour, startMinute), maxStart));
  return { startHour: Math.floor(total / 60), startMinute: total % 60 };
}

export function resolveFreePlacement(
  dateKey: string,
  proposedHour: number,
  proposedMinute: number,
  durationMinutes: number,
  shifts: Shift[],
  unavailabilities: Unavailability[],
  exclude?: { id: string; kind: "shift" | "unavail" },
): SlotPlacement {
  const day = parseDateKey(dateKey);
  day.setHours(proposedHour, proposedMinute, 0, 0);
  const snapped = snapToGrid(day);
  const clamped = clampStartMinutes(
    snapped.getHours(),
    snapped.getMinutes(),
    durationMinutes,
  );
  const hasConflict = overlapsBlock(
    dateKey,
    clamped.startHour,
    clamped.startMinute,
    durationMinutes,
    shifts,
    unavailabilities,
    exclude,
  );
  return { ...clamped, durationMinutes, hasConflict };
}

export function minutesFromPointerY(y: number, heightPerMinute = SCHEDULE.heightPerMinute): number {
  const raw = Math.floor(y / heightPerMinute);
  return Math.round(raw / SCHEDULE.snapMinutes) * SCHEDULE.snapMinutes;
}

export function pointerYToTime(
  y: number,
  durationMinutes: number,
  heightPerMinute = SCHEDULE.heightPerMinute,
): { startHour: number; startMinute: number } {
  const minutes = minutesFromPointerY(y, heightPerMinute);
  const clamped = clampStartMinutes(
    Math.floor(minutes / 60),
    minutes % 60,
    durationMinutes,
  );
  return clamped;
}

export function formatTimeRange(
  startHour: number,
  startMinute: number,
  durationMinutes: number,
): string {
  const start = new Date();
  start.setHours(startHour, startMinute, 0, 0);
  const end = new Date(start.getTime() + durationMinutes * 60_000);
  return `${start.toLocaleTimeString(undefined, { hour: "numeric", minute: "2-digit" })} – ${end.toLocaleTimeString(undefined, { hour: "numeric", minute: "2-digit" })}`;
}

export function todayKey(): string {
  return toDateKey(new Date());
}
