import { MemberAvatar } from "./MemberAvatar";
import type { FamilyMember } from "../../../lib/database.types";

interface MemberChipPickerProps {
  members: FamilyMember[];
  value: string;
  onChange: (memberId: string) => void;
  label?: string;
}

export function MemberChipPicker({
  members,
  value,
  onChange,
  label = "Companion",
}: MemberChipPickerProps) {
  return (
    <div className="field">
      <span className="field__label">{label}</span>
      <div className="member-chips">
        {members.map((member) => (
          <button
            key={member.id}
            type="button"
            className={[
              "member-chip",
              value === member.id ? "member-chip--selected" : "",
            ]
              .filter(Boolean)
              .join(" ")}
            style={{ ["--chip-color" as string]: member.color_hex }}
            aria-pressed={value === member.id}
            onClick={() => onChange(member.id)}
          >
            <MemberAvatar name={member.name} colorHex={member.color_hex} size="sm" />
            {member.name}
          </button>
        ))}
      </div>
    </div>
  );
}
