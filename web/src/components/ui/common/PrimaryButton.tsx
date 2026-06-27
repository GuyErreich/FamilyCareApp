import type { ButtonHTMLAttributes, ReactNode } from "react";

interface PrimaryButtonProps extends ButtonHTMLAttributes<HTMLButtonElement> {
  children: ReactNode;
  variant?: "primary" | "secondary";
}

export function PrimaryButton({
  children,
  variant = "primary",
  className,
  ...props
}: PrimaryButtonProps) {
  return (
    <button
      type="button"
      className={[
        "btn",
        variant === "primary" ? "btn-primary" : "btn-secondary",
        className,
      ]
        .filter(Boolean)
        .join(" ")}
      {...props}
    >
      {children}
    </button>
  );
}
