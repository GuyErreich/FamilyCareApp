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
import { checkSupabaseReachable, supabase } from "../lib/supabase";

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
    setLoading(true);
    const unreachable = await checkSupabaseReachable();
    if (unreachable) {
      setError(unreachable);
      setLoading(false);
      return;
    }
    const { error: oauthError } = await supabase.auth.signInWithOAuth({
      provider: "google",
      options: { redirectTo: `${window.location.origin}/` },
    });
    setLoading(false);
    if (oauthError) {
      const msg = oauthError.message;
      setError(
        msg.includes("provider is not enabled")
          ? "Google sign-in is not enabled on your Supabase project. Dashboard → Authentication → Providers → Google → enable and add your Client ID + Secret."
          : msg,
      );
    }
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
          <Button type="button" variant="secondary" fullWidth icon={Globe} onClick={onGoogle} disabled={loading}>
            Continue with Google
          </Button>
        </FormStack>
        <p className="muted auth-layout__footer">
          No account? <Link to={ROUTES.register}>Register</Link>
        </p>
      </Card>
    </AuthLayout>
  );
}
