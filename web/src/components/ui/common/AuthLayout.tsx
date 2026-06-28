import type { ReactNode } from "react";
import { Heart } from "lucide-react";

interface AuthLayoutProps {
  title: string;
  subtitle?: string;
  children: ReactNode;
}

export function AuthLayout({ title, subtitle, children }: AuthLayoutProps) {
  return (
    <div className="auth-layout page-enter">
      <div className="auth-layout__hero">
        <div className="auth-layout__logo">
          <Heart size={28} aria-hidden />
        </div>
        <h1 className="auth-layout__title">{title}</h1>
        {subtitle ? <p className="auth-layout__subtitle">{subtitle}</p> : null}
      </div>
      <div className="auth-layout__body">
        <div className="auth-layout__card">{children}</div>
      </div>
    </div>
  );
}
