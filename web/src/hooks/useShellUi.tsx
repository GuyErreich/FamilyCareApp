import { createContext, useContext, useMemo, useState, type ReactNode } from "react";

interface ShellUiContextValue {
  hideFab: boolean;
  setHideFab: (hide: boolean) => void;
}

const ShellUiContext = createContext<ShellUiContextValue | null>(null);

export function ShellUiProvider({ children }: { children: ReactNode }) {
  const [hideFab, setHideFab] = useState(false);
  const value = useMemo(() => ({ hideFab, setHideFab }), [hideFab]);
  return <ShellUiContext.Provider value={value}>{children}</ShellUiContext.Provider>;
}

export function useShellUi(): ShellUiContextValue {
  const ctx = useContext(ShellUiContext);
  if (!ctx) {
    throw new Error("useShellUi must be used within ShellUiProvider");
  }
  return ctx;
}
