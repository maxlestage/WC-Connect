import { useLanguage, useT, type Language } from "../i18n";

const options: readonly Language[] = ["fr", "en"];

/** Deux choix explicites plutôt qu'une bascule : on choisit sa langue, on ne
 *  devine pas ce que fait un bouton portant le nom de l'autre. */
export function LanguageSwitch() {
  const t = useT();
  const { language, setLanguage } = useLanguage();

  return (
    <div className="switch" role="group" aria-label={t.nav.languageLabel}>
      {options.map((option) => (
        <button
          key={option}
          type="button"
          // Chaque langue est nommée dans sa propre langue : c'est l'usage, et
          // c'est ce qui permet de s'en sortir quand on tombe sur la mauvaise.
          lang={option}
          aria-pressed={language === option}
          className={option === language ? "switch__choice switch__choice--on" : "switch__choice"}
          onClick={() => setLanguage(option)}
          title={t.languages[option]}
        >
          <span className="switch__code" aria-hidden="true">
            {t.languageCodes[option]}
          </span>
          <span className="switch__text">{t.languages[option]}</span>
        </button>
      ))}
    </div>
  );
}
