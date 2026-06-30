import type { FormEvent } from "react";
import { useState } from "react";
import { Link, useNavigate } from "react-router-dom";
import { AuthLayout } from "../components/ui/common/AuthLayout";
import { Button } from "../components/ui/common/Button";
import { Card } from "../components/ui/common/Card";
import { ErrorState } from "../components/ui/common/AsyncStates";
import { FormStack } from "../components/ui/common/FormStack";
import { TextInput } from "../components/ui/common/TextField";
import { ROUTES } from "../lib/constants";
import { supabase } from "../lib/supabase";

export function RegisterPage() {
  const navigate = useNavigate();
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [displayName, setDisplayName] = useState("");
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);

  const onSubmit = async (e: FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setError(null);
    const { error: signUpError } = await supabase.auth.signUp({
      email,
      password,
      options: { data: { full_name: displayName } },
    });
    setLoading(false);
    if (signUpError) {
      setError(signUpError.message);
      return;
    }
    navigate(ROUTES.onboarding);
  };

  return (
    <AuthLayout title="Create account" subtitle="Start coordinating care for your family">
      <Card>
        <FormStack gap="lg" onSubmit={onSubmit}>
          <TextInput
            label="Display name"
            value={displayName}
            onChange={(e) => setDisplayName(e.target.value)}
          />
          <TextInput
            label="Email"
            type="email"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            required
          />
          <TextInput
            label="Password"
            type="password"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            required
            minLength={6}
          />
          {error ? <ErrorState message={error} /> : null}
          <Button type="submit" fullWidth loading={loading} disabled={loading}>
            {loading ? "Creating…" : "Register"}
          </Button>
        </FormStack>
        <p className="muted auth-layout__footer">
          Already have an account? <Link to={ROUTES.login}>Sign in</Link>
        </p>
      </Card>
    </AuthLayout>
  );
}
