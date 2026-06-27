import { useMutation, useQueryClient } from "@tanstack/react-query";
import { DEFAULT_REMINDER_OFFSETS_MINUTES } from "../../lib/constants";
import { computeEndTime } from "../../lib/dates";
import type { Profile, Shift } from "../../lib/database.types";
import { supabase } from "../../lib/supabase";
import { useAuth } from "../auth/useAuth";

export interface ShiftInput {
  assigned_member_id: string;
  shift_date: string;
  start_hour: number;
  start_minute: number;
  duration_minutes: number;
  notes?: string | null;
  status?: string;
}

export function useSaveShift() {
  const queryClient = useQueryClient();
  const { profile } = useAuth();

  return useMutation({
    mutationFn: async ({
      id,
      input,
    }: {
      id?: string;
      input: ShiftInput;
    }): Promise<Shift> => {
      if (!profile?.family_id) throw new Error("No family");
      const payload = {
        family_id: profile.family_id,
        assigned_member_id: input.assigned_member_id,
        shift_date: input.shift_date,
        start_hour: input.start_hour,
        start_minute: input.start_minute,
        duration_minutes: input.duration_minutes,
        end_time: computeEndTime(
          input.shift_date,
          input.start_hour,
          input.start_minute,
          input.duration_minutes,
        ),
        notes: input.notes ?? null,
        status: input.status ?? "scheduled",
        reminder_offset_minutes: DEFAULT_REMINDER_OFFSETS_MINUTES,
      };

      if (id) {
        const { data, error } = await supabase
          .from("shifts")
          .update(payload)
          .eq("id", id)
          .select("*")
          .single();
        if (error) throw error;
        return data;
      }

      const { data, error } = await supabase
        .from("shifts")
        .insert(payload)
        .select("*")
        .single();
      if (error) throw error;
      return data;
    },
    onSuccess: () => {
      void queryClient.invalidateQueries({ queryKey: ["shifts"] });
    },
  });
}

export function useDeleteShift() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async (id: string) => {
      const { error } = await supabase.from("shifts").delete().eq("id", id);
      if (error) throw error;
    },
    onSuccess: () => {
      void queryClient.invalidateQueries({ queryKey: ["shifts"] });
    },
  });
}

export function useCreateFamily() {
  const { setProfile } = useAuth();

  return useMutation({
    mutationFn: async ({
      name,
      grandpaName,
    }: {
      name: string;
      grandpaName: string;
    }): Promise<Profile> => {
      const { data, error } = await supabase.rpc("create_family", {
        p_name: name,
        p_grandpa_name: grandpaName,
      });
      if (error) throw error;
      if (!data?.family_id) {
        throw new Error("Family setup failed — no profile returned from server.");
      }
      setProfile(data);
      return data;
    },
  });
}

export function useJoinFamily() {
  const { setProfile } = useAuth();

  return useMutation({
    mutationFn: async (inviteCode: string): Promise<Profile> => {
      const { data, error } = await supabase.rpc("join_family", {
        p_invite_code: inviteCode,
      });
      if (error) throw error;
      if (!data?.family_id) {
        throw new Error("Join failed — no profile returned from server.");
      }
      setProfile(data);
      return data;
    },
  });
}

export function useAddFamilyMember() {
  const queryClient = useQueryClient();
  const { profile } = useAuth();

  return useMutation({
    mutationFn: async ({
      name,
      colorHex,
    }: {
      name: string;
      colorHex: string;
    }) => {
      if (!profile?.family_id) throw new Error("No family");
      const { error } = await supabase.from("family_members").insert({
        family_id: profile.family_id,
        name,
        color_hex: colorHex,
      });
      if (error) throw error;
    },
    onSuccess: () => {
      void queryClient.invalidateQueries({
        queryKey: ["family-members", profile?.family_id],
      });
    },
  });
}
