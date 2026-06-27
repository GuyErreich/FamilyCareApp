import type { Shift, FamilyMember } from "../../../../lib/database.types";
import { formatTime, isSameDay, isToday, monthGridWeeks, toDateKey } from "../../../../lib/dates";

interface MonthGridProps {
  month: Date;
  shifts: Shift[];
  membersById: Map<string, FamilyMember>;
  selectedDate: Date;
  onSelectDate: (date: Date) => void;
}

export function MonthGrid({
  month,
  shifts,
  membersById,
  selectedDate,
  onSelectDate,
}: MonthGridProps) {
  const weeks = monthGridWeeks(month);
  const monthIndex = month.getMonth();

  return (
    <div>
      <div className="month-grid" style={{ marginBottom: 4 }}>
        {["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"].map((d) => (
          <div key={d} className="muted" style={{ textAlign: "center", fontSize: "0.75rem" }}>
            {d}
          </div>
        ))}
      </div>
      {weeks.map((week, wi) => (
        <div key={wi} className="month-grid">
          {week.map((day) => {
            const key = toDateKey(day);
            const dayShifts = shifts.filter((s) => s.shift_date === key);
            const outside = day.getMonth() !== monthIndex;
            const today = isToday(day);
            const selected = isSameDay(day, selectedDate);
            return (
              <button
                key={key}
                type="button"
                className={[
                  "month-cell",
                  outside ? "month-cell--outside" : "",
                  today ? "month-cell--today" : "",
                ]
                  .filter(Boolean)
                  .join(" ")}
                style={{
                  outline: selected ? "2px solid var(--color-primary)" : undefined,
                  cursor: "pointer",
                }}
                onClick={() => onSelectDate(day)}
              >
                <div>{day.getDate()}</div>
                <div className="month-cell__dots">
                  {dayShifts.slice(0, 4).map((shift) => (
                    <span
                      key={shift.id}
                      className="month-dot"
                      style={{
                        background:
                          membersById.get(shift.assigned_member_id)?.color_hex ??
                          "var(--color-primary)",
                      }}
                    />
                  ))}
                </div>
              </button>
            );
          })}
        </div>
      ))}
    </div>
  );
}

interface DayPlannerProps {
  date: Date;
  shifts: Shift[];
  membersById: Map<string, FamilyMember>;
  onSlotClick: (hour: number, minute: number) => void;
  onShiftClick?: (shiftId: string) => void;
}

export function DayPlanner({
  date,
  shifts,
  membersById,
  onSlotClick,
  onShiftClick,
}: DayPlannerProps) {
  const dateKey = toDateKey(date);
  const dayShifts = shifts.filter((s) => s.shift_date === dateKey);
  const hours = Array.from({ length: 24 }, (_, i) => i);

  return (
    <div className="planner">
      <div className="planner__gutter">
        {hours.map((hour) => (
          <div
            key={hour}
            className="planner__hour planner__hour--band"
            style={{ top: hour * 60 * 1.05 }}
          >
            {formatTime(hour, 0)}
          </div>
        ))}
      </div>
      <div
        className="planner__grid"
        role="button"
        tabIndex={0}
        onClick={(e) => {
          if ((e.target as HTMLElement).closest(".planner-event")) return;
          const rect = e.currentTarget.getBoundingClientRect();
          const y = e.clientY - rect.top;
          const minutes = Math.floor(y / 1.05);
          const snapped = Math.round(minutes / 15) * 15;
          const hour = Math.floor(snapped / 60);
          const minute = snapped % 60;
          onSlotClick(hour, minute);
        }}
        onKeyDown={() => undefined}
      >
        {hours.map((hour) => (
          <div
            key={hour}
            className="planner__hour planner__hour--band"
            style={{ top: hour * 60 * 1.05 }}
          />
        ))}
        {dayShifts.map((shift) => {
          const top = (shift.start_hour * 60 + shift.start_minute) * 1.05;
          const height = shift.duration_minutes * 1.05;
          const member = membersById.get(shift.assigned_member_id);
          return (
            <div
              key={shift.id}
              className="planner-event"
              role="button"
              tabIndex={0}
              onClick={(e) => {
                e.stopPropagation();
                onShiftClick?.(shift.id);
              }}
              onKeyDown={(e) => {
                if (e.key === "Enter" || e.key === " ") {
                  e.stopPropagation();
                  onShiftClick?.(shift.id);
                }
              }}
              style={{
                top,
                height,
                background: member?.color_hex ?? "var(--color-primary)",
              }}
            >
              {member?.name ?? "Shift"}
            </div>
          );
        })}
      </div>
    </div>
  );
}
