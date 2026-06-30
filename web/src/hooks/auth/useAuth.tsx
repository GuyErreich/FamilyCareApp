import {
  createContext,
  useCallback,
  useContext,
  useEffect,
  useMemo,
  useState,
  type ReactNode,
} from "react";
import type { Session, User } from "@supabase/supabase-js";
import type { Profile } from "../../lib/database.types";
import {
  clearPersistedCalendarTokens,
  hasCalendarConnectIntent,
  persistCalendarAccessToken,
} from "../../lib/googleCalendarTokens";
import { supabase } from "../../lib/supabase";

interface AuthContextValue {
  session: Session | null;
  user: User | null;
  profile: Profile | null;
  loading: boolean;
  refreshProfile: () => Promise<Profile | null>;
  setProfile: (profile: Profile | null) => void;
  signOut: () => Promise<void>;
}

const AuthContext = createContext<AuthContextValue | null>(null);

export function AuthProvider({ children }: { children: ReactNode }) {
  const [session, setSession] = useState<Session | null>(null);
  const [profile, setProfile] = useState<Profile | null>(null);
  const [loading, setLoading] = useState(true);

  const loadProfile = useCallback(async (userId: string): Promise<Profile | null> => {
    const { data: rpcProfile, error: rpcError } = await supabase.rpc("get_my_profile");
    if (!rpcError && rpcProfile) {
      setProfile(rpcProfile);
      return rpcProfile;
    }

    const { data, error } = await supabase
      .from("profiles")
      .select("*")
      .eq("id", userId)
      .maybeSingle();
    if (error) {
      console.error(error.message);
      setProfile(null);
      return null;
    }
    setProfile(data);
    return data;
  }, []);

  const refreshProfile = useCallback(async (): Promise<Profile | null> => {
    const { data: userData, error: userError } = await supabase.auth.getUser();
    if (userError || !userData.user?.id) return null;

    const { data: rpcProfile, error: rpcError } = await supabase.rpc("get_my_profile");
    if (!rpcError && rpcProfile) {
      setProfile(rpcProfile);
      return rpcProfile;
    }

    return loadProfile(userData.user.id);
  }, [loadProfile]);

  const setProfileState = useCallback((next: Profile | null) => {
    setProfile(next);
  }, []);

  useEffect(() => {
    let mounted = true;

    const init = async () => {
      const { data } = await supabase.auth.getSession();
      if (!mounted) return;
      setSession(data.session);
      if (data.session?.user.id) {
        await loadProfile(data.session.user.id);
      }
      setLoading(false);
    };

    void init();

    const {
      data: { subscription },
    } = supabase.auth.onAuthStateChange((_event: string, nextSession) => {
      setSession(nextSession);
      if (nextSession?.user.id) {
        if (
          nextSession.provider_token &&
          hasCalendarConnectIntent()
        ) {
          persistCalendarAccessToken(nextSession.user.id, nextSession.provider_token);
        }
        void loadProfile(nextSession.user.id);
      } else {
        setProfile(null);
      }
      setLoading(false);
    });

    return () => {
      mounted = false;
      subscription.unsubscribe();
    };
  }, [loadProfile]);

  const signOut = useCallback(async () => {
    const userId = session?.user.id;
    if (userId) clearPersistedCalendarTokens(userId);
    await supabase.auth.signOut();
    setProfile(null);
  }, [session?.user.id]);

  const value = useMemo(
    () => ({
      session,
      user: session?.user ?? null,
      profile,
      loading,
      refreshProfile,
      setProfile: setProfileState,
      signOut,
    }),
    [session, profile, loading, refreshProfile, setProfileState, signOut],
  );

  return (
    <AuthContext.Provider value={value}>{children}</AuthContext.Provider>
  );
}

export function useAuth(): AuthContextValue {
  const ctx = useContext(AuthContext);
  if (!ctx) {
    throw new Error("useAuth must be used within AuthProvider");
  }
  return ctx;
}
