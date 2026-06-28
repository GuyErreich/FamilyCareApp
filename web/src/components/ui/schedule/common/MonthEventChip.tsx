import type { CSSProperties } from "react";

interface MonthEventChipProps {
  label: string;
  color?: string;
  variant: "shift" | "unavail";
  onClick?: () => void;
}

export function MonthEventChip({ label, color, variant, onClick }: MonthEventChipProps) {
  return (
    <span
      className={[
        "month-event-chip",
        variant === "unavail" ? "month-event-chip--unavail" : "month-event-chip--shift",
      ].join(" ")}
      style={color ? ({ ["--chip-color" as string]: color } as CSSProperties) : undefined}
      onClick={onClick}
      onKeyDown={
        onClick
          ? (e) => {
              if (e.key === "Enter" || e.key === " ") {
                e.stopPropagation();
                onClick();
              }
            }
          : undefined
      }
      role={onClick ? "button" : undefined}
      tabIndex={onClick ? 0 : undefined}
    >
      {label}
    </span>
  );
}
