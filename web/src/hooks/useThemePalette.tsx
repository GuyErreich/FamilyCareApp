import {
  useCallback,
  useContext,
  useEffect,
  useMemo,
  useState,
  type ReactNode,
} from "react";
import {
  ThemePaletteContext,
  THEME_PALETTES,
  type ThemePaletteContextValue,
} from "../context/themePaletteContext";
import {
  applyPaletteTokens,
  DEFAULT_PALETTE_ID,
  getPalette,
  getPaletteGroups,
  type PaletteId,
} from "../lib/themePalettes";

const STORAGE_KEY = "familycare-theme";
const LEGACY_STORAGE_KEY = "familycare-test-palette";

function readStoredPaletteId(): PaletteId {
  const stored =
    localStorage.getItem(STORAGE_KEY) ?? localStorage.getItem(LEGACY_STORAGE_KEY);
  if (stored && THEME_PALETTES.some((p) => p.id === stored)) {
    return stored as PaletteId;
  }
  return DEFAULT_PALETTE_ID;
}

function resolveScheme(): "light" | "dark" {
  return window.matchMedia("(prefers-color-scheme: dark)").matches ? "dark" : "light";
}

/** Apply stored palette before React mounts to avoid a flash of default tokens. */
export function bootstrapThemePalette(): void {
  applyPaletteTokens(getPalette(readStoredPaletteId()), resolveScheme());
}

export function ThemePaletteProvider({ children }: { children: ReactNode }) {
  const [paletteId, setPaletteIdState] = useState<PaletteId>(() => readStoredPaletteId());

  const palette = useMemo(() => getPalette(paletteId), [paletteId]);

  const apply = useCallback((id: PaletteId) => {
    applyPaletteTokens(getPalette(id), resolveScheme());
  }, []);

  useEffect(() => {
    apply(paletteId);
    localStorage.setItem(STORAGE_KEY, paletteId);
  }, [paletteId, apply]);

  useEffect(() => {
    const media = window.matchMedia("(prefers-color-scheme: dark)");
    const onChange = () => {
      const current = getPalette(paletteId);
      if (current.fixedScheme) return;
      apply(paletteId);
    };
    media.addEventListener("change", onChange);
    return () => media.removeEventListener("change", onChange);
  }, [paletteId, apply]);

  const setPaletteId = useCallback((id: PaletteId) => {
    setPaletteIdState(id);
  }, []);

  const value = useMemo<ThemePaletteContextValue>(
    () => ({
      palette,
      paletteId,
      setPaletteId,
      palettes: THEME_PALETTES,
      paletteGroups: getPaletteGroups(),
    }),
    [palette, paletteId, setPaletteId],
  );

  return (
    <ThemePaletteContext.Provider value={value}>{children}</ThemePaletteContext.Provider>
  );
}

export function useThemePalette(): ThemePaletteContextValue {
  const ctx = useContext(ThemePaletteContext);
  if (!ctx) {
    throw new Error("useThemePalette must be used within ThemePaletteProvider");
  }
  return ctx;
}
