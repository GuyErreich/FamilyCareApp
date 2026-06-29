import { useEffect, useMemo, useRef, useState } from "react";
import { AnimatePresence, motion, useReducedMotion } from "framer-motion";
import { ChevronDown, ChevronLeft, ChevronRight } from "lucide-react";
import { IconButton } from "../../common/IconButton";
import { BottomSheet } from "../../common/BottomSheet";
import { useSheetDismiss } from "../../common/sheetDismissContext";
import { Button, SheetCloseButton } from "../../common/Button";
import { ErrorState, LoadingState } from "../../common/AsyncStates";
import {
  DayPlanner,
  MonthGrid,
  type DragState,
  type PlannerEventModel,
} from "./ScheduleViews";
import { ScheduleSlotSheet } from "./ScheduleSlotSheet";
import { EventEditSheet, type EditTarget } from "./EventEditSheet";
import { PlannerSelectionBar } from "./PlannerSelectionBar";
import { MonthYearPickerSheet } from "./MonthYearPickerSheet";
import { addDays, startOfDay, toDateKey } from "../../../../lib/dates";
import { PANEL_SLIDE_PX, slideFadeVariants } from "../../../../lib/motion";
import { SCHEDULE } from "../../../../lib/constants";
import { useShiftCalendarSync } from "../../../../hooks/calendar/useShiftCalendarSync";
import {
  useCurrentMember,
  useFamilyMembers,
  useShifts,
  useUnavailabilities,
} from "../../../../hooks/family/useFamilyData";
import { useSaveShift } from "../../../../hooks/shifts/useShiftMutations";
import {
  useBatchDeleteShifts,
  useBatchDeleteUnavailabilities,
  useUpdateUnavailability,
} from "../../../../hooks/shifts/useUnavailabilityMutations";
import { clampStartMinutes, resolveFreePlacement } from "../../../../lib/slotOverlap";
import {
  readCalendarMonth,
  readCalendarSelectedDate,
  readCalendarView,
  writeCalendarMonth,
  writeCalendarSelectedDate,
  writeCalendarView,
  type CalendarView,
} from "../../../../lib/calendarSession";
import { useShellUi } from "../../../../hooks/useShellUi";

interface PendingSlot {
  hour: number;
  minute: number;
}

function BatchDeleteActions({
  pending,
  error,
  onDelete,
}: {
  pending: boolean;
  error: string | null;
  onDelete: () => Promise<void>;
}) {
  const dismiss = useSheetDismiss();

  const onPress = async () => {
    try {
      await onDelete();
      dismiss("press");
    } catch {
      navigator.vibrate?.(20);
    }
  };

  return (
    <>
      <SheetCloseButton>Cancel</SheetCloseButton>
      <Button variant="danger" fullWidth loading={pending} disabled={pending} onClick={() => void onPress()}>
        Delete
      </Button>
      {error ? <p className="error-text">{error}</p> : null}
    </>
  );
}

export function CalendarPageContent() {
  const { setHideFab } = useShellUi();
  const [view, setView] = useState<CalendarView>(() => readCalendarView());
  const [month, setMonth] = useState(() => readCalendarMonth());
  const [selectedDate, setSelectedDate] = useState(() => readCalendarSelectedDate());
  const [pendingSlot, setPendingSlot] = useState<PendingSlot | null>(null);
  const [markedKeys, setMarkedKeys] = useState<Set<string>>(new Set());
  const [editTarget, setEditTarget] = useState<EditTarget | null>(null);
  const [dragState, setDragState] = useState<DragState | null>(null);
  const dragStateRef = useRef<DragState | null>(null);
  const dragOriginRef = useRef<{ key: string; startMinutes: number; duration: number } | null>(
    null,
  );
  const [batchDeleteOpen, setBatchDeleteOpen] = useState(false);
  const [batchDeleteError, setBatchDeleteError] = useState<string | null>(null);
  const [dragError, setDragError] = useState<string | null>(null);
  const [monthYearOpen, setMonthYearOpen] = useState(false);
  const [panelDirection, setPanelDirection] = useState(1);
  const reduceMotion = useReducedMotion();

  const rangeStart = toDateKey(addDays(month, -7));
  const rangeEnd = toDateKey(addDays(month, 42));
  const shiftsQuery = useShifts(rangeStart, rangeEnd);
  const unavailQuery = useUnavailabilities(rangeStart, rangeEnd);
  const membersQuery = useFamilyMembers();

  const saveShift = useSaveShift();
  const updateUnavail = useUpdateUnavailability();
  const batchDeleteShifts = useBatchDeleteShifts();
  const batchDeleteUnavail = useBatchDeleteUnavailabilities();
  const { syncAfterSave, removeBeforeDelete } = useShiftCalendarSync();

  const membersById = useMemo(() => {
    const map = new Map<string, NonNullable<typeof membersQuery.data>[number]>();
    for (const m of membersQuery.data ?? []) map.set(m.id, m);
    return map;
  }, [membersQuery.data]);

  const members = membersQuery.data ?? [];
  const currentMember = useCurrentMember(members);
  const shifts = shiftsQuery.data ?? [];
  const unavailabilities = unavailQuery.data ?? [];
  const dateKey = toDateKey(selectedDate);
  const selectionMode = markedKeys.size > 0;

  useEffect(() => {
    setHideFab(selectionMode);
    return () => setHideFab(false);
  }, [selectionMode, setHideFab]);

  useEffect(() => {
    writeCalendarView(view);
  }, [view]);

  useEffect(() => {
    writeCalendarMonth(month);
  }, [month]);

  useEffect(() => {
    writeCalendarSelectedDate(selectedDate);
  }, [selectedDate]);

  const shiftById = useMemo(() => new Map(shifts.map((s) => [s.id, s])), [shifts]);
  const unavailById = useMemo(
    () => new Map(unavailabilities.map((u) => [u.id, u])),
    [unavailabilities],
  );

  if (shiftsQuery.isLoading || membersQuery.isLoading || unavailQuery.isLoading) {
    return <LoadingState label="Loading calendar…" />;
  }
  if (shiftsQuery.error || membersQuery.error || unavailQuery.error) {
    const loadError =
      (shiftsQuery.error ?? membersQuery.error ?? unavailQuery.error)?.message ??
      "Failed to load calendar";
    return (
      <ErrorState
        message={loadError}
        onRetry={() => {
          void shiftsQuery.refetch();
          void membersQuery.refetch();
          void unavailQuery.refetch();
        }}
      />
    );
  }

  const monthLabel = month.toLocaleString(undefined, { month: "long", year: "numeric" });
  const dayLabel = selectedDate.toLocaleDateString(undefined, {
    weekday: "long",
    month: "short",
    day: "numeric",
  });

  const openDay = (day: Date) => {
    const dayStart = startOfDay(day);
    setSelectedDate(dayStart);
    setMonth((current) => {
      if (
        current.getFullYear() === dayStart.getFullYear() &&
        current.getMonth() === dayStart.getMonth()
      ) {
        return current;
      }
      return new Date(dayStart.getFullYear(), dayStart.getMonth(), 1);
    });
    setView("day");
    setPanelDirection(1);
    setMarkedKeys(new Set());
    navigator.vibrate?.(8);
  };

  const backToMonth = () => {
    setMonth(new Date(selectedDate.getFullYear(), selectedDate.getMonth(), 1));
    setView("month");
    setPanelDirection(-1);
    setMarkedKeys(new Set());
    navigator.vibrate?.(8);
  };

  const toggleMark = (key: string) => {
    setMarkedKeys((prev) => {
      const next = new Set(prev);
      if (next.has(key)) next.delete(key);
      else next.add(key);
      return next;
    });
  };

  const onEventTap = (event: PlannerEventModel) => {
    if (selectionMode) {
      toggleMark(event.key);
      return;
    }
    if (event.kind === "shift") {
      const data = shiftById.get(event.id);
      if (data) setEditTarget({ kind: "shift", data });
    } else {
      const data = unavailById.get(event.id);
      if (data) setEditTarget({ kind: "unavail", data });
    }
  };

  const onEventLongPress = (event: PlannerEventModel) => {
    toggleMark(event.key);
  };

  const onDragStart = (event: PlannerEventModel) => {
    setDragError(null);
    dragOriginRef.current = {
      key: event.key,
      startMinutes: event.startHour * 60 + event.startMinute,
      duration: event.durationMinutes,
    };
    const next: DragState = {
      key: event.key,
      originStartHour: event.startHour,
      originStartMinute: event.startMinute,
      previewStartHour: event.startHour,
      previewStartMinute: event.startMinute,
      hasConflict: false,
    };
    dragStateRef.current = next;
    setDragState(next);
  };

  const onDragMove = (event: PlannerEventModel, deltaY: number) => {
    const origin = dragOriginRef.current;
    if (!origin || origin.key !== event.key) return;

    const originPx = origin.startMinutes * SCHEDULE.heightPerMinute;
    const newMinutes = Math.round(
      (originPx + deltaY) / SCHEDULE.heightPerMinute / SCHEDULE.snapMinutes,
    ) * SCHEDULE.snapMinutes;
    const clamped = clampStartMinutes(
      Math.floor(newMinutes / 60),
      newMinutes % 60,
      origin.duration,
    );
    const placement = resolveFreePlacement(
      dateKey,
      clamped.startHour,
      clamped.startMinute,
      origin.duration,
      shifts,
      unavailabilities,
      { id: event.id, kind: event.kind },
    );
    const next: DragState = {
      key: event.key,
      originStartHour: dragStateRef.current?.originStartHour ?? event.startHour,
      originStartMinute: dragStateRef.current?.originStartMinute ?? event.startMinute,
      previewStartHour: placement.startHour,
      previewStartMinute: placement.startMinute,
      hasConflict: placement.hasConflict,
    };
    dragStateRef.current = next;
    setDragState(next);
  };

  const onDragEnd = async (event: PlannerEventModel) => {
    const state = dragStateRef.current;
    dragOriginRef.current = null;
    dragStateRef.current = null;
    setDragState(null);
    if (!state || state.key !== event.key || state.hasConflict) {
      if (state?.hasConflict) navigator.vibrate?.(20);
      return;
    }
    if (
      state.previewStartHour === state.originStartHour &&
      state.previewStartMinute === state.originStartMinute
    ) {
      return;
    }

    try {
      if (event.kind === "shift") {
        const shift = shiftById.get(event.id);
        if (!shift) return;
        const saved = await saveShift.mutateAsync({
          id: shift.id,
          input: {
            assigned_member_id: shift.assigned_member_id,
            shift_date: shift.shift_date,
            start_hour: state.previewStartHour,
            start_minute: state.previewStartMinute,
            duration_minutes: shift.duration_minutes,
            notes: shift.notes,
            status: shift.status,
          },
        });
        await syncAfterSave(saved, members, {
          shiftId: shift.id,
          calendarEventId: shift.calendar_event_id,
        });
      } else {
        const block = unavailById.get(event.id);
        if (!block) return;
        await updateUnavail.mutateAsync({
          id: block.id,
          input: {
            member_id: block.member_id,
            block_date: block.block_date,
            start_hour: state.previewStartHour,
            start_minute: state.previewStartMinute,
            duration_minutes: block.duration_minutes,
          },
        });
      }
      navigator.vibrate?.(8);
    } catch (err) {
      navigator.vibrate?.(20);
      setDragError(err instanceof Error ? err.message : "Could not move event");
    }
  };

  const onEditSelection = () => {
    if (markedKeys.size !== 1) return;
    const key = [...markedKeys][0];
    const [kind, id] = key.split(":");
    if (kind === "shift") {
      const data = shiftById.get(id);
      if (data) setEditTarget({ kind: "shift", data });
    } else {
      const data = unavailById.get(id);
      if (data) setEditTarget({ kind: "unavail", data });
    }
  };

  const onConfirmBatchDelete = async () => {
    setBatchDeleteError(null);
    const shiftIds: string[] = [];
    const unavailIds: string[] = [];
    for (const key of markedKeys) {
      const [kind, id] = key.split(":");
      if (kind === "shift") shiftIds.push(id);
      else unavailIds.push(id);
    }
    try {
      for (const id of shiftIds) {
        const shift = shiftById.get(id);
        await removeBeforeDelete(shift?.calendar_event_id);
      }
      if (shiftIds.length) await batchDeleteShifts.mutateAsync(shiftIds);
      if (unavailIds.length) await batchDeleteUnavail.mutateAsync(unavailIds);
      setMarkedKeys(new Set());
    } catch (err) {
      setBatchDeleteError(err instanceof Error ? err.message : "Delete failed");
      throw err;
    }
  };

  const batchDeletePending = batchDeleteShifts.isPending || batchDeleteUnavail.isPending;
  const isDayView = view === "day";
  const panelVariants = slideFadeVariants(PANEL_SLIDE_PX, reduceMotion);

  return (
    <div className="calendar-screen" data-view={view}>
      <div className="calendar-viewport">
        <AnimatePresence mode="wait" initial={false} custom={panelDirection}>
          {!isDayView ? (
            <motion.section
              key="month"
              custom={panelDirection}
              className="calendar-panel calendar-panel--month"
              variants={panelVariants}
              initial="initial"
              animate="animate"
              exit="exit"
              aria-hidden={false}
            >
          <header className="calendar-toolbar">
            <IconButton icon={ChevronLeft} label="Previous month" onClick={() =>
              setMonth(new Date(month.getFullYear(), month.getMonth() - 1, 1))
            } />
            <button
              type="button"
              className="calendar-toolbar__title calendar-toolbar__title-btn"
              onClick={() => setMonthYearOpen(true)}
              aria-label={`${monthLabel}. Choose month and year`}
            >
              <span key={monthLabel}>{monthLabel}</span>
              <ChevronDown size={18} aria-hidden className="calendar-toolbar__title-chevron" />
            </button>
            <IconButton icon={ChevronRight} label="Next month" onClick={() =>
              setMonth(new Date(month.getFullYear(), month.getMonth() + 1, 1))
            } />
          </header>
          <MonthGrid
            month={month}
            shifts={shifts}
            unavailabilities={unavailabilities}
            membersById={membersById}
            selectedDate={selectedDate}
            onSelectDate={openDay}
          />
        </motion.section>
          ) : (
            <motion.section
              key="day"
              custom={panelDirection}
              className="calendar-panel calendar-panel--day"
              variants={panelVariants}
              initial="initial"
              animate="animate"
              exit="exit"
              aria-hidden={false}
            >
          <header className="calendar-toolbar">
            <IconButton icon={ChevronLeft} label="Back to month" onClick={backToMonth} />
            <button
              type="button"
              className="calendar-toolbar__title calendar-toolbar__title-btn"
              onClick={() => setMonthYearOpen(true)}
              aria-label={`${dayLabel}. Choose month and year`}
            >
              <span key={dayLabel}>{dayLabel}</span>
              <ChevronDown size={18} aria-hidden className="calendar-toolbar__title-chevron" />
            </button>
            <span className="calendar-toolbar__spacer" aria-hidden />
          </header>
          <DayPlanner
            date={selectedDate}
            shifts={shifts}
            unavailabilities={unavailabilities}
            membersById={membersById}
            markedKeys={markedKeys}
            selectionMode={selectionMode}
            dragState={dragState}
            onSlotClick={(hour, minute) => setPendingSlot({ hour, minute })}
            onEventTap={onEventTap}
            onEventLongPress={onEventLongPress}
            onDragStart={onDragStart}
            onDragMove={onDragMove}
            onDragEnd={(e) => void onDragEnd(e)}
          />
          {dragError ? (
            <p className="error-text calendar-screen__drag-error" role="alert">
              {dragError}
            </p>
          ) : null}
        </motion.section>
          )}
        </AnimatePresence>
      </div>

      <ScheduleSlotSheet
        open={Boolean(pendingSlot)}
        onClose={() => setPendingSlot(null)}
        date={selectedDate}
        hour={pendingSlot?.hour ?? 0}
        minute={pendingSlot?.minute ?? 0}
        members={members}
        defaultMemberId={currentMember?.id ?? members[0]?.id ?? ""}
      />

      <EventEditSheet
        target={editTarget}
        members={members}
        onClose={() => setEditTarget(null)}
      />

      <PlannerSelectionBar
        count={markedKeys.size}
        onClear={() => setMarkedKeys(new Set())}
        onEdit={onEditSelection}
        onDelete={() => setBatchDeleteOpen(true)}
      />

      <MonthYearPickerSheet
        open={monthYearOpen}
        onClose={() => setMonthYearOpen(false)}
        value={new Date(selectedDate.getFullYear(), selectedDate.getMonth(), 1)}
        onApply={(nextMonth) => {
          setMonth(nextMonth);
          setView("month");
          setSelectedDate((current) => {
            const lastDay = new Date(
              nextMonth.getFullYear(),
              nextMonth.getMonth() + 1,
              0,
            ).getDate();
            const day = Math.min(current.getDate(), lastDay);
            return new Date(nextMonth.getFullYear(), nextMonth.getMonth(), day);
          });
        }}
      />

      <BottomSheet
        open={batchDeleteOpen}
        onClose={() => {
          setBatchDeleteOpen(false);
          setBatchDeleteError(null);
        }}
        title={`Delete ${markedKeys.size} item${markedKeys.size === 1 ? "" : "s"}?`}
        actions={
          <BatchDeleteActions
            pending={batchDeletePending}
            error={batchDeleteError}
            onDelete={onConfirmBatchDelete}
          />
        }
      >
        <p className="muted">This cannot be undone.</p>
      </BottomSheet>
    </div>
  );
}
