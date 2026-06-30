import { motion } from "framer-motion";
import { useInteractiveMotion } from "../../../hooks/ui/useInteractiveMotion";

interface SegmentedOption<T extends string> {
  value: T;
  label: string;
  disabled?: boolean;
}

interface SegmentedControlProps<T extends string> {
  value: T;
  onChange: (value: T) => void;
  options: SegmentedOption<T>[];
  ariaLabel: string;
}

function SegmentOptionButton<T extends string>({
  option,
  selected,
  onSelect,
}: {
  option: SegmentedOption<T>;
  selected: boolean;
  onSelect: (value: T) => void;
}) {
  const { motionProps, wrapClick } = useInteractiveMotion({
    disabled: Boolean(option.disabled),
    tapScale: "chip",
    hover: "none",
  });

  return (
    <motion.button
      type="button"
      role="radio"
      aria-checked={selected}
      disabled={option.disabled}
      className={[
        "segmented-control__btn",
        "motion-interactive",
        selected ? "segmented-control__btn--active" : "",
      ]
        .filter(Boolean)
        .join(" ")}
      onClick={wrapClick(() => onSelect(option.value))}
      {...motionProps}
    >
      {option.label}
    </motion.button>
  );
}

export function SegmentedControl<T extends string>({
  value,
  onChange,
  options,
  ariaLabel,
}: SegmentedControlProps<T>) {
  return (
    <div className="segmented-control" role="radiogroup" aria-label={ariaLabel}>
      {options.map((option) => (
        <SegmentOptionButton
          key={option.value}
          option={option}
          selected={value === option.value}
          onSelect={onChange}
        />
      ))}
    </div>
  );
}
