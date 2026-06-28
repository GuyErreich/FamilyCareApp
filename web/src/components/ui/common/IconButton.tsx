import type { LucideIcon } from "lucide-react";
import type { ButtonHTMLAttributes } from "react";

interface IconButtonProps extends ButtonHTMLAttributes<HTMLButtonElement> {
  icon: LucideIcon;
  label: string;
  variant?: "default" | "ghost";
}

export function IconButton({
  icon: Icon,
  label,
  variant = "default",
  className,
  ...props
}: IconButtonProps) {
  return (
    <button
      type="button"
      className={[
        "icon-btn",
        variant === "ghost" ? "icon-btn--ghost" : "",
        className,
      ]
        .filter(Boolean)
        .join(" ")}
      aria-label={label}
      title={label}
      {...props}
    >
      <Icon size={22} aria-hidden />
    </button>
  );
}
