import type { LucideIcon } from "lucide-react";
import type { ReactNode } from "react";
import { Button } from "./Button";
import { Spinner } from "./Spinner";

interface EmptyStateProps {
  icon?: LucideIcon;
  title?: string;
  children?: ReactNode;
  actionLabel?: string;
  onAction?: () => void;
}

export function EmptyState({
  icon: Icon,
  title,
  children,
  actionLabel,
  onAction,
}: EmptyStateProps) {
  return (
    <div className="empty-state">
      {Icon ? (
        <div className="empty-state__icon">
          <Icon size={40} strokeWidth={1.5} aria-hidden />
        </div>
      ) : null}
      {title ? <p className="empty-state__title">{title}</p> : null}
      {children ? <p className="empty-state__body">{children}</p> : null}
      {actionLabel && onAction ? (
        <Button onClick={onAction}>{actionLabel}</Button>
      ) : null}
    </div>
  );
}

export function LoadingState({ label = "Loading…" }: { label?: string }) {
  return (
    <div className="loading-state">
      <div className="loading-state__spinner-wrap">
        <Spinner />
      </div>
      <p className="loading-state__label">{label}</p>
    </div>
  );
}

interface ErrorStateProps {
  message: string;
  onRetry?: () => void;
}

export function ErrorState({ message, onRetry }: ErrorStateProps) {
  return (
    <div className="error-state">
      <p className="error-state__message">{message}</p>
      {onRetry ? (
        <Button variant="secondary" onClick={onRetry}>
          Retry
        </Button>
      ) : null}
    </div>
  );
}
