import { useT } from "../i18n";
import { themeOptions, useTheme, type Theme } from "../theme";

/** Trois choix explicites plutôt qu'une bascule : clair, sombre, automatique. */
export function ThemeSwitch() {
  const t = useT();
  const { theme, setTheme } = useTheme();

  return (
    // Un groupe de boutons bascule plutôt qu'un `radiogroup` : ce dernier
    // attend une navigation aux flèches, que rien n'implémenterait ici.
    <div className="theme" role="group" aria-label={t.theme.label}>
      {themeOptions.map((option) => (
        <button
          key={option}
          type="button"
          aria-pressed={theme === option}
          className={option === theme ? "theme__choice theme__choice--on" : "theme__choice"}
          onClick={() => setTheme(option)}
          title={t.theme[option]}
        >
          <ThemeIcon theme={option} />
          <span className="theme__text">{t.theme[option]}</span>
        </button>
      ))}
    </div>
  );
}

/** Soleil, croissant, cercle mi-plein : lisible sans le texte à côté. */
function ThemeIcon({ theme }: { readonly theme: Theme }) {
  const commun = {
    width: 16,
    height: 16,
    viewBox: "0 0 24 24",
    fill: "none",
    stroke: "currentColor",
    strokeWidth: 1.8,
    strokeLinecap: "round" as const,
    strokeLinejoin: "round" as const,
    "aria-hidden": true,
  };

  if (theme === "light") {
    return (
      <svg {...commun}>
        <circle cx="12" cy="12" r="4.2" />
        <path d="M12 2.6v2.2M12 19.2v2.2M2.6 12h2.2M19.2 12h2.2M5.4 5.4l1.6 1.6M17 17l1.6 1.6M18.6 5.4L17 7M7 17l-1.6 1.6" />
      </svg>
    );
  }

  if (theme === "dark") {
    return (
      <svg {...commun}>
        <path d="M20 14.2A8.4 8.4 0 0 1 9.8 4a8.4 8.4 0 1 0 10.2 10.2z" />
      </svg>
    );
  }

  return (
    <svg {...commun}>
      <circle cx="12" cy="12" r="8.4" />
      <path d="M12 3.6v16.8a8.4 8.4 0 0 0 0-16.8z" fill="currentColor" stroke="none" />
    </svg>
  );
}
