import { createContext, useCallback, useContext, useEffect, useMemo, useState } from "react";
import type { ReactNode } from "react";

/** « auto » suit le réglage de l'appareil ; les deux autres l'emportent. */
export type Theme = "light" | "dark" | "auto";

/** Ordre d'affichage dans le sélecteur. */
export const themeOptions: readonly Theme[] = ["light", "dark", "auto"];

const STORAGE_KEY = "wc-connect-theme";
const DARK_QUERY = "(prefers-color-scheme: dark)";

/** Couleur de la barre du navigateur, par thème réellement affiché. */
const BROWSER_COLOR: Record<"light" | "dark", string> = {
  light: "#1c66c7",
  dark: "#0b1020",
};

interface ThemeContextValue {
  readonly theme: Theme;
  readonly setTheme: (theme: Theme) => void;
  /** Ce qui est réellement affiché : « auto » résolu d'après l'appareil. */
  readonly resolved: "light" | "dark";
}

const ThemeContext = createContext<ThemeContextValue | null>(null);

function isTheme(value: unknown): value is Theme {
  return value === "light" || value === "dark" || value === "auto";
}

/** Thème retenu précédemment, sinon « auto ». */
function detectTheme(): Theme {
  try {
    const stored = window.localStorage.getItem(STORAGE_KEY);
    if (isTheme(stored)) return stored;
  } catch {
    // Stockage indisponible (navigation privée) : l'appareil décide.
  }
  return "auto";
}

function prefersDark(): boolean {
  return typeof window !== "undefined" && window.matchMedia(DARK_QUERY).matches;
}

export function ThemeProvider({ children }: { readonly children: ReactNode }) {
  const [theme, setThemeState] = useState<Theme>(() =>
    typeof window === "undefined" ? "auto" : detectTheme(),
  );
  const [systemDark, setSystemDark] = useState<boolean>(() => prefersDark());

  // Le réglage de l'appareil peut changer pendant la visite : bascule manuelle,
  // ou passage automatique au coucher du soleil.
  useEffect(() => {
    const media = window.matchMedia(DARK_QUERY);
    const onChange = (event: MediaQueryListEvent) => setSystemDark(event.matches);
    setSystemDark(media.matches);
    media.addEventListener("change", onChange);
    return () => media.removeEventListener("change", onChange);
  }, []);

  const resolved: "light" | "dark" = theme === "auto" ? (systemDark ? "dark" : "light") : theme;

  useEffect(() => {
    const root = document.documentElement;
    // Pas d'attribut en « auto » : la feuille de style retombe alors sur la
    // requête de média, et l'appareil garde la main.
    if (theme === "auto") {
      root.removeAttribute("data-theme");
    } else {
      root.setAttribute("data-theme", theme);
    }
    try {
      window.localStorage.setItem(STORAGE_KEY, theme);
    } catch {
      // Sans stockage, le choix ne survit pas au rechargement : tant pis.
    }
  }, [theme]);

  useEffect(() => {
    document.querySelector('meta[name="theme-color"]')
      ?.setAttribute("content", BROWSER_COLOR[resolved]);
  }, [resolved]);

  const setTheme = useCallback((choix: Theme) => setThemeState(choix), []);

  const value = useMemo<ThemeContextValue>(
    () => ({ theme, setTheme, resolved }),
    [theme, setTheme, resolved],
  );

  return <ThemeContext.Provider value={value}>{children}</ThemeContext.Provider>;
}

/** Thème choisi, thème affiché, et de quoi en changer. */
export function useTheme(): ThemeContextValue {
  const value = useContext(ThemeContext);
  if (!value) {
    throw new Error("useTheme doit être utilisé dans ThemeProvider");
  }
  return value;
}
