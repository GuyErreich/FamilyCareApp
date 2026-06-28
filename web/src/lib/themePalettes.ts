export type PaletteId =
  | "linen"
  | "sageRest"
  | "oceanMist"
  | "duskRose"
  | "honeyOak"
  | "moonlit"
  | "forestRest"
  | "slatePro"
  | "cloudBlue"
  | "violetEdge"
  | "modernLight"
  | "modernDark";

export type PaletteCategory = "cozy" | "saas" | "simple";

export interface PaletteTokens {
  "--color-bg": string;
  "--color-surface": string;
  "--color-primary": string;
  "--color-primary-soft": string;
  "--color-accent": string;
  "--color-accent-soft": string;
  "--color-text": string;
  "--color-muted": string;
  "--color-border": string;
  "--color-danger": string;
  "--color-danger-soft": string;
}

export interface ThemePalette {
  id: PaletteId;
  name: string;
  description: string;
  category: PaletteCategory;
  /** When set, always uses this mode regardless of system preference. */
  fixedScheme?: "light" | "dark";
  swatch: [string, string, string];
  light: PaletteTokens;
  dark: PaletteTokens;
  themeColor: string;
}

export const PALETTE_CATEGORY_LABELS: Record<PaletteCategory, string> = {
  cozy: "Cozy & relaxing",
  saas: "Modern SaaS",
  simple: "Simple modern",
};

const TOKEN_KEYS = [
  "--color-bg",
  "--color-surface",
  "--color-primary",
  "--color-primary-soft",
  "--color-accent",
  "--color-accent-soft",
  "--color-text",
  "--color-muted",
  "--color-border",
  "--color-danger",
  "--color-danger-soft",
] as const satisfies readonly (keyof PaletteTokens)[];

/** Cozy, high-contrast palettes — warm neutrals, soft surfaces, readable in light & dark. */
export const THEME_PALETTES: ThemePalette[] = [
  {
    id: "linen",
    name: "Warm Linen",
    description: "Cream paper, cocoa text — like a quiet living room",
    category: "cozy",
    swatch: ["#5c3d1e", "#d4a574", "#f5f0e8"],
    themeColor: "#5c3d1e",
    light: {
      "--color-bg": "#f5f0e8",
      "--color-surface": "#fffcf7",
      "--color-primary": "#5c3d1e",
      "--color-primary-soft": "#ede4d6",
      "--color-accent": "#8b6914",
      "--color-accent-soft": "#f3ead0",
      "--color-text": "#1c1510",
      "--color-muted": "#5c534a",
      "--color-border": "#c9baa8",
      "--color-danger": "#a32c1a",
      "--color-danger-soft": "#fce8e4",
    },
    dark: {
      "--color-bg": "#12100e",
      "--color-surface": "#1c1916",
      "--color-primary": "#d4a574",
      "--color-primary-soft": "#2e2418",
      "--color-accent": "#c9a227",
      "--color-accent-soft": "#2a2410",
      "--color-text": "#f5f0e8",
      "--color-muted": "#b8aea3",
      "--color-border": "#3d3630",
      "--color-danger": "#f0a89a",
      "--color-danger-soft": "#3a2018",
    },
  },
  {
    id: "sageRest",
    name: "Restful Sage",
    description: "Soft green-grey — calm garden, strong readable text",
    category: "cozy",
    swatch: ["#2d5a3d", "#8fad96", "#eef2ec"],
    themeColor: "#2d5a3d",
    light: {
      "--color-bg": "#eef2ec",
      "--color-surface": "#f8faf7",
      "--color-primary": "#2d5a3d",
      "--color-primary-soft": "#d8e6dc",
      "--color-accent": "#4a7260",
      "--color-accent-soft": "#dce8e2",
      "--color-text": "#0f1a14",
      "--color-muted": "#3f5248",
      "--color-border": "#b8c9bc",
      "--color-danger": "#a32c1a",
      "--color-danger-soft": "#fce8e4",
    },
    dark: {
      "--color-bg": "#0e1210",
      "--color-surface": "#171c18",
      "--color-primary": "#8fad96",
      "--color-primary-soft": "#1e2e24",
      "--color-accent": "#6a9a82",
      "--color-accent-soft": "#182820",
      "--color-text": "#eef2ec",
      "--color-muted": "#9db0a4",
      "--color-border": "#2e3a32",
      "--color-danger": "#f0a89a",
      "--color-danger-soft": "#3a2018",
    },
  },
  {
    id: "oceanMist",
    name: "Ocean Mist",
    description: "Cool blue-grey spa tones — gentle, clear, unwinding",
    category: "cozy",
    swatch: ["#3d5a6c", "#7a9eb0", "#e8eef2"],
    themeColor: "#3d5a6c",
    light: {
      "--color-bg": "#e8eef2",
      "--color-surface": "#f4f8fa",
      "--color-primary": "#3d5a6c",
      "--color-primary-soft": "#d4e2ea",
      "--color-accent": "#5b8a72",
      "--color-accent-soft": "#dceae2",
      "--color-text": "#101820",
      "--color-muted": "#4a5c68",
      "--color-border": "#b4c4ce",
      "--color-danger": "#a32c1a",
      "--color-danger-soft": "#fce8e4",
    },
    dark: {
      "--color-bg": "#0e1216",
      "--color-surface": "#161c22",
      "--color-primary": "#8eb4c8",
      "--color-primary-soft": "#1a2830",
      "--color-accent": "#7ab89a",
      "--color-accent-soft": "#1a2820",
      "--color-text": "#e8eef2",
      "--color-muted": "#9aacb8",
      "--color-border": "#2e3840",
      "--color-danger": "#f0a89a",
      "--color-danger-soft": "#3a2018",
    },
  },
  {
    id: "duskRose",
    name: "Dusk Rose",
    description: "Dusty mauve + warm grey — soft evening light",
    category: "cozy",
    swatch: ["#7d4e5f", "#c4a0ad", "#f6f2f2"],
    themeColor: "#7d4e5f",
    light: {
      "--color-bg": "#f6f2f2",
      "--color-surface": "#fcfaf9",
      "--color-primary": "#7d4e5f",
      "--color-primary-soft": "#eadde2",
      "--color-accent": "#6b5a72",
      "--color-accent-soft": "#e8e2ea",
      "--color-text": "#1a1214",
      "--color-muted": "#5c4f54",
      "--color-border": "#cfc0c6",
      "--color-danger": "#a32c1a",
      "--color-danger-soft": "#fce8e4",
    },
    dark: {
      "--color-bg": "#121014",
      "--color-surface": "#1c181c",
      "--color-primary": "#c4a0ad",
      "--color-primary-soft": "#2e2028",
      "--color-accent": "#a898b0",
      "--color-accent-soft": "#242028",
      "--color-text": "#f6f2f2",
      "--color-muted": "#b0a4a8",
      "--color-border": "#3a3238",
      "--color-danger": "#f0a89a",
      "--color-danger-soft": "#3a2018",
    },
  },
  {
    id: "honeyOak",
    name: "Honey Oak",
    description: "Wheat & chestnut — cozy cabin, warm contrast",
    category: "cozy",
    swatch: ["#7a4f1a", "#c9956a", "#fbf6ee"],
    themeColor: "#7a4f1a",
    light: {
      "--color-bg": "#fbf6ee",
      "--color-surface": "#fffbf5",
      "--color-primary": "#7a4f1a",
      "--color-primary-soft": "#f0e4d0",
      "--color-accent": "#4a6741",
      "--color-accent-soft": "#dce6d8",
      "--color-text": "#201810",
      "--color-muted": "#5c5044",
      "--color-border": "#d4c4ae",
      "--color-danger": "#a32c1a",
      "--color-danger-soft": "#fce8e4",
    },
    dark: {
      "--color-bg": "#12100c",
      "--color-surface": "#1c1814",
      "--color-primary": "#c9956a",
      "--color-primary-soft": "#2e2218",
      "--color-accent": "#8aad82",
      "--color-accent-soft": "#1e281c",
      "--color-text": "#fbf6ee",
      "--color-muted": "#b8aa9c",
      "--color-border": "#3a342c",
      "--color-danger": "#f0a89a",
      "--color-danger-soft": "#3a2018",
    },
  },
  {
    id: "moonlit",
    name: "Moonlit",
    description: "Soft blue-grey — low glare, easy before bed",
    category: "cozy",
    swatch: ["#4a6070", "#9aabb8", "#eceef2"],
    themeColor: "#4a6070",
    light: {
      "--color-bg": "#eceef2",
      "--color-surface": "#f6f7fa",
      "--color-primary": "#4a6070",
      "--color-primary-soft": "#d8dee6",
      "--color-accent": "#6a8090",
      "--color-accent-soft": "#e0e6ea",
      "--color-text": "#121820",
      "--color-muted": "#4a5560",
      "--color-border": "#b0bac4",
      "--color-danger": "#a32c1a",
      "--color-danger-soft": "#fce8e4",
    },
    dark: {
      "--color-bg": "#0c0e12",
      "--color-surface": "#161820",
      "--color-primary": "#9aabb8",
      "--color-primary-soft": "#222830",
      "--color-accent": "#b0bec8",
      "--color-accent-soft": "#242830",
      "--color-text": "#e4e8ee",
      "--color-muted": "#98a4b0",
      "--color-border": "#2e343c",
      "--color-danger": "#f0a89a",
      "--color-danger-soft": "#3a2018",
    },
  },
  {
    id: "forestRest",
    name: "Forest Rest",
    description: "Deep pine on parchment — nature calm, bold type",
    category: "cozy",
    swatch: ["#234a38", "#6a9480", "#f0ede6"],
    themeColor: "#234a38",
    light: {
      "--color-bg": "#f0ede6",
      "--color-surface": "#f8f6f1",
      "--color-primary": "#234a38",
      "--color-primary-soft": "#d6e4dc",
      "--color-accent": "#5a7268",
      "--color-accent-soft": "#dce4e0",
      "--color-text": "#101916",
      "--color-muted": "#3a4a42",
      "--color-border": "#b8c4bc",
      "--color-danger": "#a32c1a",
      "--color-danger-soft": "#fce8e4",
    },
    dark: {
      "--color-bg": "#0c100e",
      "--color-surface": "#141a16",
      "--color-primary": "#6a9480",
      "--color-primary-soft": "#1a2820",
      "--color-accent": "#88a898",
      "--color-accent-soft": "#1e2824",
      "--color-text": "#f0ede6",
      "--color-muted": "#9aaa9e",
      "--color-border": "#2a3430",
      "--color-danger": "#f0a89a",
      "--color-danger-soft": "#3a2018",
    },
  },
  {
    id: "slatePro",
    name: "Slate Pro",
    description: "Neutral zinc + indigo — Linear-style clarity",
    category: "saas",
    swatch: ["#4338ca", "#6366f1", "#f4f6f8"],
    themeColor: "#4338ca",
    light: {
      "--color-bg": "#f4f6f8",
      "--color-surface": "#ffffff",
      "--color-primary": "#4338ca",
      "--color-primary-soft": "#eef2ff",
      "--color-accent": "#0891b2",
      "--color-accent-soft": "#e0f2fe",
      "--color-text": "#0f172a",
      "--color-muted": "#475569",
      "--color-border": "#cbd5e1",
      "--color-danger": "#dc2626",
      "--color-danger-soft": "#fee2e2",
    },
    dark: {
      "--color-bg": "#0a0a0f",
      "--color-surface": "#14141c",
      "--color-primary": "#818cf8",
      "--color-primary-soft": "#1e1b4b",
      "--color-accent": "#22d3ee",
      "--color-accent-soft": "#083344",
      "--color-text": "#f1f5f9",
      "--color-muted": "#94a3b8",
      "--color-border": "#2e3340",
      "--color-danger": "#f87171",
      "--color-danger-soft": "#3f1d1d",
    },
  },
  {
    id: "cloudBlue",
    name: "Cloud Blue",
    description: "Crisp sky blue on cool grey — calm SaaS dashboard",
    category: "saas",
    swatch: ["#0369a1", "#38bdf8", "#f0f7ff"],
    themeColor: "#0369a1",
    light: {
      "--color-bg": "#f0f7ff",
      "--color-surface": "#f8fbff",
      "--color-primary": "#0369a1",
      "--color-primary-soft": "#dbeafe",
      "--color-accent": "#0d9488",
      "--color-accent-soft": "#ccfbf1",
      "--color-text": "#0c1929",
      "--color-muted": "#475569",
      "--color-border": "#bfdbfe",
      "--color-danger": "#dc2626",
      "--color-danger-soft": "#fee2e2",
    },
    dark: {
      "--color-bg": "#0a1018",
      "--color-surface": "#111827",
      "--color-primary": "#38bdf8",
      "--color-primary-soft": "#0c2847",
      "--color-accent": "#2dd4bf",
      "--color-accent-soft": "#134e4a",
      "--color-text": "#f0f9ff",
      "--color-muted": "#94a3b8",
      "--color-border": "#1e3a5f",
      "--color-danger": "#f87171",
      "--color-danger-soft": "#3f1d1d",
    },
  },
  {
    id: "violetEdge",
    name: "Violet Edge",
    description: "Refined purple-grey — modern product UI",
    category: "saas",
    swatch: ["#6d28d9", "#a78bfa", "#f8f7fa"],
    themeColor: "#6d28d9",
    light: {
      "--color-bg": "#f8f7fa",
      "--color-surface": "#ffffff",
      "--color-primary": "#6d28d9",
      "--color-primary-soft": "#f3e8ff",
      "--color-accent": "#7c3aed",
      "--color-accent-soft": "#ede9fe",
      "--color-text": "#1e1033",
      "--color-muted": "#5b5670",
      "--color-border": "#ddd6e8",
      "--color-danger": "#dc2626",
      "--color-danger-soft": "#fee2e2",
    },
    dark: {
      "--color-bg": "#0e0a14",
      "--color-surface": "#181222",
      "--color-primary": "#a78bfa",
      "--color-primary-soft": "#2e1065",
      "--color-accent": "#c4b5fd",
      "--color-accent-soft": "#3b0764",
      "--color-text": "#f5f3ff",
      "--color-muted": "#a8a3b8",
      "--color-border": "#322845",
      "--color-danger": "#f87171",
      "--color-danger-soft": "#3f1d1d",
    },
  },
  {
    id: "modernLight",
    name: "Modern Light",
    description: "Soft sage mint — bright care green, always light",
    category: "simple",
    fixedScheme: "light",
    swatch: ["#2a6b58", "#0d9488", "#f2f8f5"],
    themeColor: "#2a6b58",
    light: {
      "--color-bg": "#f2f8f5",
      "--color-surface": "#fafdfb",
      "--color-primary": "#2a6b58",
      "--color-primary-soft": "#d9f0e8",
      "--color-accent": "#0d9488",
      "--color-accent-soft": "#ccfbf1",
      "--color-text": "#0f1f1a",
      "--color-muted": "#4a665c",
      "--color-border": "#b8d4c8",
      "--color-danger": "#c2410c",
      "--color-danger-soft": "#ffedd5",
    },
    dark: {
      "--color-bg": "#f2f8f5",
      "--color-surface": "#fafdfb",
      "--color-primary": "#2a6b58",
      "--color-primary-soft": "#d9f0e8",
      "--color-accent": "#0d9488",
      "--color-accent-soft": "#ccfbf1",
      "--color-text": "#0f1f1a",
      "--color-muted": "#4a665c",
      "--color-border": "#b8d4c8",
      "--color-danger": "#c2410c",
      "--color-danger-soft": "#ffedd5",
    },
  },
  {
    id: "modernDark",
    name: "Modern Dark",
    description: "Deep forest teal — glowing mint accents, always dark",
    category: "simple",
    fixedScheme: "dark",
    swatch: ["#6ee7b7", "#34d399", "#0d1512"],
    themeColor: "#162019",
    light: {
      "--color-bg": "#0d1512",
      "--color-surface": "#162019",
      "--color-primary": "#6ee7b7",
      "--color-primary-soft": "#1a2e28",
      "--color-accent": "#34d399",
      "--color-accent-soft": "#134e3a",
      "--color-text": "#ecfdf5",
      "--color-muted": "#8fb8a8",
      "--color-border": "#2a4038",
      "--color-danger": "#fb923c",
      "--color-danger-soft": "#431407",
    },
    dark: {
      "--color-bg": "#0d1512",
      "--color-surface": "#162019",
      "--color-primary": "#6ee7b7",
      "--color-primary-soft": "#1a2e28",
      "--color-accent": "#34d399",
      "--color-accent-soft": "#134e3a",
      "--color-text": "#ecfdf5",
      "--color-muted": "#8fb8a8",
      "--color-border": "#2a4038",
      "--color-danger": "#fb923c",
      "--color-danger-soft": "#431407",
    },
  },
];

export const DEFAULT_PALETTE_ID: PaletteId = "linen";

export function getPalette(id: PaletteId): ThemePalette {
  return THEME_PALETTES.find((p) => p.id === id) ?? THEME_PALETTES[0];
}

export function getPaletteGroups(): {
  category: PaletteCategory;
  label: string;
  palettes: ThemePalette[];
}[] {
  return (["cozy", "saas", "simple"] as const).map((category) => ({
    category,
    label: PALETTE_CATEGORY_LABELS[category],
    palettes: THEME_PALETTES.filter((p) => p.category === category),
  }));
}

export function resolvePaletteScheme(
  palette: ThemePalette,
  systemScheme: "light" | "dark",
): "light" | "dark" {
  return palette.fixedScheme ?? systemScheme;
}

export function applyPaletteTokens(palette: ThemePalette, systemScheme: "light" | "dark") {
  const scheme = resolvePaletteScheme(palette, systemScheme);
  const tokens = scheme === "dark" ? palette.dark : palette.light;
  const root = document.documentElement;

  for (const key of TOKEN_KEYS) {
    root.style.setProperty(key, tokens[key]);
  }

  root.dataset.palette = palette.id;
  root.style.colorScheme = scheme;

  const themeMeta = document.querySelector('meta[name="theme-color"]');
  if (themeMeta) {
    themeMeta.setAttribute(
      "content",
      scheme === "dark" ? palette.dark["--color-surface"] : palette.themeColor,
    );
  }
}

export function clearPaletteTokens() {
  const root = document.documentElement;
  for (const key of TOKEN_KEYS) {
    root.style.removeProperty(key);
  }
  delete root.dataset.palette;
  root.style.removeProperty("color-scheme");
}
