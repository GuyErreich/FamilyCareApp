import type { FormEvent } from "react";
import { useState } from "react";
import { Link, useNavigate } from "react-router-dom";
import { Globe } from "lucide-react";
import { AuthLayout } from "../components/ui/common/AuthLayout";
import { Button } from "../components/ui/common/Button";
import { Card } from "../components/ui/common/Card";
import { ErrorState } from "../components/ui/common/AsyncStates";
import { FormStack } from "../components/ui/common/FormStack";
import { TextInput } from "../components/ui/common/TextField";
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
    <AuthLayout title={APP_NAME} subtitle="Coordinate companion shifts together">
      <Card>
        <FormStack gap="lg" onSubmit={onSubmit}>
          <TextInput
            label="Email"
            type="email"
            autoComplete="email"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            required
          />
          <TextInput
            label="Password"
            type="password"
            autoComplete="current-password"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            required
          />
          {error ? <ErrorState message={error} /> : null}
          <Button type="submit" fullWidth loading={loading} disabled={loading}>
            {loading ? "Signing in…" : "Sign in"}
          </Button>
          <Button type="button" variant="secondary" fullWidth icon={Globe} onClick={onGoogle}>
            Continue with Google
          </Button>
        </FormStack>
        <p className="muted" style={{ marginTop: 16, marginBottom: 0 }}>
          No account? <Link to={ROUTES.register}>Register</Link>
        </p>
      </Card>
    </AuthLayout>
  );
}
