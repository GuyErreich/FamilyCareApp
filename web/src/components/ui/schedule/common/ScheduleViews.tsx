import { useEffect, useLayoutEffect, useMemo, useRef, useState } from "react";
import type { Shift, Unavailability, FamilyMember } from "../../../../lib/database.types";
import { SCHEDULE } from "../../../../lib/constants";
import {
  formatTime,
  isSameDay,
  isToday,
  monthGridWeeks,
  toDateKey,
} from "../../../../lib/dates";
import { pointerYToTime } from "../../../../lib/slotOverlap";
import { MonthEventChip } from "./MonthEventChip";
import {
  PlannerEventBlock,
  eventHeight,
  eventTop,
  type PlannerEventModel,
} from "./PlannerEventBlock";

const MAX_CHIPS_DEFAULT = 2;
const MAX_CHIPS_NARROW = 1;
const NARROW_MAX_WIDTH = 374;

function useMaxMonthChips(): number {
  const [maxChips, setMaxChips] = useState(() => {
    if (typeof window === "undefined") return MAX_CHIPS_DEFAULT;
    return window.matchMedia(`(max-width: ${NARROW_MAX_WIDTH}px)`).matches
      ? MAX_CHIPS_NARROW
      : MAX_CHIPS_DEFAULT;
  });

  useEffect(() => {
    const media = window.matchMedia(`(max-width: ${NARROW_MAX_WIDTH}px)`);
    const onChange = () => {
      setMaxChips(media.matches ? MAX_CHIPS_NARROW : MAX_CHIPS_DEFAULT);
    };
    media.addEventListener("change", onChange);
    return () => media.removeEventListener("change", onChange);
  }, []);

  return maxChips;
}

interface MonthEvent {
  id: string;
  kind: "shift" | "unavail";
  label: string;
  color: string;
  sortKey: number;
}

function dayEvents(
  dateKey: string,
  shifts: Shift[],
  unavailabilities: Unavailability[],
  membersById: Map<string, FamilyMember>,
): MonthEvent[] {
  const items: MonthEvent[] = [];

  for (const shift of shifts.filter((s) => s.shift_date === dateKey)) {
    const member = membersById.get(shift.assigned_member_id);
    items.push({
      id: shift.id,
      kind: "shift",
      label: member?.name ?? "Shift",
      color: member?.color_hex ?? "var(--color-primary)",
      sortKey: shift.start_hour * 60 + shift.start_minute,
    });
  }

  for (const block of unavailabilities.filter((u) => u.block_date === dateKey)) {
    const member = membersById.get(block.member_id);
    items.push({
      id: block.id,
      kind: "unavail",
      label: member ? `${member.name}` : "Unavailable",
      color: member?.color_hex ?? "var(--color-muted)",
      sortKey: block.start_hour * 60 + block.start_minute + 0.5,
    });
  }

  return items.sort((a, b) => a.sortKey - b.sortKey);
}

interface MonthGridProps {
  month: Date;
  shifts: Shift[];
  unavailabilities: Unavailability[];
  membersById: Map<string, FamilyMember>;
  selectedDate: Date;
  onSelectDate: (date: Date) => void;
}

export function MonthGrid({
  month,
  shifts,
  unavailabilities,
  membersById,
  selectedDate,
  onSelectDate,
}: MonthGridProps) {
  const weeks = monthGridWeeks(month);
  const monthIndex = month.getMonth();
  const maxChips = useMaxMonthChips();

  return (
    <div className="calendar-month">
      <div className="month-grid month-grid--weekdays">
        {["S", "M", "T", "W", "T", "F", "S"].map((d, i) => (
          <div key={`${d}-${i}`} className="month-grid__weekday">
            {d}
          </div>
        ))}
      </div>
      <div
        className="calendar-month__weeks"
        style={{ ["--week-rows" as string]: weeks.length }}
      >
        {weeks.map((week, wi) => (
          <div key={wi} className="month-grid month-grid--week">
            {week.map((day) => {
              const key = toDateKey(day);
              const events = dayEvents(key, shifts, unavailabilities, membersById);
              const outside = day.getMonth() !== monthIndex;
              const today = isToday(day);
              const selected = isSameDay(day, selectedDate);
              const visible = events.slice(0, maxChips);
              const hidden = events.length - visible.length;

              return (
                <button
                  key={key}
                  type="button"
                  className={[
                    "month-cell",
                    outside ? "month-cell--outside" : "",
                    today ? "month-cell--today" : "",
                    selected ? "month-cell--selected" : "",
                  ]
                    .filter(Boolean)
                    .join(" ")}
                  onClick={() => onSelectDate(day)}
                >
                  <span className="month-cell__day">{day.getDate()}</span>
                  <span className="month-cell__events">
                    {visible.map((ev) => (
                      <MonthEventChip
                        key={`${ev.kind}-${ev.id}`}
                        label={ev.label}
                        color={ev.color}
                        variant={ev.kind === "unavail" ? "unavail" : "shift"}
                      />
                    ))}
                    {hidden > 0 ? (
                      <button
                        type="button"
                        className="month-event-chip month-event-chip--more"
                        onClick={(e) => {
                          e.stopPropagation();
                          onSelectDate(day);
                        }}
                      >
                        +{hidden} more
                      </button>
                    ) : null}
                  </span>
                </button>
              );
            })}
          </div>
        ))}
      </div>
    </div>
  );
}

interface DragState {
  key: string;
  originStartHour: number;
  originStartMinute: number;
  previewStartHour: number;
  previewStartMinute: number;
  hasConflict: boolean;
}

interface DayPlannerProps {
  date: Date;
  shifts: Shift[];
  unavailabilities: Unavailability[];
  membersById: Map<string, FamilyMember>;
  markedKeys: Set<string>;
  selectionMode: boolean;
  dragState: DragState | null;
  onSlotClick: (hour: number, minute: number) => void;
  onEventTap: (event: PlannerEventModel) => void;
  onEventLongPress: (event: PlannerEventModel) => void;
  onDragStart: (event: PlannerEventModel) => void;
  onDragMove: (event: PlannerEventModel, deltaY: number) => void;
  onDragEnd: (event: PlannerEventModel) => void;
}

export function DayPlanner({
  date,
  shifts,
  unavailabilities,
  membersById,
  markedKeys,
  selectionMode,
  dragState,
  onSlotClick,
  onEventTap,
  onEventLongPress,
  onDragStart,
  onDragMove,
  onDragEnd,
}: DayPlannerProps) {
  const scrollRef = useRef<HTMLDivElement>(null);
  const dateKey = toDateKey(date);
  const hours = useMemo(() => Array.from({ length: 24 }, (_, i) => i), []);
  const hpm = SCHEDULE.heightPerMinute;
  const gridHeight = 24 * 60 * hpm;

  const events = useMemo((): PlannerEventModel[] => {
    const list: PlannerEventModel[] = [];
    for (const shift of shifts.filter((s) => s.shift_date === dateKey)) {
      const member = membersById.get(shift.assigned_member_id);
      list.push({
        key: `shift:${shift.id}`,
        kind: "shift",
        id: shift.id,
        label: member?.name ?? "Shift",
        color: member?.color_hex ?? "var(--color-primary)",
        startHour: shift.start_hour,
        startMinute: shift.start_minute,
        durationMinutes: shift.duration_minutes,
      });
    }
    for (const block of unavailabilities.filter((u) => u.block_date === dateKey)) {
      const member = membersById.get(block.member_id);
      list.push({
        key: `unavail:${block.id}`,
        kind: "unavail",
        id: block.id,
        label: member ? `${member.name} · Unavail` : "Unavailable",
        color: member?.color_hex ?? "var(--color-muted)",
        startHour: block.start_hour,
        startMinute: block.start_minute,
        durationMinutes: block.duration_minutes,
      });
    }
    return list.sort(
      (a, b) =>
        a.startHour * 60 + a.startMinute - (b.startHour * 60 + b.startMinute),
    );
  }, [shifts, unavailabilities, membersById, dateKey]);

  const isToday =
    dateKey === toDateKey(new Date());
  const now = new Date();
  const nowTop = isToday ? eventTop(now.getHours(), now.getMinutes()) : null;

  useLayoutEffect(() => {
    if (!isToday || nowTop === null) return;
    const panel = scrollRef.current;
    if (!panel) return;
    const offset = panel.clientHeight * 0.25;
    panel.scrollTop = Math.max(0, nowTop - offset);
  }, [dateKey, isToday, nowTop]);

  return (
    <div className="planner-panel" ref={scrollRef}>
      <div className="planner planner--bleed">
        <div className="planner__gutter" style={{ minHeight: gridHeight }}>
          {hours.map((hour) => (
            <div
              key={hour}
              className="planner__label"
              style={{ top: hour * 60 * hpm }}
            >
              {formatTime(hour, 0)}
            </div>
          ))}
        </div>
        <div
          className="planner__grid"
          style={{ minHeight: gridHeight }}
          role="presentation"
          onClick={(e) => {
            if ((e.target as HTMLElement).closest(".planner-event")) return;
            const rect = e.currentTarget.getBoundingClientRect();
            const y = e.clientY - rect.top;
            const { startHour, startMinute } = pointerYToTime(
              y,
              SCHEDULE.defaultDurationMinutes,
              hpm,
            );
            onSlotClick(startHour, startMinute);
          }}
        >
          {hours.map((hour) => (
            <div
              key={hour}
              className={[
                "planner__band",
                hour % 2 === 0 ? "planner__band--even" : "planner__band--odd",
              ].join(" ")}
              style={{ top: hour * 60 * hpm, height: 60 * hpm }}
            />
          ))}
          {nowTop !== null ? (
            <div className="planner__now" style={{ top: nowTop }} aria-hidden />
          ) : null}
          {events.map((event) => {
            const dragging = dragState?.key === event.key;
            const startHour = dragging
              ? dragState.previewStartHour
              : event.startHour;
            const startMinute = dragging
              ? dragState.previewStartMinute
              : event.startMinute;
            return (
              <PlannerEventBlock
                key={event.key}
                event={event}
                top={eventTop(event.startHour, event.startMinute)}
                height={eventHeight(event.durationMinutes)}
                previewTop={dragging ? eventTop(startHour, startMinute) : undefined}
                displayStartHour={startHour}
                displayStartMinute={startMinute}
                marked={markedKeys.has(event.key)}
                isDragging={dragging}
                hasConflict={dragging && dragState.hasConflict}
                selectionMode={selectionMode}
                onTap={onEventTap}
                onLongPress={onEventLongPress}
                onDragStart={onDragStart}
                onDragMove={onDragMove}
                onDragEnd={onDragEnd}
              />
            );
          })}
        </div>
      </div>
    </div>
  );
}

export type { DragState, PlannerEventModel };
