import { useEffect } from "react";
import { useQueryClient } from "@tanstack/react-query";
import { supabase } from "../lib/supabase";
import { useAuth } from "./auth/useAuth";

export function useRealtimeSync() {
  const { profile, user } = useAuth();
  const queryClient = useQueryClient();
  const familyId = profile?.family_id;

  useEffect(() => {
    if (!familyId) return;

    const channel = supabase
      .channel(`family-${familyId}`)
      .on(
        "postgres_changes",
        {
          event: "*",
          schema: "public",
          table: "shifts",
          filter: `family_id=eq.${familyId}`,
        },
        () => {
          void queryClient.invalidateQueries({ queryKey: ["shifts"] });
        },
      )
      .on(
        "postgres_changes",
        {
          event: "*",
          schema: "public",
          table: "unavailabilities",
          filter: `family_id=eq.${familyId}`,
        },
        () => {
          void queryClient.invalidateQueries({ queryKey: ["unavailabilities"] });
        },
      )
      .subscribe();

    return () => {
      void supabase.removeChannel(channel);
    };
  }, [familyId, queryClient]);

  useEffect(() => {
    if (!user?.id) return;

    const channel = supabase
      .channel(`notifications-${user.id}`)
      .on(
        "postgres_changes",
        {
          event: "INSERT",
          schema: "public",
          table: "notifications",
          filter: `user_id=eq.${user.id}`,
        },
        () => {
          void queryClient.invalidateQueries({
            queryKey: ["notifications", user.id],
          });
        },
      )
      .subscribe();

    return () => {
      void supabase.removeChannel(channel);
    };
  }, [user?.id, queryClient]);
}
