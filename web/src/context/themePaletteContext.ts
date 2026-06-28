import { createContext } from "react";
import type { PaletteId, ThemePalette } from "../lib/themePalettes";
import { getPaletteGroups, THEME_PALETTES } from "../lib/themePalettes";

export interface ThemePaletteContextValue {
  palette: ThemePalette;
  paletteId: PaletteId;
  setPaletteId: (id: PaletteId) => void;
  palettes: ThemePalette[];
  paletteGroups: ReturnType<typeof getPaletteGroups>;
}

/** Stable context instance — keep in its own module so Vite HMR does not recreate it. */
export const ThemePaletteContext = createContext<ThemePaletteContextValue | null>(null);

export { THEME_PALETTES };
