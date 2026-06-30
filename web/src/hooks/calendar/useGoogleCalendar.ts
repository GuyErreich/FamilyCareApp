import { useCallback } from "react";
import { useMutation } from "@tanstack/react-query";
import { GOOGLE_CALENDAR_SCOPE } from "../../lib/constants";
import { formatShiftRange, parseDateKey } from "../../lib/dates";
import type { FamilyMember, Shift } from "../../lib/database.types";
import {
  clearPersistedCalendarTokens,
  getPersistedCalendarAccessToken,
  persistCalendarAccessToken,
  setCalendarConnectIntent,
} from "../../lib/googleCalendarTokens";
import { supabase } from "../../lib/supabase";
import { useAuth } from "../auth/useAuth";

const CALENDAR_API = "https://www.googleapis.com/calendar/v3/calendars/primary/events";
const EVENT_COLOR_ID = "3";

function formatLocalDateTime(date: Date): string {
  return `${date.getFullYear()}-${pad2(date.getMonth() + 1)}-${pad2(date.getDate())}T${pad2(date.getHours())}:${pad2(date.getMinutes())}:00`;
}

function pad2(n: number): string {
  return n.toString().padStart(2, "0");
}

async function getProviderToken(userId: string | undefined): Promise<string> {
  const { data, error } = await supabase.auth.getSession();
  if (error) throw error;

  const sessionToken = data.session?.provider_token;
  if (sessionToken) {
    if (userId) persistCalendarAccessToken(userId, sessionToken);
    return sessionToken;
  }

  if (userId) {
    const stored = getPersistedCalendarAccessToken(userId);
    if (stored) return stored;
  }

  throw new Error("Reconnect Google Calendar from Settings to grant access.");
}

async function calendarFetch(url: string, init: RequestInit): Promise<Response> {
  try {
    return await fetch(url, init);
  } catch (err) {
    if (err instanceof TypeError && err.message === "Failed to fetch") {
      throw new Error(
        "Could not reach Google Calendar. Check your network connection and that the Calendar API is enabled in Google Cloud Console.",
        { cause: err },
      );
    }
    throw err;
  }
}

function buildEventBody(
  shift: Shift,
  member: FamilyMember | undefined,
  familyName?: string,
  grandpaName?: string,
) {
  const timeZone = Intl.DateTimeFormat().resolvedOptions().timeZone;
  const start = parseDateKey(shift.shift_date);
  start.setHours(shift.start_hour, shift.start_minute, 0, 0);
  const end = new Date(start.getTime() + shift.duration_minutes * 60_000);

  const summaryParts = ["Companion shift"];
  if (familyName?.trim()) summaryParts.push(familyName.trim());
  if (grandpaName?.trim()) summaryParts.push(`for ${grandpaName.trim()}`);
  if (member?.name.trim()) summaryParts.push(`with ${member.name.trim()}`);

  const descriptionLines = [
    formatShiftRange(
      shift.shift_date,
      shift.start_hour,
      shift.start_minute,
      shift.duration_minutes,
    ),
  ];
  if (shift.notes?.trim()) {
    descriptionLines.push("", shift.notes.trim());
  }

  return {
    summary: summaryParts.join(" · "),
    description: descriptionLines.join("\n"),
    start: { dateTime: formatLocalDateTime(start), timeZone },
    end: { dateTime: formatLocalDateTime(end), timeZone },
    colorId: EVENT_COLOR_ID,
  };
}

export function useGoogleCalendar() {
  const { profile, session, refreshProfile } = useAuth();

  const connect = useCallback(async () => {
    setCalendarConnectIntent();
    const { error } = await supabase.auth.signInWithOAuth({
      provider: "google",
      options: {
        redirectTo: `${window.location.origin}/settings`,
        scopes: GOOGLE_CALENDAR_SCOPE,
        queryParams: {
          access_type: "offline",
          prompt: "consent",
        },
      },
    });
    if (error) throw error;
  }, []);

  const markConnected = useMutation({
    mutationFn: async () => {
      if (!profile?.id) return;

      const { data: sessionData } = await supabase.auth.getSession();
      const accessToken = sessionData.session?.provider_token;
      const refreshToken = sessionData.session?.provider_refresh_token;
      if (accessToken) {
        persistCalendarAccessToken(profile.id, accessToken);
      }

      const { error } = await supabase
        .from("profiles")
        .update({
          google_calendar_connected: true,
          ...(refreshToken ? { google_refresh_token: refreshToken } : {}),
        })
        .eq("id", profile.id);
      if (error) throw error;
      await refreshProfile();
    },
  });

  const disconnect = useMutation({
    mutationFn: async () => {
      if (!profile?.id) return;
      clearPersistedCalendarTokens(profile.id);
      const { error } = await supabase
        .from("profiles")
        .update({
          google_calendar_connected: false,
          google_refresh_token: null,
        })
        .eq("id", profile.id);
      if (error) throw error;
      await refreshProfile();
    },
  });

  const syncShift = useCallback(
    async (
      shift: Shift,
      member?: FamilyMember,
      familyName?: string,
      grandpaName?: string,
    ): Promise<string> => {
      const token = await getProviderToken(profile?.id);
      const body = buildEventBody(shift, member, familyName, grandpaName);

      if (shift.calendar_event_id) {
        const deleteResponse = await calendarFetch(`${CALENDAR_API}/${shift.calendar_event_id}`, {
          method: "DELETE",
          headers: { Authorization: `Bearer ${token}` },
        });
        if (
          !deleteResponse.ok &&
          deleteResponse.status !== 404 &&
          deleteResponse.status !== 410
        ) {
          throw new Error(await deleteResponse.text());
        }
      }

      const response = await calendarFetch(CALENDAR_API, {
        method: "POST",
        headers: {
          Authorization: `Bearer ${token}`,
          "Content-Type": "application/json",
        },
        body: JSON.stringify(body),
      });
      if (!response.ok) {
        throw new Error(await response.text());
      }
      const json = (await response.json()) as { id: string };
      const { error } = await supabase
        .from("shifts")
        .update({ calendar_event_id: json.id })
        .eq("id", shift.id);
      if (error) throw error;
      return json.id;
    },
    [profile?.id],
  );

  const deleteEvent = useCallback(async (eventId: string) => {
    const token = await getProviderToken(profile?.id);
    const response = await calendarFetch(`${CALENDAR_API}/${eventId}`, {
      method: "DELETE",
      headers: { Authorization: `Bearer ${token}` },
    });
    if (!response.ok && response.status !== 404 && response.status !== 410) {
      throw new Error(await response.text());
    }
  }, [profile?.id]);

  const hasStoredToken =
    Boolean(session?.provider_token) ||
    Boolean(profile?.id && getPersistedCalendarAccessToken(profile.id));

  return {
    connected: profile?.google_calendar_connected ?? false,
    hasProviderToken: hasStoredToken,
    connect,
    disconnect,
    markConnected,
    syncShift,
    deleteEvent,
  };
}
