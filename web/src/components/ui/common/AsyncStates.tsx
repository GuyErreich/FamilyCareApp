import type { ReactNode } from "react";

export function EmptyState({ children }: { children: ReactNode }) {
  return <div className="empty-state">{children}</div>;
}

export function LoadingState({ label = "Loading…" }: { label?: string }) {
  return <p className="muted">{label}</p>;
}

export function ErrorState({ message }: { message: string }) {
  return <p className="error-text">{message}</p>;
}
