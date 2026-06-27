import { useParams } from "react-router-dom";
import { ShiftFormPage } from "./ShiftFormPage";

export function ShiftEditPage() {
  const { id } = useParams<{ id: string }>();
  return <ShiftFormPage shiftId={id} />;
}
