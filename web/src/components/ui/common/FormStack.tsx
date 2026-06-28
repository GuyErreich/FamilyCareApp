import type { FormHTMLAttributes, ReactNode } from "react";

type FormStackGap = "md" | "lg";

interface FormStackProps extends FormHTMLAttributes<HTMLFormElement> {
  children: ReactNode;
  gap?: FormStackGap;
}

/** Vertical form layout with standard spacing. */
export function FormStack({ children, gap = "md", className, ...props }: FormStackProps) {
  return (
    <form
      className={[
        "stack",
        gap === "lg" ? "stack--lg" : "",
        className,
      ]
        .filter(Boolean)
        .join(" ")}
      {...props}
    >
      {children}
    </form>
  );
}
