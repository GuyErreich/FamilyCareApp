import { useCallback } from "react";
import { useQueryClient } from "@tanstack/react-query";
import type { FamilyMember, Shift } from "../../lib/database.types";
import { supabase } from "../../lib/supabase";
import { useFamily } from "../family/useFamilyData";
import { useGoogleCalendar } from "./useGoogleCalendar";

/** New shifts sync by default; existing shifts only sync when already on the calendar. */
export function shouldAutoSyncShift(
  shiftId: string | undefined,
  calendarEventId: string | null | undefined,
): boolean {
  if (!shiftId) return true;
  return Boolean(calendarEventId);
}

/** Syncs shifts to Google Calendar when connected — always remove old event, add new. */
export function useShiftCalendarSync() {
  const calendar = useGoogleCalendar();
  const familyQuery = useFamily();
  const queryClient = useQueryClient();

  const syncAfterSave = useCallback(
    async (
      shift: Shift,
      members: FamilyMember[],
      options: { shiftId?: string; calendarEventId?: string | null },
    ) => {
      if (!calendar.connected) return;
      if (
        !shouldAutoSyncShift(options.shiftId, options.calendarEventId ?? shift.calendar_event_id)
      ) {
        return;
      }
      const member = members.find((m) => m.id === shift.assigned_member_id);
      await calendar.syncShift(
        shift,
        member,
        familyQuery.data?.name,
        familyQuery.data?.grandpa_name,
      );
      void queryClient.invalidateQueries({ queryKey: ["shifts"] });
    },
    [calendar, familyQuery.data?.name, familyQuery.data?.grandpa_name, queryClient],
  );

  const removeBeforeDelete = useCallback(
    async (calendarEventId: string | null | undefined) => {
      if (!calendar.connected || !calendarEventId) return;
      await calendar.deleteEvent(calendarEventId);
    },
    [calendar],
  );

  const unsyncShift = useCallback(
    async (shiftId: string, calendarEventId: string) => {
      if (!calendar.connected) return;
      await calendar.deleteEvent(calendarEventId);
      const { error } = await supabase
        .from("shifts")
        .update({ calendar_event_id: null })
        .eq("id", shiftId);
      if (error) throw error;
      void queryClient.invalidateQueries({ queryKey: ["shifts"] });
    },
    [calendar, queryClient],
  );

  const resyncShift = useCallback(
    async (shift: Shift, members: FamilyMember[]): Promise<string> => {
      if (!calendar.connected) throw new Error("Google Calendar is not connected.");
      const member = members.find((m) => m.id === shift.assigned_member_id);
      const eventId = await calendar.syncShift(
        shift,
        member,
        familyQuery.data?.name,
        familyQuery.data?.grandpa_name,
      );
      void queryClient.invalidateQueries({ queryKey: ["shifts"] });
      return eventId;
    },
    [calendar, familyQuery.data?.name, familyQuery.data?.grandpa_name, queryClient],
  );

  return {
    connected: calendar.connected,
    syncAfterSave,
    removeBeforeDelete,
    unsyncShift,
    resyncShift,
  };
}
