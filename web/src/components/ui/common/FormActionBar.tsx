import type { ReactNode } from "react";

interface FormActionBarProps {
  children: ReactNode;
}

/** Fixed action row above the tab bar on full-page forms. */
export function FormActionBar({ children }: FormActionBarProps) {
  return <div className="form-action-bar">{children}</div>;
}
