import { createContext, useCallback, useContext, useEffect, useMemo, useState } from "react";
import type { ReactNode } from "react";
import { en } from "./en";
import { fr, type Dictionary } from "./fr";

export type Language = "fr" | "en";

const dictionaries: Record<Language, Dictionary> = { fr, en };
const STORAGE_KEY = "wc-connect-langue";

interface LanguageContextValue {
  readonly language: Language;
  readonly t: Dictionary;
  readonly toggle: () => void;
  readonly setLanguage: (language: Language) => void;
}

const LanguageContext = createContext<LanguageContextValue | null>(null);

/** Langue retenue précédemment, sinon celle du navigateur, sinon le français. */
function detectLanguage(): Language {
  try {
    const stored = window.localStorage.getItem(STORAGE_KEY);
    if (stored === "fr" || stored === "en") return stored;
  } catch {
    // Stockage indisponible (navigation privée) : on retombe sur le navigateur.
  }
  const preferred = window.navigator.languages?.[0] ?? window.navigator.language ?? "fr";
  return preferred.toLowerCase().startsWith("fr") ? "fr" : "en";
}

export function LanguageProvider({ children }: { readonly children: ReactNode }) {
  const [language, setLanguage] = useState<Language>(() =>
    typeof window === "undefined" ? "fr" : detectLanguage(),
  );

  const dictionary = dictionaries[language];

  useEffect(() => {
    document.documentElement.lang = dictionary.htmlLang;
    document.title = dictionary.documentTitle;
    try {
      window.localStorage.setItem(STORAGE_KEY, language);
    } catch {
      // Sans stockage, le choix ne survit pas au rechargement : tant pis.
    }
  }, [language, dictionary]);

  const toggle = useCallback(() => {
    setLanguage((current) => (current === "fr" ? "en" : "fr"));
  }, []);

  const value = useMemo<LanguageContextValue>(
    () => ({ language, t: dictionary, toggle, setLanguage }),
    [language, dictionary, toggle],
  );

  return <LanguageContext.Provider value={value}>{children}</LanguageContext.Provider>;
}

function useLanguageContext(): LanguageContextValue {
  const value = useContext(LanguageContext);
  if (!value) {
    throw new Error("useT doit être utilisé dans LanguageProvider");
  }
  return value;
}

/** Dictionnaire de la langue courante. */
export function useT(): Dictionary {
  return useLanguageContext().t;
}

/** Langue courante et bascule, pour le bouton de la barre de navigation. */
export function useLanguage(): Omit<LanguageContextValue, "t"> {
  const { language, toggle, setLanguage } = useLanguageContext();
  return { language, toggle, setLanguage };
}
