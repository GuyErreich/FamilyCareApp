import { useMutation, useQueryClient } from "@tanstack/react-query";
import { computeEndTime } from "../../lib/dates";
import type { Unavailability } from "../../lib/database.types";
import { supabase } from "../../lib/supabase";
import { useAuth } from "../auth/useAuth";

export interface UnavailabilityInput {
  member_id: string;
  block_date: string;
  start_hour: number;
  start_minute: number;
  duration_minutes: number;
}

export function useCreateUnavailability() {
  const queryClient = useQueryClient();
  const { profile } = useAuth();

  return useMutation({
    mutationFn: async (input: UnavailabilityInput): Promise<Unavailability> => {
      if (!profile?.family_id) throw new Error("No family");
      const payload = {
        family_id: profile.family_id,
        member_id: input.member_id,
        block_date: input.block_date,
        start_hour: input.start_hour,
        start_minute: input.start_minute,
        duration_minutes: input.duration_minutes,
        end_time: computeEndTime(
          input.block_date,
          input.start_hour,
          input.start_minute,
          input.duration_minutes,
        ),
      };
      const { data, error } = await supabase
        .from("unavailabilities")
        .insert(payload)
        .select("*")
        .single();
      if (error) throw error;
      return data;
    },
    onSuccess: () => {
      void queryClient.invalidateQueries({ queryKey: ["unavailabilities"] });
    },
  });
}

export function useUpdateUnavailability() {
  const queryClient = useQueryClient();
  const { profile } = useAuth();

  return useMutation({
    mutationFn: async ({
      id,
      input,
    }: {
      id: string;
      input: UnavailabilityInput;
    }): Promise<Unavailability> => {
      if (!profile?.family_id) throw new Error("No family");
      const payload = {
        member_id: input.member_id,
        block_date: input.block_date,
        start_hour: input.start_hour,
        start_minute: input.start_minute,
        duration_minutes: input.duration_minutes,
        end_time: computeEndTime(
          input.block_date,
          input.start_hour,
          input.start_minute,
          input.duration_minutes,
        ),
        updated_at: new Date().toISOString(),
      };
      const { data, error } = await supabase
        .from("unavailabilities")
        .update(payload)
        .eq("id", id)
        .select("*")
        .single();
      if (error) throw error;
      return data;
    },
    onSuccess: () => {
      void queryClient.invalidateQueries({ queryKey: ["unavailabilities"] });
    },
  });
}

export function useDeleteUnavailability() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async (id: string) => {
      const { error } = await supabase.from("unavailabilities").delete().eq("id", id);
      if (error) throw error;
    },
    onSuccess: () => {
      void queryClient.invalidateQueries({ queryKey: ["unavailabilities"] });
    },
  });
}

export function useBatchDeleteUnavailabilities() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async (ids: string[]) => {
      const { error } = await supabase.from("unavailabilities").delete().in("id", ids);
      if (error) throw error;
    },
    onSuccess: () => {
      void queryClient.invalidateQueries({ queryKey: ["unavailabilities"] });
    },
  });
}

export function useBatchDeleteShifts() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async (ids: string[]) => {
      const { error } = await supabase.from("shifts").delete().in("id", ids);
      if (error) throw error;
    },
    onSuccess: () => {
      void queryClient.invalidateQueries({ queryKey: ["shifts"] });
    },
  });
}
