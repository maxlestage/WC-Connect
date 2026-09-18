import { useT } from "../i18n";
import { Reveal } from "./Reveal";

/** Section « Quand ça coince » : ce que l'app propose pendant une visite. */
export function HelpSection() {
  const t = useT();

  return (
    <section className="section section--alt" id="aide">
      <div className="wrap split">
        <Reveal className="split__text">
          <p className="eyebrow">{t.help.eyebrow}</p>
          <h2>{t.help.title}</h2>
          <p>{t.help.body}</p>

          <div className="families">
            {t.help.families.map((family) => (
              <div className="family" key={family.title}>
                <h3>{family.title}</h3>
                <ul>
                  {family.examples.map((example) => (
                    <li key={example}>{example}</li>
                  ))}
                </ul>
              </div>
            ))}
          </div>
        </Reveal>

        <Reveal className="split__visual">
          <div className="nudge" role="img" aria-label={t.help.cardAlt}>
            <div className="nudge__head">
              <span className="nudge__bulb" aria-hidden="true">
                💡
              </span>
              <strong>{t.help.cardTitle}</strong>
            </div>
            <ul className="nudge__tips">
              {t.help.immediate.map((tip) => (
                <li key={tip}>{tip}</li>
              ))}
            </ul>
            <div className="nudge__actions">
              <span className="pill pill--solid">{t.help.actions.breathe}</span>
              <span className="pill">{t.help.actions.sound}</span>
              <span className="pill pill--icon">☰</span>
            </div>
          </div>

          <div className="warning">
            <h3>{t.help.warningTitle}</h3>
            <ul>
              {t.help.redFlags.map((flag) => (
                <li key={flag}>{flag}</li>
              ))}
            </ul>
            <p>{t.help.disclaimer}</p>
          </div>
        </Reveal>
      </div>
    </section>
  );
}
