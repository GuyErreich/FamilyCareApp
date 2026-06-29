import { useNavigate } from "react-router-dom";
import { Bell, ChevronRight, CalendarOff } from "lucide-react";
import { Card } from "../components/ui/common/Card";
import { Stack } from "../components/ui/common/Stack";
import { MemberAvatar } from "../components/ui/common/MemberAvatar";
import { EmptyState, ErrorState, LoadingState } from "../components/ui/common/AsyncStates";
import { useSheetNavigation } from "../hooks/ui/useSheetNavigation";
import { ROUTES } from "../lib/constants";
import { formatError } from "../lib/errors";
import { formatShiftRange, toDateKey } from "../lib/dates";
import {
  useFamilyMembers,
  useNotifications,
  useShifts,
} from "../hooks/family/useFamilyData";

export function DashboardPage() {
  const { openSheet } = useSheetNavigation();
  const navigate = useNavigate();
  const today = toDateKey(new Date());
  const shiftsQuery = useShifts(today, today);
  const membersQuery = useFamilyMembers();
  const notificationsQuery = useNotifications();

  if (shiftsQuery.isLoading || membersQuery.isLoading) {
    return <LoadingState label="Loading today’s schedule…" />;
  }

  if (shiftsQuery.error || membersQuery.error) {
    const message = [
      shiftsQuery.error && formatError(shiftsQuery.error),
      membersQuery.error && formatError(membersQuery.error),
    ]
      .filter(Boolean)
      .join(" · ");
    return <ErrorState message={message || "Could not load dashboard."} />;
  }

  const membersById = new Map((membersQuery.data ?? []).map((m) => [m.id, m]));
  const shifts = shiftsQuery.data ?? [];
  const unread = (notificationsQuery.data ?? []).filter((n) => !n.read).length;
  const todayLabel = new Date().toLocaleDateString(undefined, {
    weekday: "long",
    month: "long",
    day: "numeric",
  });

  return (
    <Stack gap="lg" stagger>
      <p className="muted page-subline">{todayLabel}</p>

      {unread > 0 ? (
        <Card
          variant="accent"
          interactive
          onClick={() => navigate(ROUTES.settings)}
          className="notification-banner-card"
        >
          <div className="notification-banner">
            <span className="notification-banner__icon">
              <Bell size={22} aria-hidden />
            </span>
            <span className="notification-banner__text">
              {unread} new notification{unread === 1 ? "" : "s"}
            </span>
            <span className="badge">{unread}</span>
            <ChevronRight className="notification-banner__chevron" size={20} aria-hidden />
          </div>
        </Card>
      ) : null}

      {shifts.length === 0 ? (
        <EmptyState
          icon={CalendarOff}
          title="No shifts today"
        >
          Tap + to schedule a companion shift.
        </EmptyState>
      ) : (
        <Stack staggerFromEdge="start">
          {shifts.map((shift) => {
            const member = membersById.get(shift.assigned_member_id);
            return (
              <Card
                key={shift.id}
                interactive
                className="shift-chip"
                style={{ ["--chip-color" as string]: member?.color_hex }}
                onClick={() => openSheet(ROUTES.shiftEdit(shift.id))}
              >
                <div className="shift-card">
                  <MemberAvatar name={member?.name ?? "Companion"} colorHex={member?.color_hex} />
                  <div className="shift-card__body">
                    <div className="shift-card__name">{member?.name ?? "Companion"}</div>
                    <div className="shift-card__time">
                      {formatShiftRange(
                        shift.shift_date,
                        shift.start_hour,
                        shift.start_minute,
                        shift.duration_minutes,
                      )}
                    </div>
                  </div>
                  <ChevronRight className="shift-card__chevron" size={20} aria-hidden />
                </div>
              </Card>
            );
          })}
        </Stack>
      )}
    </Stack>
  );
}
