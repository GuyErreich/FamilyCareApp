import { Button } from "../../common/Button";

interface ShiftCalendarSyncControlProps {
  calendarConnected: boolean;
  isNew: boolean;
  synced: boolean;
  pending?: boolean;
  onUnsync: () => void;
  onResync: () => void;
}

export function ShiftCalendarSyncControl({
  calendarConnected,
  isNew,
  synced,
  pending,
  onUnsync,
  onResync,
}: ShiftCalendarSyncControlProps) {
  if (!calendarConnected) {
    return <p className="muted">Connect Google Calendar in Settings to sync shifts.</p>;
  }

  if (isNew) {
    return <p className="muted">This shift will sync to Google Calendar when saved.</p>;
  }

  if (synced) {
    return (
      <div className="calendar-sync-control">
        <p className="muted">Synced to Google Calendar.</p>
        <Button variant="secondary" disabled={pending} onClick={onUnsync}>
          Remove from Google Calendar
        </Button>
      </div>
    );
  }

  return (
    <div className="calendar-sync-control">
      <p className="muted">Not on Google Calendar.</p>
      <Button variant="secondary" disabled={pending} onClick={onResync}>
        Add to Google Calendar
      </Button>
    </div>
  );
}
