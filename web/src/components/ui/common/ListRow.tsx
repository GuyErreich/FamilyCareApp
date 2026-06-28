import type { LucideIcon } from "lucide-react";
import type { ReactNode } from "react";

interface ListRowProps {
  icon?: LucideIcon;
  label: string;
  value?: ReactNode;
  actions?: ReactNode;
}

export function ListRow({ icon: Icon, label, value, actions }: ListRowProps) {
  return (
    <div className="list-row">
      {Icon ? (
        <span className="list-row__icon">
          <Icon size={18} aria-hidden />
        </span>
      ) : null}
      <div className="list-row__content">
        <div className="list-row__label">{label}</div>
        {value ? <div className="list-row__value">{value}</div> : null}
      </div>
      {actions ? <div className="list-row__actions">{actions}</div> : null}
    </div>
  );
}
