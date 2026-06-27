import { describe, expect, it } from "vitest";
import { snapToGrid, toDateKey } from "../lib/dates";

describe("dates", () => {
  it("formats date keys", () => {
    expect(toDateKey(new Date(2026, 2, 27))).toBe("2026-03-27");
  });

  it("snaps to 15 minute grid", () => {
    const snapped = snapToGrid(new Date(2026, 2, 27, 9, 7));
    expect(snapped.getHours()).toBe(9);
    expect(snapped.getMinutes()).toBe(0);
  });
});
