import { createContext, useContext } from "react";

type DismissMode = "press" | "immediate";

const SheetDismissContext = createContext<(mode?: DismissMode) => void>(() => {});

/** Close the active bottom sheet — use on Cancel; waits for button press feedback first. */
export function useSheetDismiss() {
  return useContext(SheetDismissContext);
}

export { SheetDismissContext, type DismissMode };
