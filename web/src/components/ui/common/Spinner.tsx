export function Spinner({ className }: { className?: string }) {
  return (
    <div
      className={["spinner", className].filter(Boolean).join(" ")}
      role="status"
      aria-label="Loading"
    />
  );
}
