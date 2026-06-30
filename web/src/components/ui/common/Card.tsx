import { motion } from "framer-motion";
import type { ReactNode } from "react";
import { useInteractiveMotion } from "../../../hooks/ui/useInteractiveMotion";

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
  const isInteractive = Boolean(interactive || onClick);
  const { motionProps, wrapClick } = useInteractiveMotion({
    tapScale: "card",
    hover: isInteractive ? "card" : "none",
  });

  const classes = [
    "card",
    variant === "accent" ? "card--accent" : "",
    isInteractive ? "card--interactive motion-interactive" : "",
    className,
  ]
    .filter(Boolean)
    .join(" ");

  if (isInteractive) {
    return (
      <motion.button
        type="button"
        className={classes}
        style={style}
        onClick={wrapClick(onClick ? () => onClick() : undefined)}
        {...motionProps}
      >
        {children}
      </motion.button>
    );
  }

  return (
    <div className={classes} style={style}>
      {children}
    </div>
  );
}
