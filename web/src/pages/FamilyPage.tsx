import type { FormEvent } from "react";
import { useState } from "react";
import { Card } from "../components/ui/common/Card";
import { PrimaryButton } from "../components/ui/common/PrimaryButton";
import { EmptyState, ErrorState, LoadingState } from "../components/ui/common/AsyncStates";
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

  if (membersQuery.isLoading) return <LoadingState />;
  if (membersQuery.error) return <ErrorState message={membersQuery.error.message} />;

  const members = membersQuery.data ?? [];

  return (
    <div className="stack">
      <h1 className="page-title">Family members</h1>
      {members.length === 0 ? (
        <EmptyState>No members yet.</EmptyState>
      ) : (
        members.map((member) => (
          <Card
            key={member.id}
            className="shift-chip"
            style={{ ["--chip-color" as string]: member.color_hex }}
          >
            <strong>{member.name}</strong>
            <div className="muted">{member.role}</div>
          </Card>
        ))
      )}
      <Card>
        <form className="stack" onSubmit={onSubmit}>
          <label className="field">
            Add companion
            <input value={name} onChange={(e) => setName(e.target.value)} required />
          </label>
          {error ? <ErrorState message={error} /> : null}
          <PrimaryButton type="submit" disabled={addMember.isPending}>
            Add member
          </PrimaryButton>
        </form>
      </Card>
    </div>
  );
}
