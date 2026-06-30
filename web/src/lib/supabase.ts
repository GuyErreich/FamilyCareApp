import { createClient, type SupabaseClient } from "@supabase/supabase-js";
import type { Database } from "./database.types";

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL as string | undefined;
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY as string | undefined;

export type TypedClient = SupabaseClient<Database>;

let supabaseClient: TypedClient | null = null;

if (supabaseUrl && supabaseAnonKey) {
  supabaseClient = createClient<Database>(supabaseUrl, supabaseAnonKey);
}

export const getSupabaseClient = (): TypedClient => {
  if (!supabaseClient) {
    throw new Error(
      "Supabase is not configured. Set VITE_SUPABASE_URL and VITE_SUPABASE_ANON_KEY.",
    );
  }
  return supabaseClient;
};

export const supabase = new Proxy({} as TypedClient, {
  get: (_, prop) => {
    const client = getSupabaseClient();
    const value = Reflect.get(client, prop, client);
    return typeof value === "function"
      ? (value as (...args: unknown[]) => unknown).bind(client)
      : value;
  },
});

export const isSupabaseConfigured = (): boolean =>
  Boolean(supabaseUrl && supabaseAnonKey);

/** Returns an error message when Supabase cannot be reached (e.g. not started). */
export async function checkSupabaseReachable(): Promise<string | null> {
  if (!supabaseUrl?.trim() || !supabaseAnonKey?.trim()) {
    return "Supabase is not configured. Set VITE_SUPABASE_URL and VITE_SUPABASE_ANON_KEY in web/.env.local (see docs/supabase-hosted.md).";
  }
  try {
    const response = await fetch(`${supabaseUrl}/auth/v1/settings`, {
      headers: { apikey: supabaseAnonKey },
    });
    if (!response.ok) {
      return `Supabase is not reachable (HTTP ${response.status}). Check the project URL and API key in web/.env.local.`;
    }
    return null;
  } catch {
    return "Supabase is not reachable. Check VITE_SUPABASE_URL in web/.env.local and that the hosted project is active.";
  }
}
