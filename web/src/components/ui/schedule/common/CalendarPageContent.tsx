import { useMemo, useState } from "react";
import { Link, useNavigate } from "react-router-dom";
import { Card } from "../../common/Card";
import { PrimaryButton } from "../../common/PrimaryButton";
import { EmptyState, ErrorState, LoadingState } from "../../common/AsyncStates";
import { DayPlanner, MonthGrid } from "./ScheduleViews";
import { ROUTES } from "../../../../lib/constants";
import { addDays, startOfDay, toDateKey } from "../../../../lib/dates";
import { useFamilyMembers, useShifts } from "../../../../hooks/family/useFamilyData";

export function CalendarPageContent() {
  const navigate = useNavigate();
  const [month, setMonth] = useState(() => startOfDay(new Date()));
  const [selectedDate, setSelectedDate] = useState(() => startOfDay(new Date()));
  const [pendingSlot, setPendingSlot] = useState<{ hour: number; minute: number } | null>(
    null,
  );

  const rangeStart = toDateKey(addDays(month, -7));
  const rangeEnd = toDateKey(addDays(month, 42));
  const shiftsQuery = useShifts(rangeStart, rangeEnd);
  const membersQuery = useFamilyMembers();

  const membersById = useMemo(() => {
    const map = new Map<string, NonNullable<typeof membersQuery.data>[number]>();
    for (const m of membersQuery.data ?? []) map.set(m.id, m);
    return map;
  }, [membersQuery.data]);

  if (shiftsQuery.isLoading || membersQuery.isLoading) {
    return <LoadingState />;
  }
  if (shiftsQuery.error || membersQuery.error) {
    return (
      <ErrorState
        message={
          (shiftsQuery.error ?? membersQuery.error)?.message ?? "Failed to load calendar"
        }
      />
    );
  }

  const shifts = shiftsQuery.data ?? [];

  return (
    <div className="stack">
      <div style={{ display: "flex", gap: 8, alignItems: "center" }}>
        <PrimaryButton
          variant="secondary"
          onClick={() =>
            setMonth(new Date(month.getFullYear(), month.getMonth() - 1, 1))
          }
        >
          Prev
        </PrimaryButton>
        <h1 className="page-title" style={{ flex: 1, margin: 0 }}>
          {month.toLocaleString(undefined, { month: "long", year: "numeric" })}
        </h1>
        <PrimaryButton
          variant="secondary"
          onClick={() =>
            setMonth(new Date(month.getFullYear(), month.getMonth() + 1, 1))
          }
        >
          Next
        </PrimaryButton>
      </div>

      <Card>
        <MonthGrid
          month={month}
          shifts={shifts}
          membersById={membersById}
          selectedDate={selectedDate}
          onSelectDate={setSelectedDate}
        />
      </Card>

      <Card>
        <h2 style={{ marginTop: 0 }}>
          {selectedDate.toLocaleDateString(undefined, {
            weekday: "long",
            month: "short",
            day: "numeric",
          })}
        </h2>
        {shifts.filter((s) => s.shift_date === toDateKey(selectedDate)).length === 0 ? (
          <EmptyState>No shifts this day — tap the planner to add one.</EmptyState>
        ) : null}
        <DayPlanner
          date={selectedDate}
          shifts={shifts}
          membersById={membersById}
          onSlotClick={(hour, minute) => setPendingSlot({ hour, minute })}
          onShiftClick={(id) => navigate(ROUTES.shiftEdit(id))}
        />
      </Card>

      {pendingSlot ? (
        <div className="confirm-sheet">
          <p>
            Create shift at {selectedDate.toLocaleDateString()} ·{" "}
            {String(pendingSlot.hour).padStart(2, "0")}:
            {String(pendingSlot.minute).padStart(2, "0")}?
          </p>
          <div className="stack" style={{ flexDirection: "row" }}>
            <PrimaryButton variant="secondary" onClick={() => setPendingSlot(null)}>
              Cancel
            </PrimaryButton>
            <Link
              to={`${ROUTES.shiftNew}?date=${toDateKey(selectedDate)}&hour=${pendingSlot.hour}&minute=${pendingSlot.minute}`}
              style={{ flex: 1 }}
            >
              <PrimaryButton style={{ width: "100%" }}>Continue</PrimaryButton>
            </Link>
          </div>
        </div>
      ) : null}
    </div>
  );
}
