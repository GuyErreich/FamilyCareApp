import { useEffect, useMemo, useState } from "react";
import { Card } from "../components/ui/common/Card";
import { PrimaryButton } from "../components/ui/common/PrimaryButton";
import { ErrorState, LoadingState } from "../components/ui/common/AsyncStates";
import { useAuth } from "../hooks/auth/useAuth";
import { useGoogleCalendar } from "../hooks/calendar/useGoogleCalendar";
import {
  useFamily,
  useFamilyMembers,
  useFamilySettings,
  useUpdateFamilySettings,
} from "../hooks/family/useFamilyData";
import { usePushNotifications } from "../hooks/notifications/usePushNotifications";
import { formatError } from "../lib/errors";

export function SettingsPage() {
  const { profile, session, signOut } = useAuth();
  const familyQuery = useFamily();
  const membersQuery = useFamilyMembers();
  const settingsQuery = useFamilySettings();
  const updateSettings = useUpdateFamilySettings();
  const push = usePushNotifications();
  const calendar = useGoogleCalendar();
  const [message, setMessage] = useState<string | null>(null);
  const [calendarError, setCalendarError] = useState<string | null>(null);

  const orderedIds = useMemo(
    () => settingsQuery.data?.coverage_fallback_member_ids ?? [],
    [settingsQuery.data?.coverage_fallback_member_ids],
  );
  const members = useMemo(() => membersQuery.data ?? [], [membersQuery.data]);

  const orderedMembers = useMemo(() => {
    const byId = new Map(members.map((m) => [m.id, m]));
    return orderedIds.map((id) => byId.get(id)).filter(Boolean);
  }, [members, orderedIds]);

  useEffect(() => {
    if (session?.provider_token && !profile?.google_calendar_connected) {
      void calendar.markConnected.mutateAsync().catch((err: unknown) => {
        setCalendarError(formatError(err));
      });
    }
  }, [
    session?.provider_token,
    profile?.google_calendar_connected,
    calendar.markConnected,
  ]);

  const move = async (index: number, direction: -1 | 1) => {
    const next = [...orderedIds];
    const target = index + direction;
    if (target < 0 || target >= next.length) return;
    [next[index], next[target]] = [next[target], next[index]];
    await updateSettings.mutateAsync(next);
  };

  const addToFallback = async (memberId: string) => {
    if (orderedIds.includes(memberId)) return;
    await updateSettings.mutateAsync([...orderedIds, memberId]);
  };

  const connectCalendar = async () => {
    setCalendarError(null);
    try {
      await calendar.connect();
    } catch (err) {
      setCalendarError(formatError(err));
    }
  };

  const disconnectCalendar = async () => {
    setCalendarError(null);
    try {
      await calendar.disconnect.mutateAsync();
      setMessage("Google Calendar disconnected.");
    } catch (err) {
      setCalendarError(formatError(err));
    }
  };

  if (familyQuery.isLoading || settingsQuery.isLoading) {
    return <LoadingState />;
  }

  return (
    <div className="stack">
      <h1 className="page-title">Settings</h1>

      <Card>
        <h2 style={{ marginTop: 0 }}>Account</h2>
        <p>{profile?.email}</p>
        <PrimaryButton variant="secondary" onClick={() => void signOut()}>
          Sign out
        </PrimaryButton>
      </Card>

      <Card>
        <h2 style={{ marginTop: 0 }}>Family invite</h2>
        <p>
          Share this code: <strong>{familyQuery.data?.invite_code}</strong>
        </p>
      </Card>

      <Card>
        <h2 style={{ marginTop: 0 }}>Coverage fallback order</h2>
        {orderedMembers.length === 0 ? (
          <p className="muted">Add members to the fallback list below.</p>
        ) : (
          orderedMembers.map((member, index) =>
            member ? (
              <div
                key={member.id}
                style={{
                  display: "flex",
                  alignItems: "center",
                  gap: 8,
                  marginBottom: 8,
                }}
              >
                <span style={{ flex: 1 }}>{member.name}</span>
                <PrimaryButton
                  variant="secondary"
                  onClick={() => void move(index, -1)}
                >
                  Up
                </PrimaryButton>
                <PrimaryButton
                  variant="secondary"
                  onClick={() => void move(index, 1)}
                >
                  Down
                </PrimaryButton>
              </div>
            ) : null,
          )
        )}
        <div className="stack">
          {members
            .filter((m) => !orderedIds.includes(m.id))
            .map((m) => (
              <PrimaryButton
                key={m.id}
                variant="secondary"
                onClick={() => void addToFallback(m.id)}
              >
                Add {m.name} to fallback
              </PrimaryButton>
            ))}
        </div>
      </Card>

      <Card>
        <h2 style={{ marginTop: 0 }}>Notifications (PWA)</h2>
        <p className="muted">
          Install this app to your home screen, then enable push notifications for
          shift alerts.
        </p>
        {push.supported ? (
          <PrimaryButton onClick={() => void push.subscribe()}>
            Enable push notifications
          </PrimaryButton>
        ) : (
          <p className="muted">Push not supported in this browser.</p>
        )}
        {push.error ? <ErrorState message={push.error} /> : null}
        {push.subscribed ? <p>Push enabled.</p> : null}
      </Card>

      <Card>
        <h2 style={{ marginTop: 0 }}>Google Calendar</h2>
        <p className="muted">
          {calendar.connected
            ? "Connected. Toggle sync on each shift when saving."
            : "Connect to add companion shifts to your Google Calendar."}
        </p>
        {calendar.connected ? (
          <PrimaryButton variant="secondary" onClick={() => void disconnectCalendar()}>
            Disconnect calendar
          </PrimaryButton>
        ) : (
          <PrimaryButton onClick={() => void connectCalendar()}>
            Connect Google Calendar
          </PrimaryButton>
        )}
        {calendarError ? <ErrorState message={calendarError} /> : null}
        {message ? <p className="muted">{message}</p> : null}
      </Card>
    </div>
  );
}
