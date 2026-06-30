import { createContext, useContext } from "react";

export const ShellOverlayContext = createContext<HTMLElement | null>(null);

export function useShellOverlayHost(): HTMLElement | null {
  return useContext(ShellOverlayContext);
}
