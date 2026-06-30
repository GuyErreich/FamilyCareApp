import { motion } from "framer-motion";
import { useInteractiveMotion } from "../../../hooks/ui/useInteractiveMotion";
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
  const { motionProps, wrapClick } = useInteractiveMotion({
    tapScale: "chip",
    hover: "none",
  });

  return (
    <div className="field">
      <span className="field__label">{label}</span>
      <div className="member-chips">
        {members.map((member) => (
          <motion.button
            key={member.id}
            type="button"
            className={[
              "member-chip",
              "motion-interactive",
              value === member.id ? "member-chip--selected" : "",
            ]
              .filter(Boolean)
              .join(" ")}
            style={{ ["--chip-color" as string]: member.color_hex }}
            aria-pressed={value === member.id}
            onClick={wrapClick(() => onChange(member.id))}
            {...motionProps}
          >
            <MemberAvatar name={member.name} colorHex={member.color_hex} size="sm" />
            {member.name}
          </motion.button>
        ))}
      </div>
    </div>
  );
}
