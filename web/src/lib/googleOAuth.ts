interface AuthSettings {
  external?: {
    google?: boolean;
  };
}

export async function checkGoogleOAuthConfigured(
  supabaseUrl: string,
): Promise<{ ok: boolean; message?: string }> {
  try {
    const response = await fetch(`${supabaseUrl}/auth/v1/settings`);
    if (!response.ok) {
      return { ok: false, message: "Could not reach Supabase Auth." };
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
    return { ok: false, message: "Could not reach Supabase Auth." };
  }
}
