import { useEffect, useMemo, useRef, useState } from "react";
import { Button, SheetCloseButton } from "../../common/Button";
import { BottomSheet } from "../../common/BottomSheet";
import { useSheetDismiss } from "../../common/sheetDismissContext";
import { SegmentedControl } from "../../common/SegmentedControl";
import { WheelPicker, type WheelPickerHandle } from "../../common/WheelPicker";

type PickerSegment = "month" | "year";

interface MonthYearPickerSheetProps {
  open: boolean;
  onClose: () => void;
  value: Date;
  onApply: (month: Date) => void;
}

const MONTH_OPTIONS = Array.from({ length: 12 }, (_, index) => ({
  value: index + 1,
  label: new Date(2000, index, 1).toLocaleString(undefined, { month: "long" }),
}));

function yearRange(): number[] {
  const now = new Date().getFullYear();
  const first = now - 2;
  const last = now + 2;
  return Array.from({ length: last - first + 1 }, (_, index) => first + index);
}

function clampYear(year: number, years: number[]): number {
  return Math.min(Math.max(year, years[0]), years[years.length - 1]);
}

function MonthYearPickerActions({
  onCommit,
}: {
  onCommit: () => Date;
}) {
  const dismiss = useSheetDismiss();

  const onDone = () => {
    onCommit();
    dismiss("press");
  };

  return (
    <>
      <SheetCloseButton>Cancel</SheetCloseButton>
      <Button fullWidth onClick={onDone}>
        Done
      </Button>
    </>
  );
}

export function MonthYearPickerSheet({
  open,
  onClose,
  value,
  onApply,
}: MonthYearPickerSheetProps) {
  const years = useMemo(() => yearRange(), []);
  const yearOptions = useMemo(
    () => years.map((year) => ({ value: year, label: String(year) })),
    [years],
  );

  const [segment, setSegment] = useState<PickerSegment>("month");
  const [month, setMonth] = useState(value.getMonth() + 1);
  const [year, setYear] = useState(() => clampYear(value.getFullYear(), years));

  const monthWheelRef = useRef<WheelPickerHandle>(null);
  const yearWheelRef = useRef<WheelPickerHandle>(null);

  useEffect(() => {
    if (!open) return;
    const frame = window.requestAnimationFrame(() => {
      setSegment("month");
      setMonth(value.getMonth() + 1);
      setYear(clampYear(value.getFullYear(), years));
    });
    return () => window.cancelAnimationFrame(frame);
  }, [open, value, years]);

  const flushSegment = (active: PickerSegment) => {
    if (active === "month") {
      const next = monthWheelRef.current?.flush();
      if (typeof next === "number") setMonth(next);
    } else {
      const next = yearWheelRef.current?.flush();
      if (typeof next === "number") setYear(next);
    }
  };

  const onSegmentChange = (next: PickerSegment) => {
    flushSegment(segment);
    setSegment(next);
  };

  const commitSelection = (): Date => {
    const resolvedMonth = (monthWheelRef.current?.flush() as number | undefined) ?? month;
    const resolvedYear = (yearWheelRef.current?.flush() as number | undefined) ?? year;
    setMonth(resolvedMonth);
    setYear(resolvedYear);
    const result = new Date(resolvedYear, resolvedMonth - 1, 1);
    onApply(result);
    return result;
  };

  return (
    <BottomSheet
      open={open}
      onClose={onClose}
      title="Go to month"
      actions={<MonthYearPickerActions onCommit={commitSelection} />}
    >
      <SegmentedControl
        value={segment}
        onChange={onSegmentChange}
        ariaLabel="Picker type"
        options={[
          { value: "month", label: "Month" },
          { value: "year", label: "Year" },
        ]}
      />

      <div
        className={[
          "wheel-picker-panel",
          segment === "month" ? "wheel-picker-panel--active" : "",
        ]
          .filter(Boolean)
          .join(" ")}
        aria-hidden={segment !== "month"}
      >
        <WheelPicker
          ref={monthWheelRef}
          value={month}
          onChange={setMonth}
          options={MONTH_OPTIONS}
          ariaLabel="Month"
        />
      </div>

      <div
        className={[
          "wheel-picker-panel",
          segment === "year" ? "wheel-picker-panel--active" : "",
        ]
          .filter(Boolean)
          .join(" ")}
        aria-hidden={segment !== "year"}
      >
        <WheelPicker
          ref={yearWheelRef}
          value={year}
          onChange={setYear}
          options={yearOptions}
          ariaLabel="Year"
        />
      </div>
    </BottomSheet>
  );
}
