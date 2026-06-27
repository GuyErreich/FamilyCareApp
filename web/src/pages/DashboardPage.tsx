import { Link } from "react-router-dom";
import { Card } from "../components/ui/common/Card";
import { PrimaryButton } from "../components/ui/common/PrimaryButton";
import { EmptyState, ErrorState, LoadingState } from "../components/ui/common/AsyncStates";
import { ROUTES } from "../lib/constants";
import { formatError } from "../lib/errors";
import { formatShiftRange, toDateKey } from "../lib/dates";
import {
  useFamily,
  useFamilyMembers,
  useNotifications,
  useShifts,
} from "../hooks/family/useFamilyData";

export function DashboardPage() {
  const today = toDateKey(new Date());
  const shiftsQuery = useShifts(today, today);
  const membersQuery = useFamilyMembers();
  const familyQuery = useFamily();
  const notificationsQuery = useNotifications();

  if (shiftsQuery.isLoading || membersQuery.isLoading || familyQuery.isLoading) {
    return <LoadingState />;
  }

  if (shiftsQuery.error || membersQuery.error || familyQuery.error) {
    const message = [
      shiftsQuery.error && formatError(shiftsQuery.error),
      membersQuery.error && formatError(membersQuery.error),
      familyQuery.error && formatError(familyQuery.error),
    ]
      .filter(Boolean)
      .join(" · ");
    return <ErrorState message={message || "Could not load dashboard."} />;
  }

  const membersById = new Map((membersQuery.data ?? []).map((m) => [m.id, m]));
  const shifts = shiftsQuery.data ?? [];
  const unread = (notificationsQuery.data ?? []).filter((n) => !n.read).length;
  const family = familyQuery.data;

  return (
    <div className="stack">
      <h1 className="page-title">
        Today · {family?.grandpa_name ?? "Family care"}
      </h1>

      {unread > 0 ? (
        <Card>
          <strong>{unread} new notification{unread === 1 ? "" : "s"}</strong>
        </Card>
      ) : null}

      {shifts.length === 0 ? (
        <EmptyState>No companion shifts scheduled for today.</EmptyState>
      ) : (
        shifts.map((shift) => {
          const member = membersById.get(shift.assigned_member_id);
          return (
            <Card
              key={shift.id}
              className="shift-chip"
              style={{ ["--chip-color" as string]: member?.color_hex }}
            >
              <strong>{member?.name ?? "Companion"}</strong>
              <div className="muted">
                {formatShiftRange(
                  shift.shift_date,
                  shift.start_hour,
                  shift.start_minute,
                  shift.duration_minutes,
                )}
              </div>
              <Link to={ROUTES.shiftEdit(shift.id)}>Edit</Link>
            </Card>
          );
        })
      )}

      <Link to={ROUTES.shiftNew} style={{ textDecoration: "none" }}>
        <PrimaryButton style={{ width: "100%" }}>Add shift</PrimaryButton>
      </Link>
    </div>
  );
}
