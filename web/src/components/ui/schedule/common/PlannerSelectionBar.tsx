import { AnimatePresence, motion, useReducedMotion } from "framer-motion";
import { Button } from "../../common/Button";
import { SHEET_ENTER_SPRING, SHEET_EXIT_TRANSITION, REDUCED_ENTER_TRANSITION, REDUCED_EXIT_TRANSITION } from "../../../../lib/motion";

interface PlannerSelectionBarProps {
  count: number;
  onEdit: () => void;
  onDelete: () => void;
  onClear: () => void;
}

export function PlannerSelectionBar({
  count,
  onEdit,
  onDelete,
  onClear,
}: PlannerSelectionBarProps) {
  const reduceMotion = useReducedMotion();
  const enter = reduceMotion ? REDUCED_ENTER_TRANSITION : SHEET_ENTER_SPRING;
  const exit = reduceMotion ? REDUCED_EXIT_TRANSITION : SHEET_EXIT_TRANSITION;

  return (
    <AnimatePresence initial={false}>
      {count > 0 ? (
        <motion.div
          key="planner-selection-bar"
          className="planner-selection-bar"
          role="toolbar"
          aria-label="Selection actions"
          initial={reduceMotion ? { opacity: 0 } : { y: "100%", opacity: 0 }}
          animate={{ y: 0, opacity: 1, transition: enter }}
          exit={
            reduceMotion
              ? { opacity: 0, transition: exit }
              : { y: "100%", opacity: 0, transition: exit }
          }
        >
          <span className="planner-selection-bar__count">{count} selected</span>
          <div className="planner-selection-bar__actions">
            <Button variant="secondary" onClick={onClear}>
              Clear
            </Button>
            <Button variant="secondary" disabled={count !== 1} onClick={onEdit}>
              Edit
            </Button>
            <Button variant="danger" onClick={onDelete}>
              Delete
            </Button>
          </div>
        </motion.div>
      ) : null}
    </AnimatePresence>
  );
}
