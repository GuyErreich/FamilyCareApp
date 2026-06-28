import { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";
import { Button, SheetCloseButton } from "../../common/Button";
import { BottomSheet } from "../../common/BottomSheet";
import { useSheetDismiss } from "../../common/sheetDismissContext";
import { MemberChipPicker } from "../../common/MemberChipPicker";
import { SegmentedControl } from "../../common/SegmentedControl";
import type { FamilyMember } from "../../../../lib/database.types";
import { ROUTES, SCHEDULE } from "../../../../lib/constants";
import { toDateKey } from "../../../../lib/dates";
import { formatTimeRange } from "../../../../lib/slotOverlap";
import { useCreateUnavailability } from "../../../../hooks/shifts/useUnavailabilityMutations";

type SlotAction = "shift" | "unavail";

interface ScheduleSlotSheetProps {
  open: boolean;
  onClose: () => void;
  date: Date;
  hour: number;
  minute: number;
  members: FamilyMember[];
  defaultMemberId: string;
}

function ScheduleSlotActions({
  action,
  memberId,
  pending,
  dateKey,
  hour,
  minute,
}: {
  action: SlotAction;
  memberId: string;
  pending: boolean;
  dateKey: string;
  hour: number;
  minute: number;
}) {
  const navigate = useNavigate();
  const dismiss = useSheetDismiss();
  const createUnavail = useCreateUnavailability();
  const [error, setError] = useState<string | null>(null);

  const onContinue = async () => {
    setError(null);
    if (action === "shift") {
      navigate(`${ROUTES.shiftNew}?date=${dateKey}&hour=${hour}&minute=${minute}`);
      dismiss("press");
      return;
    }
    try {
      await createUnavail.mutateAsync({
        member_id: memberId,
        block_date: dateKey,
        start_hour: hour,
        start_minute: minute,
        duration_minutes: SCHEDULE.defaultDurationMinutes,
      });
      dismiss("press");
    } catch (err) {
      setError(err instanceof Error ? err.message : String(err));
    }
  };

  return (
    <>
      <SheetCloseButton>Cancel</SheetCloseButton>
      <Button
        fullWidth
        loading={pending}
        disabled={pending || !memberId}
        onClick={() => void onContinue()}
      >
        {action === "shift" ? "Continue" : "Mark unavailable"}
      </Button>
      {error ? <p className="error-text">{error}</p> : null}
    </>
  );
}

export function ScheduleSlotSheet({
  open,
  onClose,
  date,
  hour,
  minute,
  members,
  defaultMemberId,
}: ScheduleSlotSheetProps) {
  const createUnavail = useCreateUnavailability();
  const [action, setAction] = useState<SlotAction>("shift");
  const [memberId, setMemberId] = useState(defaultMemberId);

  const dateKey = toDateKey(date);
  const timeLabel = formatTimeRange(hour, minute, SCHEDULE.defaultDurationMinutes);

  useEffect(() => {
    if (!open) return;
    const frame = window.requestAnimationFrame(() => {
      setAction("shift");
      setMemberId(defaultMemberId);
    });
    return () => window.cancelAnimationFrame(frame);
  }, [open, defaultMemberId, dateKey, hour, minute]);

  return (
    <BottomSheet
      open={open}
      onClose={onClose}
      title="Add to schedule"
      actions={
        <ScheduleSlotActions
          action={action}
          memberId={memberId}
          pending={createUnavail.isPending}
          dateKey={dateKey}
          hour={hour}
          minute={minute}
        />
      }
    >
      <p className="muted schedule-slot-sheet__when">
        {date.toLocaleDateString()} · {timeLabel}
      </p>

      <SegmentedControl
        value={action}
        onChange={setAction}
        ariaLabel="Action type"
        options={[
          { value: "shift", label: "Shift" },
          { value: "unavail", label: "Unavailable" },
        ]}
      />

      <MemberChipPicker members={members} value={memberId} onChange={setMemberId} />
    </BottomSheet>
  );
}
