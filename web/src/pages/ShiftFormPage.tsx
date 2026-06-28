import type { FormEvent } from "react";
import { useMemo, useState } from "react";
import { useNavigate, useSearchParams } from "react-router-dom";
import { ErrorState, LoadingState } from "../components/ui/common/AsyncStates";
import { Button } from "../components/ui/common/Button";
import { Card } from "../components/ui/common/Card";
import { FormActionBar } from "../components/ui/common/FormActionBar";
import { FormPage } from "../components/ui/common/FormPage";
import { FormStack } from "../components/ui/common/FormStack";
import { MemberChipPicker } from "../components/ui/common/MemberChipPicker";
import { TextArea, TextInput } from "../components/ui/common/TextField";
import { useGoogleCalendar } from "../hooks/calendar/useGoogleCalendar";
import {
  useFamily,
  useFamilyMembers,
  useShift,
} from "../hooks/family/useFamilyData";
import { useDeleteShift, useSaveShift } from "../hooks/shifts/useShiftMutations";
import type { FamilyMember, Shift } from "../lib/database.types";
import { ROUTES, SCHEDULE } from "../lib/constants";
import { supabase } from "../lib/supabase";

interface ShiftFormValues {
  assignedMemberId: string;
  shiftDate: string;
  startHour: number;
  startMinute: number;
  duration: number;
  notes: string;
  syncToCalendar: boolean;
}

function buildNewShiftValues(params: URLSearchParams): ShiftFormValues {
  return {
    assignedMemberId: "",
    shiftDate: params.get("date") ?? new Date().toISOString().slice(0, 10),
    startHour: Number(params.get("hour") ?? 9),
    startMinute: Number(params.get("minute") ?? 0),
    duration: SCHEDULE.defaultDurationMinutes,
    notes: "",
    syncToCalendar: false,
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
    syncToCalendar: Boolean(shift.calendar_event_id),
  };
}

function ShiftFormFields({
  shiftId,
  initialValues,
  members,
  familyName,
  grandpaName,
  calendarConnected,
}: {
  shiftId?: string;
  initialValues: ShiftFormValues;
  members: FamilyMember[];
  familyName?: string;
  grandpaName?: string;
  calendarConnected: boolean;
}) {
  const navigate = useNavigate();
  const saveShift = useSaveShift();
  const deleteShift = useDeleteShift();
  const calendar = useGoogleCalendar();

  const defaultMember = useMemo(() => members?.[0]?.id ?? "", [members]);
  const [assignedMemberId, setAssignedMemberId] = useState(
    initialValues.assignedMemberId || defaultMember,
  );
  const [shiftDate, setShiftDate] = useState(initialValues.shiftDate);
  const [startHour, setStartHour] = useState(initialValues.startHour);
  const [startMinute, setStartMinute] = useState(initialValues.startMinute);
  const [duration, setDuration] = useState(initialValues.duration);
  const [notes, setNotes] = useState(initialValues.notes);
  const [syncToCalendar, setSyncToCalendar] = useState(initialValues.syncToCalendar);
  const [error, setError] = useState<string | null>(null);

  const memberId = assignedMemberId || defaultMember;

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

      if (syncToCalendar && calendarConnected) {
        const member = members.find((m) => m.id === memberId);
        await calendar.syncShift(saved, member, familyName, grandpaName);
      } else if (!syncToCalendar && saved.calendar_event_id) {
        await calendar.deleteEvent(saved.calendar_event_id);
        await supabase
          .from("shifts")
          .update({ calendar_event_id: null })
          .eq("id", saved.id);
      }

      navigate(ROUTES.calendar);
    } catch (err) {
      setError(err instanceof Error ? err.message : String(err));
    }
  };

  const onDelete = async () => {
    if (!shiftId) return;
    setError(null);
    try {
      if (initialValues.syncToCalendar && calendarConnected) {
        const eventId = (
          await supabase.from("shifts").select("calendar_event_id").eq("id", shiftId).single()
        ).data?.calendar_event_id;
        if (eventId) await calendar.deleteEvent(eventId);
      }
      await deleteShift.mutateAsync(shiftId);
      navigate(ROUTES.calendar);
    } catch (err) {
      setError(err instanceof Error ? err.message : String(err));
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
          {calendarConnected ? (
            <label className="field field--inline">
              <input
                type="checkbox"
                checked={syncToCalendar}
                onChange={(e) => setSyncToCalendar(e.target.checked)}
              />
              <span className="field__label field__label--inline">
                Sync to Google Calendar when saved
              </span>
            </label>
          ) : (
            <p className="muted">Connect Google Calendar in Settings to sync shifts.</p>
          )}
          {error ? <ErrorState message={error} /> : null}
        </FormStack>
      </Card>

      <FormActionBar>
        <Button variant="secondary" onClick={() => navigate(ROUTES.calendar)}>
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
  const familyQuery = useFamily();
  const shiftQuery = useShift(shiftId);
  const calendar = useGoogleCalendar();

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
      familyName={familyQuery.data?.name}
      grandpaName={familyQuery.data?.grandpa_name}
      calendarConnected={calendar.connected}
    />
  );
}
