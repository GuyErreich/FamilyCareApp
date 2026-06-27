import type { FormEvent } from "react";
import { useState } from "react";
import { Link, useNavigate } from "react-router-dom";
import { Card } from "../components/ui/common/Card";
import { PrimaryButton } from "../components/ui/common/PrimaryButton";
import { ErrorState } from "../components/ui/common/AsyncStates";
import { APP_NAME, ROUTES } from "../lib/constants";
import { checkGoogleOAuthConfigured } from "../lib/googleOAuth";
import { supabase } from "../lib/supabase";

export function LoginPage() {
  const navigate = useNavigate();
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);

  const onSubmit = async (e: FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setError(null);
    const { error: signInError } = await supabase.auth.signInWithPassword({
      email,
      password,
    });
    setLoading(false);
    if (signInError) {
      setError(signInError.message);
      return;
    }
    navigate(ROUTES.dashboard);
  };

  const onGoogle = async () => {
    setError(null);
    const check = await checkGoogleOAuthConfigured(import.meta.env.VITE_SUPABASE_URL);
    if (!check.ok) {
      setError(check.message ?? "Google sign-in is not configured.");
      return;
    }
    const { error: oauthError } = await supabase.auth.signInWithOAuth({
      provider: "google",
      options: { redirectTo: `${window.location.origin}/` },
    });
    if (oauthError) setError(oauthError.message);
  };

  return (
    <div className="stack" style={{ maxWidth: 420, margin: "48px auto", padding: 16 }}>
      <h1 className="page-title">{APP_NAME}</h1>
      <Card>
        <form className="stack" onSubmit={onSubmit}>
          <label className="field">
            Email
            <input
              type="email"
              autoComplete="email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              required
            />
          </label>
          <label className="field">
            Password
            <input
              type="password"
              autoComplete="current-password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              required
            />
          </label>
          {error ? <ErrorState message={error} /> : null}
          <PrimaryButton type="submit" disabled={loading}>
            {loading ? "Signing in…" : "Sign in"}
          </PrimaryButton>
          <PrimaryButton type="button" variant="secondary" onClick={onGoogle}>
            Continue with Google
          </PrimaryButton>
        </form>
        <p className="muted">
          No account? <Link to={ROUTES.register}>Register</Link>
        </p>
      </Card>
    </div>
  );
}
