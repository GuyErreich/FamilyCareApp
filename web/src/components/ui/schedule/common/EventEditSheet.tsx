import { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";
import { Button } from "../../common/Button";
import { BottomSheet } from "../../common/BottomSheet";
import { useSheetDismiss } from "../../common/sheetDismissContext";
import { MemberChipPicker } from "../../common/MemberChipPicker";
import { Stack } from "../../common/Stack";
import { TextInput } from "../../common/TextField";
import type { FamilyMember, Shift, Unavailability } from "../../../../lib/database.types";
import { ROUTES } from "../../../../lib/constants";
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
  onError,
}: {
  target: EditTarget;
  memberId: string;
  startHour: number;
  startMinute: number;
  duration: number;
  onError: (message: string) => void;
}) {
  const navigate = useNavigate();
  const dismiss = useSheetDismiss();
  const saveShift = useSaveShift();
  const deleteShift = useDeleteShift();
  const updateUnavail = useUpdateUnavailability();
  const deleteUnavail = useDeleteUnavailability();

  const pending =
    saveShift.isPending ||
    deleteShift.isPending ||
    updateUnavail.isPending ||
    deleteUnavail.isPending;

  const onSave = async () => {
    onError("");
    try {
      if (target.kind === "shift") {
        await saveShift.mutateAsync({
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
      navigate(ROUTES.shiftEdit(target.data.id));
      dismiss("press");
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
  target: EditTarget;
  members: FamilyMember[];
  onClose: () => void;
}) {
  const initial = editInitials(target);
  const [memberId, setMemberId] = useState(initial.memberId);
  const [startHour, setStartHour] = useState(initial.startHour);
  const [startMinute, setStartMinute] = useState(initial.startMinute);
  const [duration, setDuration] = useState<number>(initial.duration);
  const [error, setError] = useState<string | null>(null);

  const targetKey = `${target.kind}:${target.data.id}`;

  useEffect(() => {
    if (!open) return;
    const frame = window.requestAnimationFrame(() => {
      const next = editInitials(target);
      setMemberId(next.memberId);
      setStartHour(next.startHour);
      setStartMinute(next.startMinute);
      setDuration(next.duration);
      setError(null);
    });
    return () => window.cancelAnimationFrame(frame);
  }, [open, targetKey, target]);

  const title = target.kind === "shift" ? "Edit shift" : "Edit unavailability";

  return (
    <BottomSheet
      open={open}
      onClose={onClose}
      title={title}
      actions={
        <EventEditActions
          target={target}
          memberId={memberId}
          startHour={startHour}
          startMinute={startMinute}
          duration={duration}
          onError={(message) => setError(message || null)}
        />
      }
    >
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
        {error ? <p className="error-text">{error}</p> : null}
      </Stack>
    </BottomSheet>
  );
}

export function EventEditSheet({ target, members, onClose }: EventEditSheetProps) {
  if (!target) return null;

  return (
    <EventEditSheetBody
      key={`${target.kind}:${target.data.id}`}
      open
      target={target}
      members={members}
      onClose={onClose}
    />
  );
}
