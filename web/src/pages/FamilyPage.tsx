import type { FormEvent } from "react";
import { useState } from "react";
import { Users } from "lucide-react";
import { Button } from "../components/ui/common/Button";
import { Card } from "../components/ui/common/Card";
import { FormStack } from "../components/ui/common/FormStack";
import { MemberAvatar } from "../components/ui/common/MemberAvatar";
import { Stack } from "../components/ui/common/Stack";
import { EmptyState, ErrorState, LoadingState } from "../components/ui/common/AsyncStates";
import { TextInput } from "../components/ui/common/TextField";
import { useFamilyMembers } from "../hooks/family/useFamilyData";
import { useAddFamilyMember } from "../hooks/shifts/useShiftMutations";

export function FamilyPage() {
  const membersQuery = useFamilyMembers();
  const addMember = useAddFamilyMember();
  const [name, setName] = useState("");
  const [error, setError] = useState<string | null>(null);

  const onSubmit = async (e: FormEvent) => {
    e.preventDefault();
    setError(null);
    try {
      await addMember.mutateAsync({ name, colorHex: "#4A6741" });
      setName("");
    } catch (err) {
      setError(err instanceof Error ? err.message : String(err));
    }
  };

  if (membersQuery.isLoading) return <LoadingState label="Loading family…" />;
  if (membersQuery.error) return <ErrorState message={membersQuery.error.message} />;

  const members = membersQuery.data ?? [];

  return (
    <Stack gap="lg">
      <p className="muted page-subline">
        {members.length} companion{members.length === 1 ? "" : "s"}
      </p>

      {members.length === 0 ? (
        <EmptyState icon={Users} title="No members yet">
          Add your first companion below.
        </EmptyState>
      ) : (
        <div className="family-grid stack--stagger">
          {members.map((member) => (
            <Card
              key={member.id}
              className="shift-chip"
              style={{ ["--chip-color" as string]: member.color_hex }}
            >
              <div className="shift-card">
                <MemberAvatar name={member.name} colorHex={member.color_hex} size="lg" />
                <div className="shift-card__body">
                  <div className="shift-card__name">{member.name}</div>
                  <div className="shift-card__time">{member.role}</div>
                </div>
              </div>
            </Card>
          ))}
        </div>
      )}

      <Card variant="accent">
        <FormStack gap="lg" onSubmit={onSubmit}>
          <TextInput
            label="Add companion"
            value={name}
            onChange={(e) => setName(e.target.value)}
            required
          />
          {error ? <ErrorState message={error} /> : null}
          <Button type="submit" fullWidth loading={addMember.isPending} disabled={addMember.isPending}>
            Add member
          </Button>
        </FormStack>
      </Card>
    </Stack>
  );
}
