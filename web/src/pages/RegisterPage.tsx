import type { FormEvent } from "react";
import { useState } from "react";
import { Link, useNavigate } from "react-router-dom";
import { Card } from "../components/ui/common/Card";
import { PrimaryButton } from "../components/ui/common/PrimaryButton";
import { ErrorState } from "../components/ui/common/AsyncStates";
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
    <div className="stack" style={{ maxWidth: 420, margin: "48px auto", padding: 16 }}>
      <h1 className="page-title">Create account</h1>
      <Card>
        <form className="stack" onSubmit={onSubmit}>
          <label className="field">
            Display name
            <input value={displayName} onChange={(e) => setDisplayName(e.target.value)} />
          </label>
          <label className="field">
            Email
            <input
              type="email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              required
            />
          </label>
          <label className="field">
            Password
            <input
              type="password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              required
              minLength={6}
            />
          </label>
          {error ? <ErrorState message={error} /> : null}
          <PrimaryButton type="submit" disabled={loading}>
            {loading ? "Creating…" : "Register"}
          </PrimaryButton>
        </form>
        <p className="muted">
          Already have an account? <Link to={ROUTES.login}>Sign in</Link>
        </p>
      </Card>
    </div>
  );
}
