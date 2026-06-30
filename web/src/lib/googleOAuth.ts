interface AuthSettings {
  external?: {
    google?: boolean;
  };
}

function missingEnvMessage(): string {
  return "Supabase is not configured. Copy web/.env.example to web/.env.local, set VITE_SUPABASE_URL and VITE_SUPABASE_ANON_KEY from supabase start, then restart npm run dev.";
}

export async function checkGoogleOAuthConfigured(
  supabaseUrl: string | undefined,
  anonKey: string | undefined,
): Promise<{ ok: boolean; message?: string }> {
  const url = supabaseUrl?.trim();
  const key = anonKey?.trim();
  if (!url || !key) {
    return { ok: false, message: missingEnvMessage() };
  }

  try {
    const response = await fetch(`${url}/auth/v1/settings`, {
      headers: {
        apikey: key,
        Authorization: `Bearer ${key}`,
      },
    });
    if (!response.ok) {
      if (response.status === 401) {
        return {
          ok: false,
          message:
            "Invalid Supabase anon key. Update VITE_SUPABASE_ANON_KEY from supabase start output, then restart npm run dev.",
        };
      }
      return {
        ok: false,
        message: `Could not reach Supabase Auth (HTTP ${response.status}). Run supabase start and confirm VITE_SUPABASE_URL matches the API URL.`,
      };
    }

    const settings = (await response.json()) as AuthSettings;
    if (!settings.external?.google) {
      return {
        ok: false,
        message:
          "Google sign-in is not enabled. Check supabase/config.toml and supabase/.env, then run: supabase stop && supabase start",
      };
    }

    return { ok: true };
  } catch {
    return {
      ok: false,
      message:
        "Could not reach Supabase Auth. Run supabase start and confirm VITE_SUPABASE_URL matches the Project URL from supabase start (http://127.0.0.1:54321).",
    };
  }
}
