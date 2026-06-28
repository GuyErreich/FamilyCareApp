import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import type { Family, FamilyMember, FamilySettings, Shift, Unavailability } from "../../lib/database.types";
import { supabase } from "../../lib/supabase";
import { useAuth } from "../auth/useAuth";

export function useFamily() {
  const { profile } = useAuth();
  const familyId = profile?.family_id ?? null;

  return useQuery({
    queryKey: ["family", familyId],
    enabled: Boolean(familyId),
    queryFn: async (): Promise<Family | null> => {
      const { data, error } = await supabase
        .from("families")
        .select("*")
        .eq("id", familyId!)
        .single();
      if (error) throw error;
      return data;
    },
  });
}

export function useFamilyMembers() {
  const { profile } = useAuth();
  const familyId = profile?.family_id ?? null;

  return useQuery({
    queryKey: ["family-members", familyId],
    enabled: Boolean(familyId),
    queryFn: async (): Promise<FamilyMember[]> => {
      const { data, error } = await supabase
        .from("family_members")
        .select("*")
        .eq("family_id", familyId!)
        .order("name");
      if (error) throw error;
      return data ?? [];
    },
  });
}

export function useFamilySettings() {
  const { profile } = useAuth();
  const familyId = profile?.family_id ?? null;

  return useQuery({
    queryKey: ["family-settings", familyId],
    enabled: Boolean(familyId),
    queryFn: async (): Promise<FamilySettings | null> => {
      const { data, error } = await supabase
        .from("family_settings")
        .select("*")
        .eq("family_id", familyId!)
        .maybeSingle();
      if (error) throw error;
      return data;
    },
  });
}

export function useUpdateFamilySettings() {
  const queryClient = useQueryClient();
  const { profile } = useAuth();

  return useMutation({
    mutationFn: async (memberIds: string[]) => {
      if (!profile?.family_id) throw new Error("No family");
      const { error } = await supabase.from("family_settings").upsert({
        family_id: profile.family_id,
        coverage_fallback_member_ids: memberIds,
        updated_at: new Date().toISOString(),
      });
      if (error) throw error;
    },
    onSuccess: () => {
      void queryClient.invalidateQueries({
        queryKey: ["family-settings", profile?.family_id],
      });
    },
  });
}

export function useShift(shiftId?: string) {
  return useQuery({
    queryKey: ["shift", shiftId],
    enabled: Boolean(shiftId),
    queryFn: async (): Promise<Shift> => {
      const { data, error } = await supabase
        .from("shifts")
        .select("*")
        .eq("id", shiftId!)
        .single();
      if (error) throw error;
      return data;
    },
  });
}

export function useShifts(fromDate?: string, toDate?: string) {
  const { profile } = useAuth();
  const familyId = profile?.family_id ?? null;

  return useQuery({
    queryKey: ["shifts", familyId, fromDate, toDate],
    enabled: Boolean(familyId),
    queryFn: async (): Promise<Shift[]> => {
      let query = supabase
        .from("shifts")
        .select("*")
        .eq("family_id", familyId!)
        .order("shift_date")
        .order("start_hour")
        .order("start_minute");
      if (fromDate) query = query.gte("shift_date", fromDate);
      if (toDate) query = query.lte("shift_date", toDate);
      const { data, error } = await query;
      if (error) throw error;
      return data ?? [];
    },
  });
}

export function useUnavailabilities(fromDate?: string, toDate?: string) {
  const { profile } = useAuth();
  const familyId = profile?.family_id ?? null;

  return useQuery({
    queryKey: ["unavailabilities", familyId, fromDate, toDate],
    enabled: Boolean(familyId),
    queryFn: async (): Promise<Unavailability[]> => {
      let query = supabase
        .from("unavailabilities")
        .select("*")
        .eq("family_id", familyId!)
        .order("block_date")
        .order("start_hour")
        .order("start_minute");
      if (fromDate) query = query.gte("block_date", fromDate);
      if (toDate) query = query.lte("block_date", toDate);
      const { data, error } = await query;
      if (error) throw error;
      return data ?? [];
    },
  });
}

export function useCurrentMember(members: FamilyMember[] | undefined) {
  const { user } = useAuth();
  return members?.find((m) => m.user_id === user?.id) ?? members?.[0] ?? null;
}

export function useNotifications() {
  const { user } = useAuth();

  return useQuery({
    queryKey: ["notifications", user?.id],
    enabled: Boolean(user?.id),
    queryFn: async () => {
      const { data, error } = await supabase
        .from("notifications")
        .select("*")
        .eq("user_id", user!.id)
        .order("created_at", { ascending: false })
        .limit(50);
      if (error) throw error;
      return data ?? [];
    },
  });
}

export function useMarkNotificationRead() {
  const queryClient = useQueryClient();
  const { user } = useAuth();

  return useMutation({
    mutationFn: async (id: string) => {
      const { error } = await supabase
        .from("notifications")
        .update({ read: true })
        .eq("id", id);
      if (error) throw error;
    },
    onSuccess: () => {
      void queryClient.invalidateQueries({
        queryKey: ["notifications", user?.id],
      });
    },
  });
}
