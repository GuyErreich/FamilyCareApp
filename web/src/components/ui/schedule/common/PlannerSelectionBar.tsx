import { Button } from "../../common/Button";

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
  if (count === 0) return null;

  return (
    <div className="planner-selection-bar" role="toolbar" aria-label="Selection actions">
      <span className="planner-selection-bar__count">
        {count} selected
      </span>
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
    </div>
  );
}
