import type { HTMLAttributes, ReactNode } from "react";

type StackGap = "md" | "lg";

type StaggerEdge = "start" | "end";

interface StackProps extends HTMLAttributes<HTMLDivElement> {
  children: ReactNode;
  gap?: StackGap;
  stagger?: boolean;
  /** Slide each child in from the screen edge (full-bleed clip). `start` = leading, `end` = trailing. */
  staggerFromEdge?: boolean | StaggerEdge;
}

export function Stack({
  children,
  gap = "md",
  stagger = false,
  staggerFromEdge = false,
  className,
  ...props
}: StackProps) {
  const edge: StaggerEdge | false =
    staggerFromEdge === true
      ? "start"
      : staggerFromEdge === "start" || staggerFromEdge === "end"
        ? staggerFromEdge
        : false;

  return (
    <div
      className={[
        "stack",
        gap === "lg" ? "stack--lg" : "",
        edge ? "stack--stagger-from-edge" : "",
        edge === "end" ? "stack--stagger-from-edge--end" : "",
        !edge && stagger ? "stack--stagger" : "",
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
