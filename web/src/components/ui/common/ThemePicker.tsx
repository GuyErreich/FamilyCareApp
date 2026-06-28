import { Palette } from "lucide-react";
import { useThemePalette } from "../../../hooks/useThemePalette";
import type { PaletteId } from "../../../lib/themePalettes";
import { Card } from "./Card";
import { ListRow } from "./ListRow";

export function ThemePicker() {
  const { palette, paletteId, setPaletteId, paletteGroups } = useThemePalette();

  return (
    <section>
      <h2 className="section-title">Appearance</h2>
      <Card>
        <ListRow icon={Palette} label="Color theme" value={palette.description} />
        <label className="field theme-picker">
          <span className="field__label">Theme</span>
          <div className="theme-picker__row">
            <span className="theme-picker__preview" aria-hidden>
              {palette.swatch.map((color) => (
                <span
                  key={color}
                  className="theme-picker__swatch"
                  style={{ background: color }}
                />
              ))}
            </span>
            <select
              className="theme-picker__select"
              value={paletteId}
              onChange={(e) => {
                setPaletteId(e.target.value as PaletteId);
                navigator.vibrate?.(8);
              }}
            >
              {paletteGroups.map((group) => (
                <optgroup key={group.category} label={group.label}>
                  {group.palettes.map((option) => (
                    <option key={option.id} value={option.id}>
                      {option.name}
                    </option>
                  ))}
                </optgroup>
              ))}
            </select>
          </div>
        </label>
        <p className="muted theme-picker__hint">
          Cozy and SaaS themes follow your device light/dark mode. Simple modern themes stay
          on light or dark.
        </p>
      </Card>
    </section>
  );
}
