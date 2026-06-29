import { useEffect, useMemo, useState } from "react";
import {
  Bell,
  Calendar,
  ChevronDown,
  ChevronUp,
  Copy,
  KeyRound,
  LogOut,
  User,
  Users,
} from "lucide-react";
import { Button } from "../components/ui/common/Button";
import { Card } from "../components/ui/common/Card";
import { ListRow } from "../components/ui/common/ListRow";
import { IconButton } from "../components/ui/common/IconButton";
import { Stack } from "../components/ui/common/Stack";
import { ThemePicker } from "../components/ui/common/ThemePicker";
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
  const [copied, setCopied] = useState(false);

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
  }, [session?.provider_token, profile?.google_calendar_connected, calendar.markConnected]);

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

  const copyInviteCode = async () => {
    const code = familyQuery.data?.invite_code;
    if (!code) return;
    await navigator.clipboard.writeText(code);
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  };

  if (familyQuery.isLoading || settingsQuery.isLoading) {
    return <LoadingState label="Loading settings…" />;
  }

  return (
    <Stack gap="lg" staggerFromEdge="end">
      <ThemePicker />

      <section>
        <h2 className="section-title">Account</h2>
        <Card>
          <ListRow icon={User} label={profile?.email ?? "Signed in"} />
          <Button variant="danger" fullWidth icon={LogOut} onClick={() => void signOut()}>
            Sign out
          </Button>
        </Card>
      </section>

      <section>
        <h2 className="section-title">Family</h2>
        <Card>
          <ListRow icon={KeyRound} label="Invite code" value="Share with family members" />
          <div className="invite-pill">
            <span>{familyQuery.data?.invite_code}</span>
            <IconButton
              icon={Copy}
              label={copied ? "Copied" : "Copy invite code"}
              variant="ghost"
              onClick={() => void copyInviteCode()}
            />
          </div>
        </Card>
      </section>

      <section>
        <h2 className="section-title">Coverage fallback</h2>
        <Card>
          {orderedMembers.length === 0 ? (
            <p className="muted">Add members to the fallback list below.</p>
          ) : (
            orderedMembers.map((member, index) =>
              member ? (
                <ListRow
                  key={member.id}
                  icon={Users}
                  label={member.name}
                  actions={
                    <>
                      <IconButton
                        icon={ChevronUp}
                        label="Move up"
                        onClick={() => void move(index, -1)}
                        disabled={index === 0}
                      />
                      <IconButton
                        icon={ChevronDown}
                        label="Move down"
                        onClick={() => void move(index, 1)}
                        disabled={index === orderedMembers.length - 1}
                      />
                    </>
                  }
                />
              ) : null,
            )
          )}
          <Stack>
            {members
              .filter((m) => !orderedIds.includes(m.id))
              .map((m) => (
                <Button
                  key={m.id}
                  variant="secondary"
                  onClick={() => void addToFallback(m.id)}
                >
                  Add {m.name} to fallback
                </Button>
              ))}
          </Stack>
        </Card>
      </section>

      <section>
        <h2 className="section-title">Notifications</h2>
        <Card>
          <ListRow
            icon={Bell}
            label="Push notifications"
            value="Install the app, then enable shift alerts"
          />
          {push.supported ? (
            <Button onClick={() => void push.subscribe()} fullWidth>
              Enable push notifications
            </Button>
          ) : (
            <p className="muted">Push not supported in this browser.</p>
          )}
          {push.error ? <ErrorState message={push.error} /> : null}
          {push.subscribed ? <p className="muted">Push enabled.</p> : null}
        </Card>
      </section>

      <section>
        <h2 className="section-title">Calendar</h2>
        <Card>
          <ListRow
            icon={Calendar}
            label="Google Calendar"
            value={
              calendar.connected
                ? "Connected — toggle sync when saving shifts"
                : "Connect to sync companion shifts"
            }
          />
          {calendar.connected ? (
            <Button variant="secondary" fullWidth onClick={() => void disconnectCalendar()}>
              Disconnect calendar
            </Button>
          ) : (
            <Button fullWidth onClick={() => void connectCalendar()}>
              Connect Google Calendar
            </Button>
          )}
          {calendarError ? <ErrorState message={calendarError} /> : null}
          {message ? <p className="muted">{message}</p> : null}
        </Card>
      </section>
    </Stack>
  );
}
