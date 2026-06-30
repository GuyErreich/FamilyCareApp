import { useEffect, useState } from "react";
import { Button } from "../../common/Button";
import { BottomSheet } from "../../common/BottomSheet";
import { useSheetDismiss } from "../../common/sheetDismissContext";
import { MemberChipPicker } from "../../common/MemberChipPicker";
import { Stack } from "../../common/Stack";
import { TextInput } from "../../common/TextField";
import { ShiftCalendarSyncControl } from "./ShiftCalendarSyncControl";
import type { FamilyMember, Shift, Unavailability } from "../../../../lib/database.types";
import { ROUTES } from "../../../../lib/constants";
import { SHEET_EXIT_CLEAR_MS } from "../../../../lib/motion";
import { useShiftCalendarSync } from "../../../../hooks/calendar/useShiftCalendarSync";
import { useSheetNavigation } from "../../../../hooks/ui/useSheetNavigation";
import { useSaveShift, useDeleteShift } from "../../../../hooks/shifts/useShiftMutations";
import {
  useDeleteUnavailability,
  useUpdateUnavailability,
} from "../../../../hooks/shifts/useUnavailabilityMutations";

export type EditTarget =
  | { kind: "shift"; data: Shift }
  | { kind: "unavail"; data: Unavailability };

interface EventEditSheetProps {
  target: EditTarget | null;
  members: FamilyMember[];
  onClose: () => void;
}

function editInitials(target: EditTarget) {
  if (target.kind === "shift") {
    return {
      memberId: target.data.assigned_member_id,
      startHour: target.data.start_hour,
      startMinute: target.data.start_minute,
      duration: target.data.duration_minutes,
    };
  }
  return {
    memberId: target.data.member_id,
    startHour: target.data.start_hour,
    startMinute: target.data.start_minute,
    duration: target.data.duration_minutes,
  };
}

function EventEditActions({
  target,
  memberId,
  startHour,
  startMinute,
  duration,
  members,
  calendarEventId,
  onError,
}: {
  target: EditTarget;
  memberId: string;
  startHour: number;
  startMinute: number;
  duration: number;
  members: FamilyMember[];
  calendarEventId: string | null;
  onError: (message: string) => void;
}) {
  const { openSheet } = useSheetNavigation();
  const dismiss = useSheetDismiss();
  const saveShift = useSaveShift();
  const deleteShift = useDeleteShift();
  const updateUnavail = useUpdateUnavailability();
  const deleteUnavail = useDeleteUnavailability();
  const { syncAfterSave, removeBeforeDelete } = useShiftCalendarSync();

  const pending =
    saveShift.isPending ||
    deleteShift.isPending ||
    updateUnavail.isPending ||
    deleteUnavail.isPending;

  const onSave = async () => {
    onError("");
    try {
      if (target.kind === "shift") {
        const saved = await saveShift.mutateAsync({
          id: target.data.id,
          input: {
            assigned_member_id: memberId,
            shift_date: target.data.shift_date,
            start_hour: startHour,
            start_minute: startMinute,
            duration_minutes: duration,
            notes: target.data.notes,
            status: target.data.status,
          },
        });
        await syncAfterSave(saved, members, {
          shiftId: target.data.id,
          calendarEventId,
        });
      } else {
        await updateUnavail.mutateAsync({
          id: target.data.id,
          input: {
            member_id: memberId,
            block_date: target.data.block_date,
            start_hour: startHour,
            start_minute: startMinute,
            duration_minutes: duration,
          },
        });
      }
      dismiss("press");
    } catch (err) {
      navigator.vibrate?.(20);
      onError(err instanceof Error ? err.message : "Save failed");
    }
  };

  const onDelete = async () => {
    onError("");
    try {
      if (target.kind === "shift") {
        await removeBeforeDelete(calendarEventId);
        await deleteShift.mutateAsync(target.data.id);
      } else {
        await deleteUnavail.mutateAsync(target.data.id);
      }
      dismiss("press");
    } catch (err) {
      navigator.vibrate?.(20);
      onError(err instanceof Error ? err.message : "Delete failed");
    }
  };

  const onOpenFullForm = () => {
    if (target.kind === "shift") {
      dismiss("press");
      openSheet(ROUTES.shiftEdit(target.data.id));
    }
  };

  return (
    <>
      <Button variant="danger" disabled={pending} onClick={() => void onDelete()}>
        Delete
      </Button>
      {target.kind === "shift" ? (
        <Button variant="secondary" disabled={pending} onClick={onOpenFullForm}>
          More
        </Button>
      ) : null}
      <Button fullWidth loading={pending} disabled={pending} onClick={() => void onSave()}>
        Save
      </Button>
    </>
  );
}

function EventEditSheetBody({
  open,
  target,
  members,
  onClose,
}: {
  open: boolean;
  target: EditTarget | null;
  members: FamilyMember[];
  onClose: () => void;
}) {
  const initial = target ? editInitials(target) : null;
  const [memberId, setMemberId] = useState(initial?.memberId ?? "");
  const [startHour, setStartHour] = useState(initial?.startHour ?? 9);
  const [startMinute, setStartMinute] = useState(initial?.startMinute ?? 0);
  const [duration, setDuration] = useState<number>(initial?.duration ?? 60);
  const [calendarEventId, setCalendarEventId] = useState<string | null>(
    target?.kind === "shift" ? target.data.calendar_event_id : null,
  );
  const [calendarPending, setCalendarPending] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const { connected: calendarConnected, unsyncShift, resyncShift } = useShiftCalendarSync();

  const targetKey = target ? `${target.kind}:${target.data.id}` : null;

  useEffect(() => {
    if (!open || !target) return;
    const frame = window.requestAnimationFrame(() => {
      const next = editInitials(target);
      setMemberId(next.memberId);
      setStartHour(next.startHour);
      setStartMinute(next.startMinute);
      setDuration(next.duration);
      setCalendarEventId(target.kind === "shift" ? target.data.calendar_event_id : null);
      setError(null);
    });
    return () => window.cancelAnimationFrame(frame);
  }, [open, targetKey, target]);

  const title =
    target?.kind === "shift"
      ? "Edit shift"
      : target?.kind === "unavail"
        ? "Edit unavailability"
        : undefined;

  const onUnsync = async () => {
    if (!target || target.kind !== "shift" || !calendarEventId) return;
    setError(null);
    setCalendarPending(true);
    try {
      await unsyncShift(target.data.id, calendarEventId);
      setCalendarEventId(null);
    } catch (err) {
      setError(err instanceof Error ? err.message : "Could not remove from calendar");
    } finally {
      setCalendarPending(false);
    }
  };

  const onResync = async () => {
    if (!target || target.kind !== "shift") return;
    setError(null);
    setCalendarPending(true);
    try {
      const shift: Shift = {
        ...target.data,
        assigned_member_id: memberId,
        start_hour: startHour,
        start_minute: startMinute,
        duration_minutes: duration,
      };
      const eventId = await resyncShift(shift, members);
      setCalendarEventId(eventId);
    } catch (err) {
      setError(err instanceof Error ? err.message : "Could not add to calendar");
    } finally {
      setCalendarPending(false);
    }
  };

  return (
    <BottomSheet
      open={open && target !== null}
      onClose={onClose}
      title={title}
      actions={
        target ? (
          <EventEditActions
            target={target}
            memberId={memberId}
            startHour={startHour}
            startMinute={startMinute}
            duration={duration}
            members={members}
            calendarEventId={calendarEventId}
            onError={(message) => setError(message || null)}
          />
        ) : undefined
      }
    >
      {target ? (
        <Stack>
          <MemberChipPicker members={members} value={memberId} onChange={setMemberId} />
          <div className="form-grid-2">
            <TextInput
              label="Start hour"
              type="number"
              min={0}
              max={23}
              value={startHour}
              onChange={(e) => setStartHour(Number(e.target.value))}
            />
            <TextInput
              label="Start minute"
              type="number"
              min={0}
              max={59}
              step={15}
              value={startMinute}
              onChange={(e) => setStartMinute(Number(e.target.value))}
            />
          </div>
          <TextInput
            label="Duration (min)"
            type="number"
            min={15}
            step={15}
            value={duration}
            onChange={(e) => setDuration(Number(e.target.value))}
          />
          {target.kind === "shift" ? (
            <ShiftCalendarSyncControl
              calendarConnected={calendarConnected}
              isNew={false}
              synced={Boolean(calendarEventId)}
              pending={calendarPending}
              onUnsync={() => void onUnsync()}
              onResync={() => void onResync()}
            />
          ) : null}
          {error ? <p className="error-text">{error}</p> : null}
        </Stack>
      ) : null}
    </BottomSheet>
  );
}

/** Quick-edit sheet for planner events — stays mounted so Vaul can run enter/exit animations. */
export function EventEditSheet({ target, members, onClose }: EventEditSheetProps) {
  const [stableTarget, setStableTarget] = useState<EditTarget | null>(null);
  const open = target !== null;

  useEffect(() => {
    if (target) setStableTarget(target);
  }, [target]);

  useEffect(() => {
    if (!open && stableTarget) {
      const id = window.setTimeout(() => setStableTarget(null), SHEET_EXIT_CLEAR_MS);
      return () => window.clearTimeout(id);
    }
  }, [open, stableTarget]);

  return (
    <EventEditSheetBody
      open={open}
      target={stableTarget}
      members={members}
      onClose={onClose}
    />
  );
}
