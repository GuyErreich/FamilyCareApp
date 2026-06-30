import { motion, type HTMLMotionProps } from "framer-motion";
import type { LucideIcon } from "lucide-react";
import { useInteractiveMotion } from "../../../hooks/ui/useInteractiveMotion";

interface IconButtonProps extends Omit<HTMLMotionProps<"button">, "children"> {
  icon: LucideIcon;
  label: string;
  variant?: "default" | "ghost";
}

export function IconButton({
  icon: Icon,
  label,
  variant = "default",
  className,
  disabled,
  onClick,
  ...props
}: IconButtonProps) {
  const { motionProps, wrapClick } = useInteractiveMotion({
    disabled: Boolean(disabled),
    tapScale: "icon",
  });

  return (
    <motion.button
      type="button"
      className={[
        "icon-btn",
        "motion-interactive",
        variant === "ghost" ? "icon-btn--ghost" : "",
        className,
      ]
        .filter(Boolean)
        .join(" ")}
      aria-label={label}
      title={label}
      disabled={disabled}
      {...props}
      {...motionProps}
      onClick={wrapClick(onClick)}
    >
      <Icon size={22} aria-hidden />
    </motion.button>
  );
}
