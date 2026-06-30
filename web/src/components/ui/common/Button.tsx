import { motion, type HTMLMotionProps } from "framer-motion";
import type { ReactNode } from "react";
import type { LucideIcon } from "lucide-react";
import { useInteractiveMotion } from "../../../hooks/ui/useInteractiveMotion";
import { useSheetDismiss } from "./sheetDismissContext";
import { Spinner } from "./Spinner";

export interface ButtonProps extends Omit<HTMLMotionProps<"button">, "children"> {
  children: ReactNode;
  variant?: "primary" | "secondary" | "danger";
  loading?: boolean;
  fullWidth?: boolean;
  icon?: LucideIcon;
}

export function Button({
  children,
  variant = "primary",
  loading,
  fullWidth,
  icon: Icon,
  className,
  disabled,
  type = "button",
  onClick,
  ...props
}: ButtonProps) {
  const isDisabled = Boolean(disabled || loading);
  const { motionProps, wrapClick } = useInteractiveMotion({
    disabled: isDisabled,
    tapScale: "button",
  });

  return (
    <motion.button
      type={type}
      className={[
        "btn",
        "motion-interactive",
        variant === "primary"
          ? "btn-primary"
          : variant === "danger"
            ? "btn-danger"
            : "btn-secondary",
        fullWidth ? "btn--full" : "",
        className,
      ]
        .filter(Boolean)
        .join(" ")}
      disabled={isDisabled}
      {...props}
      {...motionProps}
      onClick={wrapClick(onClick)}
    >
      {loading ? <Spinner className="btn__spinner" /> : Icon ? <Icon size={18} aria-hidden /> : null}
      {children}
    </motion.button>
  );
}

interface SheetCloseButtonProps extends Omit<ButtonProps, "type"> {
  children: ReactNode;
}

/** Cancel/dismiss control for bottom sheets — press feedback, then sheet exit animation. */
export function SheetCloseButton({
  children,
  variant = "secondary",
  onClick,
  ...props
}: SheetCloseButtonProps) {
  const dismiss = useSheetDismiss();
  return (
    <Button
      {...props}
      variant={variant}
      onClick={(event) => {
        onClick?.(event);
        if (!event.defaultPrevented) dismiss("press");
      }}
    >
      {children}
    </Button>
  );
}
