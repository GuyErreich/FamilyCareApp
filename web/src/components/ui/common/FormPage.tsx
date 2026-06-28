import type { ReactNode } from "react";

interface FormPageProps {
  children: ReactNode;
  className?: string;
}

/** Page shell with bottom padding for a fixed action bar. */
export function FormPage({ children, className }: FormPageProps) {
  return (
    <div className={["form-page", className].filter(Boolean).join(" ")}>{children}</div>
  );
}
