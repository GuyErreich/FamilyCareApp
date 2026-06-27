import type { ReactNode } from "react";

interface CardProps {
  children: ReactNode;
  className?: string;
  style?: React.CSSProperties;
}

export function Card({ children, className, style }: CardProps) {
  return (
    <div className={["card", className].filter(Boolean).join(" ")} style={style}>
      {children}
    </div>
  );
}
