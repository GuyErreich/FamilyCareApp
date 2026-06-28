import { describe, expect, it } from "vitest";
import {
  clampStartMinutes,
  overlapsBlock,
  resolveFreePlacement,
} from "./slotOverlap";
import type { Shift, Unavailability } from "./database.types";

const shift = (partial: Partial<Shift> & Pick<Shift, "id">): Shift => ({
  family_id: "f1",
  assigned_member_id: "m1",
  shift_date: "2026-06-15",
  start_hour: 9,
  start_minute: 0,
  duration_minutes: 120,
  end_time: "2026-06-15T11:00:00.000Z",
  notes: null,
  reminder_offset_minutes: [],
  calendar_event_id: null,
  status: "scheduled",
  repeat_rule: null,
  created_at: "",
  updated_at: "",
  ...partial,
});

const unavail = (
  partial: Partial<Unavailability> & Pick<Unavailability, "id">,
): Unavailability => ({
  family_id: "f1",
  member_id: "m2",
  block_date: "2026-06-15",
  start_hour: 14,
  start_minute: 0,
  duration_minutes: 60,
  end_time: "2026-06-15T15:00:00.000Z",
  created_at: "",
  updated_at: "",
  ...partial,
});

describe("slotOverlap", () => {
  it("detects overlap between shift and unavailability", () => {
    const shifts = [shift({ id: "s1", start_hour: 10, start_minute: 0, duration_minutes: 60 })];
    const blocks = [unavail({ id: "u1", start_hour: 10, start_minute: 30, duration_minutes: 60 })];
    expect(
      overlapsBlock("2026-06-15", 10, 45, 30, shifts, blocks),
    ).toBe(true);
  });

  it("excludes self when dragging", () => {
    const shifts = [shift({ id: "s1", start_hour: 10, start_minute: 0, duration_minutes: 60 })];
    expect(
      overlapsBlock("2026-06-15", 10, 0, 60, shifts, [], {
        id: "s1",
        kind: "shift",
      }),
    ).toBe(false);
  });

  it("clamps start to day bounds", () => {
    expect(clampStartMinutes(23, 30, 120)).toEqual({ startHour: 22, startMinute: 0 });
  });

  it("flags conflict in resolveFreePlacement", () => {
    const shifts = [shift({ id: "s1", start_hour: 9, start_minute: 0, duration_minutes: 120 })];
    const result = resolveFreePlacement(
      "2026-06-15",
      9,
      30,
      60,
      shifts,
      [],
    );
    expect(result.hasConflict).toBe(true);
    expect(result.startHour).toBe(9);
    expect(result.startMinute).toBe(30);
  });
});
