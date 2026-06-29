import type { FormEvent } from "react";
import { useMemo, useState } from "react";
import { useSearchParams } from "react-router-dom";
import { ErrorState, LoadingState } from "../components/ui/common/AsyncStates";
import { Button } from "../components/ui/common/Button";
import { Card } from "../components/ui/common/Card";
import { FormActionBar } from "../components/ui/common/FormActionBar";
import { FormPage } from "../components/ui/common/FormPage";
import { FormStack } from "../components/ui/common/FormStack";
import { MemberChipPicker } from "../components/ui/common/MemberChipPicker";
import { TextArea, TextInput } from "../components/ui/common/TextField";
import { ShiftCalendarSyncControl } from "../components/ui/schedule/common/ShiftCalendarSyncControl";
import { useShiftCalendarSync } from "../hooks/calendar/useShiftCalendarSync";
import { useSheetNavigation } from "../hooks/ui/useSheetNavigation";
import {
  useFamilyMembers,
  useShift,
} from "../hooks/family/useFamilyData";
import { useDeleteShift, useSaveShift } from "../hooks/shifts/useShiftMutations";
import type { FamilyMember, Shift } from "../lib/database.types";
import { SCHEDULE } from "../lib/constants";

interface ShiftFormValues {
  assignedMemberId: string;
  shiftDate: string;
  startHour: number;
  startMinute: number;
  duration: number;
  notes: string;
}

function buildNewShiftValues(params: URLSearchParams): ShiftFormValues {
  return {
    assignedMemberId: "",
    shiftDate: params.get("date") ?? new Date().toISOString().slice(0, 10),
    startHour: Number(params.get("hour") ?? 9),
    startMinute: Number(params.get("minute") ?? 0),
    duration: SCHEDULE.defaultDurationMinutes,
    notes: "",
  };
}

function buildEditShiftValues(shift: Shift): ShiftFormValues {
  return {
    assignedMemberId: shift.assigned_member_id,
    shiftDate: shift.shift_date,
    startHour: shift.start_hour,
    startMinute: shift.start_minute,
    duration: shift.duration_minutes,
    notes: shift.notes ?? "",
  };
}

function ShiftFormFields({
  shiftId,
  initialValues,
  members,
  calendarConnected,
  initialCalendarEventId,
}: {
  shiftId?: string;
  initialValues: ShiftFormValues;
  members: FamilyMember[];
  calendarConnected: boolean;
  initialCalendarEventId?: string | null;
}) {
  const { closeSheet } = useSheetNavigation();
  const saveShift = useSaveShift();
  const deleteShift = useDeleteShift();
  const { syncAfterSave, removeBeforeDelete, unsyncShift, resyncShift } = useShiftCalendarSync();

  const defaultMember = useMemo(() => members?.[0]?.id ?? "", [members]);
  const [assignedMemberId, setAssignedMemberId] = useState(
    initialValues.assignedMemberId || defaultMember,
  );
  const [shiftDate, setShiftDate] = useState(initialValues.shiftDate);
  const [startHour, setStartHour] = useState(initialValues.startHour);
  const [startMinute, setStartMinute] = useState(initialValues.startMinute);
  const [duration, setDuration] = useState(initialValues.duration);
  const [notes, setNotes] = useState(initialValues.notes);
  const [calendarEventId, setCalendarEventId] = useState(initialCalendarEventId ?? null);
  const [calendarPending, setCalendarPending] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const memberId = assignedMemberId || defaultMember;
  const calendarSynced = Boolean(calendarEventId);

  const buildShiftSnapshot = (): Shift | null => {
    if (!shiftId) return null;
    return {
      id: shiftId,
      family_id: "",
      assigned_member_id: memberId,
      shift_date: shiftDate,
      start_hour: startHour,
      start_minute: startMinute,
      duration_minutes: duration,
      end_time: "",
      notes: notes || null,
      status: "scheduled",
      reminder_offset_minutes: [],
      repeat_rule: null,
      calendar_event_id: calendarEventId,
      created_at: "",
      updated_at: "",
    };
  };

  const onSubmit = async (e: FormEvent) => {
    e.preventDefault();
    setError(null);
    try {
      const saved = await saveShift.mutateAsync({
        id: shiftId,
        input: {
          assigned_member_id: memberId,
          shift_date: shiftDate,
          start_hour: startHour,
          start_minute: startMinute,
          duration_minutes: duration,
          notes: notes || null,
        },
      });

      await syncAfterSave(saved, members, { shiftId, calendarEventId });
      closeSheet();
    } catch (err) {
      setError(err instanceof Error ? err.message : String(err));
    }
  };

  const onDelete = async () => {
    if (!shiftId) return;
    setError(null);
    try {
      await removeBeforeDelete(calendarEventId);
      await deleteShift.mutateAsync(shiftId);
      closeSheet();
    } catch (err) {
      setError(err instanceof Error ? err.message : String(err));
    }
  };

  const onUnsync = async () => {
    if (!shiftId || !calendarEventId) return;
    setError(null);
    setCalendarPending(true);
    try {
      await unsyncShift(shiftId, calendarEventId);
      setCalendarEventId(null);
    } catch (err) {
      setError(err instanceof Error ? err.message : String(err));
    } finally {
      setCalendarPending(false);
    }
  };

  const onResync = async () => {
    const shift = buildShiftSnapshot();
    if (!shift) return;
    setError(null);
    setCalendarPending(true);
    try {
      const eventId = await resyncShift(shift, members);
      setCalendarEventId(eventId);
    } catch (err) {
      setError(err instanceof Error ? err.message : String(err));
    } finally {
      setCalendarPending(false);
    }
  };

  return (
    <FormPage>
      <Card>
        <FormStack gap="lg" id="shift-form" onSubmit={onSubmit}>
          <MemberChipPicker members={members} value={memberId} onChange={setAssignedMemberId} />
          <TextInput
            label="Date"
            type="date"
            value={shiftDate}
            onChange={(e) => setShiftDate(e.target.value)}
            required
          />
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
            label="Duration (minutes)"
            type="number"
            min={15}
            step={15}
            value={duration}
            onChange={(e) => setDuration(Number(e.target.value))}
          />
          <TextArea
            label="Notes"
            rows={3}
            value={notes}
            onChange={(e) => setNotes(e.target.value)}
          />
          <ShiftCalendarSyncControl
            calendarConnected={calendarConnected}
            isNew={!shiftId}
            synced={calendarSynced}
            pending={calendarPending}
            onUnsync={() => void onUnsync()}
            onResync={() => void onResync()}
          />
          {error ? <ErrorState message={error} /> : null}
        </FormStack>
      </Card>

      <FormActionBar>
        <Button variant="secondary" onClick={closeSheet}>
          Cancel
        </Button>
        {shiftId ? (
          <Button
            variant="danger"
            disabled={deleteShift.isPending}
            onClick={() => void onDelete()}
          >
            Delete
          </Button>
        ) : null}
        <Button
          type="submit"
          form="shift-form"
          loading={saveShift.isPending}
          disabled={saveShift.isPending}
        >
          Save shift
        </Button>
      </FormActionBar>
    </FormPage>
  );
}

export function ShiftFormPage({ shiftId }: { shiftId?: string }) {
  const [params] = useSearchParams();
  const membersQuery = useFamilyMembers();
  const shiftQuery = useShift(shiftId);
  const { connected: calendarConnected } = useShiftCalendarSync();

  if (membersQuery.isLoading || (shiftId && shiftQuery.isLoading)) {
    return <LoadingState label="Loading shift…" />;
  }

  if (shiftQuery.error) {
    return <ErrorState message={shiftQuery.error.message} />;
  }

  const members = membersQuery.data ?? [];
  const initialValues =
    shiftId && shiftQuery.data
      ? buildEditShiftValues(shiftQuery.data)
      : buildNewShiftValues(params);

  return (
    <ShiftFormFields
      key={shiftId ?? `${params.toString()}-${members.length}`}
      shiftId={shiftId}
      initialValues={initialValues}
      members={members}
      calendarConnected={calendarConnected}
      initialCalendarEventId={shiftQuery.data?.calendar_event_id}
    />
  );
}
