import type { HTMLAttributes, ReactNode } from "react";

type StackGap = "md" | "lg";

interface StackProps extends HTMLAttributes<HTMLDivElement> {
  children: ReactNode;
  gap?: StackGap;
  stagger?: boolean;
}

export function Stack({
  children,
  gap = "md",
  stagger = false,
  className,
  ...props
}: StackProps) {
  return (
    <div
      className={[
        "stack",
        gap === "lg" ? "stack--lg" : "",
        stagger ? "stack--stagger" : "",
        className,
      ]
        .filter(Boolean)
        .join(" ")}
      {...props}
    >
      {children}
    </div>
  );
}
