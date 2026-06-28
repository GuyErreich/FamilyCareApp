import type { KeyboardEvent } from "react";
import { Check } from "lucide-react";
import { usePlannerPointerGesture } from "../../../../hooks/schedule/usePlannerPointerGesture";
import { SCHEDULE } from "../../../../lib/constants";
import { formatTimeRange } from "../../../../lib/slotOverlap";

export type PlannerItemKind = "shift" | "unavail";

export interface PlannerEventModel {
  key: string;
  kind: PlannerItemKind;
  id: string;
  label: string;
  color: string;
  startHour: number;
  startMinute: number;
  durationMinutes: number;
}

interface PlannerEventBlockProps {
  event: PlannerEventModel;
  top: number;
  height: number;
  marked: boolean;
  isDragging: boolean;
  hasConflict: boolean;
  previewTop?: number;
  displayStartHour?: number;
  displayStartMinute?: number;
  selectionMode: boolean;
  onTap: (event: PlannerEventModel) => void;
  onLongPress: (event: PlannerEventModel) => void;
  onDragStart: (event: PlannerEventModel) => void;
  onDragMove: (event: PlannerEventModel, deltaY: number) => void;
  onDragEnd: (event: PlannerEventModel) => void;
}

export function PlannerEventBlock({
  event,
  top,
  height,
  marked,
  isDragging,
  hasConflict,
  previewTop,
  displayStartHour,
  displayStartMinute,
  selectionMode,
  onTap,
  onLongPress,
  onDragStart,
  onDragMove,
  onDragEnd,
}: PlannerEventBlockProps) {
  const { handlers } = usePlannerPointerGesture({
    onTap: () => onTap(event),
    onLongPress: () => onLongPress(event),
    onDragStart: () => onDragStart(event),
    onDragMove: (deltaY) => onDragMove(event, deltaY),
    onDragEnd: () => onDragEnd(event),
  });

  const displayTop = isDragging && previewTop !== undefined ? previewTop : top;
  const labelHour = displayStartHour ?? event.startHour;
  const labelMinute = displayStartMinute ?? event.startMinute;
  const timeLabel = formatTimeRange(labelHour, labelMinute, event.durationMinutes);

  const onKeyDown = (e: KeyboardEvent) => {
    if (e.key === "Enter" || e.key === " ") {
      e.preventDefault();
      onTap(event);
    }
  };

  return (
    <div
      role="button"
      tabIndex={0}
      aria-label={`${event.label}, ${timeLabel}`}
      className={[
        "planner-event",
        event.kind === "unavail" ? "planner-event--unavail" : "",
        marked ? "planner-event--marked" : "",
        isDragging ? "planner-event--dragging" : "",
        hasConflict ? "planner-event--conflict" : "",
        selectionMode ? "planner-event--selectable" : "",
      ]
        .filter(Boolean)
        .join(" ")}
      style={{
        top: displayTop,
        height: Math.max(height, 28),
        ["--event-color" as string]: event.color,
      }}
      onKeyDown={onKeyDown}
      {...handlers}
    >
      <span className="planner-event__accent" aria-hidden />
      <span className="planner-event__body">
        <span className="planner-event__name">{event.label}</span>
        <span className="planner-event__time">{timeLabel}</span>
      </span>
      {marked ? (
        <span className="planner-event__mark" aria-hidden>
          <Check size={14} strokeWidth={3} />
        </span>
      ) : null}
    </div>
  );
}

export function eventTop(startHour: number, startMinute: number): number {
  return (startHour * 60 + startMinute) * SCHEDULE.heightPerMinute;
}

export function eventHeight(durationMinutes: number): number {
  return durationMinutes * SCHEDULE.heightPerMinute;
}
