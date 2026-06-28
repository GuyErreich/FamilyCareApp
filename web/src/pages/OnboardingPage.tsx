import type { FormEvent } from "react";
import { useState } from "react";
import { Navigate, useNavigate } from "react-router-dom";
import { AuthLayout } from "../components/ui/common/AuthLayout";
import { Button } from "../components/ui/common/Button";
import { Card } from "../components/ui/common/Card";
import { ErrorState, LoadingState } from "../components/ui/common/AsyncStates";
import { FormStack } from "../components/ui/common/FormStack";
import { SegmentedControl } from "../components/ui/common/SegmentedControl";
import { Stack } from "../components/ui/common/Stack";
import { TextInput } from "../components/ui/common/TextField";
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
    <AuthLayout title="Join your family" subtitle="Create a new family or enter an invite code">
      <Card>
        <Stack gap="lg">
          <SegmentedControl
            value={joinMode ? "join" : "create"}
            onChange={(mode) => setJoinMode(mode === "join")}
            ariaLabel="Onboarding mode"
            options={[
              { value: "create", label: "Create family", disabled: submitting },
              { value: "join", label: "Join with code", disabled: submitting },
            ]}
          />
          <FormStack gap="lg" onSubmit={onSubmit}>
            {!joinMode ? (
              <>
                <TextInput
                  label="Family name"
                  value={familyName}
                  onChange={(e) => setFamilyName(e.target.value)}
                  required
                  disabled={submitting}
                />
                <TextInput
                  label="Who are we caring for?"
                  value={grandpaName}
                  onChange={(e) => setGrandpaName(e.target.value)}
                  required
                  disabled={submitting}
                />
              </>
            ) : (
              <TextInput
                label="Invite code"
                value={inviteCode}
                onChange={(e) => setInviteCode(e.target.value.toUpperCase())}
                required
                disabled={submitting}
              />
            )}
            {error ? <ErrorState message={error} /> : null}
            <Button type="submit" fullWidth loading={submitting} disabled={submitting}>
              {submitting ? "Setting up…" : "Continue"}
            </Button>
          </FormStack>
        </Stack>
      </Card>
    </AuthLayout>
  );
}
