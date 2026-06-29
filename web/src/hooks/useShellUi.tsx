import { createContext, useContext, useMemo, useState, type ReactNode } from "react";

interface ShellUiContextValue {
  hideFab: boolean;
  setHideFab: (hide: boolean) => void;
  /** Extra top inset (px) for floating install banner so page content stays visible. */
  installBannerInset: number;
  setInstallBannerInset: (px: number) => void;
}

const ShellUiContext = createContext<ShellUiContextValue | null>(null);

export function ShellUiProvider({ children }: { children: ReactNode }) {
  const [hideFab, setHideFab] = useState(false);
  const [installBannerInset, setInstallBannerInset] = useState(0);
  const value = useMemo(
    () => ({ hideFab, setHideFab, installBannerInset, setInstallBannerInset }),
    [hideFab, installBannerInset],
  );
  return <ShellUiContext.Provider value={value}>{children}</ShellUiContext.Provider>;
}

export function useShellUi(): ShellUiContextValue {
  const ctx = useContext(ShellUiContext);
  if (!ctx) {
    throw new Error("useShellUi must be used within ShellUiProvider");
  }
  return ctx;
}
