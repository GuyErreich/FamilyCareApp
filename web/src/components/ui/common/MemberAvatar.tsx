interface MemberAvatarProps {
  name: string;
  colorHex?: string;
  size?: "sm" | "md" | "lg";
}

function initials(name: string): string {
  const parts = name.trim().split(/\s+/);
  if (parts.length >= 2) {
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }
  return name.slice(0, 2).toUpperCase();
}

export function MemberAvatar({ name, colorHex, size = "md" }: MemberAvatarProps) {
  const sizeClass =
    size === "sm" ? "member-avatar--sm" : size === "lg" ? "member-avatar--lg" : "";

  return (
    <span
      className={["member-avatar", sizeClass].filter(Boolean).join(" ")}
      style={{ background: colorHex ?? "var(--color-primary)" }}
      aria-hidden
    >
      {initials(name)}
    </span>
  );
}
