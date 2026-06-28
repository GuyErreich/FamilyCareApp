import { Link } from "react-router-dom";
import { Plus } from "lucide-react";
import { ROUTES } from "../../../lib/constants";

export function AddShiftFab() {
  return (
    <Link to={ROUTES.shiftNew} className="fab" aria-label="Add shift">
      <Plus size={26} strokeWidth={2.5} aria-hidden />
    </Link>
  );
}
