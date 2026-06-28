import type { ReactNode } from "react";

interface CardProps {
  children: ReactNode;
  className?: string;
  style?: React.CSSProperties;
  variant?: "default" | "accent";
  interactive?: boolean;
  onClick?: () => void;
}

export function Card({
  children,
  className,
  style,
  variant = "default",
  interactive,
  onClick,
}: CardProps) {
  const classes = [
    "card",
    variant === "accent" ? "card--accent" : "",
    interactive ? "card--interactive" : "",
    className,
  ]
    .filter(Boolean)
    .join(" ");

  if (interactive || onClick) {
    return (
      <button type="button" className={classes} style={style} onClick={onClick}>
        {children}
      </button>
    );
  }

  return (
    <div className={classes} style={style}>
      {children}
    </div>
  );
}
