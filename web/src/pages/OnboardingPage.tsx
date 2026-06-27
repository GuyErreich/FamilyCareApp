import type { FormEvent } from "react";
import { useState } from "react";
import { Navigate, useNavigate } from "react-router-dom";
import { Card } from "../components/ui/common/Card";
import { PrimaryButton } from "../components/ui/common/PrimaryButton";
import { ErrorState, LoadingState } from "../components/ui/common/AsyncStates";
import { useAuth } from "../hooks/auth/useAuth";
import { ROUTES } from "../lib/constants";
import { useCreateFamily, useJoinFamily } from "../hooks/shifts/useShiftMutations";

export function OnboardingPage() {
  const navigate = useNavigate();
  const { user, profile, loading } = useAuth();
  const createFamily = useCreateFamily();
  const joinFamily = useJoinFamily();
  const [joinMode, setJoinMode] = useState(false);
  const [familyName, setFamilyName] = useState("");
  const [grandpaName, setGrandpaName] = useState("Grandpa");
  const [inviteCode, setInviteCode] = useState("");
  const [error, setError] = useState<string | null>(null);

  if (loading) return <LoadingState />;
  if (!user) return <Navigate to={ROUTES.login} replace />;
  if (profile?.family_id) return <Navigate to={ROUTES.dashboard} replace />;

  const onSubmit = async (e: FormEvent) => {
    e.preventDefault();
    setError(null);
    try {
      if (joinMode) {
        await joinFamily.mutateAsync(inviteCode);
      } else {
        await createFamily.mutateAsync({
          name: familyName.trim(),
          grandpaName: grandpaName.trim(),
        });
      }
      navigate(ROUTES.dashboard, { replace: true });
    } catch (err) {
      setError(err instanceof Error ? err.message : String(err));
    }
  };

  const submitting = createFamily.isPending || joinFamily.isPending;

  return (
    <div className="stack" style={{ maxWidth: 480, margin: "32px auto", padding: 16 }}>
      <h1 className="page-title">Join your family</h1>
      <Card>
        <div className="stack">
          <div style={{ display: "flex", gap: 8 }}>
            <PrimaryButton
              type="button"
              variant={joinMode ? "secondary" : "primary"}
              onClick={() => setJoinMode(false)}
              disabled={submitting}
            >
              Create family
            </PrimaryButton>
            <PrimaryButton
              type="button"
              variant={joinMode ? "primary" : "secondary"}
              onClick={() => setJoinMode(true)}
              disabled={submitting}
            >
              Join with code
            </PrimaryButton>
          </div>
          <form className="stack" onSubmit={onSubmit}>
            {!joinMode ? (
              <>
                <label className="field">
                  Family name
                  <input
                    value={familyName}
                    onChange={(e) => setFamilyName(e.target.value)}
                    required
                    disabled={submitting}
                  />
                </label>
                <label className="field">
                  Who are we caring for?
                  <input
                    value={grandpaName}
                    onChange={(e) => setGrandpaName(e.target.value)}
                    required
                    disabled={submitting}
                  />
                </label>
              </>
            ) : (
              <label className="field">
                Invite code
                <input
                  value={inviteCode}
                  onChange={(e) => setInviteCode(e.target.value.toUpperCase())}
                  required
                  disabled={submitting}
                />
              </label>
            )}
            {error ? <ErrorState message={error} /> : null}
            <PrimaryButton type="submit" disabled={submitting}>
              {submitting ? "Setting up…" : "Continue"}
            </PrimaryButton>
          </form>
        </div>
      </Card>
    </div>
  );
}
